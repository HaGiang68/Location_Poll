// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_requirement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthRequirement _$AuthRequirementFromJson(Map json) => AuthRequirement(
      auth: $enumDecode(_$AuthStageEnumMap, json['auth']),
    );

Map<String, dynamic> _$AuthRequirementToJson(AuthRequirement instance) =>
    <String, dynamic>{
      'auth': _$AuthStageEnumMap[instance.auth],
    };

const _$AuthStageEnumMap = {
  AuthStage.anonymous: 'ANONYMOUS',
  AuthStage.mailVerified: 'MAIL_VERIFIED',
  AuthStage.phoneVerified: 'PHONE_VERIFIED',
  AuthStage.idVerified: 'ID_VERIFIED',
};
