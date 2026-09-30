import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

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
