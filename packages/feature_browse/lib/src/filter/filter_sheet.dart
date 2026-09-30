import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

import '../state/listing_facets_provider.dart';
import '../state/listing_filter_controller.dart';
import 'filter_edits.dart';
import 'filter_labels.dart';
import 'price_scale.dart';

/// Opens the filter sheet over the browse screen.
Future<void> showFilterSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
      builder: (context) => const FilterSheet(),
    );

/// The filter form. It edits its own DRAFT and hands it over once, on "Show
/// results", so the list does not reload on every slider tick. Closing the sheet
/// any other way (back, swipe down) throws the draft away.
///
/// Every option and bound comes from the facets, so nothing here knows a city, a
/// currency or a price.
class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late ListingFilter _draft = ref.read(listingFilterControllerProvider);

  /// The last picked dates had no nights. Cleared by the next valid pick.
  bool _datesTooShort = false;

  void _edit(ListingFilter draft) => setState(() => _draft = draft);

  void _apply() {
    final canSeeReviews = ref.read(capabilitiesProvider).canSeeReviews;
    // A sort by something the user cannot see is a bug, so it is never applied.
    final filter = !canSeeReviews && _draft.sort.needsReviews
        ? _draft.copyWith(sort: ListingSort.newest)
        : _draft;
    ref.read(listingFilterControllerProvider.notifier).apply(filter);
    Navigator.of(context).pop();
  }

  Future<void> _pickDates() async {
    final l10n = context.l10n;
    final today = LocalDate.today();
    final current = _draft.dates;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: asDateTime(today),
      // The API refuses a stay longer than 366 nights.
      lastDate: asDateTime(
        today.addDays(ListingsRepository.maxAvailabilityDays - 1),
      ),
      initialDateRange: current == null || current.start < today
          ? null
          : DateTimeRange(
              start: asDateTime(current.start),
              end: asDateTime(current.end),
            ),
      helpText: l10n.filterDatesHelp,
      saveText: l10n.filterDatesSave,
      fieldStartLabelText: l10n.filterCheckIn,
      fieldEndLabelText: l10n.filterCheckOut,
    );
    if (!mounted || picked == null) return;

    final range = dateRangeFromPicker(picked);
    setState(() {
      _datesTooShort = range == null;
      if (range != null) _draft = _draft.copyWith(dates: range);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final facets = ref.watch(listingFacetsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.browseFilters,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: _draft.isUnfiltered
                    ? null
                    : () => _edit(_draft.cleared()),
                child: Text(l10n.filterClear),
              ),
            ],
          ),
        ),
        Flexible(
          child: facets.when(
            loading: () => LoadingView(semanticsLabel: l10n.loading),
            error: (error, _) => ErrorView(
              message: error is AppFailure
                  ? failureMessage(error, l10n)
                  : l10n.errorGeneric,
              action: ViewAction(
                label: l10n.retry,
                onPressed: () => ref.invalidate(listingFacetsProvider),
              ),
            ),
            data: _form,
          ),
        ),
      ],
    );
  }

  Widget _form(ListingFacets facets) {
    final l10n = context.l10n;
    final canSeeReviews = ref.watch(
      capabilitiesProvider.select((capabilities) => capabilities.canSeeReviews),
    );
    final scale = PriceScale(min: facets.priceMin, max: facets.priceMax);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Section(title: l10n.filterCity, child: _cities(facets)),
                _Section(
                  title: l10n.filterGuests,
                  child: _GuestStepper(
                    guests: _draft.guests ?? 1,
                    max: facets.maxGuests,
                    onChanged: (count) => _edit(_draft.withGuests(count)),
                  ),
                ),
                if (scale.isAdjustable)
                  _Section(
                    title: l10n.filterPrice,
                    child: _PriceSlider(
                      scale: scale,
                      currency: facets.currency,
                      draft: _draft,
                      onChanged: (start, end) =>
                          _edit(_draft.withPriceIndices(scale, start, end)),
                    ),
                  ),
                _Section(title: l10n.filterDates, child: _dates()),
                _Section(title: l10n.filterSort, child: _sorts(canSeeReviews)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: FilledButton(
            onPressed: _apply,
            child: Text(l10n.filterShowResults),
          ),
        ),
      ],
    );
  }

  Widget _cities(ListingFacets facets) {
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        ChoiceChip(
          label: Text(context.l10n.filterCityAny),
          selected: _draft.city == null,
          onSelected: (_) => _edit(_draft.copyWith(city: null)),
        ),
        for (final city in facets.cities)
          ChoiceChip(
            label: Text(city),
            selected: _draft.city == city,
            onSelected: (_) => _edit(_draft.copyWith(city: city)),
          ),
      ],
    );
  }

  Widget _dates() {
    final l10n = context.l10n;
    final dates = _draft.dates;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDates,
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  dates == null
                      ? l10n.filterDatesAny
                      : stayLabel(context, dates),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (dates != null)
              IconButton(
                tooltip: l10n.filterDatesClear,
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _datesTooShort = false;
                  _draft = _draft.copyWith(dates: null);
                }),
              ),
          ],
        ),
        if (_datesTooShort)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s),
            child: Semantics(
              liveRegion: true,
              child: Text(
                l10n.filterDatesTooShort,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
      ],
    );
  }

  Widget _sorts(bool canSeeReviews) {
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        for (final sort in ListingSort.values)
          if (canSeeReviews || !sort.needsReviews)
            ChoiceChip(
              label: Text(sortLabel(sort, l10n)),
              selected: _draft.sort == sort,
              onSelected: (_) => _edit(_draft.copyWith(sort: sort)),
            ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.s),
          child,
        ],
      ),
    );
  }
}

