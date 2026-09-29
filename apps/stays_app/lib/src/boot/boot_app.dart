import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

/// The app before a tenant exists: neutral theme, device language. Used while
/// the runtime config loads, when it fails, and for a bad launch. Once the
/// config arrives it is replaced by the tenant's own app.
class BootApp extends StatelessWidget {
  const BootApp({required this.body, super.key});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildNeutralTheme(Brightness.light),
      darkTheme: buildNeutralTheme(Brightness.dark),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: (locales, _) => resolveBootLocale(locales),
      home: Scaffold(body: SafeArea(child: body)),
    );
  }
}

class BootLoading extends StatelessWidget {
  const BootLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingView(semanticsLabel: context.l10n.loading);
  }
}

/// Our own copy for a failed config load, chosen by [failureMessage]. Never
/// the server's message. Anything that is not an [AppFailure] (a bug) gets the
/// generic text.
class BootError extends StatelessWidget {
  const BootError({required this.error, required this.onRetry, super.key});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failure = error is AppFailure ? error as AppFailure : null;
    return ErrorView(
      icon: failure is NetworkFailure ? Icons.cloud_off : Icons.error_outline,
      message: failure == null
          ? context.l10n.errorGeneric
          : failureMessage(failure, context.l10n),
      action: ViewAction(label: context.l10n.retry, onPressed: onRetry),
    );
  }
}

/// A bad launch (missing or mismatched TENANT). This is a developer mistake,
/// so the message comes from the environment check, not from ARB, and there
/// is nothing to retry.
class StartupError extends StatelessWidget {
  const StartupError({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => ErrorView(message: message);
}
