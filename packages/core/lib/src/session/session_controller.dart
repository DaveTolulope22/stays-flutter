import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../failures/app_failure.dart';
import '../network/auth_hooks_provider.dart';
import '../network/no_automatic_retry.dart';
import '../tenant/tenant_environment_provider.dart';
import 'auth_repository_provider.dart';
import 'session.dart';
import 'session_storage_provider.dart';

part 'session_controller.g.dart';

/// Who is signed in, or nobody. Its value is:
/// - `AsyncData(Session)`: signed in,
/// - `AsyncData(null)`: signed out,
/// - `AsyncLoading`: restoring a stored session,
/// - `AsyncError(AppFailure)`: the stored session could not be verified right
///   now (network or server trouble). Nothing is decided; retry with
///   `ref.invalidate(sessionControllerProvider)`.
///
/// keepAlive: the session is app-wide state that outlives every screen, and
/// the router, the interceptor hooks and the capabilities all read it. The
/// restore step reports its own failure and the boot screen offers Retry, so it
/// does not retry automatically.
@Riverpod(keepAlive: true, retry: noAutomaticRetry)
class SessionController extends _$SessionController {
  /// Restores a stored session. It is trusted only after `/auth/me` confirms
  /// it, so a revoked token can never show a signed-in screen. A 401 or a
  /// foreign tenant discards it. Any other failure fails closed: the error is
  /// surfaced and the stored session is left as it is.
  @override
  Future<Session?> build() async {
    final storage = ref.watch(sessionStorageProvider);
    final tenant = ref.watch(tenantEnvironmentProvider).tenant;

    // Nothing is trusted until confirmed, so requests go out without a token
    // (restore passes its own explicitly).
    _bridge
      ..accessToken = null
      ..onSessionRejected = () => unawaited(expireLocally());

    final stored = await storage.read();
    if (stored == null) return null;
    if (stored.user.tenantId != tenant) {
      await storage.clear();
      return null;
    }

    final result = await ref
        .watch(authRepositoryProvider)
        .me(token: stored.accessToken)
        .run();

    final failure = result.getLeft().toNullable();
    if (failure != null) {
      if (failure is UnauthorizedFailure || failure is TenantMismatchFailure) {
        await storage.clear();
        return null;
      }
      throw failure;
    }

    // Keep the freshly confirmed user (its role is the server's word today,
    // not what was on disk).
    final confirmed = stored.copyWith(user: result.getRight().toNullable()!);
    await storage.write(confirmed).run();
    _bridge.accessToken = confirmed.accessToken;
    return confirmed;
  }

  /// The hand-off the network layer reads (see [SessionBridge]).
  SessionBridge get _bridge => ref.read(sessionBridgeProvider);

  /// A wrong password comes back as a failure and leaves the session as it
  /// was: signed out. It is not a session error.
  Future<Either<AppFailure, Session>> signIn({
    required String email,
    required String password,
  }) async {
    final result = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password)
        .run();
    await _adopt(result);
    return result;
  }

  Future<Either<AppFailure, Session>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final result = await ref
        .read(authRepositoryProvider)
        .register(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        )
        .run();
    await _adopt(result);
    return result;
  }

  /// Signs out locally first, so the app leaves the signed-in area at once,
  /// then asks the server to revoke the token. That call can fail or answer
  /// 401 (already revoked); either way the device is already signed out.
  Future<void> signOut() async {
    final token = state.value?.accessToken;
    await _clearLocally();
    if (token != null) {
      await ref.read(authRepositoryProvider).logout(token: token).run();
    }
  }

  /// The server rejected our token on an authenticated call, so the session is
  /// dead. Clear it locally without calling the server. Safe to call several
  /// times, and a no-op when nobody is signed in.
  Future<void> expireLocally() async {
    if (state.value == null) return;
    await _clearLocally();
  }

  Future<void> _adopt(Either<AppFailure, Session> result) async {
    final session = result.getRight().toNullable();
    if (session == null) return;
    // If the platform refuses to store it, the user is still signed in for
    // this run; they will just have to sign in again next launch.
    await ref.read(sessionStorageProvider).write(session).run();
    _bridge.accessToken = session.accessToken;
    state = AsyncData(session);
  }

  Future<void> _clearLocally() async {
    _bridge.accessToken = null;
    await ref.read(sessionStorageProvider).clear();
    state = const AsyncData(null);
  }
}
