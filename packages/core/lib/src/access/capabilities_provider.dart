import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../session/session_controller.dart';
import '../tenant/tenant_config_provider.dart';
import '../tenant/tenant_flags.dart';
import 'capabilities.dart';

part 'capabilities_provider.g.dart';

/// keepAlive: derived from two app-wide providers and read by the router on
/// every navigation, so it is cheaper to keep than to rebuild.
///
/// While the session is loading or in error, nobody is signed in as far as
/// permissions go: [Capabilities.none]. While the config is not loaded, flags
/// are all off, so no feature appears early.
@Riverpod(keepAlive: true)
Capabilities capabilities(Ref ref) {
  final session = ref.watch(sessionControllerProvider).value;
  final flags =
      ref.watch(tenantConfigProvider).value?.flags ?? const TenantFlags();
  return resolveCapabilities(session, flags);
}
