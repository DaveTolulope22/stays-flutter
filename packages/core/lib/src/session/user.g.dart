// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'role': _$UserRoleEnumMap[instance.role]!,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
};

const _$UserRoleEnumMap = {UserRole.client: 'client', UserRole.host: 'host'};
