import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:location_poll/models/poll.dart';
import 'package:location_poll/services/firebase/functions/models/fcm_token_submit.dart';
import 'package:location_poll/services/firebase/functions/models/poll_id_key_pair.dart';
import 'package:location_poll/services/firebase/functions/models/poll_ids_request.dart';
import 'package:location_poll/services/firebase/functions/models/selection_submit.dart';
import 'package:logger/logger.dart';

class FirebaseFunctionsService {
  final FirebaseFunctions _firebaseFunctions = FirebaseFunctions.instanceFor(
    region: 'europe-west3',
  );

  static final _logger = Logger(
    printer: PrettyPrinter(),
  );

  Future<List<PollIdKeyPair>> getVoteKeysForPollIds(
      Iterable<String> pollIds) async {
    final body = PollIdsRequest(pollIds: pollIds.toList()).toJson();
    final res = await _firebaseFunctions
        .httpsCallable('requestKeysForPolls')
        .call(body);
    final pairsJson = res.data['polls'];
    final pairs = <PollIdKeyPair>[];
    for (final p in pairsJson) {
      final pair = Map<String, dynamic>.from(p);
      pairs.add(PollIdKeyPair.fromJson(pair));
    }
    return pairs;
  }

  Future<bool> submitVote(Poll p, Map<int, int> votes) async {
    final key = p.voteKey;
    final id = p.documentReference;
    if (key == null || id == null) {
      _logger.e('Failed to submit vote with key: $key, id: $id.');
      return false;
    }
    final selectionSubmit = SelectionSubmit(
      key: key,
      pollId: id,
      answers: votes,
    );
    try {
      HttpsCallable callable =
          _firebaseFunctions.httpsCallable('submitSelection');
      await callable.call(
        selectionSubmit.toJson(),
      );
    } catch (e) {
      _logger.e('Votes could not be submitted', e);
      return false;
    }
    return true;
  }

  Future<void> submitFCMToken(String token) async {
    final fcmTokenSubmit = FCMTokenSubmit(
      token: token,
    );
    try {
      HttpsCallable callable =
          _firebaseFunctions.httpsCallable('storeFCMToken');
      await callable.call(
        fcmTokenSubmit.toJson(),
      );
    } catch (e) {
      _logger.e('FCM Token could not be submitted', e);
    }
  }
}
