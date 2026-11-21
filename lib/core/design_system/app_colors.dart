import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Reactive theme flag synchronized with active ThemeMode and system brightness
  static bool isDark = false;

  /// Helper to select between light and dark palette tokens
  static Color _p(Color light, Color dark) => isDark ? dark : light;

  static bool computeIsDark(ThemeMode mode, [Brightness? platformBrightness]) {
    Brightness? platform = platformBrightness;
    if (platform == null) {
      try {
        platform =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
      } catch (_) {
        platform = Brightness.light;
      }
    }
    return switch (mode) {
      ThemeMode.light => false,
      ThemeMode.dark => true,
      ThemeMode.system => platform == Brightness.dark,
    };
  }

  static void updateTheme(ThemeMode mode, [Brightness? platformBrightness]) {
    isDark = computeIsDark(mode, platformBrightness);
  }

  // Brand primary colors (Modern Indigo & Emerald) - Strictly Preserved
  static const Color primary = Color(0xFF2563EB); // Vibrant Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color secondary = Color(0xFF0D9488); // Teal
  static const Color accent = Color(0xFFF59E0B); // Amber

  // Functional Semantic Colors
  static const Color safeGreen = Color(0xFF16A34A); // Safe, active, paid
  static const Color warningOrange = Color(0xFFEA580C); // Approaching expiry
  static const Color dangerRed = Color(0xFFDC2626); // Expired, due today, error
  static const Color infoBlue = Color(0xFF0284C7); // Information, synced

  // Module category colors
  static const Color lifePocketColor = Color(0xFF4F46E5); // Indigo
  static const Color freshCheckColor = Color(0xFF059669); // Emerald
  static const Color docAlertColor = Color(0xFFD97706); // Amber/Bronze
  static const Color medicineCareColor = Color(0xFFE11D48); // Rose / Crimson
  static const Color vaultColor = Color(0xFF7C3AED); // Violet

  // Surfaces & Backgrounds
  static Color get background =>
      _p(const Color(0xFFF8FAFC), const Color(0xFF0F172A));
  static Color get surface =>
      _p(const Color(0xFFFFFFFF), const Color(0xFF1E293B));
  static Color get surfaceRaised =>
      _p(const Color(0xFFF1F5F9), const Color(0xFF334155));
  static Color get surfaceSubtle =>
      _p(const Color(0xFFF8FAFC), const Color(0xFF162032));
  static Color get cardBorder =>
      _p(const Color(0xFFE2E8F0), const Color(0xFF334155));
  static Color get cardBorderSubtle =>
      _p(const Color(0xFFEEF2F6), const Color(0xFF263345));

  // Subtle semantic surface tints (Calm, non-aggressive backgrounds)
  static Color get primarySubtle => _p(
        const Color(0xFFEFF6FF),
        const Color(0xFF1E3A8A).withValues(alpha: 0.3),
      );
  static Color get safeGreenSubtle => _p(
        const Color(0xFFECFDF5),
        const Color(0xFF064E3B).withValues(alpha: 0.3),
      );
  static Color get warningOrangeSubtle => _p(
        const Color(0xFFFFFBEB),
        const Color(0xFF78350F).withValues(alpha: 0.3),
      );
  static Color get dangerRedSubtle => _p(
        const Color(0xFFFEF2F2),
        const Color(0xFF7F1D1D).withValues(alpha: 0.3),
      );

  // Text Colors
  static Color get textPrimary =>
      _p(const Color(0xFF0F172A), const Color(0xFFF8FAFC));
  static Color get textSecondary =>
      _p(const Color(0xFF475569), const Color(0xFF94A3B8));
  static Color get textMuted =>
      _p(const Color(0xFF94A3B8), const Color(0xFF64748B));

  // Shimmer / Divider
  static Color get divider =>
      _p(const Color(0xFFE2E8F0), const Color(0xFF1E293B));

  // --- Context-Aware Resolution Helpers ---
  static bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surfaceOf(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);

  static Color surfaceRaisedOf(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

  static Color surfaceSubtleOf(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF162032) : const Color(0xFFF8FAFC);

  static Color cardBorderOf(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  static Color cardBorderSubtleOf(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF263345) : const Color(0xFFEEF2F6);

  static Color textPrimaryOf(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

  static Color textSecondaryOf(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF94A3B8) : const Color(0xFF475569);

  static Color textMutedOf(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  static Color dividerOf(BuildContext context) =>
      isDarkMode(context) ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

  static Color primarySubtleOf(BuildContext context) => isDarkMode(context)
      ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
      : const Color(0xFFEFF6FF);

  static Color warningOrangeSubtleOf(BuildContext context) =>
      isDarkMode(context)
          ? const Color(0xFF78350F).withValues(alpha: 0.3)
          : const Color(0xFFFFFBEB);

  /// Seamless atmospheric ambient scaffold gradient (Soft brand glow fading to solid background)
  static LinearGradient scaffoldGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.35, 1.0],
        colors: [
          Color(0xFF131D33), // Deep midnight navy ambient tint
          Color(0xFF101826), // Smooth transitional dark slate
          Color(0xFF0F172A), // Base deep slate scaffold background
        ],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.35, 1.0],
        colors: [
          Color(0xFFEEF4FF), // Soft airy blue-indigo glow (4% brand saturation)
          Color(0xFFF5F8FC), // Gentle transition
          Color(0xFFF8FAFC), // Base calm light background
        ],
      );
    }
  }
}

/// Seamless BuildContext extension for robust, reactive theme color resolution
extension ThemeContextX on BuildContext {
  /// Whether the active Flutter Theme in this context is dark
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Full-screen ambient atmospheric background gradient
  LinearGradient get scaffoldGradient => AppColors.scaffoldGradient(this);

  /// Surface color for cards, panels, and modal backgrounds (White in Light, Slate-800 in Dark)
  Color get surfaceColor =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);

  /// Slightly elevated / distinct surface for input boxes, date pickers, chips (Slate-100 in Light, Slate-700 in Dark)
  Color get surfaceRaisedColor =>
      isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

  /// Subtle container background
  Color get surfaceSubtleColor =>
      isDark ? const Color(0xFF162032) : const Color(0xFFF8FAFC);

  /// Standard card border color
  Color get cardBorderColor =>
      isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  /// Subtle border color
  Color get cardBorderSubtleColor =>
      isDark ? const Color(0xFF263345) : const Color(0xFFEEF2F6);

  /// Primary high-contrast text color
  Color get textPrimaryColor =>
      isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

  /// Secondary readable text color
  Color get textSecondaryColor =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);

  /// Muted / disabled text color
  Color get textMutedColor =>
      isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  /// Divider color
  Color get dividerColor =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

  /// Subtle tinted background for primary brand accents
  Color get primarySubtleColor => isDark
      ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
      : const Color(0xFFEFF6FF);

  /// Subtle tinted background for warning banners
  Color get warningSubtleColor => isDark
      ? const Color(0xFF78350F).withValues(alpha: 0.3)
      : const Color(0xFFFFFBEB);
}
