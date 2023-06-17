// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requirements.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Requirements _$RequirementsFromJson(Map json) => Requirements(
      authRequirement: AuthRequirement.fromJson(
          Map<String, dynamic>.from(json['authRequirement'] as Map)),
      locationRequirement: LocationRequirement.fromJson(
          Map<String, dynamic>.from(json['locationRequirement'] as Map)),
      timeRequirement: TimeRequirement.fromJson(
          Map<String, dynamic>.from(json['timeRequirement'] as Map)),
    );

Map<String, dynamic> _$RequirementsToJson(Requirements instance) =>
    <String, dynamic>{
      'authRequirement': instance.authRequirement.toJson(),
      'locationRequirement': instance.locationRequirement.toJson(),
      'timeRequirement': instance.timeRequirement.toJson(),
    };
