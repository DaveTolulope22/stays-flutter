import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_in_submission.g.dart';

/// The sign-in form's request: loading while it runs, then the failure if
/// there was one (null otherwise). On success it changes nothing itself; the
/// session changes and the router moves the user away.
///
/// Auto-dispose: this is one screen's state, gone when the screen is.
@riverpod
class SignInSubmission extends _$SignInSubmission {
  @override
  FutureOr<AppFailure?> build() => null;

  Future<void> submit({required String email, required String password}) async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    final result = await ref
        .read(sessionControllerProvider.notifier)
        .signIn(email: email, password: password);

    // After a success the screen may already be gone (the router redirected).
    if (!ref.mounted) return;
    state = AsyncData(result.getLeft().toNullable());
  }
}
