import 'package:flutter/services.dart' show appFlavor;

/// Thrown when the build was started with a missing or inconsistent tenant.
/// It is a developer error, not a runtime condition, so it is fatal and its
/// message is for the developer (never shown to users).
class TenantEnvironmentError extends Error {
  TenantEnvironmentError(this.message);

  final String message;

  @override
  String toString() => 'TenantEnvironmentError: $message';
}

/// The only things the app knows at compile time: which tenant it is and
/// where the API lives. Everything else arrives with the runtime config.
class TenantEnvironment {
  const TenantEnvironment._({required this.tenant, required this.apiBaseUrl});

  /// USB phone with `adb reverse tcp:8080 tcp:8080`. An emulator overrides it
  /// with `--dart-define=API_BASE_URL=http://10.0.2.2:8080`.
  static const defaultApiBaseUrl = 'http://127.0.0.1:8080';

  final String tenant;
  final String apiBaseUrl;

  /// Reads `--dart-define=TENANT` and `API_BASE_URL` and the flavor Flutter
  /// exposes from `--flavor`. `String.fromEnvironment` only works with a
  /// `const` call, which is why the reading lives here and the rule lives in
  /// [validated], where a test can reach it.
  factory TenantEnvironment.fromBuild() => TenantEnvironment.validated(
    tenant: const String.fromEnvironment('TENANT'),
    flavor: appFlavor,
    apiBaseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: defaultApiBaseUrl,
    ),
  );

  /// The tenant must be non-empty and equal to the flavor. There is no list
  /// of known slugs on purpose: a new tenant needs a new flavor and no Dart
  /// change, and no tenant name may appear in Dart code.
  factory TenantEnvironment.validated({
    required String tenant,
    required String? flavor,
    required String apiBaseUrl,
  }) {
    if (tenant.trim().isEmpty) {
      throw TenantEnvironmentError(
        'TENANT is not set. Start the app with --flavor <slug> '
        '--dart-define=TENANT=<slug>.',
      );
    }
    if (tenant != flavor) {
      throw TenantEnvironmentError(
        'TENANT ("$tenant") does not match the flavor ("${flavor ?? 'none'}"). '
        'Pass the same slug to --flavor and --dart-define=TENANT.',
      );
    }
    return TenantEnvironment._(tenant: tenant, apiBaseUrl: apiBaseUrl);
  }
}
