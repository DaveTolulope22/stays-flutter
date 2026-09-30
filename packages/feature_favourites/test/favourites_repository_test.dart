import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:feature_favourites/src/data/favourites_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_http_adapter.dart';
import 'support/favourites_harness.dart';

FavouritesRepository repositoryWith(FakeHttpAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = adapter;
  return FavouritesRepository(dio: dio, tenant: testTenant);
}

ResponseBody emptyBody(int status) => ResponseBody.fromString('', status);

ResponseBody errorBody(int status, String code) => FakeHttpAdapter.json(
  jsonEncode({'statusCode': status, 'messageCode': code, 'message': 'secret'}),
  status: status,
);

void main() {
  group('list', () {
    test('reads the plain array and keeps the API order', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(
          jsonEncode([listingRow('b'), listingRow('a')]),
        ),
      );

      final result = await repositoryWith(adapter).list().run();

      expect(adapter.requests.single.path, '/favourites');
      expect(adapter.requests.single.method, 'GET');
      expect([for (final l in result.getOrElse((_) => [])) l.id], ['b', 'a']);
    });

    test('a row of another tenant is a failure, nothing is returned', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(
          jsonEncode([listingRow('a'), listingRow('b', tenantId: 'other')]),
        ),
      );

      final result = await repositoryWith(adapter).list().run();

      expect(result.getLeft().toNullable(), isA<TenantMismatchFailure>());
    });

    test('maps an error to a failure that carries the messageCode', () async {
      final adapter = FakeHttpAdapter(
        (_) => errorBody(401, 'error.unauthorized'),
      );

      final failure = (await repositoryWith(adapter).list().run())
          .getLeft()
          .toNullable();

      expect(failure, isA<UnauthorizedFailure>());
      expect(failure!.messageCode, 'error.unauthorized');
    });
  });

  group('add', () {
    test('posts the listing id as JSON', () async {
      final adapter = FakeHttpAdapter((_) => emptyBody(201));

      final result = await repositoryWith(adapter).add('l 1').run();

      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/favourites');
      expect(request.data, {'listingId': 'l 1'});
      expect(result.isRight(), isTrue);
    });

    test('an unknown listing is a NotFoundFailure', () async {
      final adapter = FakeHttpAdapter((_) => errorBody(404, 'error.notFound'));

      final result = await repositoryWith(adapter).add('nope').run();

      expect(result.getLeft().toNullable(), isA<NotFoundFailure>());
    });
  });

  group('remove', () {
    test('deletes by id, encoded in the path', () async {
      final adapter = FakeHttpAdapter((_) => emptyBody(204));

      final result = await repositoryWith(adapter).remove('l 1').run();

      final request = adapter.requests.single;
      expect(request.method, 'DELETE');
      expect(request.uri.path, '/favourites/l%201');
      expect(result.isRight(), isTrue);
    });

    test('a network error is a NetworkFailure', () async {
      final adapter = FakeHttpAdapter(
        (options) => throw DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        ),
      );

      final result = await repositoryWith(adapter).remove('l1').run();

      expect(result.getLeft().toNullable(), isA<NetworkFailure>());
    });
  });
}
