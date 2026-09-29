import 'package:flutter/material.dart';

import 'app_colors.dart';

// The config has no error colour, so these two neutral reds live with the
// other fallbacks. Material requires an `error` in every ColorScheme.
const _errorLight = Color(0xFFB3261E);
const _errorDark = Color(0xFFF2B8B5);

/// Builds the theme for one brightness from the tenant's colour tokens.
///
/// The Material [ColorScheme] is derived from the same eight roles, so stock
/// widgets (buttons, text fields, app bars) use the tenant's colours instead
/// of a default seed colour the tenant never sent. [AppColors] rides along in
/// `extensions` for our own widgets.
ThemeData buildTheme(Map<String, String> tokens, Brightness brightness) {
  final colors = AppColors.fromTokens(tokens, brightness: brightness);
  final isDark = brightness == Brightness.dark;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: colors.surfaceAction,
    onPrimary: colors.textOnAction,
    secondary: colors.surfaceAction,
    onSecondary: colors.textOnAction,
    error: isDark ? _errorDark : _errorLight,
    onError: colors.surfacePrimary,
    surface: colors.surfacePrimary,
    onSurface: colors.textDefault,
    onSurfaceVariant: colors.textMuted,
    surfaceContainerLowest: colors.surfacePrimary,
    surfaceContainerLow: colors.surfaceSecondary,
    surfaceContainer: colors.surfaceSecondary,
    surfaceContainerHigh: colors.surfaceSecondary,
    surfaceContainerHighest: colors.surfaceSecondary,
    outline: colors.borderPrimary,
    outlineVariant: colors.borderPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.surfacePrimary,
    dividerColor: colors.borderPrimary,
    iconTheme: IconThemeData(color: colors.iconAction),
    extensions: [colors],
  );
}
