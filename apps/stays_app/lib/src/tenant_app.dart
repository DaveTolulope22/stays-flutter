import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

/// The real app, built once the runtime config is known. Everything tenant
/// specific enters here, from [config], and nowhere else: the themes, the
/// title and the languages.
class TenantApp extends StatefulWidget {
  const TenantApp({required this.config, super.key});

  final TenantConfig config;

  @override
  State<TenantApp> createState() => _TenantAppState();
}

class _TenantAppState extends State<TenantApp> {
  // Held in state so a rebuild of this widget never creates a second router.
  // Phase 4 replaces this single placeholder route with the real route table.
  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => _HomePlaceholder(config: widget.config),
      ),
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    return MaterialApp.router(
      title: config.name,
      theme: buildTheme(config.theme.light, Brightness.light),
      darkTheme: buildTheme(config.theme.dark, Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocalesFor(config.locales),
      localeListResolutionCallback: (locales, _) => resolveLocale(
        deviceLocales: locales,
        configLocales: config.locales,
        defaultLocale: config.defaultLocale,
      ),
    );
  }
}

/// Temporary landing page: the tenant's name and its eight colour roles, so
/// both flavors and both brightnesses can be checked on a device. Replaced by
/// the real screens from Phase 4.
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder({required this.config});

  final TenantConfig config;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final swatches = [
      colors.surfacePrimary,
      colors.surfaceSecondary,
      colors.surfaceAction,
      colors.textDefault,
      colors.textMuted,
      colors.textOnAction,
      colors.borderPrimary,
      colors.iconAction,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(config.name)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            for (final color in swatches)
              Container(
                width: AppSizes.iconL,
                height: AppSizes.iconL,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: AppRadius.mediumAll,
                  border: Border.all(color: colors.borderPrimary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
