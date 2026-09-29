import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

Response<dynamic> _response(Object? body, Map<String, String> headers) =>
    Response<dynamic>(
      requestOptions: RequestOptions(path: '/things'),
      data: body,
      headers: Headers.fromMap({
        for (final e in headers.entries) e.key: [e.value],
      }),
    );

String _decode(Map<String, dynamic> json) => json['id'] as String;

void main() {
  group('CursorPage.fromResponse', () {
    test('decodes the array and reads the position headers', () {
      final page = CursorPage.fromResponse(
        _response(
          [
            {'id': 'a'},
            {'id': 'b'},
          ],
          {
            'x-total-count': '500',
            'x-next-cursor': 'bzoy',
            'x-prev-cursor': 'null',
          },
        ),
        _decode,
      );

      expect(page.items, ['a', 'b']);
      expect(page.total, 500);
      expect(page.nextCursor, 'bzoy');
      expect(page.prevCursor, isNull);
      expect(page.hasNext, isTrue);
    });

    test('the last page has no next cursor', () {
      final page = CursorPage.fromResponse(
        _response(
          [
            {'id': 'a'},
          ],
          {'x-next-cursor': 'null', 'x-prev-cursor': 'null'},
        ),
        _decode,
      );

      expect(page.hasNext, isFalse);
    });

    test('an empty array is an empty page', () {
      final page = CursorPage.fromResponse(
        _response([], {'x-total-count': '0', 'x-next-cursor': 'null'}),
        _decode,
      );

      expect(page.items, isEmpty);
      expect(page.total, 0);
      expect(page.hasNext, isFalse);
    });

    test('a body that is not an array throws a FormatException', () {
      expect(
        () => CursorPage.fromResponse(_response({'id': 'a'}, {}), _decode),
        throwsFormatException,
      );
    });

    test('a row that is not an object throws', () {
      expect(
        () => CursorPage.fromResponse(_response(['a'], {}), _decode),
        throwsA(isA<TypeError>()),
      );
    });

    test('inside apiCall a bad body becomes an UnknownFailure', () async {
      final result = await apiCall(
        () async => CursorPage.fromResponse(_response('<html>', {}), _decode),
      ).run();

      expect(result.getLeft().toNullable(), isA<UnknownFailure>());
    });
  });
}