/// A minus button, the count and a plus button. Each icon carries a semantic
/// label (a tooltip alone is a separate property that screen readers do not
/// always treat as the name), and the buttons stop at 1 and at [max]. The count
/// is a live region, so the new value is spoken after each tap.
class _GuestStepper extends StatelessWidget {
  const _GuestStepper({
    required this.guests,
    required this.max,
    required this.onChanged,
  });

  final int guests;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        IconButton.outlined(
          tooltip: l10n.filterGuestsDecrease,
          icon: Icon(Icons.remove, semanticLabel: l10n.filterGuestsDecrease),
          onPressed: guests > 1 ? () => onChanged(guests - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Semantics(
            liveRegion: true,
            label: l10n.filterGuestsCount(guests),
            excludeSemantics: true,
            child: Text(
              guests.toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        IconButton.outlined(
          tooltip: l10n.filterGuestsIncrease,
          icon: Icon(Icons.add, semanticLabel: l10n.filterGuestsIncrease),
          onPressed: guests < max ? () => onChanged(guests + 1) : null,
        ),
      ],
    );
  }
}

/// The current range as text, and a [RangeSlider] over the positions of [scale].
class _PriceSlider extends StatelessWidget {
  const _PriceSlider({
    required this.scale,
    required this.currency,
    required this.draft,
    required this.onChanged,
  });

  final PriceScale scale;
  final String currency;
  final ListingFilter draft;
  final void Function(int startIndex, int endIndex) onChanged;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    String format(num price) => formatPrice(price, currency, locale);

    final start = scale.indexOf(draft.minPrice ?? scale.min);
    final end = scale.indexOf(draft.maxPrice ?? scale.max);
    final low = format(scale.valueAt(start));
    final high = format(scale.valueAt(end));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.filterPriceRange(low, high),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        RangeSlider(
          min: 0,
          max: scale.divisions.toDouble(),
          divisions: scale.divisions,
          values: RangeValues(start.toDouble(), end.toDouble()),
          labels: RangeLabels(low, high),
          semanticFormatterCallback: (position) =>
              format(scale.valueAt(position.round())),
          onChanged: (values) =>
              onChanged(values.start.round(), values.end.round()),
        ),
      ],
    );
  }
}
