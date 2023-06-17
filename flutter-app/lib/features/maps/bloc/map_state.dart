import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class MapsState extends Equatable {
  final LatLng marker;
  final LatLng mapCenter;
  final double radiusInMeter;

  const MapsState({
    required this.marker,
    required this.mapCenter,
    required this.radiusInMeter,
  }) : super();

  @override
  List<Object?> get props => [marker, mapCenter, radiusInMeter];
}

class MapInit extends MapsState {
  MapInit.fromPosition({
    LatLng? position,
    required double radiusInMeter,
  }) : super(
          mapCenter: position ?? LatLng(0.0, 0.0),
          marker: position ?? LatLng(0.0, 0.0),
          radiusInMeter: radiusInMeter,
        );
}

class MapPos extends MapsState {
  const MapPos({
    required position,
    required radiusInMeter,
  }) : super(
            marker: position,
            mapCenter: position,
            radiusInMeter: radiusInMeter);
}

class AddMarker extends MapsState {
  const AddMarker({
    required marker,
    required mapCenter,
    required radiusInMeter,
  }) : super(
          marker: marker,
          mapCenter: mapCenter,
          radiusInMeter: radiusInMeter,
        );
}

class SaveLocation extends MapsState {
  const SaveLocation({
    required marker,
    required mapCenter,
    required radiusInMeter,
  }) : super(
          marker: marker,
          mapCenter: mapCenter,
          radiusInMeter: radiusInMeter,
        );
}

class FindLocation extends MapsState {
  const FindLocation({
    required marker,
    required mapCenter,
    required radiusInMeter,
  }) : super(
          marker: marker,
          mapCenter: mapCenter,
          radiusInMeter: radiusInMeter,
        );
}

class FindLocationError extends MapsState {
  const FindLocationError({
    required marker,
    required mapCenter,
    required radiusInMeter,
  }) : super(
          marker: marker,
          mapCenter: mapCenter,
          radiusInMeter: radiusInMeter,
        );
}
