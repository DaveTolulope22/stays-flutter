import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'boot/boot_app.dart';

/// App start. The tenant environment is checked here, once, before any
/// provider exists: a missing or mismatched TENANT shows a developer error
/// instead of a half-working app. The validated value is then handed to
/// Riverpod, so the rest of the app can rely on it without a second check.
void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();

  final TenantEnvironment environment;
  try {
    environment = TenantEnvironment.fromBuild();
  } on TenantEnvironmentError catch (error) {
    runApp(
      ProviderScope(
        child: BootApp(body: StartupError(message: error.message)),
      ),
    );
    return;
  }

  runApp(
    ProviderScope(
      overrides: [tenantEnvironmentProvider.overrideWithValue(environment)],
      child: const StaysApp(),
    ),
  );
}
