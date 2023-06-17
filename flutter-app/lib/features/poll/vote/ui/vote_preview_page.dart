import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_poll/features/maps/ui/map_marker.dart';
import 'package:location_poll/features/maps/ui/map_page.dart';
import 'package:location_poll/features/poll/poll_module.dart';
import 'package:location_poll/features/poll/vote/bloc/vote_preview_page_cubit.dart';
import 'package:location_poll/features/poll/vote/ui/poll_header.dart';
import 'package:location_poll/features/poll/vote/ui/vote_page.dart';
import 'package:location_poll/global_ui/theme/colors.dart';
import 'package:location_poll/models/poll.dart';
import 'package:location_poll/services/anonymity_layer_service.dart';
import 'package:location_poll/services/location_service.dart';

class VotePreviewPage extends StatelessWidget {
  VotePreviewPage({
    Key? key,
    required this.poll,
  }) : super(key: key);

  final Poll poll;

  static const String routeName = '/preview';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VotePreviewPageCubit>(
      create: (context) => VotePreviewPageCubit(
        poll: poll,
        locationService: Modular.get<LocationService>(),
        anonymityLayerService: Modular.get<AnonymityLayerService>(),
      ),
      child: Scaffold(
        body: Column(
          children: [
            PollHeader(
              text: poll.title,
            ),
            const _PageContent(),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  _TimeContent(),
                  _LocationRequirement(),
                  _KeyRequirement(),
                ],
              ),
            ),
          ),
          const _BottomButton(),
        ],
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<VotePreviewPageCubit, VotePreviewPageState>(
        builder: (context, state) {
          return FloatingActionButton.extended(
            onPressed: () {
              if (state is VotePreviewPageInPollRadius && state.isTimeValid) {
                Modular.to.pushNamed(
                  '${PollModule.routeName}${VotePage.routeName}',
                  arguments: {
                    'poll': state.poll,
                  },
                );
              } else {
                Modular.to.pop();
              }
            },
            backgroundColor:
                state is VotePreviewPageInPollRadius && state.isTimeValid
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            label: Text(
              state is VotePreviewPageInPollRadius && state.isTimeValid
                  ? 'VOTE NOW'
                  : 'GO BACK',
            ),
          );
        },
      ),
    );
  }
}

class _KeyRequirement extends StatelessWidget {
  const _KeyRequirement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VotePreviewPageCubit, VotePreviewPageState>(
        builder: (context, state) {
      if (state.poll.voteKey != null) {
        return const Text('Your vote key is ready');
      } else {
        return const Text('Loading vote key.');
      }
    });
  }
}

class _TimeContent extends StatelessWidget {
  const _TimeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VotePreviewPageCubit, VotePreviewPageState>(
      builder: (context, state) {
        return Column(
          children: [
            if (state.isAfterStartTime && state.isBeforeEndTime)
              _Countdown(
                title: 'Poll ends in',
                timeToReach: state.poll.requirements.timeRequirement.endTime,
              ),
            if (!state.isAfterStartTime)
              _Countdown(
                title: 'Poll starts in',
                timeToReach: state.poll.requirements.timeRequirement.startTime,
              ),
            if (!state.isBeforeEndTime)
              Text(
                'Poll already ended',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline3?.apply(
                      color: Theme.of(context).errorColor,
                    ),
              ),
          ],
        );
      },
    );
  }
}

class _Countdown extends StatefulWidget {
  const _Countdown({
    Key? key,
    required this.title,
    required this.timeToReach,
  }) : super(key: key);

  final String title;
  final DateTime timeToReach;

  @override
  _CountdownState createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  DateTime? _curTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => setState(
        () {
          _curTime = DateTime.now();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Duration duration =
        widget.timeToReach.difference(_curTime ?? DateTime.now());
    return Text(
      '${widget.title}\n'
      '${_format(duration)}',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headline3,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
}

class _LocationRequirement extends StatelessWidget {
  const _LocationRequirement({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Modular.get<LocationService>();
    return BlocBuilder<VotePreviewPageCubit, VotePreviewPageState>(
      builder: (context, state) {
        return Column(
          children: [
            SizedBox(
              height: 250,
              child: _ShowOnMap(
                poll: state.poll,
                userPosition: state is VotePreviewPagePositionLoaded
                    ? state.position
                    : null,
              ),
            ),
            if (state is VotePreviewPagePositionLoaded)
              Text(
                state is VotePreviewPageOutsidePollRadius
                    ? 'You are ${state.distanceMeter}m away from the poll region'
                    : 'You are in the poll region',
                textAlign: TextAlign.center,
                style: state is VotePreviewPageOutsidePollRadius
                    ? Theme.of(context).textTheme.headline4?.apply(color: ColorTheme.denialColor)
                    : Theme.of(context)
                        .textTheme
                        .headline4
                        ?.apply(color: ColorTheme.approvedColor),
              ),
            if (state is! VotePreviewPagePositionLoaded)
              Text(
                'Loading location...',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4!.apply(),
              ),
          ],
        );
      },
    );
  }
}

class _ShowOnMap extends StatelessWidget {
  const _ShowOnMap({
    Key? key,
    required this.poll,
    required this.userPosition,
  }) : super(key: key);

  final Poll poll;
  final Position? userPosition;

  @override
  Widget build(BuildContext context) {
    final geoPoint = poll.requirements.locationRequirement.geoPoint;
    return FlutterMap(
      mapController: MapController(),
      options: MapOptions(
        center: LatLng(
          geoPoint.latitude,
          geoPoint.longitude,
        ),
        zoom: 12,
        plugins: [
          ZoomButtonsPlugin(),
        ],
      ),
      layers: [
        CircleLayerOptions(circles: [
          CircleMarker(
              point: LatLng(
                userPosition?.latitude ?? 0,
                userPosition?.longitude ?? 0,
              ),
              color: Colors.blue.withOpacity(1),
              useRadiusInMeter: true,
              radius: userPosition?.accuracy ?? 2000),
          CircleMarker(
              point: LatLng(
                geoPoint.latitude,
                geoPoint.longitude,
              ),
              color: ColorTheme.approvedColor.withOpacity(0.5),
              useRadiusInMeter: true,
              radius: poll
                  .requirements.locationRequirement.radius // 2000 meters | 2 km
              ),
        ]),
        MarkerLayerOptions(markers: [
          Marker(
            point: LatLng(
              userPosition?.latitude ?? 0,
              userPosition?.longitude ?? 0,
            ),
            builder: (ctx) => const Icon(
              Icons.accessibility_new_rounded,
              color: Colors.orange,
              size: 48,
            ),
          ),
          ...MapMarker.getMarkers(
            polls: [
              poll,
            ],
          ),
        ]),
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
}
