import 'package:location_poll/models/poll.dart';
import 'package:location_poll/services/sq_lite/models/poll_key.dart';
import 'package:location_poll/services/storage_service.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteStorageService extends StorageService {
  SQLiteStorageService({
    required this.database,
  }) : super();

  final Database database;

  static const String _keyTbl = 'keys';

  static final _logger = Logger(
    printer: PrettyPrinter(),
  );

  static Future<Database> initDatabase() async {
    final database = await openDatabase(
      join(
        await getDatabasesPath(),
        'poll_key.db',
      ),
      onCreate: (db, version) {
        return db.execute('CREATE TABLE $_keyTbl '
            '(pollId VARCHAR(45) PRIMARY KEY, '
            'key VARCHAR(45),'
            'alreadyVoted TEXT)');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 3) {
          db.execute('ALTER TABLE $_keyTbl ADD vote TEXT;');
        }
        if (oldVersion < 4) {
          db.execute('ALTER TABLE $_keyTbl ADD alreadyVoted TEXT;');
          db.execute('ALTER TABLE $_keyTbl DROP COLUMN vote;');
        }
      },
      version: 4,
    );
    return database;
  }

  ///
  /// Read keys already stored in database and return a new list.
  ///
  @override
  Future<void> addInformationFromDbToPolls(List<Poll> polls) async {
    _logger.i('Searching for keys for ${polls.length} polls.');
    for (final poll in polls) {
      final id = poll.documentReference;
      if (id != null && poll.voteKey == null) {
        final res = await database.rawQuery(
          'SELECT `pollId`, `key`, `alreadyVoted` FROM `$_keyTbl` '
              'WHERE '
              'pollId =?',
          [id],
        );
        for (var element in res) {
          final pollKey = PollKey.fromJson(element);
          poll.voteKey = pollKey.key;
          final alreadyVoted = element['alreadyVoted'] == '1';
          poll.alreadyVoted = alreadyVoted;
        }
      }
    }
  }

  ///
  /// Save keys into database.
  ///
  @override
  Future<void> saveKeys(List<Poll> polls) async {
    for (final poll in polls) {
      if (poll.voteKey == null) {
        continue;
      }
      final id = poll.documentReference;
      final key = poll.voteKey;
      if (id == null || key == null) {
        continue;
      }
      final pollKey = PollKey(
        pollId: id,
        key: key,
      );
      await database.insert(
        _keyTbl,
        pollKey.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  ///
  /// Store information on user vote in db.
  ///
  @override
  Future<void> storeUserVote(Poll poll) async {
    final id = poll.documentReference;
    final key = poll.voteKey;
    if (id == null || key == null) {
      return;
    }
    await database
        .rawQuery('UPDATE $_keyTbl SET alreadyVoted = true WHERE pollId = ?', [
      id,
    ],
    );
  }
}
