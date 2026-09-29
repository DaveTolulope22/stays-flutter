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
}
