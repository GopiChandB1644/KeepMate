import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/backup_restore/pages/backup_restore_page.dart';
import '../../features/categories/pages/categories_hub_page.dart';
import '../../features/doc_alert/pages/doc_alert_page.dart';
import '../../features/document_vault/pages/vault_page.dart';
import '../../features/fresh_check/pages/fresh_check_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/life_pocket/pages/life_pocket_page.dart';
import '../../features/settings/pages/settings_page.dart';
import '../../features/tracked_items/domain/entities/tracked_item_entity.dart';
import '../../features/tracked_items/pages/add_edit_item_page.dart';
import '../../features/tracked_items/pages/item_detail_page.dart';
import '../shell/main_shell.dart';
import 'app_routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // Branch 1: Categories
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.categories,
                builder: (context, state) => const CategoriesHubPage(),
              ),
            ],
          ),
          // Branch 2: Vault
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.vault,
                builder: (context, state) => const VaultPage(),
              ),
            ],
          ),
          // Branch 3: Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),

      // Direct routes outside bottom nav
      GoRoute(
        path: AppRoutes.lifePocket,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LifePocketPage(),
      ),
      GoRoute(
        path: AppRoutes.freshCheck,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FreshCheckPage(),
      ),
      GoRoute(
        path: AppRoutes.docAlert,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const DocAlertPage(),
      ),
      GoRoute(
        path: AppRoutes.backupRestore,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const BackupRestorePage(),
      ),
      GoRoute(
        path: AppRoutes.addItem,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AddEditItemPage(),
      ),
      GoRoute(
        path: AppRoutes.itemDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final item = state.extra as TrackedItemEntity;
          return ItemDetailPage(item: item);
        },
      ),
    ],
  );
}

