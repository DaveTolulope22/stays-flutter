// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_hooks_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// keepAlive: one bridge for the process, shared by the controller and the
/// hooks below.

@ProviderFor(sessionBridge)
final sessionBridgeProvider = SessionBridgeProvider._();

/// keepAlive: one bridge for the process, shared by the controller and the
/// hooks below.

final class SessionBridgeProvider
    extends $FunctionalProvider<SessionBridge, SessionBridge, SessionBridge>
    with $Provider<SessionBridge> {
  /// keepAlive: one bridge for the process, shared by the controller and the
  /// hooks below.
  SessionBridgeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionBridgeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionBridgeHash();

  @$internal
  @override
  $ProviderElement<SessionBridge> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionBridge create(Ref ref) {
    return sessionBridge(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionBridge value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionBridge>(value),
    );
  }
}

String _$sessionBridgeHash() => r'abdd6a49abe511332bd899678060659702fe94ac';

/// keepAlive: read once when the Dio is built. The function reads the bridge
/// per request, so it always sees the current token.

@ProviderFor(authTokenGetter)
final authTokenGetterProvider = AuthTokenGetterProvider._();

/// keepAlive: read once when the Dio is built. The function reads the bridge
/// per request, so it always sees the current token.

final class AuthTokenGetterProvider
    extends
        $FunctionalProvider<AuthTokenGetter, AuthTokenGetter, AuthTokenGetter>
    with $Provider<AuthTokenGetter> {
  /// keepAlive: read once when the Dio is built. The function reads the bridge
  /// per request, so it always sees the current token.
  AuthTokenGetterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authTokenGetterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authTokenGetterHash();

  @$internal
  @override
  $ProviderElement<AuthTokenGetter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthTokenGetter create(Ref ref) {
    return authTokenGetter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthTokenGetter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthTokenGetter>(value),
    );
  }
}

String _$authTokenGetterHash() => r'51a50aec68798c991297f88cdf09440d637afad7';

/// keepAlive, same reason. A rejected authenticated call ends the session
/// locally, through whatever handler the controller registered.

@ProviderFor(unauthorizedCallback)
final unauthorizedCallbackProvider = UnauthorizedCallbackProvider._();

/// keepAlive, same reason. A rejected authenticated call ends the session
/// locally, through whatever handler the controller registered.

final class UnauthorizedCallbackProvider
    extends
        $FunctionalProvider<
          UnauthorizedCallback,
          UnauthorizedCallback,
          UnauthorizedCallback
        >
    with $Provider<UnauthorizedCallback> {
  /// keepAlive, same reason. A rejected authenticated call ends the session
  /// locally, through whatever handler the controller registered.
  UnauthorizedCallbackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unauthorizedCallbackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unauthorizedCallbackHash();

  @$internal
  @override
  $ProviderElement<UnauthorizedCallback> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UnauthorizedCallback create(Ref ref) {
    return unauthorizedCallback(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnauthorizedCallback value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnauthorizedCallback>(value),
    );
  }
}

String _$unauthorizedCallbackHash() =>
    r'fb619e40a5c8f12a4b129e528d0cb88a0fdca146';
