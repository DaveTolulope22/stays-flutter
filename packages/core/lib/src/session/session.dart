import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'session.freezed.dart';
part 'session.g.dart';

/// A signed-in user: the bearer token and the identity that goes with it.
/// This is exactly what login and registration return.
@freezed
abstract class Session with _$Session {
  const Session._();

  const factory Session({required String accessToken, required User user}) =
      _Session;

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);

  /// Deliberately leaves the token out, so logging a session or a state that
  /// holds one can never print the credential.
  @override
  String toString() => 'Session(user: $user)';
}
