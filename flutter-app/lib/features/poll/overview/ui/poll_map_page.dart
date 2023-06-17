import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_poll/features/maps/ui/map_marker.dart';
import 'package:location_poll/features/maps/ui/map_page.dart';
import 'package:location_poll/features/poll/overview/bloc/polls_page_cubit.dart';
import 'package:location_poll/features/poll/overview/bloc/polls_page_state.dart';
import 'package:location_poll/features/poll/poll_module.dart';
import 'package:location_poll/features/poll/vote/ui/vote_preview_page.dart';
import 'package:location_poll/services/location_service.dart';

class PollMapPage extends StatelessWidget {
  const PollMapPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PollsPageCubit>.value(
      value: Modular.get<PollsPageCubit>(),
      child: _PageContent(),
    );
  }
}

class _PageContent extends StatelessWidget {
  _PageContent({Key? key}) : super(key: key);

  final double initialZoom = 12.0;
  final MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    _mapInit(context);
    return BlocBuilder<PollsPageCubit, PollsPageState>(
      builder: (context, state) {
        final currState = state;
        if (currState is PollsPageLoaded) {
          return FlutterMap(
            nonRotatedLayers: [
              ZoomButtonsPluginOption(
                minZoom: 1,
                maxZoom: 19,
                mini: true,
                padding: 10,
                alignment: Alignment.topRight,
              ),
            ],
            mapController: mapController,
            options: MapOptions(
              center: LatLng(0.0, 0.0),
              zoom: 12,
              plugins: [
                ZoomButtonsPlugin(),
              ],
            ),
            layers: [
              CircleLayerOptions(circles: [
                CircleMarker(
                    point: LatLng(0.0, 0.0),
                    color: Colors.blue.withOpacity(0.5),
                    useRadiusInMeter: true,
                    radius: 10 // 2000 meters | 2 km
                    ),
              ]),
              MarkerLayerOptions(
                markers: MapMarker.getMarkers(
                  polls: currState.allPolls,
                  onClick: (poll) => Modular.to.pushNamed(
                    '${PollModule.routeName}${VotePreviewPage.routeName}',
                    arguments: {'poll': poll},
                  ),
                ),
              ),
            ],
            children: <Widget>[
              TileLayerWidget(
                  options: TileLayerOptions(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'])),
            ],
          );
        }
        return const Center(
          child: Text('Loading...'),
        );
      },
    );
  }

  void _mapInit(BuildContext context) async {
    final curPos = await Modular.get<LocationService>().getCurrentLocation();
    mapController.move(
      LatLng(curPos.latitude, curPos.longitude),
      initialZoom,
    );
  }
}
