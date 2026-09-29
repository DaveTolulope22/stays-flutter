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
}
