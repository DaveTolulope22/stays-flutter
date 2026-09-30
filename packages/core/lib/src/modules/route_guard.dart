import '../access/capabilities.dart';
import 'feature_module.dart';

/// Where to send someone who may not be where they are: the front page of the
/// first module, in registration order, that they may enter. Null if there is
/// none.
String? homeLocation(
  Iterable<FeatureModule> modules,
  Capabilities capabilities,
) {
  for (final module in modules) {
    if (module.isAllowedFor(capabilities)) return module.initialLocation;
  }
  return null;
}

/// The whole access rule, for the router's `redirect`. Returns a location to
/// go to instead, or null to stay.
///
/// - A location owned by a module the user may enter: stay.
/// - A location owned by a module they may not enter (a client at a host
///   route, a signed-in user at sign-in, a signed-out user anywhere inside):
///   go to their home. This is decided here, on the device, before any screen
///   builds; the API's 403 is never part of it.
/// - A location no module owns (`/`, a mistyped deep link): go to their home.
///
/// It never redirects to where the user already is, so it cannot loop.
String? resolveRedirect({
  required Iterable<FeatureModule> modules,
  required Capabilities capabilities,
  required String location,
}) {
  for (final module in modules) {
    if (module.owns(location)) {
      if (module.isAllowedFor(capabilities)) return null;
      break;
    }
  }

  final home = homeLocation(modules, capabilities);
  if (home == null) return null;
  return Uri.parse(location).path == home ? null : home;
}
