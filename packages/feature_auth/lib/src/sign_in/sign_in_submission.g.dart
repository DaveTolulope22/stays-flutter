// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_submission.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The sign-in form's request: loading while it runs, then the failure if
/// there was one (null otherwise). On success it changes nothing itself; the
/// session changes and the router moves the user away.
///
/// Auto-dispose: this is one screen's state, gone when the screen is.

@ProviderFor(SignInSubmission)
final signInSubmissionProvider = SignInSubmissionProvider._();

/// The sign-in form's request: loading while it runs, then the failure if
/// there was one (null otherwise). On success it changes nothing itself; the
/// session changes and the router moves the user away.
///
/// Auto-dispose: this is one screen's state, gone when the screen is.
final class SignInSubmissionProvider
    extends $AsyncNotifierProvider<SignInSubmission, AppFailure?> {
  /// The sign-in form's request: loading while it runs, then the failure if
  /// there was one (null otherwise). On success it changes nothing itself; the
  /// session changes and the router moves the user away.
  ///
  /// Auto-dispose: this is one screen's state, gone when the screen is.
  SignInSubmissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInSubmissionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInSubmissionHash();

  @$internal
  @override
  SignInSubmission create() => SignInSubmission();
}

String _$signInSubmissionHash() => r'94ad9f5a022dff6d859fbd34e23eacbb79639aed';

/// The sign-in form's request: loading while it runs, then the failure if
/// there was one (null otherwise). On success it changes nothing itself; the
/// session changes and the router moves the user away.
///
/// Auto-dispose: this is one screen's state, gone when the screen is.

abstract class _$SignInSubmission extends $AsyncNotifier<AppFailure?> {
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
