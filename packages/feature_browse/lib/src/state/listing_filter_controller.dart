import 'package:listings/listings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'listing_filter_controller.g.dart';

/// The filter the browse list is showing right now.
///
/// Auto-dispose: it lives exactly as long as the browse screen listens to it.
/// Opening a listing pushes a screen ON TOP of browse, so the screen stays in
/// the navigation stack, is still listening, and the filter survives. Leaving
/// the browse branch for good disposes it and the next visit starts unfiltered.
///
/// The filter sheet edits its own draft and calls [apply] once, so the list
/// reloads on "Show results" and not on every slider tick.
@riverpod
class ListingFilterController extends _$ListingFilterController {
  @override
  ListingFilter build() => const ListingFilter();

  void apply(ListingFilter filter) => state = filter;

  /// Removes every narrowing filter and keeps the sort.
  void clear() => state = state.cleared();
}
