import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class LocalDb {
  LocalDb._();

  static final LocalDb instance = LocalDb._();
  Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'pairnest.db');
    _db = await openDatabase(
      path,
      version: 1,
      password: 'pairnest-local-encrypted-db',
      onCreate: (database, _) async {
        await database.execute('''
          CREATE TABLE events (
            event_id TEXT PRIMARY KEY,
            pair_id TEXT NOT NULL,
            device_id TEXT NOT NULL,
            event_type TEXT NOT NULL,
            payload TEXT NOT NULL,
            created_at TEXT NOT NULL,
            synced_at TEXT
          )
        ''');

        await database.execute('''
          CREATE TABLE app_state (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');

        await database.execute(
          'CREATE INDEX idx_events_pair_time ON events(pair_id, created_at DESC)',
        );
      },
    );
    return _db!;
  }
}
