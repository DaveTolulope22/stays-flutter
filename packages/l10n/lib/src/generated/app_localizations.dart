import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// Button that repeats a failed action, such as loading the app or a list.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// Accessibility label for a loading indicator.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// Shown when a request got no response: offline, timeout or refused connection.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t reach the server. Please check your connection and try again.'**
  String get errorNetwork;

  /// Final fallback for any failure that has no more specific message.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Fallback for a rejected request (4xx) whose messageCode we do not know.
  ///
  /// In en, this message translates to:
  /// **'The request could not be completed. Please try again.'**
  String get errorRequestFailed;

  /// Server errors (5xx), including error.internalServerError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Please try again later.'**
  String get errorServer;

  /// error.tenantRequired and error.tenantUnknown: the build's tenant was not accepted.
  ///
  /// In en, this message translates to:
  /// **'This app is not set up correctly. Please update the app or contact support.'**
  String get errorTenantSetup;

  /// error.badCredentials: shown on the sign-in screen after a wrong login.
  ///
  /// In en, this message translates to:
  /// **'The email address or password is incorrect.'**
  String get errorBadCredentials;

  /// error.userAlreadyExist: registering with an email that is taken.
  ///
  /// In en, this message translates to:
  /// **'An account with this email address already exists.'**
  String get errorUserAlreadyExists;

  /// error.fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get errorFieldRequired;

  /// error.badRequest.
  ///
  /// In en, this message translates to:
  /// **'That request was not valid. Please check your input and try again.'**
  String get errorBadRequest;

  /// auth.token.invalid.UnauthorizedException and any other 401.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorSessionExpired;

  /// auth.forbidden.ForbiddenException and any other 403.
  ///
  /// In en, this message translates to:
  /// **'You do not have access to this.'**
  String get errorForbidden;

  /// listing.NotFoundException.
  ///
  /// In en, this message translates to:
  /// **'This listing could not be found.'**
  String get errorListingNotFound;

  /// route.NotFoundException and any other 404.
  ///
  /// In en, this message translates to:
  /// **'We could not find what you were looking for.'**
  String get errorNotFound;

  /// error.rangeTooLong: a date search or availability window over 366 days.
  ///
  /// In en, this message translates to:
  /// **'Please choose a shorter date range (up to one year).'**
  String get errorRangeTooLong;

  /// Sign-in screen title and its submit button.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// Registration screen title and its submit button.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegister;

  /// Label of the email field.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get authEmail;

  /// Label of the password field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// Label of the first name field on the registration form.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get authFirstName;

  /// Label of the last name field on the registration form.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get authLastName;

  /// Link on the sign-in screen that opens registration.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get authGoToRegister;

  /// Link on the registration screen that opens sign-in.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authGoToSignIn;

  /// Tooltip and accessibility label of the button that reveals the password.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// Tooltip and accessibility label of the button that hides the password.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// Inline error for an empty required field.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get authErrorRequired;

  /// Inline error for an email that is not shaped like one.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authErrorEmailInvalid;

  /// Inline error for a password shorter than the minimum.
  ///
  /// In en, this message translates to:
  /// **'Use at least {min} characters.'**
  String authErrorPasswordTooShort(int min);

  /// Line above the terms and privacy links on the registration screen.
  ///
  /// In en, this message translates to:
  /// **'By creating an account you agree to:'**
  String get authTermsIntro;

  /// Link to the tenant's terms of use.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get authTermsOfUse;

  /// Link to the tenant's privacy policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get authPrivacyPolicy;

  /// Button that ends the session.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Shown to a host whose tenant has the host panel switched off.
  ///
  /// In en, this message translates to:
  /// **'The host area is not available right now.'**
  String get hostUnavailable;

  /// Message shown when the terms or privacy page cannot be opened.
  ///
  /// In en, this message translates to:
  /// **'The link could not be opened.'**
  String get authLinkOpenFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
