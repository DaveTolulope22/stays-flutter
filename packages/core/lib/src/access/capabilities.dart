import 'package:freezed_annotation/freezed_annotation.dart';

import '../session/session.dart';
import '../session/user.dart';
import '../tenant/tenant_flags.dart';

part 'capabilities.freezed.dart';

/// Which side of the app someone belongs to. It follows the account, not the
/// tenant's flags: a host whose tenant has the host panel switched off still
/// belongs to [host] (and sees a "not available" screen), never to [guest].
enum AccessArea {
  /// Not signed in. Nothing is reachable except sign-in and registration.
  none,

  /// A client: browse, open, filter, save.
  guest,

  /// A host: only the host area. No browsing, no favourites.
  host,
}

/// What the current user may do, computed once from who they are and what this
/// tenant offers. Screens and the router ask this; nothing checks a role
/// directly. Every value defaults to "no".
@freezed
abstract class Capabilities with _$Capabilities {
  const Capabilities._();

  const factory Capabilities({
    @Default(AccessArea.none) AccessArea area,
    @Default(false) bool canSaveListings,
    @Default(false) bool canSeeReviews,
    @Default(false) bool canUseHostPanel,
    @Default(false) bool canBlockDays,
  }) = _Capabilities;

  /// Signed out: nothing.
  static const none = Capabilities();

  /// The guest side: searching, opening and filtering listings.
  bool get canBrowse => area == AccessArea.guest;
}

/// Turns identity and tenant flags into permissions. Pure: no providers, no
/// I/O, so the whole matrix is one table test.
///
/// Role decides WHO may use something, flags decide whether it EXISTS in this
/// tenant. A capability that depends on both needs both.
Capabilities resolveCapabilities(Session? session, TenantFlags flags) {
  if (session == null) return Capabilities.none;

  return switch (session.user.role) {
    UserRole.client => Capabilities(
      area: AccessArea.guest,
      canSaveListings: flags.favourites,
      canSeeReviews: flags.reviews,
    ),
    UserRole.host => Capabilities(
      area: AccessArea.host,
      canSeeReviews: flags.reviews,
      canUseHostPanel: flags.hostPanel,
      // The calendar lives inside the host area, so it needs the panel too.
      canBlockDays: flags.hostPanel && flags.blockedDays,
    ),
  };
}
