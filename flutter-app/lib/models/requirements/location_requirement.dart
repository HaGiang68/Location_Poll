import 'package:json_annotation/json_annotation.dart';
import 'package:location_poll/models/geo_point.dart';

part 'location_requirement.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class LocationRequirement {
  LocationRequirement({
    required this.geoPoint,
    required this.geoHash,
    required this.radius,
  });

  /// Center of circle.
  final GeoPoint geoPoint;

  /// GeoHash of circle.
  final String geoHash;

  /// Radius around center in meters.
  final double radius;

  factory LocationRequirement.fromJson(Map<String, dynamic> json) =>
      _$LocationRequirementFromJson(json);

  Map<String, Object?> toJson() =>
      Map<String, Object?>.from(_$LocationRequirementToJson(this));
}
