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
    return Center(
      child: CircularProgressIndicator(semanticsLabel: context.l10n.loading),
    );
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
    final message = error is AppFailure
        ? failureMessage(error as AppFailure, context.l10n)
        : context.l10n.errorGeneric;
    return _CenteredColumn(
      children: [
        Icon(
          Icons.cloud_off,
          size: AppSizes.iconL,
          color: context.colors.textMuted,
        ),
        const SizedBox(height: AppSpacing.m),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.l),
        FilledButton(onPressed: onRetry, child: Text(context.l10n.retry)),
      ],
    );
  }
}

/// A bad launch (missing or mismatched TENANT). This is a developer mistake,
/// so the message comes from the environment check, not from ARB.
class StartupError extends StatelessWidget {
  const StartupError({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _CenteredColumn(
      children: [
        Icon(
          Icons.error_outline,
          size: AppSizes.iconL,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: AppSpacing.m),
        Text(message, textAlign: TextAlign.center),
      ],
    );
  }
}

class _CenteredColumn extends StatelessWidget {
  const _CenteredColumn({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}
