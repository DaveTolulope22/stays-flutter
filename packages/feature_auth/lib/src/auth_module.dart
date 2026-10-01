import 'package:core/core.dart';
import 'package:go_router/go_router.dart';

import 'auth_paths.dart';
import 'register/register_screen.dart';
import 'sign_in/sign_in_screen.dart';

/// Sign-in and registration. It belongs to [AccessArea.none]: reachable only
/// while signed out, so a signed-in user who opens these paths is redirected
/// away by the same rule that guards every other module. It has no tab.
final authModule = FeatureModule(
  id: 'auth',
  area: AccessArea.none,
  basePath: AuthPaths.base,
  // `/auth` itself has no page; a signed-out user lands on sign-in.
  initialLocation: AuthPaths.signIn,
  routes: [
    GoRoute(
      path: AuthPaths.signIn,
      builder: (context, state) => const SignInScreen(),
      routes: [
        GoRoute(
          path: AuthPaths.registerSegment,
          builder: (context, state) => const RegisterScreen(),
        ),
      ],
    ),
  ],
);
