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
}
