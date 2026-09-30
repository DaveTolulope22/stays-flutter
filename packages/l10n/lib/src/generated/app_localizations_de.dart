// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get loading => 'Wird geladen';

  @override
  String get errorNetwork =>
      'Der Server ist nicht erreichbar. Bitte prüfen Sie Ihre Verbindung und versuchen Sie es erneut.';

  @override
  String get errorGeneric =>
      'Etwas ist schiefgelaufen. Bitte versuchen Sie es erneut.';

  @override
  String get errorRequestFailed =>
      'Die Anfrage konnte nicht abgeschlossen werden. Bitte versuchen Sie es erneut.';

  @override
  String get errorServer =>
      'Auf unserer Seite ist etwas schiefgelaufen. Bitte versuchen Sie es später erneut.';

  @override
  String get errorTenantSetup =>
      'Die App ist nicht richtig eingerichtet. Bitte aktualisieren Sie die App oder wenden Sie sich an den Support.';

  @override
  String get errorBadCredentials =>
      'Die E-Mail-Adresse oder das Passwort ist nicht korrekt.';

  @override
  String get errorUserAlreadyExists =>
      'Mit dieser E-Mail-Adresse existiert bereits ein Konto.';

  @override
  String get errorFieldRequired => 'Bitte füllen Sie alle Pflichtfelder aus.';

  @override
  String get errorBadRequest =>
      'Die Anfrage war ungültig. Bitte prüfen Sie Ihre Eingaben und versuchen Sie es erneut.';

  @override
  String get errorSessionExpired =>
      'Ihre Sitzung ist abgelaufen. Bitte melden Sie sich erneut an.';

  @override
  String get errorForbidden => 'Sie haben darauf keinen Zugriff.';

  @override
  String get errorListingNotFound => 'Diese Unterkunft wurde nicht gefunden.';

  @override
  String get errorNotFound =>
      'Wir haben nicht gefunden, wonach Sie gesucht haben.';

  @override
  String get errorRangeTooLong =>
      'Bitte wählen Sie einen kürzeren Zeitraum (höchstens ein Jahr).';

  @override
  String get authSignIn => 'Anmelden';

  @override
  String get authRegister => 'Konto erstellen';

  @override
  String get authEmail => 'E-Mail-Adresse';

  @override
  String get authPassword => 'Passwort';

  @override
  String get authFirstName => 'Vorname';

  @override
  String get authLastName => 'Nachname';

  @override
  String get authGoToRegister => 'Neu hier? Konto erstellen';

  @override
  String get authGoToSignIn => 'Bereits ein Konto? Anmelden';

  @override
  String get authShowPassword => 'Passwort anzeigen';

  @override
  String get authHidePassword => 'Passwort verbergen';

  @override
  String get authErrorRequired => 'Dieses Feld ist erforderlich.';

  @override
  String get authErrorEmailInvalid =>
      'Geben Sie eine gültige E-Mail-Adresse ein.';

  @override
  String authErrorPasswordTooShort(int min) {
    return 'Verwenden Sie mindestens $min Zeichen.';
  }

  @override
  String get authTermsIntro =>
      'Mit der Erstellung eines Kontos stimmen Sie Folgendem zu:';

  @override
  String get authTermsOfUse => 'Nutzungsbedingungen';

  @override
  String get authPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get signOut => 'Abmelden';

  @override
  String get hostUnavailable =>
      'Der Gastgeberbereich ist derzeit nicht verfügbar.';

  @override
  String get authLinkOpenFailed => 'Der Link konnte nicht geöffnet werden.';

  @override
  String get listingNew => 'Neu';

  @override
  String listingPricePerNight(String price) {
    return '$price / Nacht';
  }

  @override
  String listingRatingLabel(String rating, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$rating ($countString)';
  }

  @override
  String listingRatingSemantics(String rating, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bewertungen',
      one: '1 Bewertung',
    );
    return 'Bewertet mit $rating von 5 aus $_temp0';
  }

  @override
  String get listingNewSemantics => 'Neues Angebot, noch keine Bewertungen';

  @override
  String listingCardSemantics(String title, String city, String price) {
    return '$title, $city, $price';
  }

  @override
  String listingCardSemanticsRated(
    String title,
    String city,
    String price,
    String rating,
  ) {
    return '$title, $city, $price, $rating';
  }

  @override
  String get amenityWifi => 'WLAN';

  @override
  String get amenityKitchen => 'Küche';

  @override
  String get amenityParking => 'Parkplatz';

  @override
  String get amenityWasher => 'Waschmaschine';

  @override
  String get amenityDryer => 'Wäschetrockner';

  @override
  String get amenityAirConditioning => 'Klimaanlage';

  @override
  String get amenityHeating => 'Heizung';

  @override
  String get amenityTv => 'Fernseher';

  @override
  String get amenityPool => 'Pool';

  @override
  String get amenityHotTub => 'Whirlpool';

  @override
  String get amenityFireplace => 'Kamin';

  @override
  String get amenityBalcony => 'Balkon';

  @override
  String get amenitySeaView => 'Meerblick';

  @override
  String get amenityMountainView => 'Bergblick';

  @override
  String get amenitySkiStorage => 'Skiraum';

  @override
  String get amenityPetsAllowed => 'Haustiere erlaubt';

  @override
  String get amenityWorkspace => 'Arbeitsplatz';

  @override
  String get amenityElevator => 'Aufzug';

  @override
  String get amenityBbq => 'Grill';

  @override
  String get amenitySauna => 'Sauna';

  @override
  String get browseTab => 'Entdecken';

  @override
  String browseResultCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Unterkünfte',
      one: '1 Unterkunft',
    );
    return '$_temp0';
  }

  @override
  String get browseEmpty => 'Derzeit gibt es keine Unterkünfte.';

  @override
  String get browseEmptyFiltered => 'Keine Unterkünfte passen zu Ihrer Suche.';

  @override
  String get browseClearFilters => 'Filter zurücksetzen';

  @override
  String get browseFilters => 'Filter';
}
