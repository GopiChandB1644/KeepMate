import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepmate/core/design_system/app_colors.dart';
import 'package:keepmate/core/design_system/app_theme.dart';

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
      expect(AppColors.computeIsDark(ThemeMode.system, Brightness.light), isFalse);
      expect(AppColors.computeIsDark(ThemeMode.system, Brightness.dark), isTrue);
    });
  });
}

