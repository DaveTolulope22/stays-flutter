// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get retry => 'Try again';

  @override
  String get loading => 'Loading';

  @override
  String get errorNetwork =>
      'We couldn\'t reach the server. Please check your connection and try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorRequestFailed =>
      'The request could not be completed. Please try again.';

  @override
  String get errorServer =>
      'Something went wrong on our side. Please try again later.';

  @override
  String get errorTenantSetup =>
      'This app is not set up correctly. Please update the app or contact support.';

  @override
  String get errorBadCredentials =>
      'The email address or password is incorrect.';

  @override
  String get errorUserAlreadyExists =>
      'An account with this email address already exists.';

  @override
  String get errorFieldRequired => 'Please fill in all required fields.';

  @override
  String get errorBadRequest =>
      'That request was not valid. Please check your input and try again.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorForbidden => 'You do not have access to this.';

  @override
  String get errorListingNotFound => 'This listing could not be found.';

  @override
  String get errorNotFound => 'We could not find what you were looking for.';

  @override
  String get errorRangeTooLong =>
      'Please choose a shorter date range (up to one year).';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authRegister => 'Create account';

  @override
  String get authWelcomeTitle => 'Welcome back';

  @override
  String get authWelcomeSubtitle => 'Sign in to continue.';

  @override
  String get authRegisterSubtitle => 'Enter your details to get started.';

  @override
  String get authBackToSignIn => 'Back to sign in';

  @override
  String get authEmail => 'Email address';

  @override
  String get authPassword => 'Password';

  @override
  String get authFirstName => 'First name';

  @override
  String get authLastName => 'Last name';

  @override
  String get authGoToRegister => 'New here? Create an account';

  @override
  String get authGoToSignIn => 'Already have an account? Sign in';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authErrorRequired => 'This field is required.';

  @override
  String get authErrorEmailInvalid => 'Enter a valid email address.';

  @override
  String authErrorPasswordTooShort(int min) {
    return 'Use at least $min characters.';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get hostUnavailable => 'The host area is not available right now.';

  @override
  String get listingNew => 'New';

  @override
  String listingPricePerNight(String price) {
    return '$price / night';
  }

  @override
  String listingRatingLabel(String rating, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$rating ($countString)';
  }

  @override
  String listingRatingSemantics(String rating, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return 'Rated $rating out of 5 from $_temp0';
  }

  @override
  String get listingNewSemantics => 'New listing, no reviews yet';

  @override
  String listingCardSemantics(String title, String city, String price) {
    return '$title, $city, $price';
  }

  @override
  String listingCardSemanticsRated(
    String title,
    String city,
    String price,
    String rating,
  ) {
    return '$title, $city, $price, $rating';
  }

  @override
  String get amenityWifi => 'Wi-Fi';

  @override
  String get amenityKitchen => 'Kitchen';

  @override
  String get amenityParking => 'Parking';

  @override
  String get amenityWasher => 'Washing machine';

  @override
  String get amenityDryer => 'Dryer';

  @override
  String get amenityAirConditioning => 'Air conditioning';

  @override
  String get amenityHeating => 'Heating';

  @override
  String get amenityTv => 'TV';

  @override
  String get amenityPool => 'Pool';

  @override
  String get amenityHotTub => 'Hot tub';

  @override
  String get amenityFireplace => 'Fireplace';

  @override
  String get amenityBalcony => 'Balcony';

  @override
  String get amenitySeaView => 'Sea view';

  @override
  String get amenityMountainView => 'Mountain view';

  @override
  String get amenitySkiStorage => 'Ski storage';

  @override
  String get amenityPetsAllowed => 'Pets allowed';

  @override
  String get amenityWorkspace => 'Workspace';

  @override
  String get amenityElevator => 'Elevator';

  @override
  String get amenityBbq => 'Barbecue';

  @override
  String get amenitySauna => 'Sauna';

  @override
  String get browseTab => 'Browse';

  @override
  String browseResultCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString stays',
      one: '1 stay',
    );
    return '$_temp0';
  }

  @override
  String get browseEmpty => 'There are no stays to show right now.';

  @override
  String get browseEmptyFiltered => 'No stays match your search.';

  @override
  String get browseClearFilters => 'Clear filters';

  @override
  String get browseFilters => 'Filters';

  @override
  String get filterClear => 'Clear';

  @override
  String get filterShowResults => 'Show results';

  @override
  String get filterCity => 'City';

  @override
  String get filterCityAny => 'Any city';

  @override
  String get filterGuests => 'Guests';

  @override
  String get filterGuestsDecrease => 'Fewer guests';

  @override
  String get filterGuestsIncrease => 'More guests';

  @override
  String filterGuestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guests',
      one: '1 guest',
    );
    return '$_temp0';
  }

  @override
  String filterGuestsAtLeast(int count) {
    return '$count+ guests';
  }

  @override
  String get filterPrice => 'Price per night';

  @override
  String filterPriceRange(String min, String max) {
    return '$min – $max';
  }

  @override
  String filterPriceFrom(String price) {
    return 'From $price';
  }

  @override
  String filterPriceUpTo(String price) {
    return 'Up to $price';
  }

  @override
  String get filterDates => 'Dates';

  @override
  String get filterDatesAny => 'Any dates';

  @override
  String filterDatesRange(String start, String end, int nights) {
    String _temp0 = intl.Intl.pluralLogic(
      nights,
      locale: localeName,
      other: '$nights nights',
      one: '1 night',
    );
    return '$start – $end · $_temp0';
  }

  @override
  String get filterDatesClear => 'Clear dates';

  @override
  String get filterDatesHelp => 'Select dates';

  @override
  String get filterDatesSave => 'Done';

  @override
  String get filterCheckIn => 'Check-in';

  @override
  String get filterCheckOut => 'Check-out';

  @override
  String get filterDatesTooShort => 'Check-out must be after check-in.';

  @override
  String get filterSort => 'Sort by';

  @override
  String get filterSortNewest => 'Newest';

  @override
  String get filterSortPriceLowToHigh => 'Price: low to high';

  @override
  String get filterSortPriceHighToLow => 'Price: high to low';

  @override
  String get filterSortRating => 'Top rated';

  @override
  String get filterRemove => 'Remove filter';

  @override
  String get countryAT => 'Austria';

  @override
  String get countryCH => 'Switzerland';

  @override
  String get countryFR => 'France';

  @override
  String get countryIT => 'Italy';

  @override
  String get countryMC => 'Monaco';

  @override
  String detailLocation(String city, String country) {
    return '$city, $country';
  }

  @override
  String detailGuests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guests',
      one: '1 guest',
    );
    return '$_temp0';
  }

  @override
  String detailBedrooms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bedrooms',
      one: '1 bedroom',
      zero: 'Studio',
    );
    return '$_temp0';
  }

  @override
  String detailBeds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count beds',
      one: '1 bed',
    );
    return '$_temp0';
  }

  @override
  String detailBathrooms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bathrooms',
      one: '1 bathroom',
    );
    return '$_temp0';
  }

  @override
  String get detailAbout => 'About this place';

  @override
  String get detailAmenities => 'Amenities';

  @override
  String get detailPrice => 'Price';

  @override
  String detailCleaningFee(String price) {
    return 'Cleaning fee $price, once per stay';
  }

  @override
  String detailPhoto(int index, int total) {
    return 'Photo $index of $total';
  }

  @override
  String get availabilityTitle => 'Availability';

  @override
  String get availabilityPrevious => 'Previous month';

  @override
  String get availabilityNext => 'Next month';

  @override
  String get availabilityLegendAvailable => 'Available';

  @override
  String get availabilityLegendTaken => 'Taken';

  @override
  String get availabilityLegendYourDates => 'Your dates';

  @override
  String availabilityDayAvailable(String date) {
    return '$date, available';
  }

  @override
  String availabilityDayTaken(String date) {
    return '$date, taken';
  }

  @override
  String availabilityDayPast(String date) {
    return '$date, in the past';
  }

  @override
  String availabilityDayInStay(String label) {
    return '$label, in your dates';
  }

  @override
  String get saveListing => 'Save';

  @override
  String get unsaveListing => 'Remove from saved';

  @override
  String get savedTab => 'Saved';

  @override
  String get savedTitle => 'Saved stays';

  @override
  String get savedEmpty =>
      'You haven\'t saved any stays yet. Tap the heart on a stay to keep it here.';

  @override
  String get hostListingsTab => 'My listings';

  @override
  String get hostListingsTitle => 'My listings';

  @override
  String get hostListingsEmpty => 'You don\'t have any listings yet.';

  @override
  String get hostActionEdit => 'Edit';

  @override
  String get hostActionCalendar => 'Calendar';

  @override
  String get hostActionBookings => 'Bookings';

  @override
  String hostActionEditSemantics(String title) {
    return 'Edit $title';
  }

  @override
  String hostActionCalendarSemantics(String title) {
    return 'Calendar of $title';
  }

  @override
  String hostActionBookingsSemantics(String title) {
    return 'Bookings of $title';
  }

  @override
  String get hostEditTitle => 'Edit listing';

  @override
  String get hostEditSave => 'Save';

  @override
  String get hostEditSaved => 'Listing saved';

  @override
  String get hostEditFieldTitle => 'Title';

  @override
  String get hostEditFieldDescription => 'Description';

  @override
  String get hostEditFieldPricePerNight => 'Price per night';

  @override
  String get hostEditFieldCleaningFee => 'Cleaning fee';

  @override
  String get hostEditFieldMaxGuests => 'Guests';

  @override
  String get hostEditFieldBedrooms => 'Bedrooms';

  @override
  String get hostEditFieldBeds => 'Beds';

  @override
  String get hostEditFieldBathrooms => 'Bathrooms';

  @override
  String get hostEditFieldPropertyType => 'Property type';

  @override
  String get hostEditFieldAmenities => 'Amenities';

  @override
  String get hostEditErrorRequired => 'Required';

  @override
  String get hostEditErrorAmount => 'Enter an amount of 0 or more';

  @override
  String get hostEditErrorCount => 'Enter a whole number of 0 or more';

  @override
  String get hostEditErrorGuests => 'Enter a whole number of 1 or more';

  @override
  String get propertyTypeApartment => 'Apartment';

  @override
  String get propertyTypeChalet => 'Chalet';

  @override
  String get propertyTypeVilla => 'Villa';

  @override
  String get propertyTypeStudio => 'Studio';

  @override
  String get propertyTypeLoft => 'Loft';

  @override
  String get propertyTypeCabin => 'Cabin';

  @override
  String get propertyTypeTownhouse => 'Townhouse';

  @override
  String get hostCalendarLegendBooked => 'Booked';

  @override
  String get hostCalendarLegendBlocked => 'Blocked';

  @override
  String get hostCalendarHint =>
      'Tap a free day to block it. Tap a blocked day to open it again.';

  @override
  String get hostCalendarReadOnly =>
      'Blocking days is switched off, so this calendar is view only.';

  @override
  String hostCalendarDayFreeTap(String date) {
    return '$date, available. Tap to block.';
  }

  @override
  String hostCalendarDayBlockedTap(String date) {
    return '$date, blocked. Tap to unblock.';
  }

  @override
  String hostCalendarDayBlocked(String date) {
    return '$date, blocked';
  }

  @override
  String hostCalendarDayBooked(String date) {
    return '$date, booked';
  }

  @override
  String get hostBookingsFilterAll => 'All';

  @override
  String get bookingStatusConfirmed => 'Confirmed';

  @override
  String get bookingStatusPending => 'Pending';

  @override
  String get bookingStatusCompleted => 'Completed';

  @override
  String get bookingStatusCancelled => 'Cancelled';

  @override
  String get bookingStatusUnknown => 'Unknown status';

  @override
  String hostBookingsCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString bookings',
      one: '1 booking',
    );
    return '$_temp0';
  }

  @override
  String get hostBookingsEmpty => 'This listing has no bookings yet.';

  @override
  String get hostBookingsEmptyFiltered => 'No bookings have this status.';

  @override
  String get hostBookingsShowAll => 'Show all bookings';

  @override
  String hostBookingDates(String checkIn, String checkOut) {
    return '$checkIn – $checkOut';
  }

  @override
  String hostBookingNights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nights',
      one: '1 night',
    );
    return '$_temp0';
  }

  @override
  String hostBookingGuests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guests',
      one: '1 guest',
    );
    return '$_temp0';
  }
}
