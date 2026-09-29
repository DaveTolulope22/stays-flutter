import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

extension L10nContext on BuildContext {
  /// The copy for the active locale: `context.l10n.retry`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
