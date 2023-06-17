import 'package:location_poll/models/poll.dart';
import 'package:location_poll/services/storage_service.dart';

abstract class AnonymityLayerService {
  AnonymityLayerService({
    required this.storageService,
  });

  final StorageService storageService;

  /// Add keys for voting to given polls.
  Future<List<Poll>> addKeysToPolls(List<Poll> polls);

  Future<void> addInformationFromDbToPolls(List<Poll> polls);
}
