import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';

import '../failures/app_failure.dart';
import 'session.dart';

/// Keeps the session on the device, in the platform's secure storage (Android
/// Keystore), never in SharedPreferences.
///
/// The key includes the tenant. Two tenant builds already have separate
/// storage because their application ids differ; the namespace is a second
/// layer for the day both would ever share a store.
class SessionStorage {
  SessionStorage({required this.storage, required this.tenant});

  final FlutterSecureStorage storage;
  final String tenant;

  String get _key => 'session.$tenant';

  /// The stored session, or null. It never throws: a value that is missing,
  /// unreadable, corrupt or of the wrong shape is the same as being signed
  /// out, and is removed so it cannot fail again on the next launch.
  Future<Session?> read() async {
    try {
      final raw = await storage.read(key: _key);
      if (raw == null) return null;
      return Session.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (error) {
      // Log the type only: the message could contain the stored value.
      developer.log(
        'Discarding an unreadable stored session (${error.runtimeType}).',
        name: 'core.session',
      );
      await clear();
      return null;
    }
  }

  /// Fails with an [UnknownFailure] if the platform refuses the write. The
  /// caller decides what that means; signing in can still continue for this
  /// run of the app.
  TaskEither<AppFailure, Unit> write(Session session) =>
      TaskEither.tryCatch(() async {
        await storage.write(key: _key, value: jsonEncode(session.toJson()));
        return unit;
      }, (error, _) => const UnknownFailure());

  /// Best effort and never throws: signing out must always succeed locally,
  /// even if the platform storage misbehaves.
  Future<void> clear() async {
    try {
      await storage.delete(key: _key);
    } catch (error) {
      developer.log(
        'Could not clear the stored session (${error.runtimeType}).',
        name: 'core.session',
      );
    }
  }
}
