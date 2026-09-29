import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import 'hex_color.dart';

/// The tenant's eight colour roles. Registered in `ThemeData.extensions`, so
/// widgets read them with `context.colors` and never see a hex value.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.surfaceAction,
    required this.textDefault,
    required this.textMuted,
    required this.textOnAction,
    required this.borderPrimary,
    required this.iconAction,
  });

  /// Config token names, kept next to the fields they fill.
  static const _surfacePrimary = 'surface-primary';
  static const _surfaceSecondary = 'surface-secondary';
  static const _surfaceAction = 'surface-action';
  static const _textDefault = 'text-default';
  static const _textMuted = 'text-muted';
  static const _textOnAction = 'text-on-action';
  static const _borderPrimary = 'border-primary';
  static const _iconAction = 'icon-action';

  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color surfaceAction;
  final Color textDefault;
  final Color textMuted;
  final Color textOnAction;
  final Color borderPrimary;
  final Color iconAction;

  /// Neutral greys, used only for a token the config lacks or sends invalid.
  /// They are deliberately colourless so a fallback never looks like a brand.
  static const neutralLight = AppColors(
    surfacePrimary: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF2F2F2),
    surfaceAction: Color(0xFF404040),
    textDefault: Color(0xFF111111),
    textMuted: Color(0xFF666666),
    textOnAction: Color(0xFFFFFFFF),
    borderPrimary: Color(0xFFDDDDDD),
    iconAction: Color(0xFF404040),
  );

  static const neutralDark = AppColors(
    surfacePrimary: Color(0xFF111111),
    surfaceSecondary: Color(0xFF1E1E1E),
    surfaceAction: Color(0xFFBDBDBD),
    textDefault: Color(0xFFEEEEEE),
    textMuted: Color(0xFF999999),
    textOnAction: Color(0xFF111111),
    borderPrimary: Color(0xFF333333),
    iconAction: Color(0xFFBDBDBD),
  );

  /// Builds the roles from the config's token map. A missing or invalid token
  /// takes the neutral value for [brightness] and is logged; it never throws.
  factory AppColors.fromTokens(
    Map<String, String> tokens, {
    required Brightness brightness,
  }) {
    final fallback = brightness == Brightness.dark ? neutralDark : neutralLight;

    Color pick(String token, Color neutral) {
      final parsed = parseHexColor(tokens[token]);
      if (parsed == null) {
        developer.log(
          'Theme token "$token" is ${tokens.containsKey(token) ? 'invalid' : 'missing'}; '
          'using the neutral ${brightness.name} value.',
          name: 'design_system.theme',
        );
        return neutral;
      }
      return parsed;
    }

    return AppColors(
      surfacePrimary: pick(_surfacePrimary, fallback.surfacePrimary),
      surfaceSecondary: pick(_surfaceSecondary, fallback.surfaceSecondary),
      surfaceAction: pick(_surfaceAction, fallback.surfaceAction),
      textDefault: pick(_textDefault, fallback.textDefault),
      textMuted: pick(_textMuted, fallback.textMuted),
      textOnAction: pick(_textOnAction, fallback.textOnAction),
      borderPrimary: pick(_borderPrimary, fallback.borderPrimary),
      iconAction: pick(_iconAction, fallback.iconAction),
    );
  }

  @override
  AppColors copyWith({
    Color? surfacePrimary,
    Color? surfaceSecondary,
    Color? surfaceAction,
    Color? textDefault,
    Color? textMuted,
    Color? textOnAction,
    Color? borderPrimary,
    Color? iconAction,
  }) => AppColors(
    surfacePrimary: surfacePrimary ?? this.surfacePrimary,
    surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
    surfaceAction: surfaceAction ?? this.surfaceAction,
    textDefault: textDefault ?? this.textDefault,
    textMuted: textMuted ?? this.textMuted,
    textOnAction: textOnAction ?? this.textOnAction,
    borderPrimary: borderPrimary ?? this.borderPrimary,
    iconAction: iconAction ?? this.iconAction,
  );

  /// Called when the theme animates between two [ThemeData] (light to dark).
  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      surfacePrimary: Color.lerp(surfacePrimary, other.surfacePrimary, t)!,
      surfaceSecondary: Color.lerp(
        surfaceSecondary,
        other.surfaceSecondary,
        t,
      )!,
      surfaceAction: Color.lerp(surfaceAction, other.surfaceAction, t)!,
      textDefault: Color.lerp(textDefault, other.textDefault, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textOnAction: Color.lerp(textOnAction, other.textOnAction, t)!,
      borderPrimary: Color.lerp(borderPrimary, other.borderPrimary, t)!,
      iconAction: Color.lerp(iconAction, other.iconAction, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  /// The tenant's colours from the nearest [Theme]. Fails loudly if the theme
  /// was not built with `buildTheme`, since that is a wiring bug.
  AppColors get colors {
    final colors = Theme.of(this).extension<AppColors>();
    if (colors == null) {
      throw StateError(
        'AppColors is not registered on the Theme. Build it with buildTheme().',
      );
    }
    return colors;
  }
}
