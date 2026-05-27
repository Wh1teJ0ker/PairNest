import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../domain/models.dart';
import '../domain/sync_port.dart';
import 'local_db.dart';

class DuplicateDailyCheckinException implements Exception {
  const DuplicateDailyCheckinException();

  @override
  String toString() => '今天已经签到过了';
}

class PairRepository implements SyncRepositoryPort {
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
    return CoupleProfile.fromJson(map);
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

  Future<CoupleProfile> joinCoupleByInvite({
    required String meName,
    required String pairId,
    required String partnerName,
    required DateTime startedAt,
  }) async {
    final profile = CoupleProfile(
      pairId: pairId,
      myDeviceId: _uuid.v4(),
      meName: meName.trim(),
      partnerName: partnerName.trim(),
      startedAt: startedAt,
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
          'joinMode': 'scan_qr',
        },
        createdAt: DateTime.now(),
      ),
    );
    return profile;
  }

  Future<void> _saveProfile(CoupleProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  @override
  Future<void> appendEvent(PairEvent event) async {
    final database = await _localDb.db;
    await database.insert(
      'events',
      event.toDb(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  @override
  Future<bool> hasEvent(String eventId) async {
    final database = await _localDb.db;
    final rows = await database.query(
      'events',
      columns: ['event_id'],
      where: 'event_id = ?',
      whereArgs: [eventId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  @override
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

  Future<void> addTimelineEntry({
    required CoupleProfile profile,
    required String text,
    String? mood,
    String? imagePath,
    List<String> tags = const <String>[],
  }) async {
    String? localImagePath = imagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      localImagePath = await _persistImageToLocalStorage(imagePath);
    }

    await appendEvent(
      PairEvent(
        eventId: _uuid.v4(),
        pairId: profile.pairId,
        deviceId: profile.myDeviceId,
        type: EventType.addNote,
        payload: {
          'text': text,
          'mood': mood,
          'imagePath': localImagePath,
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

    if (localImagePath != null && localImagePath.isNotEmpty) {
      await appendEvent(
        PairEvent(
          eventId: _uuid.v4(),
          pairId: profile.pairId,
          deviceId: profile.myDeviceId,
          type: EventType.addImage,
          payload: {'imagePath': localImagePath, 'source': 'note'},
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> addPartnerScoreRecord({
    required CoupleProfile profile,
    required String title,
    required int intimacyDelta,
    required int activityDelta,
    required int chemistryDelta,
    String? detail,
    String? imagePath,
  }) async {
    String? localImagePath = imagePath;
    final scoreEventId = _uuid.v4();
    final createdAt = DateTime.now();

    if (localImagePath != null && localImagePath.isNotEmpty) {
      localImagePath = await _persistImageToLocalStorage(localImagePath);
    }

    await appendEvent(
      PairEvent(
        eventId: scoreEventId,
        pairId: profile.pairId,
        deviceId: profile.myDeviceId,
        type: EventType.addScore,
        payload: {
          'title': title.trim(),
          'detail': detail?.trim(),
          'intimacy': intimacyDelta,
          'activity': activityDelta,
          'chemistry': chemistryDelta,
          'reason': 'partner_feedback',
          'imagePath': localImagePath,
        },
        createdAt: createdAt,
      ),
    );

    if (localImagePath != null && localImagePath.isNotEmpty) {
      await appendEvent(
        PairEvent(
          eventId: _uuid.v4(),
          pairId: profile.pairId,
          deviceId: profile.myDeviceId,
          type: EventType.addImage,
          payload: {
            'imagePath': localImagePath,
            'source': 'partner_feedback',
            'relatedEventId': scoreEventId,
          },
          createdAt: createdAt,
        ),
      );
    }
  }

  Future<void> checkinTogether(CoupleProfile profile) async {
    final database = await _localDb.db;
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    await database.transaction((txn) async {
      final existing = await txn.query(
        'events',
        columns: ['event_id'],
        where:
            'pair_id = ? AND event_type = ? AND created_at >= ? AND created_at < ?',
        whereArgs: [
          profile.pairId,
          EventType.dailyCheckin.value,
          dayStart.toIso8601String(),
          dayEnd.toIso8601String(),
        ],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        throw const DuplicateDailyCheckinException();
      }

      final checkinEvent = PairEvent(
        eventId: _uuid.v4(),
        pairId: profile.pairId,
        deviceId: profile.myDeviceId,
        type: EventType.dailyCheckin,
        payload: {'date': now.toIso8601String()},
        createdAt: now,
      );

      final scoreEvent = PairEvent(
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
        createdAt: now,
      );

      await txn.insert(
        'events',
        checkinEvent.toDb(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      await txn.insert(
        'events',
        scoreEvent.toDb(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    });
  }

  Future<void> completeTaskTogether({
    required CoupleProfile profile,
    required String taskTitle,
  }) async {
    await appendEvent(
      PairEvent(
        eventId: _uuid.v4(),
        pairId: profile.pairId,
        deviceId: profile.myDeviceId,
        type: EventType.completeTask,
        payload: {
          'taskTitle': taskTitle,
          'completedAt': DateTime.now().toIso8601String(),
        },
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
          'intimacy': 4,
          'activity': 2,
          'chemistry': 4,
          'reason': 'complete_task',
          'taskTitle': taskTitle,
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
          'remindDays': 7,
        },
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<List<TimelineEntry>> timeline(CoupleProfile profile) async {
    final events = await eventsByPair(profile.pairId);
    final entries = <TimelineEntry>[];

    for (final event in events) {
      final entry = timelineEntryFromEvent(event);
      if (entry != null) {
        entries.add(entry);
      }
    }

    return entries;
  }

  @visibleForTesting
  static TimelineEntry? timelineEntryFromEvent(PairEvent event) {
    if (event.type == EventType.addNote) {
      final tags = (event.payload['tags'] as List<dynamic>? ?? <dynamic>[])
          .map((e) => e.toString())
          .toList();
      return TimelineEntry(
        id: event.eventId,
        date: event.createdAt,
        text: (event.payload['text'] as String?) ?? '',
        imagePath: event.payload['imagePath'] as String?,
        mood: event.payload['mood'] as String?,
        tags: tags,
      );
    }

    if (event.type == EventType.addAnniversary) {
      final title = (event.payload['title'] as String?)?.trim();
      if (title == null || title.isEmpty) {
        return null;
      }
      final kind = (event.payload['kind'] as String?)?.trim();
      final targetDate = DateTime.tryParse(
        event.payload['date'] as String? ?? '',
      );
      final targetDateLabel = targetDate == null
          ? ''
          : '${targetDate.year}.${targetDate.month.toString().padLeft(2, '0')}.${targetDate.day.toString().padLeft(2, '0')}';
      final label = (kind == null || kind.isEmpty) ? '纪念日' : kind;
      final text = targetDateLabel.isEmpty
          ? '新增$label：$title'
          : '新增$label：$title（$targetDateLabel）';
      final tags = <String>{'纪念日', label}.toList();
      return TimelineEntry(
        id: event.eventId,
        date: event.createdAt,
        text: text,
        tags: tags,
      );
    }

    if (event.type == EventType.addScore &&
        event.payload['reason'] == 'partner_feedback') {
      final title = (event.payload['title'] as String?)?.trim();
      if (title == null || title.isEmpty) {
        return null;
      }
      final detail = (event.payload['detail'] as String?)?.trim();
      final tags = <String>['奖惩记录'];
      final total =
          ((event.payload['intimacy'] as num?)?.toInt() ?? 0) +
          ((event.payload['activity'] as num?)?.toInt() ?? 0) +
          ((event.payload['chemistry'] as num?)?.toInt() ?? 0);
      tags.add(total >= 0 ? '加分' : '减分');
      return TimelineEntry(
        id: event.eventId,
        date: event.createdAt,
        text: detail == null || detail.isEmpty ? title : '$title\n$detail',
        imagePath: event.payload['imagePath'] as String?,
        tags: tags,
      );
    }

    return null;
  }

  Future<GrowthScore> growthScore(CoupleProfile profile) async {
    final events = await eventsByPair(profile.pairId);
    return growthScoreFromEvents(events);
  }

  @visibleForTesting
  static GrowthScore growthScoreFromEvents(List<PairEvent> events) {
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

  Future<List<GrowthTaskRecord>> recentGrowthTasks(
    CoupleProfile profile, {
    int limit = 8,
  }) async {
    final events = await eventsByPair(profile.pairId);
    final records = events
        .where((event) => event.type == EventType.completeTask)
        .map(growthTaskRecordFromEvent)
        .whereType<GrowthTaskRecord>()
        .toList();
    records.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    if (records.length <= limit) {
      return records;
    }
    return records.take(limit).toList();
  }

  Future<List<PartnerScoreRecord>> recentPartnerScoreRecords(
    CoupleProfile profile, {
    int limit = 10,
  }) async {
    final events = await eventsByPair(profile.pairId);
    final records = events
        .where(
          (event) =>
              event.type == EventType.addScore &&
              event.payload['reason'] == 'partner_feedback',
        )
        .map(partnerScoreRecordFromEvent)
        .whereType<PartnerScoreRecord>()
        .toList();
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (records.length <= limit) {
      return records;
    }
    return records.take(limit).toList();
  }

  @visibleForTesting
  static GrowthTaskRecord? growthTaskRecordFromEvent(PairEvent event) {
    if (event.type != EventType.completeTask) {
      return null;
    }
    final title = (event.payload['taskTitle'] as String?)?.trim();
    if (title == null || title.isEmpty) {
      return null;
    }
    final completedAtText = event.payload['completedAt'] as String?;
    final completedAt = DateTime.tryParse(completedAtText ?? '');
    return GrowthTaskRecord(
      id: event.eventId,
      title: title,
      completedAt: completedAt ?? event.createdAt,
      deviceId: event.deviceId,
    );
  }

  @visibleForTesting
  static PartnerScoreRecord? partnerScoreRecordFromEvent(PairEvent event) {
    if (event.type != EventType.addScore ||
        event.payload['reason'] != 'partner_feedback') {
      return null;
    }
    final title = (event.payload['title'] as String?)?.trim();
    if (title == null || title.isEmpty) {
      return null;
    }
    return PartnerScoreRecord(
      id: event.eventId,
      title: title,
      detail: (event.payload['detail'] as String?)?.trim(),
      imagePath: event.payload['imagePath'] as String?,
      createdAt: event.createdAt,
      intimacyDelta: (event.payload['intimacy'] as num?)?.toInt() ?? 0,
      activityDelta: (event.payload['activity'] as num?)?.toInt() ?? 0,
      chemistryDelta: (event.payload['chemistry'] as num?)?.toInt() ?? 0,
    );
  }

  Future<List<AnniversaryItem>> anniversaries(CoupleProfile profile) async {
    final events = await eventsByPair(profile.pairId);
    final items = events
        .where((event) => event.type == EventType.addAnniversary)
        .map(
          (event) => AnniversaryItem(
            id: event.payload['id'] as String,
            title: event.payload['title'] as String,
            date: DateTime.parse(event.payload['date'] as String),
            kind: event.payload['kind'] as String,
            remindDays: (event.payload['remindDays'] as num?)?.toInt() ?? 7,
          ),
        )
        .toList();
    items.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    return items;
  }

  Future<TodayStatus> todayStatus(CoupleProfile profile) async {
    final events = await eventsByPair(profile.pairId);
    return todayStatusFromEvents(events, DateTime.now());
  }

  Future<PairingStatus> pairingStatus(CoupleProfile profile) async {
    final events = await eventsByPair(profile.pairId);
    return pairingStatusFromEvents(events, profile);
  }

  @visibleForTesting
  static TodayStatus todayStatusFromEvents(
    List<PairEvent> events,
    DateTime now,
  ) {
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    var checkinDone = false;
    var noteCount = 0;
    var completedTaskCount = 0;
    String? latestMood;
    DateTime? latestMoodAt;

    for (final event in events) {
      final inToday =
          !event.createdAt.isBefore(dayStart) &&
          event.createdAt.isBefore(dayEnd);
      if (!inToday) {
        continue;
      }

      if (event.type == EventType.dailyCheckin) {
        checkinDone = true;
      }
      if (event.type == EventType.addNote) {
        noteCount += 1;
      }
      if (event.type == EventType.completeTask) {
        completedTaskCount += 1;
      }
      if (event.type == EventType.addMood) {
        final mood = event.payload['mood'] as String?;
        if (mood != null &&
            (latestMoodAt == null || event.createdAt.isAfter(latestMoodAt))) {
          latestMood = mood;
          latestMoodAt = event.createdAt;
        }
      }
    }

    return TodayStatus(
      checkinDone: checkinDone,
      noteCount: noteCount,
      completedTaskCount: completedTaskCount,
      latestMood: latestMood,
    );
  }

  @visibleForTesting
  static PairingStatus pairingStatusFromEvents(
    List<PairEvent> events,
    CoupleProfile profile,
  ) {
    final bindEvents = events.where(
      (event) => event.type == EventType.bindPair,
    );
    final Map<String, PairEvent> latestByDevice = <String, PairEvent>{};

    for (final event in bindEvents) {
      final current = latestByDevice[event.deviceId];
      if (current == null || event.createdAt.isAfter(current.createdAt)) {
        latestByDevice[event.deviceId] = event;
      }
    }

    final hasLocalBinding = latestByDevice.containsKey(profile.myDeviceId);
    final remoteEntries =
        latestByDevice.entries
            .where((entry) => entry.key != profile.myDeviceId)
            .toList()
          ..sort((a, b) => b.value.createdAt.compareTo(a.value.createdAt));

    final participantNames =
        latestByDevice.values
            .map((event) => (event.payload['meName'] as String?)?.trim() ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    final remoteParticipantNames = remoteEntries
        .map(
          (entry) => (entry.value.payload['meName'] as String?)?.trim() ?? '',
        )
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    final remoteDeviceIds = remoteEntries.map((entry) => entry.key).toList();

    return PairingStatus(
      pairId: profile.pairId,
      myDeviceId: profile.myDeviceId,
      meName: profile.meName,
      expectedPartnerName: profile.partnerName,
      startedAt: profile.startedAt,
      participantNames: participantNames,
      remoteParticipantNames: remoteParticipantNames,
      remoteDeviceIds: remoteDeviceIds,
      syncedDeviceCount: latestByDevice.length,
      hasLocalBinding: hasLocalBinding,
      hasRemoteBinding: remoteEntries.isNotEmpty,
      lastRemoteBoundAt: remoteEntries.isEmpty
          ? null
          : remoteEntries.first.value.createdAt,
    );
  }

  @override
  Future<void> mergeRemoteEvents(List<PairEvent> remoteEvents) async {
    for (final event in remoteEvents) {
      await appendEvent(event);
    }
  }

  Future<void> updateEventImagePath({
    required String eventId,
    required String imagePath,
  }) async {
    final database = await _localDb.db;
    final rows = await database.query(
      'events',
      columns: ['event_id', 'payload'],
      where: 'event_id = ?',
      whereArgs: [eventId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return;
    }

    final payload =
        jsonDecode(rows.first['payload'] as String) as Map<String, dynamic>;
    payload['imagePath'] = imagePath;
    await database.update(
      'events',
      {'payload': jsonEncode(payload)},
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
  }

  Future<void> updateLinkedImagePath({
    required String imageEventId,
    required String imagePath,
  }) async {
    final database = await _localDb.db;
    final rows = await database.query(
      'events',
      columns: ['payload'],
      where: 'event_id = ?',
      whereArgs: [imageEventId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return;
    }

    final payload =
        jsonDecode(rows.first['payload'] as String) as Map<String, dynamic>;
    final relatedEventId = payload['relatedEventId'] as String?;
    if (relatedEventId == null || relatedEventId.isEmpty) {
      return;
    }
    await updateEventImagePath(eventId: relatedEventId, imagePath: imagePath);
  }

  @override
  List<Map<String, dynamic>> serializeEvents(List<PairEvent> events) {
    return events
        .map(
          (event) => {
            'eventId': event.eventId,
            'pairId': event.pairId,
            'deviceId': event.deviceId,
            'type': event.type.value,
            'payload': event.payload,
            'createdAt': event.createdAt.toIso8601String(),
          },
        )
        .toList();
  }

  @override
  List<PairEvent> deserializeEvents(List<dynamic> raw) {
    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (map) => PairEvent(
            eventId: map['eventId'] as String,
            pairId: map['pairId'] as String,
            deviceId: map['deviceId'] as String,
            type: EventTypeValue.fromValue(map['type'] as String),
            payload: (map['payload'] as Map).cast<String, dynamic>(),
            createdAt: DateTime.parse(map['createdAt'] as String),
          ),
        )
        .toList();
  }

  Future<String> _persistImageToLocalStorage(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(dir.path, 'timeline_media'));
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final ext = p.extension(sourcePath).toLowerCase();
    final filename =
        '${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}$ext';
    final targetPath = p.join(mediaDir.path, filename);
    final sourceFile = File(sourcePath);
    await sourceFile.copy(targetPath);
    return targetPath;
  }

  @override
  Future<int> crossDeviceNoteDays(String pairId) async {
    final database = await _localDb.db;
    final rows = await database.query(
      'events',
      columns: ['device_id', 'created_at', 'event_type'],
      where: 'pair_id = ? AND event_type = ?',
      whereArgs: [pairId, EventType.addNote.value],
    );

    final Map<String, Set<String>> dayToDeviceIds = <String, Set<String>>{};
    for (final row in rows) {
      final createdAt = DateTime.parse(row['created_at'] as String);
      final dayKey =
          '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
      dayToDeviceIds.putIfAbsent(dayKey, () => <String>{});
      dayToDeviceIds[dayKey]!.add(row['device_id'] as String);
    }

    return dayToDeviceIds.values.where((set) => set.length >= 2).length;
  }

  @visibleForTesting
  Future<void> clearAll() async {
    final database = await _localDb.db;
    await database.delete('events');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }
}
