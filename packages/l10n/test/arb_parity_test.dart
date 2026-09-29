import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

Set<String> _keys(String file) {
  final json = jsonDecode(
    File('lib/src/arb/$file').readAsStringSync(),
  ) as Map<String, dynamic>;
  return json.keys.where((key) => !key.startsWith('@')).toSet();
}

void main() {
  test('German has exactly the keys English has', () {
    expect(_keys('app_de.arb'), _keys('app_en.arb'));
  });

  for (final language in ['en', 'de']) {
    testWidgets('$language copy is served through context.l10n', (
      tester,
    ) async {
      late AppLocalizations copy;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              copy = context.l10n;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(copy.retry, isNotEmpty);
      expect(copy.errorGeneric, isNotEmpty);
      expect(copy.localeName, language);
    });
  }

  testWidgets('English and German copy differ', (tester) async {
    expect(AppLocalizations.delegate.isSupported(const Locale('de')), isTrue);
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final de = await AppLocalizations.delegate.load(const Locale('de'));

    expect(de.retry, isNot(en.retry));
    expect(de.errorNetwork, isNot(en.errorNetwork));
  });
}
