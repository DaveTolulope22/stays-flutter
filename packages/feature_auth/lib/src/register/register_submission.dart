import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'register_submission.g.dart';

/// The registration form's request. Same shape as the sign-in one; kept apart
/// so a failure on one screen never shows on the other.
///
/// Auto-dispose: one screen's state.
@riverpod
class RegisterSubmission extends _$RegisterSubmission {
  @override
  FutureOr<AppFailure?> build() => null;

  Future<void> submit({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    final result = await ref
        .read(sessionControllerProvider.notifier)
        .register(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        );

    if (!ref.mounted) return;
    state = AsyncData(result.getLeft().toNullable());
  }
}
