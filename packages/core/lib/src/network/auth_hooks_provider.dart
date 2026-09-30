import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth_interceptor.dart';

part 'auth_hooks_provider.g.dart';

/// A small hand-off between the session controller and the network layer.
///
/// The controller needs the Dio (for `/auth/me`) and the Dio's interceptor
/// needs the session (for the token). Riverpod forbids a provider from reading
/// one of its own dependents, even lazily, so the interceptor's hooks cannot
/// read the controller. Instead the controller WRITES the current token and its
/// "session rejected" handler here, and the hooks READ this object, which
/// depends on nothing.
class SessionBridge {
  /// The signed-in user's token, or null. Kept in step by the controller.
  String? accessToken;

  /// Set by the controller. Called when the server rejects our token.
  void Function()? onSessionRejected;
}

/// keepAlive: one bridge for the process, shared by the controller and the
/// hooks below.
@Riverpod(keepAlive: true)
SessionBridge sessionBridge(Ref ref) => SessionBridge();

/// keepAlive: read once when the Dio is built. The function reads the bridge
/// per request, so it always sees the current token.
@Riverpod(keepAlive: true)
AuthTokenGetter authTokenGetter(Ref ref) {
  final bridge = ref.watch(sessionBridgeProvider);
  return () => bridge.accessToken;
}

/// keepAlive, same reason. A rejected authenticated call ends the session
/// locally, through whatever handler the controller registered.
@Riverpod(keepAlive: true)
UnauthorizedCallback unauthorizedCallback(Ref ref) {
  final bridge = ref.watch(sessionBridgeProvider);
  return () => bridge.onSessionRejected?.call();
}
