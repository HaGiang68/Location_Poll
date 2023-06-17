import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_poll/features/maps/bloc/map_state.dart';

class MapCubit extends Cubit<MapsState> {
  MapCubit() : super(MapInit.fromPosition(position: null, radiusInMeter: 10));

  GooglePlace googlePlace =
      GooglePlace('AIzaSyBRiDd62dvwjTEYShk40ZveVeewDYGVWNo');
  final textSearchController = TextEditingController();
  MapController mapController = MapController();
  double initalZoom = 12.0;

  changeMarker(LatLng marker) {
    final currState = state;
    emit(AddMarker(
        marker: marker,
        mapCenter: currState.mapCenter,
        radiusInMeter: currState.radiusInMeter));
  }

  mapInit(LatLng position, double radius) async {
    emit(MapPos(position: position, radiusInMeter: radius));
    if (position.latitude == 0.0 && position.longitude == 0.00) {
      _determinePosition();
    } else {
      mapController.move(position, initalZoom);
    }
  }

  saveLocation(LatLng marker) {
    final currState = state;
    emit(SaveLocation(
        marker: marker,
        mapCenter: currState.mapCenter,
        radiusInMeter: currState.radiusInMeter));
  }

  Future<void> findLocation(String locationQuery) async {
    var result = await googlePlace.search.getFindPlace(
        locationQuery, InputType.TextQuery,
        fields: "name,formatted_address,geometry");
    double lat = 0.0;
    double lng = 0.0;
    if (result?.status == 'OK') {
      if (result != null && result.candidates != null) {
        List<SearchCandidate> candidates = [];
        candidates = result.candidates!;
        lat = candidates[0].geometry?.location?.lat as double;
        lng = candidates[0].geometry?.location?.lng as double;
        LatLng loc = LatLng(lat, lng);
        mapController.move(loc, initalZoom);
      }
    }
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  void _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Geolocator.getCurrentPosition().then((value) => mapController.move(
        LatLng(value.latitude, value.longitude), initalZoom));
  }
}
