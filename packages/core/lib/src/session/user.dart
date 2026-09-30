import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Who the API says you are. Only two roles exist. A role the app does not
/// know fails to decode instead of defaulting to something, so a surprise from
/// the server can never grant access.
enum UserRole { client, host }

/// The `user` object from login, register and `/auth/me`. Role and tenant come
/// only from here, never from decoding the access token.
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String tenantId,
    required UserRole role,
    required String email,
    required String firstName,
    required String lastName,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
