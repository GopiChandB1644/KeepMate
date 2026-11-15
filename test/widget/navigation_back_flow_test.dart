import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:keepremind/app/router/app_routes.dart';
import 'package:keepremind/app/shell/main_shell.dart';
import 'package:keepremind/shared/widgets/widgets.dart';

void main() {
  group('Back Button & Navigation Flow Tests', () {
    testWidgets('KeepRemindAppBar defaults to showing back button when no leading is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: KeepRemindAppBar(
              title: 'Sub Page',
              subtitle: 'Testing default back button',
            ),
          ),
        ),
      );

      // Back button icon should be present
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
    });

    testWidgets('KeepRemindAppBar hides back button when showBack: false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: KeepRemindAppBar(
              title: 'Root Page',
              showBack: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
      expect(find.byTooltip('Back'), findsNothing);
    });

    testWidgets('KeepRemindAppBar hides back button and shows custom leading when leading is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: KeepRemindAppBar(
              title: 'Home',
              leading: Icon(Icons.bookmark_added_rounded, key: Key('custom_logo')),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('custom_logo')), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
    });

    testWidgets('Default back tap pops when navigator canPop is true', (tester) async {
      var popped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              child: const Text('Open'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const Scaffold(
                      appBar: KeepRemindAppBar(
                        title: 'Pushed Page',
                      ),
                    ),
                  ),
                ).then((_) => popped = true);
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Pushed Page'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('Default back tap falls back to AppRoutes.home when navigator cannot pop', (tester) async {
      String currentLocation = '';
      final router = GoRouter(
        initialLocation: AppRoutes.categories,
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) {
              currentLocation = AppRoutes.home;
              return const Scaffold(body: Text('Home Screen Content'));
            },
          ),
          GoRoute(
            path: AppRoutes.categories,
            builder: (context, state) {
              currentLocation = AppRoutes.categories;
              return const Scaffold(
                appBar: KeepRemindAppBar(
                  title: 'Categories',
                  showBack: true,
                ),
                body: Text('Categories Screen Content'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      expect(currentLocation, AppRoutes.categories);
      expect(find.text('Categories Screen Content'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);

      // Tapping back button on unpoppable Categories page returns to Home
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(currentLocation, AppRoutes.home);
      expect(find.text('Home Screen Content'), findsOneWidget);
    });

    testWidgets('MainShell PopScope redirects system back to Home tab when on non-home tab', (tester) async {
      final router = GoRouter(
        initialLocation: AppRoutes.home,
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.home,
                    builder: (context, state) => const Scaffold(body: Text('Tab 0: Home Page')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.categories,
                    builder: (context, state) => const Scaffold(
                      appBar: KeepRemindAppBar(
                        title: 'Categories',
                        showBack: true,
                      ),
                      body: Text('Tab 1: Categories Page'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Tab 0: Home Page'), findsOneWidget);

      // Switch to Categories tab (index 1) via router.go
      router.go(AppRoutes.categories);
      await tester.pumpAndSettle();

      final popScopeAfter = tester.widget<PopScope>(
        find.byKey(const ValueKey('main_shell_pop_scope')),
      );
      expect(popScopeAfter.canPop, isFalse);

      // Simulate system back trigger: PopScope redirects to Home tab
      popScopeAfter.onPopInvokedWithResult!(false, null);
      await tester.pumpAndSettle();
      expect(find.text('Tab 0: Home Page'), findsOneWidget);

      // Switch back to Categories and test AppBar back button tap
      router.go(AppRoutes.categories);
      await tester.pumpAndSettle();
      expect(find.text('Tab 1: Categories Page'), findsOneWidget);

      // Tap app bar back button on Categories tab
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      // Should seamlessly return to Tab 0: Home Page
      expect(find.text('Tab 0: Home Page'), findsOneWidget);
    });
  });
}
