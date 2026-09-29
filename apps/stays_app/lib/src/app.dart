import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'boot/boot_app.dart';
import 'tenant_app.dart';

/// Chooses what to show while the runtime config is loading, has failed, or
/// is ready. It is the only widget that watches [tenantConfigProvider]; the
/// tenant's app below it receives the config as a plain value.
class StaysApp extends ConsumerWidget {
  const StaysApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(tenantConfigProvider)
        .when(
          data: (config) => TenantApp(config: config),
          loading: () => const BootApp(body: BootLoading()),
          error: (error, _) => BootApp(
            body: BootError(
              error: error,
              onRetry: () => ref.invalidate(tenantConfigProvider),
            ),
          ),
        );
  }
}
