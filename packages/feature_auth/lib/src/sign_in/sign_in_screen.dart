import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

import '../auth_paths.dart';
import '../validation/auth_validation.dart';
import '../widgets/auth_widgets.dart';
import 'sign_in_submission.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  // Quiet until the first attempt, then live, so the form does not shout at a
  // user who has not typed anything yet.
  var _validation = AutovalidateMode.disabled;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _validation = AutovalidateMode.onUserInteraction);
      return;
    }
    ref
        .read(signInSubmissionProvider.notifier)
        .submit(email: cleaned(_email.text), password: cleaned(_password.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final submission = ref.watch(signInSubmissionProvider);
    final isLoading = submission.isLoading;
    // Riverpod keeps the previous value while loading, so the last failure
    // would otherwise stay on screen during a retry.
    final failure = isLoading ? null : submission.value;

    String? emailError(String? value) {
      final error = validateEmail(value);
      return error == null ? null : authErrorText(l10n, error);
    }

    String? passwordError(String? value) {
      final error = validateExistingPassword(value);
      return error == null ? null : authErrorText(l10n, error);
    }

    return AuthFormLayout(
      header: AuthBrandHeader(
        title: l10n.authWelcomeTitle,
        subtitle: l10n.authWelcomeSubtitle,
      ),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: _email,
                label: l10n.authEmail,
                validator: emailError,
                autovalidateMode: _validation,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: AppSpacing.m),
              PasswordField(
                controller: _password,
                label: l10n.authPassword,
                validator: passwordError,
                autovalidateMode: _validation,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => isLoading ? null : _submit(),
              ),
              const SizedBox(height: AppSpacing.m),
              if (failure != null) ...[
                FormFailureBanner(failure: failure),
                const SizedBox(height: AppSpacing.m),
              ],
              SubmitButton(
                label: l10n.authSignIn,
                isLoading: isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.s),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => context.go(AuthPaths.register),
                child: Text(l10n.authGoToRegister),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
