import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _tokens = {
  'surface-primary': '#111111',
  'surface-secondary': '#222222',
  'surface-action': '#333333',
  'text-default': '#444444',
  'text-muted': '#555555',
  'text-on-action': '#666666',
  'border-primary': '#777777',
  'icon-action': '#888888',
};

void main() {
  group('AppColors.fromTokens', () {
    test('reads all eight roles', () {
      final colors = AppColors.fromTokens(
        _tokens,
        brightness: Brightness.light,
      );

      expect(colors.surfacePrimary, const Color(0xFF111111));
      expect(colors.surfaceSecondary, const Color(0xFF222222));
      expect(colors.surfaceAction, const Color(0xFF333333));
      expect(colors.textDefault, const Color(0xFF444444));
      expect(colors.textMuted, const Color(0xFF555555));
      expect(colors.textOnAction, const Color(0xFF666666));
      expect(colors.borderPrimary, const Color(0xFF777777));
      expect(colors.iconAction, const Color(0xFF888888));
    });

    test('a missing token falls back to the neutral value only for it', () {
      final tokens = {..._tokens}..remove('text-muted');

      final colors = AppColors.fromTokens(tokens, brightness: Brightness.light);

      expect(colors.textMuted, AppColors.neutralLight.textMuted);
      expect(colors.textDefault, const Color(0xFF444444));
    });

    test('an invalid token falls back to the neutral value', () {
      final tokens = {..._tokens, 'surface-action': 'not-a-colour'};

      final colors = AppColors.fromTokens(tokens, brightness: Brightness.light);

      expect(colors.surfaceAction, AppColors.neutralLight.surfaceAction);
    });

    test('an empty map yields the whole neutral palette, without throwing', () {
      final light = AppColors.fromTokens({}, brightness: Brightness.light);
      final dark = AppColors.fromTokens({}, brightness: Brightness.dark);

      expect(light.surfacePrimary, AppColors.neutralLight.surfacePrimary);
      expect(dark.surfacePrimary, AppColors.neutralDark.surfacePrimary);
      expect(light.surfacePrimary, isNot(dark.surfacePrimary));
    });
  });

  group('ThemeExtension contract', () {
    test('copyWith replaces only the given role', () {
      final copy = AppColors.neutralLight.copyWith(
        surfaceAction: const Color(0xFF123456),
      );

      expect(copy.surfaceAction, const Color(0xFF123456));
      expect(copy.textDefault, AppColors.neutralLight.textDefault);
    });

    test('lerp interpolates every role and ignores null', () {
      final halfway = AppColors.neutralLight.lerp(AppColors.neutralDark, 0.5);

      expect(
        halfway.surfacePrimary,
        Color.lerp(
          AppColors.neutralLight.surfacePrimary,
          AppColors.neutralDark.surfacePrimary,
          0.5,
        ),
      );
      expect(AppColors.neutralLight.lerp(null, 0.5), AppColors.neutralLight);
      expect(
        AppColors.neutralLight.lerp(AppColors.neutralDark, 0).textMuted,
        AppColors.neutralLight.textMuted,
      );
      expect(
        AppColors.neutralLight.lerp(AppColors.neutralDark, 1).textMuted,
        AppColors.neutralDark.textMuted,
      );
    });
  });

  group('buildTheme', () {
    test('registers AppColors and matches the brightness', () {
      final theme = buildTheme(_tokens, Brightness.dark);

      expect(theme.brightness, Brightness.dark);
      expect(
        theme.extension<AppColors>()?.surfacePrimary,
        const Color(0xFF111111),
      );
    });

    test('derives the Material ColorScheme from the tokens', () {
      final scheme = buildTheme(_tokens, Brightness.light).colorScheme;

      expect(scheme.primary, const Color(0xFF333333));
      expect(scheme.onPrimary, const Color(0xFF666666));
      expect(scheme.surface, const Color(0xFF111111));
      expect(scheme.onSurface, const Color(0xFF444444));
      expect(scheme.onSurfaceVariant, const Color(0xFF555555));
      expect(scheme.outline, const Color(0xFF777777));
    });

    test('builds a usable theme from an empty config', () {
      final theme = buildTheme({}, Brightness.light);

      expect(theme.colorScheme.primary, AppColors.neutralLight.surfaceAction);
    });
  });

  testWidgets('context.colors returns the active theme colours', (
    tester,
  ) async {
    late AppColors seen;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(_tokens, Brightness.light),
        home: Builder(
          builder: (context) {
            seen = context.colors;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(seen.surfaceAction, const Color(0xFF333333));
  });

  testWidgets('context.colors fails loudly without buildTheme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            expect(() => context.colors, throwsStateError);
            return const SizedBox();
          },
        ),
      ),
    );
  });

  testWidgets('the phone switching to dark selects the dark palette', (
    tester,
  ) async {
    final light = buildTheme(_tokens, Brightness.light);
    final dark = buildTheme({
      ..._tokens,
      'surface-primary': '#000001',
    }, Brightness.dark);
    late AppColors seen;

    Future<void> pump(Brightness platform) async {
      tester.platformDispatcher.platformBrightnessTestValue = platform;
      await tester.pumpWidget(
        MaterialApp(
          theme: light,
          darkTheme: dark,
          home: Builder(
            builder: (context) {
              seen = context.colors;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await pump(Brightness.light);
    expect(seen.surfacePrimary, const Color(0xFF111111));

    await pump(Brightness.dark);
    expect(seen.surfacePrimary, const Color(0xFF000001));
  });
}
