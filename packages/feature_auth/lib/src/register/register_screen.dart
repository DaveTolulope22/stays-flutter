import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

import '../auth_paths.dart';
import '../url_opener.dart';
import '../validation/auth_validation.dart';
import '../widgets/auth_widgets.dart';
import 'register_submission.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  var _validation = AutovalidateMode.disabled;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
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
        .read(registerSubmissionProvider.notifier)
        .submit(
          email: cleaned(_email.text),
          password: cleaned(_password.text),
          firstName: cleaned(_firstName.text),
          lastName: cleaned(_lastName.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final submission = ref.watch(registerSubmissionProvider);
    final isLoading = submission.isLoading;
    // Riverpod keeps the previous value while loading, so the last failure
    // would otherwise stay on screen during a retry.
    final failure = isLoading ? null : submission.value;

    String? Function(String?) checked(AuthFieldError? Function(String?) rule) {
      return (value) {
        final error = rule(value);
        return error == null ? null : authErrorText(l10n, error);
      };
    }

    return AuthFormLayout(
      header: AuthBackHeader(
        title: l10n.authRegister,
        subtitle: l10n.authRegisterSubtitle,
        backTooltip: l10n.authBackToSignIn,
        // Register is reached with `go`, so there is nothing to pop.
        onBack: () => context.go(AuthPaths.signIn),
      ),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: _firstName,
                label: l10n.authFirstName,
                validator: checked(validateName),
                autovalidateMode: _validation,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.givenName],
              ),
              const SizedBox(height: AppSpacing.m),
              AuthTextField(
                controller: _lastName,
                label: l10n.authLastName,
                validator: checked(validateName),
                autovalidateMode: _validation,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.familyName],
              ),
              const SizedBox(height: AppSpacing.m),
              AuthTextField(
                controller: _email,
                label: l10n.authEmail,
                validator: checked(validateEmail),
                autovalidateMode: _validation,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: AppSpacing.m),
              PasswordField(
                controller: _password,
                label: l10n.authPassword,
                validator: checked(validateNewPassword),
                autovalidateMode: _validation,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onFieldSubmitted: (_) => isLoading ? null : _submit(),
              ),
              const SizedBox(height: AppSpacing.m),
              const _LegalLinks(),
              const SizedBox(height: AppSpacing.m),
              if (failure != null) ...[
                FormFailureBanner(failure: failure),
                const SizedBox(height: AppSpacing.m),
              ],
              SubmitButton(
                label: l10n.authRegister,
                isLoading: isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.s),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => context.go(AuthPaths.signIn),
                child: Text(l10n.authGoToSignIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The tenant's terms and privacy pages, from the runtime config.
class _LegalLinks extends ConsumerWidget {
  const _LegalLinks();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(tenantConfigProvider).value;
    if (config == null) return const SizedBox.shrink();
    final l10n = context.l10n;

    return Column(
      children: [
        Text(l10n.authTermsIntro, textAlign: TextAlign.center),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            TextButton(
              onPressed: () => _open(context, ref, config.termsOfUseUrl),
              child: Text(l10n.authTermsOfUse),
            ),
            TextButton(
              onPressed: () => _open(context, ref, config.privacyPolicyUrl),
              child: Text(l10n.authPrivacyPolicy),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.authLinkOpenFailed;
    final uri = _webAddress(url);
    final opened = uri != null && await ref.read(urlOpenerProvider)(uri);
    if (!opened) messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  /// Only real web pages. The address comes from a server, so anything else
  /// (a `tel:` or a custom app scheme) is refused rather than launched.
  static Uri? _webAddress(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return null;
    return (uri.scheme == 'https' || uri.scheme == 'http') ? uri : null;
  }
}
