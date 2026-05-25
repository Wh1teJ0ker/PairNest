import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class LocalDb {
  LocalDb._();

  static final LocalDb instance = LocalDb._();
  static const _dbKeyStorage = 'pairnest_db_key_v1';
  static const _legacyDbPassword = 'pairnest-local-encrypted-db';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'pairnest.db');
    _db = await _openWithManagedPassword(path);
    return _db!;
  }

  Future<Database> _openWithManagedPassword(String path) async {
    final stored = await _secureStorage.read(key: _dbKeyStorage);
    if (stored != null && stored.isNotEmpty) {
      return _openDatabase(path: path, password: stored);
    }

    final generated = _generateDbPassword();
    final dbFile = File(path);
    final exists = await dbFile.exists();

    if (!exists) {
      final database = await _openDatabase(path: path, password: generated);
      await _secureStorage.write(key: _dbKeyStorage, value: generated);
      return database;
    }

    await _migrateFromLegacyPassword(path: path, newPassword: generated);
    await _secureStorage.write(key: _dbKeyStorage, value: generated);
    return _openDatabase(path: path, password: generated);
  }

  Future<void> _migrateFromLegacyPassword({
    required String path,
    required String newPassword,
  }) async {
    Database? legacyDb;
    try {
      legacyDb = await _openDatabase(path: path, password: _legacyDbPassword);
      final escaped = _escapeSqlLiteral(newPassword);
      await legacyDb.execute("PRAGMA rekey = '$escaped';");
    } catch (e) {
      throw StateError('数据库密钥迁移失败: $e');
    } finally {
      await legacyDb?.close();
    }
  }

  Future<Database> _openDatabase({
    required String path,
    required String password,
  }) {
    return openDatabase(
      path,
      version: 1,
      password: password,
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
  }

  String _generateDbPassword() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _escapeSqlLiteral(String value) {
    return value.replaceAll("'", "''");
  }
}
