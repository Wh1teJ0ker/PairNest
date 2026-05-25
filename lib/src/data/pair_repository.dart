import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../domain/models.dart';
import 'local_db.dart';

class PairRepository {
  PairRepository({LocalDb? localDb}) : _localDb = localDb ?? LocalDb.instance;

  final LocalDb _localDb;
  final Uuid _uuid = const Uuid();

  static const _profileKey = 'pair_profile';

  Future<CoupleProfile?> readProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return CoupleProfile(
      pairId: map['pairId'] as String,
      myDeviceId: map['myDeviceId'] as String,
      meName: map['meName'] as String,
      partnerName: map['partnerName'] as String,
      startedAt: DateTime.parse(map['startedAt'] as String),
    );
  }

  Future<CoupleProfile> bindCouple({
    required String meName,
    required String partnerName,
    DateTime? startedAt,
  }) async {
    final profile = CoupleProfile(
      pairId: _uuid.v4(),
      myDeviceId: _uuid.v4(),
      meName: meName.trim(),
      partnerName: partnerName.trim(),
      startedAt: startedAt ?? DateTime.now(),
    );

    await _saveProfile(profile);
    await appendEvent(
      PairEvent(
        eventId: _uuid.v4(),
        pairId: profile.pairId,
        deviceId: profile.myDeviceId,
        type: EventType.bindPair,
        payload: {
          'meName': profile.meName,
          'partnerName': profile.partnerName,
          'startedAt': profile.startedAt.toIso8601String(),
        },
        createdAt: DateTime.now(),
      ),
    );
    return profile;
  }

  Future<void> _saveProfile(CoupleProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _profileKey,
      jsonEncode({
        'pairId': profile.pairId,
        'myDeviceId': profile.myDeviceId,
        'meName': profile.meName,
        'partnerName': profile.partnerName,
        'startedAt': profile.startedAt.toIso8601String(),
      }),
    );
  }

  Future<void> appendEvent(PairEvent event) async {
    final database = await _localDb.db;
    await database.insert(
      'events',
      event.toDb(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<PairEvent>> eventsByPair(String pairId) async {
    final database = await _localDb.db;
    final rows = await database.query(
      'events',
      where: 'pair_id = ?',
      whereArgs: [pairId],
      orderBy: 'created_at DESC',
    );
    return rows.map(PairEvent.fromDb).toList();
  }

  Future<List<PairEvent>> unsyncedEvents(String pairId) async {
    final database = await _localDb.db;
    final rows = await database.query(
      'events',
      where: 'pair_id = ? AND synced_at IS NULL',
      whereArgs: [pairId],
      orderBy: 'created_at ASC',
    );
    return rows.map(PairEvent.fromDb).toList();
  }

  Future<void> markEventsSynced(List<String> eventIds) async {
    if (eventIds.isEmpty) {
      return;
    }
    final database = await _localDb.db;
    final syncedAt = DateTime.now().toIso8601String();
    final placeholders = List.filled(eventIds.length, '?').join(',');
    await database.rawUpdate(
      'UPDATE events SET synced_at = ? WHERE event_id IN ($placeholders)',
      [syncedAt, ...eventIds],
    );
  }

  Future<void> addTimelineEntry({
    required CoupleProfile profile,
    required String text,
    String? mood,
    String? imagePath,
    List<String> tags = const <String>[],
  }) async {
    await appendEvent(
      PairEvent(
        eventId: _uuid.v4(),
        pairId: profile.pairId,
        deviceId: profile.myDeviceId,
        type: EventType.addNote,
        payload: {
          'text': text,
          'mood': mood,
          'imagePath': imagePath,
          'tags': tags,
        },
        createdAt: DateTime.now(),
      ),
    );

    if (mood != null && mood.isNotEmpty) {
      await appendEvent(
        PairEvent(
          eventId: _uuid.v4(),
          pairId: profile.pairId,
          deviceId: profile.myDeviceId,
          type: EventType.addMood,
          payload: {'mood': mood, 'source': 'note'},
          createdAt: DateTime.now(),
        ),
      );
    }

    if (imagePath != null && imagePath.isNotEmpty) {
      await appendEvent(
        PairEvent(
          eventId: _uuid.v4(),
          pairId: profile.pairId,
          deviceId: profile.myDeviceId,
          type: EventType.addImage,
          payload: {'imagePath': imagePath, 'source': 'note'},
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> checkinTogether(CoupleProfile profile) async {
    await appendEvent(
      PairEvent(
        eventId: _uuid.v4(),
        pairId: profile.pairId,
        deviceId: profile.myDeviceId,
        type: EventType.dailyCheckin,
        payload: {'date': DateTime.now().toIso8601String()},
        createdAt: DateTime.now(),
      ),
    );

    await appendEvent(
      PairEvent(
        eventId: _uuid.v4(),
        pairId: profile.pairId,
        deviceId: profile.myDeviceId,
        type: EventType.addScore,
        payload: {
          'intimacy': 5,
          'activity': 3,
          'chemistry': 2,
          'reason': 'checkin',
        },
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> addAnniversary({
    required CoupleProfile profile,
    required String title,
    required DateTime date,
    required String kind,
  }) async {
    await appendEvent(
      PairEvent(
        eventId: _uuid.v4(),
        pairId: profile.pairId,
        deviceId: profile.myDeviceId,
        type: EventType.addAnniversary,
        payload: {
          'id': _uuid.v4(),
          'title': title,
          'date': date.toIso8601String(),
          'kind': kind,
        },
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<List<TimelineEntry>> timeline(CoupleProfile profile) async {
    final events = await eventsByPair(profile.pairId);
    final entries = <TimelineEntry>[];

    for (final event in events) {
      if (event.type == EventType.addNote) {
        final tags = (event.payload['tags'] as List<dynamic>? ?? <dynamic>[])
            .map((e) => e.toString())
            .toList();
        entries.add(
          TimelineEntry(
            id: event.eventId,
            date: event.createdAt,
            text: (event.payload['text'] as String?) ?? '',
            imagePath: event.payload['imagePath'] as String?,
            mood: event.payload['mood'] as String?,
            tags: tags,
          ),
        );
      }
    }

    return entries;
  }

  Future<GrowthScore> growthScore(CoupleProfile profile) async {
    final events = await eventsByPair(profile.pairId);
    var score = GrowthScore.zero;

    for (final event in events) {
      if (event.type == EventType.addScore) {
        score = score.add(
          intimacy: (event.payload['intimacy'] as num?)?.toInt() ?? 0,
          activity: (event.payload['activity'] as num?)?.toInt() ?? 0,
          chemistry: (event.payload['chemistry'] as num?)?.toInt() ?? 0,
        );
      }

      if (event.type == EventType.addNote) {
        score = score.add(activity: 1);
      }
    }

    return score;
  }

  Future<List<AnniversaryItem>> anniversaries(CoupleProfile profile) async {
    final events = await eventsByPair(profile.pairId);
    return events
        .where((event) => event.type == EventType.addAnniversary)
        .map(
          (event) => AnniversaryItem(
            id: event.payload['id'] as String,
            title: event.payload['title'] as String,
            date: DateTime.parse(event.payload['date'] as String),
            kind: event.payload['kind'] as String,
          ),
        )
        .toList();
  }

  Future<void> mergeRemoteEvents(List<PairEvent> remoteEvents) async {
    for (final event in remoteEvents) {
      await appendEvent(event);
    }
  }

  @visibleForTesting
  Future<void> clearAll() async {
    final database = await _localDb.db;
    await database.delete('events');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }
}
