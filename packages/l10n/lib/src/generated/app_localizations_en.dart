// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get retry => 'Try again';

  @override
  String get loading => 'Loading';

  @override
  String get errorNetwork =>
      'We couldn\'t reach the server. Please check your connection and try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorRequestFailed =>
      'The request could not be completed. Please try again.';

  @override
  String get errorServer =>
      'Something went wrong on our side. Please try again later.';

  @override
  String get errorTenantSetup =>
      'This app is not set up correctly. Please update the app or contact support.';

  @override
  String get errorBadCredentials =>
      'The email address or password is incorrect.';

  @override
  String get errorUserAlreadyExists =>
      'An account with this email address already exists.';

  @override
  String get errorFieldRequired => 'Please fill in all required fields.';

  @override
  String get errorBadRequest =>
      'That request was not valid. Please check your input and try again.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorForbidden => 'You do not have access to this.';

  @override
  String get errorListingNotFound => 'This listing could not be found.';

  @override
  String get errorNotFound => 'We could not find what you were looking for.';

  @override
  String get errorRangeTooLong =>
      'Please choose a shorter date range (up to one year).';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authRegister => 'Create account';

  @override
  String get authEmail => 'Email address';

  @override
  String get authPassword => 'Password';

  @override
  String get authFirstName => 'First name';

  @override
  String get authLastName => 'Last name';

  @override
  String get authGoToRegister => 'New here? Create an account';

  @override
  String get authGoToSignIn => 'Already have an account? Sign in';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authErrorRequired => 'This field is required.';

  @override
  String get authErrorEmailInvalid => 'Enter a valid email address.';

  @override
  String authErrorPasswordTooShort(int min) {
    return 'Use at least $min characters.';
  }

  @override
  String get authTermsIntro => 'By creating an account you agree to:';

  @override
  String get authTermsOfUse => 'Terms of use';

  @override
  String get authPrivacyPolicy => 'Privacy policy';

  @override
  String get signOut => 'Sign out';

  @override
  String get hostUnavailable => 'The host area is not available right now.';

  @override
  String get authLinkOpenFailed => 'The link could not be opened.';
}
