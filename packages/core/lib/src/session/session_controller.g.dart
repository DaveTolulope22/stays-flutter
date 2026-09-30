// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Who is signed in, or nobody. Its value is:
/// - `AsyncData(Session)`: signed in,
/// - `AsyncData(null)`: signed out,
/// - `AsyncLoading`: restoring a stored session,
/// - `AsyncError(AppFailure)`: the stored session could not be verified right
///   now (network or server trouble). Nothing is decided; retry with
///   `ref.invalidate(sessionControllerProvider)`.
///
/// keepAlive: the session is app-wide state that outlives every screen, and
/// the router, the interceptor hooks and the capabilities all read it.

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

/// Who is signed in, or nobody. Its value is:
/// - `AsyncData(Session)`: signed in,
/// - `AsyncData(null)`: signed out,
/// - `AsyncLoading`: restoring a stored session,
/// - `AsyncError(AppFailure)`: the stored session could not be verified right
///   now (network or server trouble). Nothing is decided; retry with
///   `ref.invalidate(sessionControllerProvider)`.
///
/// keepAlive: the session is app-wide state that outlives every screen, and
/// the router, the interceptor hooks and the capabilities all read it.
final class SessionControllerProvider
    extends $AsyncNotifierProvider<SessionController, Session?> {
  /// Who is signed in, or nobody. Its value is:
  /// - `AsyncData(Session)`: signed in,
  /// - `AsyncData(null)`: signed out,
  /// - `AsyncLoading`: restoring a stored session,
  /// - `AsyncError(AppFailure)`: the stored session could not be verified right
  ///   now (network or server trouble). Nothing is decided; retry with
  ///   `ref.invalidate(sessionControllerProvider)`.
  ///
  /// keepAlive: the session is app-wide state that outlives every screen, and
  /// the router, the interceptor hooks and the capabilities all read it.
  SessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noAutomaticRetry,
        name: r'sessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionControllerHash();

  @$internal
  @override
  SessionController create() => SessionController();
}

String _$sessionControllerHash() => r'ac692bbe875ca0aa50678ef8489ffc5395a81d91';

/// Who is signed in, or nobody. Its value is:
/// - `AsyncData(Session)`: signed in,
/// - `AsyncData(null)`: signed out,
/// - `AsyncLoading`: restoring a stored session,
/// - `AsyncError(AppFailure)`: the stored session could not be verified right
///   now (network or server trouble). Nothing is decided; retry with
///   `ref.invalidate(sessionControllerProvider)`.
///
/// keepAlive: the session is app-wide state that outlives every screen, and
/// the router, the interceptor hooks and the capabilities all read it.

abstract class _$SessionController extends $AsyncNotifier<Session?> {
  FutureOr<Session?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Session?>, Session?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Session?>, Session?>,
              AsyncValue<Session?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
