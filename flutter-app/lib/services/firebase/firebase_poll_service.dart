import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_poll/models/poll.dart';
import 'package:location_poll/services/anonymity_layer_service.dart';
import 'package:location_poll/services/firebase/functions/firebase_function_service.dart';
import 'package:location_poll/services/poll_service.dart';
import 'package:logger/logger.dart';

class FirebasePollService extends PollService {
  FirebasePollService({
    required FirebaseFirestore firestore,
    required AnonymityLayerService anonymityLayerService,
    required FirebaseFunctionsService firebaseFunctionsService,
  })  : _firestore = firestore,
        _anonymityLayerService = anonymityLayerService,
        _functionsService = firebaseFunctionsService,
        super() {
    _pollsRef = _firestore.collection('polls').withConverter<Poll>(
          fromFirestore: (snapshot, _) => Poll.fromJson(snapshot.data() ?? {}),
          toFirestore: (poll, _) => poll.toJson(),
        );
  }

  final FirebaseFirestore _firestore;
  final AnonymityLayerService _anonymityLayerService;
  final FirebaseFunctionsService _functionsService;
  late final CollectionReference _pollsRef;

  static final _logger = Logger(
    printer: PrettyPrinter(),
  );

  /// Return a list of polls created by user with [uuid].
  @override
  Future<List<Poll>> getPollsCreatedBy({
    required String uuid,
  }) async {
    final now = DateTime.now();
    _logger.i('Load polls created by user. '
        'User: $uuid');
    final snapshots =
        await _pollsRef.where('owner.uuid', isEqualTo: uuid).get();
    final List<Poll> polls = [];
    for (var poll in snapshots.docs) {
      final pollObj = poll.data() as Poll;
      pollObj.documentReference = poll.id;
      pollObj.isEditable =
          now.isBefore(pollObj.requirements.timeRequirement.endTime);
      pollObj.isDeletable = true;
      polls.add(pollObj);
    }
    // populate polls with voteKeys
    await _anonymityLayerService.addInformationFromDbToPolls(polls);
    try {
      _anonymityLayerService.addKeysToPolls(polls);
    } catch (e) {
      _logger.e(e);
    }
    return polls;
  }

  /// Return a list of polls with all available polls that end in the future.
  @override
  Future<List<Poll>> getFutureEndingPolls() async {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    _logger.i('Load polls ending in future. Current time: $currentTime');
    final snapshots = await _pollsRef
        .where('requirements.timeRequirement.endTime',
            isGreaterThanOrEqualTo: currentTime)
        .get();
    final List<Poll> polls = [];
    for (var poll in snapshots.docs) {
      final pollObj = poll.data() as Poll;
      pollObj.documentReference = poll.id;
      pollObj.isEditable = false;
      polls.add(pollObj);
    }
    _logger.i('Loaded ${polls.length} polls.');
    // populate polls with voteKeys
    await _anonymityLayerService.addInformationFromDbToPolls(polls);
    try {
      _anonymityLayerService.addKeysToPolls(polls);
    } catch (e) {
      _logger.e(e);
    }
    return polls;
  }

  @override
  Future<void> createPoll(Poll newPoll) async {
    _logger.i('Create new poll: ${newPoll.toJson()}');
    final docRef = await _pollsRef.add(newPoll);
    newPoll.documentReference = docRef.id;
    _logger.i('Poll created with document id ${newPoll.documentReference}');
  }

  @override
  Future<void> updatePoll(Poll poll) async {
    _logger.i('Update poll: ${poll.toJson()}');
    await _pollsRef.doc(poll.documentReference).set(poll);
    _logger.i('Poll updated with document id ${poll.documentReference}');
  }

  @override
  Future<bool> submitVote(Poll p, Map<int, int> votes) async {
    if (p.voteKey == null) {
      await _anonymityLayerService.addKeysToPolls([p]);
    }
    return await _functionsService.submitVote(p, votes);
  }

  @override
  Future<void> submitFCMToken(String token) async {
    return await _functionsService.submitFCMToken(token);
  }

  @override
  Future<void> deletePoll(Poll poll) async {
    _logger.i('Delete poll with id ${poll.documentReference}');
    await _pollsRef.doc(poll.documentReference).delete();
    _logger.i('Deleted poll with id ${poll.documentReference}');
  }

  @override
  Future<Poll?> loadPollWithId(String documentReference) async {
    _logger.i('Load poll with id $documentReference');
    try {
      final snapshot = await _pollsRef.doc(documentReference).get();
      final pollObj = snapshot.data() as Poll;
      return pollObj;
    } catch (e) {
      _logger.e(e);
    }
    return null;
  }
}
