import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static Brightness _brightness = Brightness.dark;

  static const darkBackgroundValue = Color(0xFF171A1F);
  static const darkSurfaceValue = Color(0xFF20242B);
  static const darkSurfaceElevatedValue = Color(0xFF292F38);
  static const darkPrimaryValue = Color(0xFF8FB7FF);
  static const darkPrimarySoftValue = Color(0xFF2B3B56);
  static const darkTextPrimaryValue = Color(0xFFF4F0E8);
  static const darkTextSecondaryValue = Color(0xFFC3CAD5);
  static const darkTextMutedValue = Color(0xFF8D97A6);
  static const darkBorderValue = Color(0xFF343B46);
  static const darkSuccessValue = Color(0xFF86D7A5);
  static const darkWarningValue = Color(0xFFEBCB86);
  static const darkDangerValue = Color(0xFFFF9A9A);

  static const lightBackground = Color(0xFFF7F8FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceElevated = Color(0xFFF1F3F6);
  static const lightPrimary = Color(0xFF315C94);
  static const lightPrimarySoft = Color(0xFFE6EDF7);
  static const lightTextPrimary = Color(0xFF111827);
  static const lightTextSecondary = Color(0xFF4B5563);
  static const lightTextMuted = Color(0xFF8A94A3);
  static const lightBorder = Color(0xFFE2E6EC);
  static const lightSuccess = Color(0xFF047857);
  static const lightWarning = Color(0xFFB45309);
  static const lightDanger = Color(0xFFB91C1C);

  static void useBrightness(Brightness brightness) {
    _brightness = brightness;
  }

  static bool get _isDark => _brightness == Brightness.dark;

  static Color get darkBackground =>
      _isDark ? darkBackgroundValue : lightBackground;
  static Color get darkSurface => _isDark ? darkSurfaceValue : lightSurface;
  static Color get darkSurfaceElevated =>
      _isDark ? darkSurfaceElevatedValue : lightSurfaceElevated;
  static Color get darkPrimary => _isDark ? darkPrimaryValue : lightPrimary;
  static Color get darkPrimarySoft =>
      _isDark ? darkPrimarySoftValue : lightPrimarySoft;
  static Color get darkTextPrimary =>
      _isDark ? darkTextPrimaryValue : lightTextPrimary;
  static Color get darkTextSecondary =>
      _isDark ? darkTextSecondaryValue : lightTextSecondary;
  static Color get darkTextMuted =>
      _isDark ? darkTextMutedValue : lightTextMuted;
  static Color get darkBorder => _isDark ? darkBorderValue : lightBorder;
  static Color get darkSuccess => _isDark ? darkSuccessValue : lightSuccess;
  static Color get darkWarning => _isDark ? darkWarningValue : lightWarning;
  static Color get darkDanger => _isDark ? darkDangerValue : lightDanger;
}
