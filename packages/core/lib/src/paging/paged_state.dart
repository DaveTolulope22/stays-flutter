import 'package:freezed_annotation/freezed_annotation.dart';

import '../failures/app_failure.dart';
import 'cursor_page.dart';

part 'paged_state.freezed.dart';

/// The state of a list that loads page by page. Browse, host listings and
/// bookings all use it; only the item type differs.
///
/// Every change is a method that returns a new state, so the rules live here
/// and are tested once: a page never replaces earlier ones, a failed
/// "load more" keeps what is on screen, and a second "load more" cannot start
/// while one is running.
@freezed
abstract class PagedState<T> with _$PagedState<T> {
  const PagedState._();

  const factory PagedState({
    @Default([]) List<T> items,

    /// Rows matching the filter before paging, for a "N results" label.
    int? total,

    /// Null means the end of the list.
    String? nextCursor,
    @Default(false) bool isLoadingMore,

    /// Set when the last "load more" failed. The items stay; the UI shows a
    /// retry at the end of the list instead of replacing the whole screen.
    AppFailure? loadMoreError,
  }) = _PagedState<T>;

  /// State after the first page arrives.
  factory PagedState.fromFirstPage(CursorPage<T> page) => PagedState(
    items: page.items,
    total: page.total,
    nextCursor: page.nextCursor,
  );

  bool get hasMore => nextCursor != null;

  /// False while a request is running and at the end of the list, which is
  /// what makes a double scroll event or a fast fling harmless.
  bool get canLoadMore => hasMore && !isLoadingMore;

  PagedState<T> loadingMore() =>
      copyWith(isLoadingMore: true, loadMoreError: null);

  PagedState<T> withNextPage(CursorPage<T> page) => copyWith(
    items: [...items, ...page.items],
    total: page.total ?? total,
    nextCursor: page.nextCursor,
    isLoadingMore: false,
    loadMoreError: null,
  );

  /// Keeps [nextCursor], so trying again asks for the same page.
  PagedState<T> loadMoreFailed(AppFailure failure) =>
      copyWith(isLoadingMore: false, loadMoreError: failure);
}
