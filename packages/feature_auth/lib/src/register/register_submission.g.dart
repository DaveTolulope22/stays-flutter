// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_submission.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The registration form's request. Same shape as the sign-in one; kept apart
/// so a failure on one screen never shows on the other.
///
/// Auto-dispose: one screen's state.

@ProviderFor(RegisterSubmission)
final registerSubmissionProvider = RegisterSubmissionProvider._();

/// The registration form's request. Same shape as the sign-in one; kept apart
/// so a failure on one screen never shows on the other.
///
/// Auto-dispose: one screen's state.
final class RegisterSubmissionProvider
    extends $AsyncNotifierProvider<RegisterSubmission, AppFailure?> {
  /// The registration form's request. Same shape as the sign-in one; kept apart
  /// so a failure on one screen never shows on the other.
  ///
  /// Auto-dispose: one screen's state.
  RegisterSubmissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerSubmissionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerSubmissionHash();

  @$internal
  @override
  RegisterSubmission create() => RegisterSubmission();
}

String _$registerSubmissionHash() =>
    r'93c3749cc3d73eeac81a8cc0def2d0f217731439';

/// The registration form's request. Same shape as the sign-in one; kept apart
/// so a failure on one screen never shows on the other.
///
/// Auto-dispose: one screen's state.

abstract class _$RegisterSubmission extends $AsyncNotifier<AppFailure?> {
  FutureOr<AppFailure?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppFailure?>, AppFailure?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppFailure?>, AppFailure?>,
              AsyncValue<AppFailure?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
