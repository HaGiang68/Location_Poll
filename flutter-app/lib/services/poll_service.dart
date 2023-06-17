import 'package:location_poll/models/poll.dart';

abstract class PollService {
  /// Return a list of polls with all available polls that end in the future.
  Future<List<Poll>> getFutureEndingPolls();

  /// Return a list of polls created by user with [uuid].
  Future<List<Poll>> getPollsCreatedBy({
    required String uuid,
  });

  /// Create a new poll.
  Future<void> createPoll(Poll newPoll);

  /// Update an existing poll.
  Future<void> updatePoll(Poll p);

  /// Submit vote to poll.
  Future<bool> submitVote(Poll p, Map<int, int> votes);

  /// Submit fcm token
  Future<void> submitFCMToken(String token);

  /// Delete a specific poll
  Future<void> deletePoll(Poll poll);

  /// Load a poll
  Future<Poll?> loadPollWithId(String documentReference);
}
