// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capabilities_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// keepAlive: derived from two app-wide providers and read by the router on
/// every navigation, so it is cheaper to keep than to rebuild.
///
/// While the session is loading or in error, nobody is signed in as far as
/// permissions go: [Capabilities.none]. While the config is not loaded, flags
/// are all off, so no feature appears early.

@ProviderFor(capabilities)
final capabilitiesProvider = CapabilitiesProvider._();

/// keepAlive: derived from two app-wide providers and read by the router on
/// every navigation, so it is cheaper to keep than to rebuild.
///
/// While the session is loading or in error, nobody is signed in as far as
/// permissions go: [Capabilities.none]. While the config is not loaded, flags
/// are all off, so no feature appears early.

final class CapabilitiesProvider
    extends $FunctionalProvider<Capabilities, Capabilities, Capabilities>
    with $Provider<Capabilities> {
  /// keepAlive: derived from two app-wide providers and read by the router on
  /// every navigation, so it is cheaper to keep than to rebuild.
  ///
  /// While the session is loading or in error, nobody is signed in as far as
  /// permissions go: [Capabilities.none]. While the config is not loaded, flags
  /// are all off, so no feature appears early.
  CapabilitiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'capabilitiesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$capabilitiesHash();

  @$internal
  @override
  $ProviderElement<Capabilities> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Capabilities create(Ref ref) {
    return capabilities(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Capabilities value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Capabilities>(value),
    );
  }
}

String _$capabilitiesHash() => r'd3f9a8f8f70cc8d0f4161a2ab113bef46e7b7574';
