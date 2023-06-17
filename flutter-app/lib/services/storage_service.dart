import 'package:location_poll/models/poll.dart';

abstract class StorageService {
  Future<void> addInformationFromDbToPolls(List<Poll> polls);

  Future<void> saveKeys(List<Poll> polls);

  Future<void> storeUserVote(Poll poll);
}
