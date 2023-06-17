import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_poll/models/poll.dart';
import 'package:location_poll/services/anonymity_layer_service.dart';
import 'package:location_poll/services/location_service.dart';

part 'vote_preview_page_state.dart';

class VotePreviewPageCubit extends Cubit<VotePreviewPageState> {
  VotePreviewPageCubit({
    required Poll poll,
    required LocationService locationService,
    required AnonymityLayerService anonymityLayerService,
  })  : _locationService = locationService,
        _anonymityLayerService = anonymityLayerService,
        super(
          VotePreviewPageInitial(
            poll: poll,
          ),
        ) {
    _init();
    if (poll.voteKey == null) {
      requestKey(poll);
    }
  }

  final LocationService _locationService;
  final AnonymityLayerService _anonymityLayerService;
  late final StreamSubscription<Position> _locationSubscription;

  void _init() async {
    final positionStream = await _locationService.getLocationStream();
    _locationSubscription = positionStream.listen(
      (position) {
        final geoPointPoll =
            state.poll.requirements.locationRequirement.geoPoint;
        LatLng pollLatLng = LatLng(
          geoPointPoll.latitude,
          geoPointPoll.longitude,
        );
        LatLng userLatLng = LatLng(
          position.latitude,
          position.longitude,
        );
        const distance = Distance();
        final distanceMeter =
            distance.as(LengthUnit.Meter, pollLatLng, userLatLng);
        final distanceToRadius =
            distanceMeter - state.poll.requirements.locationRequirement.radius;
        if (distanceToRadius > 0) {
          emit(
            VotePreviewPageOutsidePollRadius(
              poll: state.poll,
              position: position,
              distanceMeter: distanceToRadius,
            ),
          );
        } else {
          emit(
            VotePreviewPageInPollRadius(
              poll: state.poll,
              position: position,
            ),
          );
        }
      },
    );
  }

  Future<void> requestKey(Poll poll) async {
    final polls = await _anonymityLayerService.addKeysToPolls([poll]);
    emit(
      state.copyWith(
        poll: polls.first,
      ),
    );
  }

  @override
  Future<void> close() {
    _locationSubscription.cancel();
    return super.close();
  }
}
