import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../validation/auth_validation.dart';

/// Turns a validation result into translated copy.
String authErrorText(AppLocalizations l10n, AuthFieldError error) =>
    switch (error) {
      AuthFieldError.required => l10n.authErrorRequired,
      AuthFieldError.invalidEmail => l10n.authErrorEmailInvalid,
      AuthFieldError.tooShort => l10n.authErrorPasswordTooShort(
        minPasswordLength,
      ),
    };

/// A scrollable, width-limited page for an auth form, so it survives a small
/// screen, the keyboard, large text and a wide window.
/// The [header] sits above the form.
class AuthFormLayout extends StatelessWidget {
  const AuthFormLayout({required this.header, required this.child, super.key});

  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  const SizedBox(height: AppSpacing.xl),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The registration heading: a back arrow and the title on one row, with a
/// short subtitle under them.
class AuthBackHeader extends StatelessWidget {
  const AuthBackHeader({
    required this.title,
    required this.subtitle,
    required this.backTooltip,
    required this.onBack,
    super.key,
  });

  final String title;
  final String subtitle;
  final String backTooltip;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: backTooltip,
              icon: const BackButtonIcon(),
              onPressed: onBack,
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: context.colors.textMuted,
          ),
        ),
      ],
    );
  }
}

/// The sign-in heading: the app mark, a centred title and a short subtitle.
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const AuthMark(),
        const SizedBox(height: AppSpacing.l),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: context.colors.textMuted,
          ),
        ),
      ],
    );
  }
}

/// A rounded square with a neutral icon, coloured from the tenant's tokens.
///
/// Deliberately not a per-tenant image: the colours already carry the brand,
/// the mark follows light and dark for free, and no tenant name or asset path
/// is needed in code. It is decoration, so a screen reader skips it.
class AuthMark extends StatelessWidget {
  const AuthMark({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceAction,
          borderRadius: AppRadius.largeAll,
        ),
        child: SizedBox.square(
          dimension: AppSizes.brandMark,
          child: Icon(
            Icons.home_work_outlined,
            size: AppSizes.iconL,
            color: colors.textOnAction,
          ),
        ),
      ),
    );
  }
}

/// A text field with the auth forms' shared look and behaviour.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.label,
    required this.validator,
    required this.autovalidateMode,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.suffixIcon,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final AutovalidateMode autovalidateMode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      autovalidateMode: autovalidateMode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onFieldSubmitted: onFieldSubmitted,
      obscureText: obscureText,
      // A password or an email is not something to autocorrect or suggest.
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(borderRadius: AppRadius.mediumAll),
      ),
    );
  }
}

/// A password field with a show/hide toggle. The toggle has a tooltip, which
/// is also its accessibility label.
class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.controller,
    required this.label,
    required this.validator,
    required this.autovalidateMode,
    this.textInputAction,
    this.autofillHints,
    this.onFieldSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final AutovalidateMode autovalidateMode;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthTextField(
      controller: widget.controller,
      label: widget.label,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onFieldSubmitted: widget.onFieldSubmitted,
      obscureText: !_visible,
      suffixIcon: IconButton(
        tooltip: _visible ? l10n.authHidePassword : l10n.authShowPassword,
        icon: Icon(_visible ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _visible = !_visible),
      ),
    );
  }
}

/// The failure of a submission, in our own words (never the server's), read
/// out by a screen reader when it appears.
class FormFailureBanner extends StatelessWidget {
  const FormFailureBanner({required this.failure, super.key});

  final AppFailure failure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: true,
      container: true,
      child: Text(
        failureMessage(failure, context.l10n),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

/// The form's main button. While a request is running it is disabled and shows
/// a spinner, so a second tap cannot send a second request.
class SubmitButton extends StatelessWidget {
  const SubmitButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox.square(
              dimension: AppSizes.iconM,
              child: CircularProgressIndicator(
                semanticsLabel: context.l10n.loading,
              ),
            )
          : Text(label),
    );
  }
}
