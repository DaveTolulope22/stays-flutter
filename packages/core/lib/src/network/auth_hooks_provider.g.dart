// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_hooks_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// keepAlive: read once when the Dio is built. The default has no token, so
/// requests go out unauthenticated. Step 4.2 binds it to the session with a
/// closure that reads the session only when a request is made, which is why
/// building the Dio never touches the session and there is no cycle.

@ProviderFor(authTokenGetter)
final authTokenGetterProvider = AuthTokenGetterProvider._();

/// keepAlive: read once when the Dio is built. The default has no token, so
/// requests go out unauthenticated. Step 4.2 binds it to the session with a
/// closure that reads the session only when a request is made, which is why
/// building the Dio never touches the session and there is no cycle.

final class AuthTokenGetterProvider
    extends
        $FunctionalProvider<AuthTokenGetter, AuthTokenGetter, AuthTokenGetter>
    with $Provider<AuthTokenGetter> {
  /// keepAlive: read once when the Dio is built. The default has no token, so
  /// requests go out unauthenticated. Step 4.2 binds it to the session with a
  /// closure that reads the session only when a request is made, which is why
  /// building the Dio never touches the session and there is no cycle.
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

String _$authTokenGetterHash() => r'15f7236e5d44e6ec45ac5b2ecf859c8d14551d48';

/// keepAlive, same reason. The default does nothing; step 4.2 binds it to a
/// local sign-out.

@ProviderFor(unauthorizedCallback)
final unauthorizedCallbackProvider = UnauthorizedCallbackProvider._();

/// keepAlive, same reason. The default does nothing; step 4.2 binds it to a
/// local sign-out.

final class UnauthorizedCallbackProvider
    extends
        $FunctionalProvider<
          UnauthorizedCallback,
          UnauthorizedCallback,
          UnauthorizedCallback
        >
    with $Provider<UnauthorizedCallback> {
  /// keepAlive, same reason. The default does nothing; step 4.2 binds it to a
  /// local sign-out.
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
    r'9257f284343b9d91e42ae79b574fb9e821aa1b98';
