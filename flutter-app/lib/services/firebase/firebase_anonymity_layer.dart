import 'package:location_poll/models/poll.dart';
import 'package:location_poll/services/anonymity_layer_service.dart';
import 'package:location_poll/services/firebase/functions/firebase_function_service.dart';
import 'package:location_poll/services/storage_service.dart';
import 'package:logger/logger.dart';

class FirebaseAnonymityLayer extends AnonymityLayerService {
  FirebaseAnonymityLayer({
    required StorageService storageService,
    required this.firebaseFunctionsService,
  }) : super(
          storageService: storageService,
        );

  final FirebaseFunctionsService firebaseFunctionsService;

  final Logger _logger = Logger();

  @override
  Future<List<Poll>> addKeysToPolls(List<Poll> polls) async {
    _logger.i('Load keys for polls');
    await storageService.addInformationFromDbToPolls(polls);
    final Iterable<String> pollIdsToGenerateKeyFor = polls
        .where((element) =>
            element.voteKey == null && element.documentReference != null)
        .map((e) => e.documentReference!);
    if (pollIdsToGenerateKeyFor.isEmpty) {
      return polls;
    }

    final keysForPolls = await firebaseFunctionsService
        .getVoteKeysForPollIds(pollIdsToGenerateKeyFor);
    final List<Poll> pollsWithKeys = [];

    for (var poll in polls) {
      if (poll.voteKey != null) {
        // add polls where voteKey is already assigned
        pollsWithKeys.add(poll);
      } else {
        pollsWithKeys.add(
          poll.copyWith(
            voteKey: keysForPolls
                .firstWhere((e) => e.pollId == poll.documentReference)
                .key,
          ),
        );
      }
    }
    storageService.saveKeys(pollsWithKeys);
    return pollsWithKeys;
  }

  @override
  Future<void> addInformationFromDbToPolls(List<Poll> polls) async {
    await storageService.addInformationFromDbToPolls(polls);
  }
}
