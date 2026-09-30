import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'boot/boot_app.dart';
import 'tenant_app.dart';

/// Chooses what to show while the app is getting ready: the runtime config
/// loads, then the stored session is verified. Either can be loading (a
/// spinner) or failed (a translated message with Retry). Only when both are
/// resolved does the tenant's app, with its router, exist.
///
/// Holding the router back until the session is resolved is what stops a
/// signed-in user from seeing the sign-in screen flash while the stored
/// session is being checked.
class StaysApp extends ConsumerWidget {
  const StaysApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(tenantConfigProvider)
        .when(
          loading: () => const BootApp(body: BootLoading()),
          error: (error, _) => BootApp(
            body: BootError(
              error: error,
              onRetry: () => ref.invalidate(tenantConfigProvider),
            ),
          ),
          data: (config) => ref
              .watch(sessionControllerProvider)
              .when(
                loading: () => const BootApp(body: BootLoading()),
                error: (error, _) => BootApp(
                  body: BootError(
                    error: error,
                    onRetry: () => ref.invalidate(sessionControllerProvider),
                  ),
                ),
                data: (_) => TenantApp(config: config),
              ),
        );
  }
}
