import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

CursorPage<String> _page(List<String> items, {String? next, int? total}) =>
    CursorPage(items: items, nextCursor: next, total: total);

void main() {
  group('PagedState', () {
    test('starts from the first page', () {
      final state = PagedState.fromFirstPage(
        _page(['a', 'b'], next: 'c2', total: 5),
      );

      expect(state.items, ['a', 'b']);
      expect(state.total, 5);
      expect(state.nextCursor, 'c2');
      expect(state.isLoadingMore, isFalse);
      expect(state.loadMoreError, isNull);
      expect(state.hasMore, isTrue);
    });

    test('appends the next page after the earlier ones', () {
      final state = PagedState.fromFirstPage(_page(['a', 'b'], next: 'c2'))
          .loadingMore()
          .withNextPage(_page(['c'], next: 'c3'));

      expect(state.items, ['a', 'b', 'c']);
      expect(state.nextCursor, 'c3');
      expect(state.isLoadingMore, isFalse);
    });

    test('stops at the end: the last page has no next cursor', () {
      final state = PagedState.fromFirstPage(_page(['a'], next: 'c2'))
          .withNextPage(_page(['b']));

      expect(state.hasMore, isFalse);
      expect(state.canLoadMore, isFalse);
    });

    test('keeps the total when a later page does not send one', () {
      final state = PagedState.fromFirstPage(_page(['a'], next: 'c2', total: 9))
          .withNextPage(_page(['b'], next: 'c3'));

      expect(state.total, 9);
    });

    group('canLoadMore', () {
      test('is true with a next cursor and nothing running', () {
        final state = PagedState.fromFirstPage(_page(['a'], next: 'c2'));

        expect(state.canLoadMore, isTrue);
      });

      test('is false while a load is in flight', () {
        final state = PagedState.fromFirstPage(_page(['a'], next: 'c2'))
            .loadingMore();

        expect(state.canLoadMore, isFalse);
      });

      test('is false on an empty list with no cursor', () {
        final state = PagedState<String>.fromFirstPage(_page([]));

        expect(state.canLoadMore, isFalse);
      });
    });

    group('when loading more fails', () {
      final loaded = PagedState.fromFirstPage(_page(['a', 'b'], next: 'c2'));

      test('keeps the items and records the failure', () {
        final state = loaded.loadingMore().loadMoreFailed(
          const NetworkFailure(),
        );

        expect(state.items, ['a', 'b']);
        expect(state.isLoadingMore, isFalse);
        expect(state.loadMoreError, isA<NetworkFailure>());
      });

      test('keeps the cursor, so a retry asks for the same page', () {
        final state = loaded.loadingMore().loadMoreFailed(
          const NetworkFailure(),
        );

        expect(state.nextCursor, 'c2');
        expect(state.canLoadMore, isTrue);
      });

      test('a new attempt clears the old error', () {
        final state = loaded
            .loadingMore()
            .loadMoreFailed(const NetworkFailure())
            .loadingMore();

        expect(state.loadMoreError, isNull);
        expect(state.isLoadingMore, isTrue);
      });

      test('a successful retry clears the error and appends', () {
        final state = loaded
            .loadingMore()
            .loadMoreFailed(const NetworkFailure())
            .loadingMore()
            .withNextPage(_page(['c']));

        expect(state.items, ['a', 'b', 'c']);
        expect(state.loadMoreError, isNull);
      });
    });
  });
}
