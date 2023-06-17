// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_requirement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationRequirement _$LocationRequirementFromJson(Map json) =>
    LocationRequirement(
      geoPoint:
          GeoPoint.fromJson(Map<String, dynamic>.from(json['geoPoint'] as Map)),
      geoHash: json['geoHash'] as String,
      radius: (json['radius'] as num).toDouble(),
    );

Map<String, dynamic> _$LocationRequirementToJson(
        LocationRequirement instance) =>
    <String, dynamic>{
      'geoPoint': instance.geoPoint.toJson(),
      'geoHash': instance.geoHash,
      'radius': instance.radius,
    };
