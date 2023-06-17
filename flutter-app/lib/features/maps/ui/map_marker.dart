import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_poll/models/poll.dart';

class MapMarker {
  static List<Marker> getMarkers({
    required List<Poll> polls,
    Function(Poll poll)? onClick,
  }) {
    List<Marker> markers = [];
    for (Poll poll in polls) {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(poll.requirements.locationRequirement.geoPoint.latitude,
              poll.requirements.locationRequirement.geoPoint.longitude),
          builder: (ctx) => GestureDetector(
            onTap: () => onClick?.call(poll),
            child: Column(
              children: [
                const Icon(
                  Icons.poll_rounded,
                  color: Colors.black,
                  size: 48,
                ),
                Container(
                  color: Colors.black,
                  child: Text(
                    poll.title,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return markers;
  }
}
