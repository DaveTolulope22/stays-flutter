// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_opener.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A provider so tests can replace the platform call. It is scoped to the
/// screens that use it (auto-dispose): there is nothing to keep alive.

@ProviderFor(urlOpener)
final urlOpenerProvider = UrlOpenerProvider._();

/// A provider so tests can replace the platform call. It is scoped to the
/// screens that use it (auto-dispose): there is nothing to keep alive.

final class UrlOpenerProvider
    extends $FunctionalProvider<UrlOpener, UrlOpener, UrlOpener>
    with $Provider<UrlOpener> {
  /// A provider so tests can replace the platform call. It is scoped to the
  /// screens that use it (auto-dispose): there is nothing to keep alive.
  UrlOpenerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'urlOpenerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$urlOpenerHash();

  @$internal
  @override
  $ProviderElement<UrlOpener> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UrlOpener create(Ref ref) {
    return urlOpener(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UrlOpener value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UrlOpener>(value),
    );
  }
}

String _$urlOpenerHash() => r'723ad5ccb2f4f90e07faa0dc3d104a7088b65f76';
