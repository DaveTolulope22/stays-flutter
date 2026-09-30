// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_blocked_days.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every day the host has closed on ONE listing, and the one way to change that.
///
/// A family keyed by the listing. The API lists blocked days for the whole
/// listing in one call (they are not paginated and there are few), so this loads
/// once and the calendar only reads from it as the month changes.
///
/// Auto-dispose: it lives while that listing's calendar is open. It does not
/// retry automatically; the calendar shows the error with a Retry button.

@ProviderFor(HostBlockedDays)
final hostBlockedDaysProvider = HostBlockedDaysFamily._();

/// Every day the host has closed on ONE listing, and the one way to change that.
///
/// A family keyed by the listing. The API lists blocked days for the whole
/// listing in one call (they are not paginated and there are few), so this loads
/// once and the calendar only reads from it as the month changes.
///
/// Auto-dispose: it lives while that listing's calendar is open. It does not
/// retry automatically; the calendar shows the error with a Retry button.
final class HostBlockedDaysProvider
    extends $AsyncNotifierProvider<HostBlockedDays, Set<LocalDate>> {
  /// Every day the host has closed on ONE listing, and the one way to change that.
  ///
  /// A family keyed by the listing. The API lists blocked days for the whole
  /// listing in one call (they are not paginated and there are few), so this loads
  /// once and the calendar only reads from it as the month changes.
  ///
  /// Auto-dispose: it lives while that listing's calendar is open. It does not
  /// retry automatically; the calendar shows the error with a Retry button.
  HostBlockedDaysProvider._({
    required HostBlockedDaysFamily super.from,
    required String super.argument,
  }) : super(
         retry: noAutomaticRetry,
         name: r'hostBlockedDaysProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostBlockedDaysHash();

  @override
  String toString() {
    return r'hostBlockedDaysProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HostBlockedDays create() => HostBlockedDays();

  @override
  bool operator ==(Object other) {
    return other is HostBlockedDaysProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostBlockedDaysHash() => r'20b12f5e3245e2a77eb4be8117a45621d38df5ab';

/// Every day the host has closed on ONE listing, and the one way to change that.
///
/// A family keyed by the listing. The API lists blocked days for the whole
/// listing in one call (they are not paginated and there are few), so this loads
/// once and the calendar only reads from it as the month changes.
///
/// Auto-dispose: it lives while that listing's calendar is open. It does not
/// retry automatically; the calendar shows the error with a Retry button.

final class HostBlockedDaysFamily extends $Family
    with
        $ClassFamilyOverride<
          HostBlockedDays,
          AsyncValue<Set<LocalDate>>,
          Set<LocalDate>,
          FutureOr<Set<LocalDate>>,
          String
        > {
  HostBlockedDaysFamily._()
    : super(
        retry: noAutomaticRetry,
        name: r'hostBlockedDaysProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every day the host has closed on ONE listing, and the one way to change that.
  ///
  /// A family keyed by the listing. The API lists blocked days for the whole
  /// listing in one call (they are not paginated and there are few), so this loads
  /// once and the calendar only reads from it as the month changes.
  ///
  /// Auto-dispose: it lives while that listing's calendar is open. It does not
  /// retry automatically; the calendar shows the error with a Retry button.

  HostBlockedDaysProvider call(String listingId) =>
      HostBlockedDaysProvider._(argument: listingId, from: this);

  @override
  String toString() => r'hostBlockedDaysProvider';
}

/// Every day the host has closed on ONE listing, and the one way to change that.
///
/// A family keyed by the listing. The API lists blocked days for the whole
/// listing in one call (they are not paginated and there are few), so this loads
/// once and the calendar only reads from it as the month changes.
///
/// Auto-dispose: it lives while that listing's calendar is open. It does not
/// retry automatically; the calendar shows the error with a Retry button.

abstract class _$HostBlockedDays extends $AsyncNotifier<Set<LocalDate>> {
  late final _$args = ref.$arg as String;
  String get listingId => _$args;

  FutureOr<Set<LocalDate>> build(String listingId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<LocalDate>>, Set<LocalDate>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<LocalDate>>, Set<LocalDate>>,
              AsyncValue<Set<LocalDate>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
