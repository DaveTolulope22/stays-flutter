// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Session _$SessionFromJson(Map<String, dynamic> json) => _Session(
  accessToken: json['accessToken'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SessionToJson(_Session instance) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'user': instance.user.toJson(),
};
