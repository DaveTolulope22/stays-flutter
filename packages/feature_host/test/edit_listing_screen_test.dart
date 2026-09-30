import 'dart:async';

import 'package:core/core.dart';
import 'package:feature_host/feature_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

import 'support/host_harness.dart';

void main() {
  // A tap that misses its target must fail the test, not just warn: a missed
  // tap can leave an assertion true for the wrong reason.
  WidgetController.hitTestWarningShouldBeFatal = true;

  final en = copyFor('en');
  final de = copyFor('de');

  // Tall enough that the whole form is on screen, so no test has to scroll.
  const tall = Size(400, 1800);

  Finder field(String label) => find.widgetWithText(TextFormField, label);
  Finder saveButton(AppLocalizations l10n) =>
      find.widgetWithText(FilledButton, l10n.hostEditSave);

  String textOf(WidgetTester tester, String label) =>
      tester.widget<TextFormField>(field(label)).controller!.text;

  /// Types into a field and lets the form react (Save may switch on or off), as
  /// a real frame would between a person's keystrokes and their tap.
  Future<void> type(WidgetTester tester, String label, String text) async {
    await tester.enterText(field(label), text);
    await tester.pump();
  }

  bool canSave(WidgetTester tester, AppLocalizations l10n) =>
      tester.widget<FilledButton>(saveButton(l10n)).onPressed != null;

  /// The host's list with one listing, `l0`, opened on its edit screen.
  Future<ScriptedHostRepository> openEdit(
    WidgetTester tester, {
    Future<UpdateResult> Function(String id, ListingPatch patch)? onUpdate,
    Listing? listing,
    Locale locale = const Locale('en'),
    Size size = tall,
  }) async {
    final repo = ScriptedHostRepository(
      (_) async =>
          right(CursorPage(items: [listing ?? listingOf('l0')], total: 1)),
      onUpdate: onUpdate,
    );
    final harness = HostHarness(repo);
    await harness.pump(tester, locale: locale, size: size);
    final l10n = copyFor(locale.languageCode);
    await tester.tap(find.widgetWithText(TextButton, l10n.hostActionEdit));
    await tester.pumpAndSettle();
    return repo;
  }

  group('the form', () {
    testWidgets('starts with the listing as it is now', (tester) async {
      await openEdit(tester);

      expect(textOf(tester, en.hostEditFieldTitle), 'Chalet l0');
      expect(textOf(tester, en.hostEditFieldDescription), 'Quiet.');
      expect(textOf(tester, en.hostEditFieldPricePerNight), '249');
      expect(textOf(tester, en.hostEditFieldCleaningFee), '40.5');
      expect(textOf(tester, en.hostEditFieldMaxGuests), '4');
      expect(textOf(tester, en.hostEditFieldBedrooms), '2');
      expect(textOf(tester, en.hostEditFieldBeds), '3');
      expect(textOf(tester, en.hostEditFieldBathrooms), '1');
      expect(find.text(en.propertyTypeChalet), findsOneWidget);
    });

    testWidgets('a German host sees a decimal comma', (tester) async {
      await openEdit(tester, locale: const Locale('de'));

      expect(textOf(tester, de.hostEditFieldCleaningFee), '40,5');
    });

    testWidgets('offers every amenity we can label, the listing\'s selected', (
      tester,
    ) async {
      await openEdit(tester);

      expect(find.byType(FilterChip), findsNWidgets(knownAmenitySlugs.length));
      final wifi = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, en.amenityWifi),
      );
      final sauna = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, en.amenitySauna),
      );
      expect(wifi.selected, isTrue);
      expect(sauna.selected, isFalse);
    });

    testWidgets('an amenity we cannot label is shown, selected, and kept', (
      tester,
    ) async {
      final listing = Listing.fromJson({
        ...listingRow('l0'),
        'amenities': ['wifi', 'heated_towel_rail'],
      });
      final repo = await openEdit(tester, listing: listing);

      final chip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Heated towel rail'),
      );
      expect(chip.selected, isTrue);

      await tester.tap(find.widgetWithText(FilterChip, en.amenitySauna));
      await tester.pump();
      await tester.tap(saveButton(en));
      await tester.pumpAndSettle();

      expect(repo.updates.single.patch.amenities, [
        'wifi',
        'heated_towel_rail',
        'sauna',
      ]);
    });

    testWidgets('a listing that is not in the host\'s list is not found', (
      tester,
    ) async {
      final repo = ScriptedHostRepository((_) async => right(pageOf(1)));
      final harness = HostHarness(repo);
      await harness.pump(tester);

      harness.router.go(HostPaths.edit('nope'));
      await tester.pumpAndSettle();

      expect(find.text(en.errorListingNotFound), findsOneWidget);
      expect(saveButton(en), findsNothing);
    });
  });

  group('saving', () {
    testWidgets('is off until something changes, and off again if undone', (
      tester,
    ) async {
      await openEdit(tester);
      expect(canSave(tester, en), isFalse);

      await type(tester, en.hostEditFieldTitle, 'Changed');
      await tester.pump();
      expect(canSave(tester, en), isTrue);

      await type(tester, en.hostEditFieldTitle, 'Chalet l0');
      await tester.pump();
      expect(canSave(tester, en), isFalse);
    });

    testWidgets('a change of spaces only does not switch it on', (
      tester,
    ) async {
      await openEdit(tester);

      await type(tester, en.hostEditFieldTitle, '  Chalet l0  ');
      await tester.pump();

      expect(canSave(tester, en), isFalse);
    });

    testWidgets('sends only the fields that changed, trimmed, numbers as '
        'numbers', (tester) async {
      final repo = await openEdit(tester);

      await type(tester, en.hostEditFieldTitle, '  New title ');
      await type(tester, en.hostEditFieldPricePerNight, '250');
      await type(tester, en.hostEditFieldCleaningFee, '45,5');
      await tester.tap(saveButton(en));
      await tester.pumpAndSettle();

      final sent = repo.updates.single;
      expect(sent.id, 'l0');
      expect(sent.patch.toJson(), {
        'title': 'New title',
        'pricePerNight': 250,
        'cleaningFee': 45.5,
      });
      expect(sent.patch.toJson()['pricePerNight'], isA<num>());
    });

    testWidgets('a changed property type is sent', (tester) async {
      final repo = await openEdit(tester);

      await tester.tap(find.text(en.propertyTypeChalet));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.propertyTypeVilla).last);
      await tester.pumpAndSettle();
      await tester.tap(saveButton(en));
      await tester.pumpAndSettle();

      expect(repo.updates.single.patch.toJson(), {'propertyType': 'villa'});
    });

    testWidgets('success closes the form, says so, and the list shows the '
        'change', (tester) async {
      await openEdit(
        tester,
        onUpdate: (id, patch) async =>
            right(listingOf(id).copyWith(title: 'New title')),
      );

      await type(tester, en.hostEditFieldTitle, 'New title');
      await tester.tap(saveButton(en));
      // Not pumpAndSettle: that runs the clock past the message, which closes
      // itself after a few seconds.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text(en.hostEditSaved), findsOneWidget);
      expect(find.text('New title'), findsOneWidget);
      expect(find.text(en.hostListingsTitle), findsOneWidget);
      expect(saveButton(en), findsNothing);
    });

    testWidgets('while saving: a spinner, fields off, no second request', (
      tester,
    ) async {
      final gate = Completer<UpdateResult>();
      final repo = await openEdit(tester, onUpdate: (id, patch) => gate.future);

      await type(tester, en.hostEditFieldTitle, 'New title');
      await tester.tap(saveButton(en));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(FilledButton),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: field(en.hostEditFieldTitle),
                matching: find.byType(TextField),
              ),
            )
            .enabled,
        isFalse,
      );
      expect(repo.updates, hasLength(1));

      gate.complete(right(listingOf('l0').copyWith(title: 'New title')));
      await tester.pumpAndSettle();
    });
  });

  group('a failed save', () {
    testWidgets('shows one banner in our words and keeps what was typed', (
      tester,
    ) async {
      await openEdit(
        tester,
        onUpdate: (id, patch) async => left(
          const ValidationFailure(
            statusCode: 400,
            messageCode: 'error.badRequest',
          ),
        ),
      );

      await type(tester, en.hostEditFieldTitle, 'New title');
      await type(tester, en.hostEditFieldPricePerNight, '250');
      await tester.tap(saveButton(en));
      await tester.pumpAndSettle();

      expect(find.text(en.errorBadRequest), findsOneWidget);
      expect(textOf(tester, en.hostEditFieldTitle), 'New title');
      expect(textOf(tester, en.hostEditFieldPricePerNight), '250');
      expect(saveButton(en), findsOneWidget);
      expect(canSave(tester, en), isTrue);
    });

    testWidgets('trying again after a failure can succeed', (tester) async {
      var fail = true;
      final repo = await openEdit(
        tester,
        onUpdate: (id, patch) async => fail
            ? left(const NetworkFailure())
            : right(listingOf(id).copyWith(title: 'New title')),
      );
      await type(tester, en.hostEditFieldTitle, 'New title');
      await tester.tap(saveButton(en));
      await tester.pumpAndSettle();
      expect(find.text(en.errorNetwork), findsOneWidget);

      fail = false;
      await tester.tap(saveButton(en));
      await tester.pumpAndSettle();

      expect(repo.updates, hasLength(2));
      expect(saveButton(en), findsNothing);
    });
  });

  group('validation', () {
    testWidgets('an empty title is refused and nothing is sent', (
      tester,
    ) async {
      final repo = await openEdit(tester);

      await type(tester, en.hostEditFieldTitle, '   ');
      await tester.pump();
      await tester.tap(saveButton(en));
      await tester.pumpAndSettle();

      expect(find.text(en.hostEditErrorRequired), findsOneWidget);
      expect(repo.updates, isEmpty);
    });

    testWidgets('a price that is not an amount is refused', (tester) async {
      final repo = await openEdit(tester);

      await type(tester, en.hostEditFieldPricePerNight, 'abc');
      await tester.pump();
      await tester.tap(saveButton(en));
      await tester.pumpAndSettle();

      expect(find.text(en.hostEditErrorAmount), findsOneWidget);
      expect(repo.updates, isEmpty);
    });

    testWidgets('a negative price cannot be typed as a count, nor as an '
        'amount', (tester) async {
      final repo = await openEdit(tester);

      await type(tester, en.hostEditFieldCleaningFee, '-5');
      await tester.pump();
      await tester.tap(saveButton(en));
      await tester.pumpAndSettle();

      expect(find.text(en.hostEditErrorAmount), findsOneWidget);
      expect(repo.updates, isEmpty);
    });

    testWidgets('zero guests is refused, zero bedrooms is fine', (
      tester,
    ) async {
      final repo = await openEdit(tester);

      await type(tester, en.hostEditFieldBedrooms, '0');
      await type(tester, en.hostEditFieldMaxGuests, '0');
      await tester.pump();
      await tester.tap(saveButton(en));
      await tester.pumpAndSettle();

      expect(find.text(en.hostEditErrorGuests), findsOneWidget);
      expect(find.text(en.hostEditErrorCount), findsNothing);
      expect(repo.updates, isEmpty);
    });

    testWidgets('an empty count is refused', (tester) async {
      await openEdit(tester);

      await type(tester, en.hostEditFieldBeds, '');
      await tester.pump();

      expect(find.text(en.hostEditErrorCount), findsOneWidget);
    });
  });

  group('German', () {
    testWidgets('the form does not overflow a narrow screen', (tester) async {
      await openEdit(
        tester,
        locale: const Locale('de'),
        size: const Size(320, 1800),
      );

      expect(find.text(de.hostEditTitle), findsOneWidget);
      expect(saveButton(de), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
