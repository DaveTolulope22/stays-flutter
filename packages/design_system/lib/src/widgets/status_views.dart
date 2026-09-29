import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../tokens/app_sizes.dart';
import '../tokens/app_spacing.dart';

/// A button under a status message, such as "Try again" or "Clear filters".
/// The caller supplies both the words and the behaviour; the view has neither.
class ViewAction {
  const ViewAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

/// A centred spinner. [semanticsLabel] is what a screen reader announces; it
/// is passed in because this package holds no copy.
class LoadingView extends StatelessWidget {
  const LoadingView({this.semanticsLabel, super.key});

  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(semanticsLabel: semanticsLabel),
    );
  }
}

/// A failure: an icon, a message and, if the caller offers one, a way to try
/// again. It knows nothing about what failed.
class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.message,
    this.action,
    this.icon = Icons.error_outline,
    super.key,
  });

  final String message;
  final ViewAction? action;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _StatusView(
      icon: icon,
      message: message,
      action: action,
      announce: true,
    );
  }
}

/// A list or screen with nothing to show, optionally with a way out.
class EmptyView extends StatelessWidget {
  const EmptyView({
    required this.message,
    this.action,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String message;
  final ViewAction? action;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _StatusView(icon: icon, message: message, action: action);
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.message,
    required this.action,
    this.announce = false,
  });

  final IconData icon;
  final String message;
  final ViewAction? action;

  /// Errors are announced by a screen reader as they appear.
  final bool announce;

  @override
  Widget build(BuildContext context) {
    final action = this.action;
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Icon(
                    icon,
                    size: AppSizes.iconL,
                    color: context.colors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Semantics(
                  liveRegion: announce,
                  child: Text(message, textAlign: TextAlign.center),
                ),
                if (action != null) ...[
                  const SizedBox(height: AppSpacing.l),
                  FilledButton(
                    onPressed: action.onPressed,
                    child: Text(action.label),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
