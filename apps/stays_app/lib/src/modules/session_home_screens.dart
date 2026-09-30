import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

/// TEMPORARY landing page for a signed-in host, until the real host screens
/// exist (Phase 7). It shows who is signed in, the tenant's eight colour roles,
/// and a sign-out button, so the host side of the loop can be tried on a
/// device.
class SessionHomeScreen extends ConsumerWidget {
  const SessionHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(tenantConfigProvider).value;
    final user = ref.watch(sessionControllerProvider).value?.user;
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
      appBar: AppBar(title: Text(config?.name ?? '')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Text(
                '${user.firstName} ${user.lastName}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(user.role.name),
              const SizedBox(height: AppSpacing.l),
            ],
            Wrap(
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
            const SizedBox(height: AppSpacing.l),
            FilledButton(
              onPressed: () =>
                  ref.read(sessionControllerProvider.notifier).signOut(),
              child: Text(context.l10n.signOut),
            ),
          ],
        ),
      ),
    );
  }
}

/// What a host sees when the tenant has the host panel switched off: the host
/// side exists for them, but the host area does not, and browsing is not a
/// fallback (a host sees only the host side). They can still sign out.
class HostUnavailableScreen extends ConsumerWidget {
  const HostUnavailableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(tenantConfigProvider).value;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(config?.name ?? '')),
      body: EmptyView(
        icon: Icons.storefront_outlined,
        message: l10n.hostUnavailable,
        action: ViewAction(
          label: l10n.signOut,
          onPressed: () =>
              ref.read(sessionControllerProvider.notifier).signOut(),
        ),
      ),
    );
  }
}
