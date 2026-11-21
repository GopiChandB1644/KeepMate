import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepremind/core/design_system/app_colors.dart';
import 'package:keepremind/core/design_system/app_theme.dart';

void main() {
  group('Theme & Color Palette Tests', () {
    test('AppColors toggles between light and dark palettes accurately', () {
      AppColors.updateTheme(ThemeMode.light);
      expect(AppColors.isDark, isFalse);
      expect(AppColors.background, equals(const Color(0xFFF8FAFC)));
      expect(AppColors.surface, equals(const Color(0xFFFFFFFF)));
      expect(AppColors.textPrimary, equals(const Color(0xFF0F172A)));

      AppColors.updateTheme(ThemeMode.dark);
      expect(AppColors.isDark, isTrue);
      expect(AppColors.background, equals(const Color(0xFF0F172A)));
      expect(AppColors.surface, equals(const Color(0xFF1E293B)));
      expect(AppColors.textPrimary, equals(const Color(0xFFF8FAFC)));
    });

    test('AppTheme getters are pure and do not alter AppColors.isDark', () {
      AppColors.isDark = false;
      final darkTheme = AppTheme.darkTheme;
      expect(darkTheme.brightness, equals(Brightness.dark));
      // Calling AppTheme.darkTheme should NOT mutate AppColors.isDark
      expect(AppColors.isDark, isFalse);

      final lightTheme = AppTheme.lightTheme;
      expect(lightTheme.brightness, equals(Brightness.light));
      expect(AppColors.isDark, isFalse);
    });

    test('ThemeMode.system resolves according to platform brightness', () {
      expect(
          AppColors.computeIsDark(ThemeMode.system, Brightness.light), isFalse);
      expect(
          AppColors.computeIsDark(ThemeMode.system, Brightness.dark), isTrue);

      AppColors.updateTheme(ThemeMode.system, Brightness.dark);
      expect(AppColors.isDark, isTrue);
      expect(AppColors.background, equals(const Color(0xFF0F172A)));

      AppColors.updateTheme(ThemeMode.system, Brightness.light);
      expect(AppColors.isDark, isFalse);
      expect(AppColors.background, equals(const Color(0xFFF8FAFC)));
    });

    testWidgets(
        'ThemeContextX extension and AppColors context helpers resolve light theme colors cleanly',
        (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const Scaffold(body: SizedBox());
            },
          ),
        ),
      );

      expect(capturedContext.isDark, isFalse);
      expect(capturedContext.surfaceColor, equals(const Color(0xFFFFFFFF)));
      expect(
          capturedContext.surfaceRaisedColor, equals(const Color(0xFFF1F5F9)));
      expect(capturedContext.cardBorderColor, equals(const Color(0xFFE2E8F0)));
      expect(capturedContext.textPrimaryColor, equals(const Color(0xFF0F172A)));
      expect(
          capturedContext.textSecondaryColor, equals(const Color(0xFF475569)));
      expect(AppColors.surfaceOf(capturedContext),
          equals(const Color(0xFFFFFFFF)));
      expect(AppColors.surfaceRaisedOf(capturedContext),
          equals(const Color(0xFFF1F5F9)));
      expect(AppColors.cardBorderOf(capturedContext),
          equals(const Color(0xFFE2E8F0)));
    });

    testWidgets(
        'ThemeContextX extension and AppColors context helpers resolve dark theme colors accurately',
        (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const Scaffold(body: SizedBox());
            },
          ),
        ),
      );

      expect(capturedContext.isDark, isTrue);
      expect(capturedContext.surfaceColor, equals(const Color(0xFF1E293B)));
      expect(
          capturedContext.surfaceRaisedColor, equals(const Color(0xFF334155)));
      expect(capturedContext.cardBorderColor, equals(const Color(0xFF334155)));
      expect(capturedContext.textPrimaryColor, equals(const Color(0xFFF8FAFC)));
      expect(
          capturedContext.textSecondaryColor, equals(const Color(0xFF94A3B8)));
      expect(AppColors.surfaceOf(capturedContext),
          equals(const Color(0xFF1E293B)));
      expect(AppColors.surfaceRaisedOf(capturedContext),
          equals(const Color(0xFF334155)));
      expect(AppColors.cardBorderOf(capturedContext),
          equals(const Color(0xFF334155)));
    });
  });
}
