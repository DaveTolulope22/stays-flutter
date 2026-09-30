import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

import '../state/listing_facets_provider.dart';
import '../state/listing_filter_controller.dart';
import 'filter_labels.dart';

/// One chip per applied filter, each with a delete button, and "Clear filters".
/// It is empty (takes no space) when nothing is applied. It scrolls sideways
/// instead of wrapping, so a long German label cannot push the list down.
class ActiveFilterChips extends ConsumerWidget {
  const ActiveFilterChips({required this.filter, super.key});

  final ListingFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (filter.isUnfiltered) return const SizedBox.shrink();

    final l10n = context.l10n;
    final controller = ref.read(listingFilterControllerProvider.notifier);
    // A price chip needs the currency, which only the facets know. A price can
    // only have been chosen from the facets, so they are there; if they ever
    // were not, the count and "Clear filters" still cover that filter.
    final currency = ref.watch(listingFacetsProvider).value?.currency;

    Widget chip(String label, ListingFilter without) => InputChip(
      label: Text(label),
      onDeleted: () => controller.apply(without),
      deleteButtonTooltipMessage: l10n.filterRemove,
    );

    final dates = filter.dates;
    final chips = [
      if (filter.city case final city?) chip(city, filter.copyWith(city: null)),
      if (filter.guests case final guests?)
        chip(l10n.filterGuestsAtLeast(guests), filter.copyWith(guests: null)),
      if ((filter.minPrice != null || filter.maxPrice != null) &&
          currency != null)
        chip(
          priceLabel(
            min: filter.minPrice,
            max: filter.maxPrice,
            currency: currency,
            context: context,
          ),
          filter.copyWith(minPrice: null, maxPrice: null),
        ),
      if (dates != null)
        chip(stayLabel(context, dates), filter.copyWith(dates: null)),
    ];

    // "Clear filters" is pinned outside the scrolling chips, so it is always
    // in reach however many chips there are.
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                for (final chip in chips)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s),
                    child: chip,
                  ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: controller.clear,
          child: Text(l10n.browseClearFilters),
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}
