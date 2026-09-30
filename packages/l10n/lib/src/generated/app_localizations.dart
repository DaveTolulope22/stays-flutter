import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// Button that repeats a failed action, such as loading the app or a list.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// Accessibility label for a loading indicator.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// Shown when a request got no response: offline, timeout or refused connection.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t reach the server. Please check your connection and try again.'**
  String get errorNetwork;

  /// Final fallback for any failure that has no more specific message.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Fallback for a rejected request (4xx) whose messageCode we do not know.
  ///
  /// In en, this message translates to:
  /// **'The request could not be completed. Please try again.'**
  String get errorRequestFailed;

  /// Server errors (5xx), including error.internalServerError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Please try again later.'**
  String get errorServer;

  /// error.tenantRequired and error.tenantUnknown: the build's tenant was not accepted.
  ///
  /// In en, this message translates to:
  /// **'This app is not set up correctly. Please update the app or contact support.'**
  String get errorTenantSetup;

  /// error.badCredentials: shown on the sign-in screen after a wrong login.
  ///
  /// In en, this message translates to:
  /// **'The email address or password is incorrect.'**
  String get errorBadCredentials;

  /// error.userAlreadyExist: registering with an email that is taken.
  ///
  /// In en, this message translates to:
  /// **'An account with this email address already exists.'**
  String get errorUserAlreadyExists;

  /// error.fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get errorFieldRequired;

  /// error.badRequest.
  ///
  /// In en, this message translates to:
  /// **'That request was not valid. Please check your input and try again.'**
  String get errorBadRequest;

  /// auth.token.invalid.UnauthorizedException and any other 401.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorSessionExpired;

  /// auth.forbidden.ForbiddenException and any other 403.
  ///
  /// In en, this message translates to:
  /// **'You do not have access to this.'**
  String get errorForbidden;

  /// listing.NotFoundException.
  ///
  /// In en, this message translates to:
  /// **'This listing could not be found.'**
  String get errorListingNotFound;

  /// route.NotFoundException and any other 404.
  ///
  /// In en, this message translates to:
  /// **'We could not find what you were looking for.'**
  String get errorNotFound;

  /// error.rangeTooLong: a date search or availability window over 366 days.
  ///
  /// In en, this message translates to:
  /// **'Please choose a shorter date range (up to one year).'**
  String get errorRangeTooLong;

  /// Sign-in screen title and its submit button.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// Registration screen title and its submit button.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegister;

  /// Label of the email field.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get authEmail;

  /// Label of the password field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// Label of the first name field on the registration form.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get authFirstName;

  /// Label of the last name field on the registration form.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get authLastName;

  /// Link on the sign-in screen that opens registration.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get authGoToRegister;

  /// Link on the registration screen that opens sign-in.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authGoToSignIn;

  /// Tooltip and accessibility label of the button that reveals the password.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// Tooltip and accessibility label of the button that hides the password.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// Inline error for an empty required field.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get authErrorRequired;

  /// Inline error for an email that is not shaped like one.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authErrorEmailInvalid;

  /// Inline error for a password shorter than the minimum.
  ///
  /// In en, this message translates to:
  /// **'Use at least {min} characters.'**
  String authErrorPasswordTooShort(int min);

  /// Line above the terms and privacy links on the registration screen.
  ///
  /// In en, this message translates to:
  /// **'By creating an account you agree to:'**
  String get authTermsIntro;

  /// Link to the tenant's terms of use.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get authTermsOfUse;

  /// Link to the tenant's privacy policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get authPrivacyPolicy;

  /// Button that ends the session.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Shown to a host whose tenant has the host panel switched off.
  ///
  /// In en, this message translates to:
  /// **'The host area is not available right now.'**
  String get hostUnavailable;

  /// Message shown when the terms or privacy page cannot be opened.
  ///
  /// In en, this message translates to:
  /// **'The link could not be opened.'**
  String get authLinkOpenFailed;

  /// Badge on a listing that has no reviews yet (instead of a zero rating).
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get listingNew;

  /// Price line of a listing. The price is already formatted with the listing's currency.
  ///
  /// In en, this message translates to:
  /// **'{price} / night'**
  String listingPricePerNight(String price);

  /// Visible rating badge: the score to one decimal and the number of reviews.
  ///
  /// In en, this message translates to:
  /// **'{rating} ({count})'**
  String listingRatingLabel(String rating, int count);

  /// Screen reader text for the rating badge.
  ///
  /// In en, this message translates to:
  /// **'Rated {rating} out of 5 from {count, plural, one{1 review} other{{count} reviews}}'**
  String listingRatingSemantics(String rating, int count);

  /// Screen reader text for the New badge.
  ///
  /// In en, this message translates to:
  /// **'New listing, no reviews yet'**
  String get listingNewSemantics;

  /// Screen reader text for a listing card without a rating.
  ///
  /// In en, this message translates to:
  /// **'{title}, {city}, {price}'**
  String listingCardSemantics(String title, String city, String price);

  /// Screen reader text for a listing card whose rating is visible. The rating is the rating's own screen reader text.
  ///
  /// In en, this message translates to:
  /// **'{title}, {city}, {price}, {rating}'**
  String listingCardSemanticsRated(
    String title,
    String city,
    String price,
    String rating,
  );

  /// Amenity label: wifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get amenityWifi;

  /// Amenity label: kitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get amenityKitchen;

  /// Amenity label: parking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get amenityParking;

  /// Amenity label: washer.
  ///
  /// In en, this message translates to:
  /// **'Washing machine'**
  String get amenityWasher;

  /// Amenity label: dryer.
  ///
  /// In en, this message translates to:
  /// **'Dryer'**
  String get amenityDryer;

  /// Amenity label: air_conditioning.
  ///
  /// In en, this message translates to:
  /// **'Air conditioning'**
  String get amenityAirConditioning;

  /// Amenity label: heating.
  ///
  /// In en, this message translates to:
  /// **'Heating'**
  String get amenityHeating;

  /// Amenity label: tv.
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get amenityTv;

  /// Amenity label: pool.
  ///
  /// In en, this message translates to:
  /// **'Pool'**
  String get amenityPool;

  /// Amenity label: hot_tub.
  ///
  /// In en, this message translates to:
  /// **'Hot tub'**
  String get amenityHotTub;

  /// Amenity label: fireplace.
  ///
  /// In en, this message translates to:
  /// **'Fireplace'**
  String get amenityFireplace;

  /// Amenity label: balcony.
  ///
  /// In en, this message translates to:
  /// **'Balcony'**
  String get amenityBalcony;

  /// Amenity label: sea_view.
  ///
  /// In en, this message translates to:
  /// **'Sea view'**
  String get amenitySeaView;

  /// Amenity label: mountain_view.
  ///
  /// In en, this message translates to:
  /// **'Mountain view'**
  String get amenityMountainView;

  /// Amenity label: ski_storage.
  ///
  /// In en, this message translates to:
  /// **'Ski storage'**
  String get amenitySkiStorage;

  /// Amenity label: pets_allowed.
  ///
  /// In en, this message translates to:
  /// **'Pets allowed'**
  String get amenityPetsAllowed;

  /// Amenity label: workspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get amenityWorkspace;

  /// Amenity label: elevator.
  ///
  /// In en, this message translates to:
  /// **'Elevator'**
  String get amenityElevator;

  /// Amenity label: bbq.
  ///
  /// In en, this message translates to:
  /// **'Barbecue'**
  String get amenityBbq;

  /// Amenity label: sauna.
  ///
  /// In en, this message translates to:
  /// **'Sauna'**
  String get amenitySauna;

  /// Label of the guest's browse tab.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browseTab;

  /// Number of listings matching the current filters, shown above the list.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 stay} other{{count} stays}}'**
  String browseResultCount(int count);

  /// The list is empty and no filter is applied.
  ///
  /// In en, this message translates to:
  /// **'There are no stays to show right now.'**
  String get browseEmpty;

  /// The list is empty because of the applied filters.
  ///
  /// In en, this message translates to:
  /// **'No stays match your search.'**
  String get browseEmptyFiltered;

  /// Button that removes every applied filter.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get browseClearFilters;

  /// Tooltip and accessibility label of the button that opens the filter sheet, and the sheet's title.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get browseFilters;

  /// Button in the filter sheet that resets the choices made so far.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get filterClear;

  /// Button in the filter sheet that applies the choices and closes it.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get filterShowResults;

  /// Heading of the city choice in the filter sheet.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get filterCity;

  /// City choice that applies no city filter.
  ///
  /// In en, this message translates to:
  /// **'Any city'**
  String get filterCityAny;

  /// Heading of the guest count in the filter sheet.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get filterGuests;

  /// Tooltip and accessibility label of the minus button of the guest stepper.
  ///
  /// In en, this message translates to:
  /// **'Fewer guests'**
  String get filterGuestsDecrease;

  /// Tooltip and accessibility label of the plus button of the guest stepper.
  ///
  /// In en, this message translates to:
  /// **'More guests'**
  String get filterGuestsIncrease;

  /// Accessibility label of the current value of the guest stepper.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 guest} other{{count} guests}}'**
  String filterGuestsCount(int count);

  /// Active-filter chip: listings that sleep at least this many guests.
  ///
  /// In en, this message translates to:
  /// **'{count}+ guests'**
  String filterGuestsAtLeast(int count);

  /// Heading of the price range in the filter sheet.
  ///
  /// In en, this message translates to:
  /// **'Price per night'**
  String get filterPrice;

  /// A price range. Both prices are already formatted with the currency.
  ///
  /// In en, this message translates to:
  /// **'{min} – {max}'**
  String filterPriceRange(String min, String max);

  /// Active-filter chip when only a lowest price is set.
  ///
  /// In en, this message translates to:
  /// **'From {price}'**
  String filterPriceFrom(String price);

  /// Active-filter chip when only a highest price is set.
  ///
  /// In en, this message translates to:
  /// **'Up to {price}'**
  String filterPriceUpTo(String price);

  /// Heading of the date range in the filter sheet.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get filterDates;

  /// Date button label when no dates are chosen.
  ///
  /// In en, this message translates to:
  /// **'Any dates'**
  String get filterDatesAny;

  /// The chosen stay: first night, check-out day and the number of nights.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end} · {nights, plural, one{1 night} other{{nights} nights}}'**
  String filterDatesRange(String start, String end, int nights);

  /// Tooltip and accessibility label of the button that removes the chosen dates.
  ///
  /// In en, this message translates to:
  /// **'Clear dates'**
  String get filterDatesClear;

  /// Title of the date range picker.
  ///
  /// In en, this message translates to:
  /// **'Select dates'**
  String get filterDatesHelp;

  /// Confirm button of the date range picker.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get filterDatesSave;

  /// Label of the start date field in the date range picker.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get filterCheckIn;

  /// Label of the end date field in the date range picker.
  ///
  /// In en, this message translates to:
  /// **'Check-out'**
  String get filterCheckOut;

  /// Shown when the chosen dates have zero nights.
  ///
  /// In en, this message translates to:
  /// **'Check-out must be after check-in.'**
  String get filterDatesTooShort;

  /// Heading of the sort choice in the filter sheet.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get filterSort;

  /// Sort option.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get filterSortNewest;

  /// Sort option.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get filterSortPriceLowToHigh;

  /// Sort option.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get filterSortPriceHighToLow;

  /// Sort option, offered only when reviews are visible.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get filterSortRating;

  /// Tooltip and accessibility label of the delete button on an active-filter chip.
  ///
  /// In en, this message translates to:
  /// **'Remove filter'**
  String get filterRemove;

  /// Country name for the code AT.
  ///
  /// In en, this message translates to:
  /// **'Austria'**
  String get countryAT;

  /// Country name for the code CH.
  ///
  /// In en, this message translates to:
  /// **'Switzerland'**
  String get countryCH;

  /// Country name for the code FR.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get countryFR;

  /// Country name for the code IT.
  ///
  /// In en, this message translates to:
  /// **'Italy'**
  String get countryIT;

  /// Country name for the code MC.
  ///
  /// In en, this message translates to:
  /// **'Monaco'**
  String get countryMC;

  /// Where a listing is: the city and the country name (or the raw country code when we have no name for it).
  ///
  /// In en, this message translates to:
  /// **'{city}, {country}'**
  String detailLocation(String city, String country);

  /// How many guests a listing sleeps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 guest} other{{count} guests}}'**
  String detailGuests(int count);

  /// Number of bedrooms. Zero means a studio.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Studio} one{1 bedroom} other{{count} bedrooms}}'**
  String detailBedrooms(int count);

  /// Number of beds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 bed} other{{count} beds}}'**
  String detailBeds(int count);

  /// Number of bathrooms.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 bathroom} other{{count} bathrooms}}'**
  String detailBathrooms(int count);

  /// Heading above a listing's description.
  ///
  /// In en, this message translates to:
  /// **'About this place'**
  String get detailAbout;

  /// Heading above a listing's amenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get detailAmenities;

  /// Heading above a listing's price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get detailPrice;

  /// The one-off cleaning fee. Shown only when it is not zero.
  ///
  /// In en, this message translates to:
  /// **'Cleaning fee {price}, once per stay'**
  String detailCleaningFee(String price);

  /// Screen reader label of one photo in a listing's photo pager.
  ///
  /// In en, this message translates to:
  /// **'Photo {index} of {total}'**
  String detailPhoto(int index, int total);

  /// Heading of the availability calendar on a listing.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availabilityTitle;

  /// Tooltip and accessibility label of the button that shows the previous month.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get availabilityPrevious;

  /// Tooltip and accessibility label of the button that shows the next month.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get availabilityNext;

  /// Legend entry for a day that is free.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availabilityLegendAvailable;

  /// Legend entry for a day that is booked or blocked. A guest is not told which.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get availabilityLegendTaken;

  /// Legend entry for the nights of the stay the guest searched for.
  ///
  /// In en, this message translates to:
  /// **'Your dates'**
  String get availabilityLegendYourDates;

  /// Screen reader label of a free day in the calendar.
  ///
  /// In en, this message translates to:
  /// **'{date}, available'**
  String availabilityDayAvailable(String date);

  /// Screen reader label of a taken day in the calendar.
  ///
  /// In en, this message translates to:
  /// **'{date}, taken'**
  String availabilityDayTaken(String date);

  /// Screen reader label of a day that has already gone.
  ///
  /// In en, this message translates to:
  /// **'{date}, in the past'**
  String availabilityDayPast(String date);

  /// Added to a day's screen reader label when it is one of the searched nights.
  ///
  /// In en, this message translates to:
  /// **'{label}, in your dates'**
  String availabilityDayInStay(String label);

  /// Tooltip and accessibility label of the heart that saves a listing.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveListing;

  /// Tooltip and accessibility label of the heart on a listing that is already saved.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get unsaveListing;

  /// Label of the guest's saved-listings tab.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedTab;

  /// Title of the screen that lists the guest's saved listings.
  ///
  /// In en, this message translates to:
  /// **'Saved stays'**
  String get savedTitle;

  /// Shown on the saved screen when nothing is saved.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t saved any stays yet. Tap the heart on a stay to keep it here.'**
  String get savedEmpty;

  /// Label of the host's listings tab.
  ///
  /// In en, this message translates to:
  /// **'My listings'**
  String get hostListingsTab;

  /// Title of the screen that lists the host's own listings.
  ///
  /// In en, this message translates to:
  /// **'My listings'**
  String get hostListingsTitle;

  /// Shown on the host's listings screen when the host has none.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any listings yet.'**
  String get hostListingsEmpty;

  /// Button on a host's listing that opens the edit form.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get hostActionEdit;

  /// Button on a host's listing that opens its availability calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get hostActionCalendar;

  /// Button on a host's listing that opens its bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get hostActionBookings;

  /// Screen reader text for the edit button on one listing, so each button says which listing it is for.
  ///
  /// In en, this message translates to:
  /// **'Edit {title}'**
  String hostActionEditSemantics(String title);

  /// Screen reader text for the calendar button on one listing.
  ///
  /// In en, this message translates to:
  /// **'Calendar of {title}'**
  String hostActionCalendarSemantics(String title);

  /// Screen reader text for the bookings button on one listing.
  ///
  /// In en, this message translates to:
  /// **'Bookings of {title}'**
  String hostActionBookingsSemantics(String title);

  /// Title of the screen where a host edits one of their listings.
  ///
  /// In en, this message translates to:
  /// **'Edit listing'**
  String get hostEditTitle;

  /// Button that saves the changes to a listing.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get hostEditSave;

  /// Confirmation shown after a listing was saved.
  ///
  /// In en, this message translates to:
  /// **'Listing saved'**
  String get hostEditSaved;

  /// Label of the listing title field.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get hostEditFieldTitle;

  /// Label of the listing description field.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get hostEditFieldDescription;

  /// Label of the price per night field.
  ///
  /// In en, this message translates to:
  /// **'Price per night'**
  String get hostEditFieldPricePerNight;

  /// Label of the cleaning fee field. The fee is charged once per stay.
  ///
  /// In en, this message translates to:
  /// **'Cleaning fee'**
  String get hostEditFieldCleaningFee;

  /// Label of the field for how many guests the listing sleeps.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get hostEditFieldMaxGuests;

  /// Label of the bedrooms field.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get hostEditFieldBedrooms;

  /// Label of the beds field.
  ///
  /// In en, this message translates to:
  /// **'Beds'**
  String get hostEditFieldBeds;

  /// Label of the bathrooms field.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get hostEditFieldBathrooms;

  /// Label of the property type dropdown.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get hostEditFieldPropertyType;

  /// Heading of the amenity chips on the edit form.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get hostEditFieldAmenities;

  /// Shown under a text field that was left empty.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get hostEditErrorRequired;

  /// Shown under a price field that does not hold a valid amount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount of 0 or more'**
  String get hostEditErrorAmount;

  /// Shown under a count field (bedrooms, beds, bathrooms) that does not hold a whole number.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number of 0 or more'**
  String get hostEditErrorCount;

  /// Shown under the guests field when it is not a whole number of at least one.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number of 1 or more'**
  String get hostEditErrorGuests;

  /// Property type: apartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get propertyTypeApartment;

  /// Property type: chalet.
  ///
  /// In en, this message translates to:
  /// **'Chalet'**
  String get propertyTypeChalet;

  /// Property type: villa.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get propertyTypeVilla;

  /// Property type: studio.
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get propertyTypeStudio;

  /// Property type: loft.
  ///
  /// In en, this message translates to:
  /// **'Loft'**
  String get propertyTypeLoft;

  /// Property type: cabin.
  ///
  /// In en, this message translates to:
  /// **'Cabin'**
  String get propertyTypeCabin;

  /// Property type: townhouse.
  ///
  /// In en, this message translates to:
  /// **'Townhouse'**
  String get propertyTypeTownhouse;

  /// Legend entry on the host's calendar for a day a guest has booked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get hostCalendarLegendBooked;

  /// Legend entry on the host's calendar for a day the host closed by hand.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get hostCalendarLegendBlocked;

  /// Instruction under the host's calendar when blocking days is available.
  ///
  /// In en, this message translates to:
  /// **'Tap a free day to block it. Tap a blocked day to open it again.'**
  String get hostCalendarHint;

  /// Shown on the host's calendar when the tenant has turned blocking days off.
  ///
  /// In en, this message translates to:
  /// **'Blocking days is switched off, so this calendar is view only.'**
  String get hostCalendarReadOnly;

  /// Screen reader label of a free day the host can block.
  ///
  /// In en, this message translates to:
  /// **'{date}, available. Tap to block.'**
  String hostCalendarDayFreeTap(String date);

  /// Screen reader label of a day the host blocked and can open again.
  ///
  /// In en, this message translates to:
  /// **'{date}, blocked. Tap to unblock.'**
  String hostCalendarDayBlockedTap(String date);

  /// Screen reader label of a blocked day on a view-only calendar.
  ///
  /// In en, this message translates to:
  /// **'{date}, blocked'**
  String hostCalendarDayBlocked(String date);

  /// Screen reader label of a day a guest has booked. It cannot be blocked.
  ///
  /// In en, this message translates to:
  /// **'{date}, booked'**
  String hostCalendarDayBooked(String date);

  /// Status filter chip that shows bookings of every status.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get hostBookingsFilterAll;

  /// Booking status: upcoming and paid for.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get bookingStatusConfirmed;

  /// Booking status: upcoming, not yet confirmed.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get bookingStatusPending;

  /// Booking status: the stay is in the past.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bookingStatusCompleted;

  /// Booking status: called off.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bookingStatusCancelled;

  /// Shown for a booking status this app does not know, so one new value on the API does not break the list.
  ///
  /// In en, this message translates to:
  /// **'Unknown status'**
  String get bookingStatusUnknown;

  /// Number of bookings matching the status filter, shown above the list.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 booking} other{{count} bookings}}'**
  String hostBookingsCount(int count);

  /// Shown on the bookings screen when a listing has no bookings at all.
  ///
  /// In en, this message translates to:
  /// **'This listing has no bookings yet.'**
  String get hostBookingsEmpty;

  /// Shown on the bookings screen when the chosen status filter matches nothing.
  ///
  /// In en, this message translates to:
  /// **'No bookings have this status.'**
  String get hostBookingsEmptyFiltered;

  /// Button on the empty filtered bookings list that clears the status filter.
  ///
  /// In en, this message translates to:
  /// **'Show all bookings'**
  String get hostBookingsShowAll;

  /// A booking's stay: check-in date to check-out date.
  ///
  /// In en, this message translates to:
  /// **'{checkIn} – {checkOut}'**
  String hostBookingDates(String checkIn, String checkOut);

  /// How many nights a booking lasts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 night} other{{count} nights}}'**
  String hostBookingNights(int count);

  /// How many guests a booking is for.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 guest} other{{count} guests}}'**
  String hostBookingGuests(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
