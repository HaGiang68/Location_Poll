import 'package:json_annotation/json_annotation.dart';

part 'geo_point.g.dart';

@JsonSerializable()
class GeoPoint {
  final double latitude;
  final double longitude;

  GeoPoint({
    required this.latitude,
    required this.longitude,
  });

  factory GeoPoint.fromJson(Map<String, dynamic> json) =>
      _$GeoPointFromJson(json);

  Map<String, Object?> toJson() =>
      Map<String, Object?>.from(_$GeoPointToJson(this));
}
