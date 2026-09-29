import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

Headers _headers(Map<String, String> values) => Headers.fromMap({
  for (final e in values.entries) e.key: [e.value],
});

void main() {
  group('PageInfo.fromHeaders', () {
    test('reads total and both cursors', () {
      final info = PageInfo.fromHeaders(
        _headers({
          'x-total-count': '500',
          'x-next-cursor': 'bzoy',
          'x-prev-cursor': 'abcd',
        }),
      );

      expect(info.total, 500);
      expect(info.nextCursor, 'bzoy');
      expect(info.prevCursor, 'abcd');
    });

    test('the string "null" means no page', () {
      final info = PageInfo.fromHeaders(
        _headers({
          'x-total-count': '71',
          'x-next-cursor': 'null',
          'x-prev-cursor': 'null',
        }),
      );

      expect(info.total, 71);
      expect(info.nextCursor, isNull);
      expect(info.prevCursor, isNull);
    });

    test('a first page has a next cursor and prev "null"', () {
      final info = PageInfo.fromHeaders(
        _headers({
          'x-total-count': '500',
          'x-next-cursor': 'bzoy',
          'x-prev-cursor': 'null',
        }),
      );

      expect(info.nextCursor, 'bzoy');
      expect(info.prevCursor, isNull);
    });

    test('missing headers are no page and no total', () {
      final info = PageInfo.fromHeaders(Headers());

      expect(info.total, isNull);
      expect(info.nextCursor, isNull);
      expect(info.prevCursor, isNull);
    });

    test('an empty cursor is no page', () {
      final info = PageInfo.fromHeaders(_headers({'x-next-cursor': ''}));

      expect(info.nextCursor, isNull);
    });

    test('surrounding spaces are ignored', () {
      final info = PageInfo.fromHeaders(
        _headers({'x-total-count': ' 12 ', 'x-next-cursor': ' bzoy '}),
      );

      expect(info.total, 12);
      expect(info.nextCursor, 'bzoy');
    });

    test('a total that is not a number is null', () {
      final info = PageInfo.fromHeaders(_headers({'x-total-count': 'many'}));

      expect(info.total, isNull);
    });

    test('a cursor is passed through untouched, never decoded', () {
      final info = PageInfo.fromHeaders(
        _headers({'x-next-cursor': 'eyJ4Ijoic29tZXRoaW5nIn0='}),
      );

      expect(info.nextCursor, 'eyJ4Ijoic29tZXRoaW5nIn0=');
    });

    test('header names are case insensitive', () {
      final info = PageInfo.fromHeaders(
        _headers({'X-Total-Count': '9', 'X-Next-Cursor': 'zz'}),
      );

      expect(info.total, 9);
      expect(info.nextCursor, 'zz');
    });
  });
}
