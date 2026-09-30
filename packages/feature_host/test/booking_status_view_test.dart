import 'package:feature_host/feature_host.dart';
import 'package:feature_host/src/bookings/booking_status_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/host_harness.dart';

void main() {
  final en = copyFor('en');
  final de = copyFor('de');

  group('decoding a status from the API', () {
    test('each status the API documents maps to its own value', () {
      final decoded = {
        for (final name in ['confirmed', 'pending', 'completed', 'cancelled'])
          name: Booking.fromJson(bookingRow('b1', status: name)).status,
      };

      expect(decoded, {
        'confirmed': BookingStatus.confirmed,
        'pending': BookingStatus.pending,
        'completed': BookingStatus.completed,
        'cancelled': BookingStatus.cancelled,
      });
    });

    test('a status we have never seen is unknown, not a crash', () {
      final booking = Booking.fromJson(bookingRow('b1', status: 'on_hold'));

      expect(booking.status, BookingStatus.unknown);
    });

    test('the name sent as a filter is the name the API uses', () {
      expect(
        [for (final status in bookingStatusFilters) status.name],
        ['confirmed', 'pending', 'completed', 'cancelled'],
      );
    });
  });

  group('the filters', () {
    test('offer every real status once and never unknown', () {
      expect(bookingStatusFilters, hasLength(4));
      expect(bookingStatusFilters.toSet(), hasLength(4));
      expect(bookingStatusFilters, isNot(contains(BookingStatus.unknown)));
    });
  });

  group('the label', () {
    test('is our own word for each status, in each language', () {
      expect(bookingStatusLabel(BookingStatus.confirmed, en), 'Confirmed');
      expect(bookingStatusLabel(BookingStatus.pending, en), 'Pending');
      expect(bookingStatusLabel(BookingStatus.completed, en), 'Completed');
      expect(bookingStatusLabel(BookingStatus.cancelled, en), 'Cancelled');
      expect(bookingStatusLabel(BookingStatus.confirmed, de), 'Bestätigt');
      expect(bookingStatusLabel(BookingStatus.cancelled, de), 'Storniert');
    });

    test('an unknown status gets a generic label', () {
      expect(bookingStatusLabel(BookingStatus.unknown, en), 'Unknown status');
      expect(
        bookingStatusLabel(BookingStatus.unknown, de),
        'Unbekannter Status',
      );
    });

    test('differs for every status, so the badge says something', () {
      for (final l10n in [en, de]) {
        final labels = {
          for (final status in BookingStatus.values)
            bookingStatusLabel(status, l10n),
        };

        expect(labels, hasLength(BookingStatus.values.length));
      }
    });
  });

  group('the icon', () {
    test('is different for every status: colour is never the only cue', () {
      final icons = {
        for (final status in BookingStatus.values) bookingStatusIcon(status),
      };

      expect(icons, hasLength(BookingStatus.values.length));
      expect(bookingStatusIcon(BookingStatus.unknown), Icons.help_outline);
    });
  });
}
