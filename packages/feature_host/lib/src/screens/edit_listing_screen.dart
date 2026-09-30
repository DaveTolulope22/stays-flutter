import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

import '../edit/listing_draft.dart';
import '../edit/property_type.dart';
import '../state/host_listings.dart';
import '../state/listing_saver.dart';

/// The form for one of the host's listings: the editable fields only (city and
/// address are read-only), validated as the host types, and saved as a PATCH of
/// just what changed.
///
/// The listing comes from the host's list, which is still open underneath. A
/// listing that is not in it (a deep link, a list that has not loaded) is
/// reported as not found rather than fetched.
class EditListingScreen extends ConsumerWidget {
  const EditListingScreen({required this.listingId, super.key});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(
      hostListingsProvider.select(
        (listings) =>
            listings.value?.items.where((l) => l.id == listingId).firstOrNull,
      ),
    );
    if (listing == null) {
      final l10n = context.l10n;
      return Scaffold(
        appBar: AppBar(title: Text(l10n.hostEditTitle)),
        body: ErrorView(message: l10n.errorListingNotFound),
      );
    }
    return _EditForm(listing: listing);
  }
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({required this.listing});

  final Listing listing;

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  final _formKey = GlobalKey<FormState>();

  // Created once, in didChangeDependencies, because seeding a price needs the
  // locale and a widget cannot read it in initState.
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _cleaningFee;
  late final TextEditingController _maxGuests;
  late final TextEditingController _bedrooms;
  late final TextEditingController _beds;
  late final TextEditingController _bathrooms;
  late String _propertyType;
  late List<String> _amenities;
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    final listing = widget.listing;
    final locale = Localizations.localeOf(context).toString();
    _title = TextEditingController(text: listing.title);
    _description = TextEditingController(text: listing.description);
    _price = TextEditingController(
      text: amountToInput(listing.pricePerNight, locale),
    );
    _cleaningFee = TextEditingController(
      text: amountToInput(listing.cleaningFee, locale),
    );
    _maxGuests = TextEditingController(text: listing.maxGuests.toString());
    _bedrooms = TextEditingController(text: listing.bedrooms.toString());
    _beds = TextEditingController(text: listing.beds.toString());
    _bathrooms = TextEditingController(text: listing.bathrooms.toString());
    _propertyType = listing.propertyType;
    _amenities = [...listing.amenities];
  }

  @override
  void dispose() {
    if (_seeded) {
      for (final controller in [
        _title,
        _description,
        _price,
        _cleaningFee,
        _maxGuests,
        _bedrooms,
        _beds,
        _bathrooms,
      ]) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  /// What the form says, or null while any field is not valid.
  ListingDraft? _tryDraft() {
    final price = parseAmount(_price.text);
    final cleaningFee = parseAmount(_cleaningFee.text);
    final maxGuests = parseCount(_maxGuests.text);
    final bedrooms = parseCount(_bedrooms.text);
    final beds = parseCount(_beds.text);
    final bathrooms = parseCount(_bathrooms.text);
    if (_title.text.trim().isEmpty ||
        _description.text.trim().isEmpty ||
        price == null ||
        cleaningFee == null ||
        maxGuests == null ||
        maxGuests < 1 ||
        bedrooms == null ||
        beds == null ||
        bathrooms == null) {
      return null;
    }
    return ListingDraft(
      title: _title.text,
      description: _description.text,
      pricePerNight: price,
      cleaningFee: cleaningFee,
      maxGuests: maxGuests,
      bedrooms: bedrooms,
      beds: beds,
      bathrooms: bathrooms,
      propertyType: _propertyType,
      amenities: _amenities,
    );
  }

  /// Saving is offered once something changed. While a field is invalid it stays
  /// offered, so pressing it shows what is wrong instead of doing nothing.
  bool get _canSave {
    final draft = _tryDraft();
    return draft == null || !buildListingPatch(widget.listing, draft).isEmpty;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final draft = _tryDraft();
    if (draft == null) return;
    final patch = buildListingPatch(widget.listing, draft);
    if (patch.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    final savedMessage = context.l10n.hostEditSaved;
    final saved = await ref
        .read(listingSaverProvider.notifier)
        .save(widget.listing.id, patch);
    if (!mounted) return;
    if (saved.isSome()) {
      messenger.showSnackBar(SnackBar(content: Text(savedMessage)));
      context.pop();
    }
  }

  void _toggleAmenity(String slug, {required bool selected}) => setState(() {
    if (selected) {
      _amenities = [..._amenities, slug];
    } else {
      _amenities = [
        for (final amenity in _amenities)
          if (amenity != slug) amenity,
      ];
    }
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final listing = widget.listing;
    final saveState = ref.watch(listingSaverProvider);
    final saving = saveState.isLoading;
    final error = saveState.error;

    String? required(String? value) =>
        (value ?? '').trim().isEmpty ? l10n.hostEditErrorRequired : null;
    String? amount(String? value) =>
        parseAmount(value ?? '') == null ? l10n.hostEditErrorAmount : null;
    String? count(String? value) =>
        parseCount(value ?? '') == null ? l10n.hostEditErrorCount : null;
    String? guests(String? value) {
      final parsed = parseCount(value ?? '');
      return parsed == null || parsed < 1 ? l10n.hostEditErrorGuests : null;
    }

    // What the host can pick: everything we can label, plus anything this
    // listing already has that we cannot, so it stays visible and removable.
    final amenityChoices = [
      ...knownAmenitySlugs,
      for (final slug in listing.amenities)
        if (!knownAmenitySlugs.contains(slug)) slug,
    ];
    final typeChoices = [
      ...propertyTypes,
      if (!propertyTypes.contains(_propertyType)) _propertyType,
    ];

    Widget pair(Widget first, Widget second) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: AppSpacing.m),
        Expanded(child: second),
      ],
    );

    Widget number(
      TextEditingController controller,
      String label,
      String? Function(String?) validator, {
      bool decimal = false,
      String? suffix,
    }) => TextFormField(
      controller: controller,
      enabled: !saving,
      validator: validator,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: decimal
          ? null
          : [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label, suffixText: suffix),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.hostEditTitle)),
      body: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.maxContentWidth,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    // Any edit: the Save button may need to switch on or off.
                    onChanged: () => setState(() {}),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (error != null) ...[
                          _FailureBanner(
                            message: error is AppFailure
                                ? failureMessage(error, l10n)
                                : l10n.errorGeneric,
                          ),
                          const SizedBox(height: AppSpacing.m),
                        ],
                        TextFormField(
                          controller: _title,
                          enabled: !saving,
                          validator: required,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: l10n.hostEditFieldTitle,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        TextFormField(
                          controller: _description,
                          enabled: !saving,
                          validator: required,
                          minLines: 3,
                          maxLines: 8,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: l10n.hostEditFieldDescription,
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        pair(
                          number(
                            _price,
                            l10n.hostEditFieldPricePerNight,
                            amount,
                            decimal: true,
                            suffix: listing.currency,
                          ),
                          number(
                            _cleaningFee,
                            l10n.hostEditFieldCleaningFee,
                            amount,
                            decimal: true,
                            suffix: listing.currency,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        pair(
                          number(
                            _maxGuests,
                            l10n.hostEditFieldMaxGuests,
                            guests,
                          ),
                          number(_bedrooms, l10n.hostEditFieldBedrooms, count),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        pair(
                          number(_beds, l10n.hostEditFieldBeds, count),
                          number(
                            _bathrooms,
                            l10n.hostEditFieldBathrooms,
                            count,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        DropdownButtonFormField<String>(
                          initialValue: _propertyType,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: l10n.hostEditFieldPropertyType,
                          ),
                          items: [
                            for (final type in typeChoices)
                              DropdownMenuItem(
                                value: type,
                                child: Text(propertyTypeLabel(type, l10n)),
                              ),
                          ],
                          onChanged: saving
                              ? null
                              : (type) {
                                  if (type != null) {
                                    setState(() => _propertyType = type);
                                  }
                                },
                        ),
                        const SizedBox(height: AppSpacing.l),
                        Text(
                          l10n.hostEditFieldAmenities,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Wrap(
                          spacing: AppSpacing.s,
                          runSpacing: AppSpacing.s,
                          children: [
                            for (final slug in amenityChoices)
                              FilterChip(
                                avatar: Icon(
                                  amenityIcon(slug),
                                  size: AppSizes.iconS,
                                ),
                                label: Text(amenityLabel(slug, l10n)),
                                selected: _amenities.contains(slug),
                                onSelected: saving
                                    ? null
                                    : (selected) => _toggleAmenity(
                                        slug,
                                        selected: selected,
                                      ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _SaveBar(
            saving: saving,
            savingLabel: l10n.loading,
            label: l10n.hostEditSave,
            onPressed: saving || !_canSave ? null : _save,
          ),
        ],
      ),
    );
  }
}

/// The one message for a failed save, above the form. An icon AND words, so it
/// never depends on colour alone, and a live region so a screen reader says it
/// when it appears.
class _FailureBanner extends StatelessWidget {
  const _FailureBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: AppRadius.mediumAll,
          border: Border.all(color: colors.borderPrimary),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              const Icon(Icons.error_outline),
              const SizedBox(width: AppSpacing.s),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Save, pinned under the scrolling form so it is always in reach.
class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.saving,
    required this.savingLabel,
    required this.label,
    required this.onPressed,
  });

  final bool saving;
  final String savingLabel;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfacePrimary,
        border: Border(top: BorderSide(color: context.colors.borderPrimary)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppSizes.minTapTarget),
                ),
                onPressed: onPressed,
                child: saving
                    ? SizedBox(
                        width: AppSizes.iconM,
                        height: AppSizes.iconM,
                        child: CircularProgressIndicator(
                          semanticsLabel: savingLabel,
                        ),
                      )
                    : Text(label),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
