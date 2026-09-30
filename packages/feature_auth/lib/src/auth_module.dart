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
  routes: [
    GoRoute(
      path: AuthPaths.signIn,
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: AuthPaths.register,
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
);
