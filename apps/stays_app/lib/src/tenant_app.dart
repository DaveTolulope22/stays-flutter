import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

import 'modules/shell_modules.dart';
import 'routing/app_routes.dart';

/// The real app, built once the runtime config is known AND the session has
/// been resolved (restored, or found empty). Everything tenant specific enters
/// here, from [config]: the themes, the title, the languages and, through the
/// flags, which modules exist at all.
class TenantApp extends ConsumerStatefulWidget {
  const TenantApp({
    required this.config,
    this.buildModules = modulesFor,
    super.key,
  });

  final TenantConfig config;

  /// Which modules this tenant offers. A parameter only so tests can supply
  /// their own; the app always uses [modulesFor].
  final List<FeatureModule> Function(TenantFlags flags) buildModules;

  @override
  ConsumerState<TenantApp> createState() => _TenantAppState();
}

class _TenantAppState extends ConsumerState<TenantApp> {
  late final List<FeatureModule> _modules = widget.buildModules(
    widget.config.flags,
  );
  final _refresh = _RouterRefresh();
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      // Held in state so a rebuild never creates a second router.
      initialLocation: homeLocation(_modules, _capabilities) ?? '/',
      routes: routesFor(_modules),
      // The one place access is decided, on the device, before any screen
      // builds. It asks the module that owns the location.
      redirect: (context, state) => resolveRedirect(
        modules: _modules,
        capabilities: _capabilities,
        location: state.uri.toString(),
      ),
      // Signing in or out changes the capabilities; the router re-runs the
      // redirect, so the user is moved without any screen navigating.
      refreshListenable: _refresh,
    );
    ref.listenManual(capabilitiesProvider, (_, _) => _refresh.notify());
  }

  Capabilities get _capabilities => ref.read(capabilitiesProvider);

  @override
  void dispose() {
    _router.dispose();
    _refresh.dispose();
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

/// A `Listenable` the router watches; the app pokes it when capabilities
/// change. (`notifyListeners` is protected, so it is wrapped.)
class _RouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}
