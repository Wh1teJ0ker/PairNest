import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pairnest/src/domain/models.dart';
import 'package:pairnest/src/domain/sync_port.dart';
import 'package:pairnest/src/features/sync/sync_session.dart';

class InMemorySyncRepository implements SyncRepositoryPort {
  InMemorySyncRepository(this.events);

  final List<PairEvent> events;

  @override
  Future<void> appendEvent(PairEvent event) async {
    if (events.any((e) => e.eventId == event.eventId)) {
      return;
    }
    events.add(event);
  }

  @override
  Future<int> crossDeviceNoteDays(String pairId) async {
    final relevant = events
        .where((e) => e.pairId == pairId && e.type == EventType.addNote)
        .toList();
    final Map<String, Set<String>> dayToDeviceIds = <String, Set<String>>{};
    for (final event in relevant) {
      final d = event.createdAt;
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      dayToDeviceIds.putIfAbsent(key, () => <String>{});
      dayToDeviceIds[key]!.add(event.deviceId);
    }
    return dayToDeviceIds.values.where((set) => set.length >= 2).length;
  }

  @override
  List<PairEvent> deserializeEvents(List<dynamic> raw) {
    return raw
        .map(
          (entry) => PairEvent(
            eventId: entry['eventId'] as String,
            pairId: entry['pairId'] as String,
            deviceId: entry['deviceId'] as String,
            type: EventTypeValue.fromValue(entry['type'] as String),
            payload: (entry['payload'] as Map).cast<String, dynamic>(),
            createdAt: DateTime.parse(entry['createdAt'] as String),
          ),
        )
        .toList();
  }

  @override
  Future<List<PairEvent>> eventsByPair(String pairId) async {
    return events.where((e) => e.pairId == pairId).toList();
  }

  @override
  Future<bool> hasEvent(String eventId) async {
    return events.any((e) => e.eventId == eventId);
  }

  @override
  Future<void> mergeRemoteEvents(List<PairEvent> remoteEvents) async {
    for (final event in remoteEvents) {
      if (!events.any((e) => e.eventId == event.eventId)) {
        events.add(event);
      }
    }
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
}

PairEvent buildEvent({
  required String id,
  required String pairId,
  required String deviceId,
  required EventType type,
  required DateTime createdAt,
  Map<String, dynamic> payload = const <String, dynamic>{},
}) {
  return PairEvent(
    eventId: id,
    pairId: pairId,
    deviceId: deviceId,
    type: type,
    payload: payload,
    createdAt: createdAt,
  );
}

void main() {
  group('SyncSession', () {
    late CoupleProfile profile;

    setUp(() {
      profile = CoupleProfile(
        pairId: 'pair-1',
        myDeviceId: 'device-a',
        meName: 'A',
        partnerName: 'B',
        startedAt: DateTime(2026, 1, 1),
      );
    });

    test('buildSyncResponse only includes missing events', () async {
      final repo = InMemorySyncRepository([
        buildEvent(
          id: 'e1',
          pairId: 'pair-1',
          deviceId: 'device-a',
          type: EventType.addNote,
          createdAt: DateTime(2026, 5, 26, 10),
        ),
        buildEvent(
          id: 'e2',
          pairId: 'pair-1',
          deviceId: 'device-a',
          type: EventType.addScore,
          createdAt: DateTime(2026, 5, 26, 11),
        ),
      ]);

      final session = SyncSession(repository: repo, profile: profile);
      final text = await session.buildSyncResponse(['e1']);
      final body = jsonDecode(text) as Map<String, dynamic>;
      final events = body['events'] as List<dynamic>;
      final ids = events
          .map((entry) => (entry as Map<String, dynamic>)['eventId'] as String)
          .toList();
      expect(ids, contains('e2'));
      expect(ids, isNot(contains('e1')));
    });

    test('mergeWithReport tracks inserts and duplicates', () async {
      final repo = InMemorySyncRepository([
        buildEvent(
          id: 'e1',
          pairId: 'pair-1',
          deviceId: 'device-a',
          type: EventType.addNote,
          createdAt: DateTime(2026, 5, 26, 10),
        ),
      ]);

      final session = SyncSession(repository: repo, profile: profile);
      final report = await session.mergeWithReport([
        {
          'eventId': 'e1',
          'pairId': 'pair-1',
          'deviceId': 'device-a',
          'type': 'ADD_NOTE',
          'payload': {},
          'createdAt': DateTime(2026, 5, 26, 10).toIso8601String(),
        },
        {
          'eventId': 'e2',
          'pairId': 'pair-1',
          'deviceId': 'device-b',
          'type': 'ADD_NOTE',
          'payload': {},
          'createdAt': DateTime(2026, 5, 26, 12).toIso8601String(),
        },
      ]);

      expect(report.insertedEvents, 1);
      expect(report.duplicateEvents, 1);
      expect(report.filteredPairMismatchEvents, 0);
      expect(report.crossDeviceNoteDays, 1);
    });

    test('mergeWithReport filters events from other pair ids', () async {
      final repo = InMemorySyncRepository([]);
      final session = SyncSession(repository: repo, profile: profile);
      final report = await session.mergeWithReport([
        {
          'eventId': 'e1',
          'pairId': 'pair-2',
          'deviceId': 'device-z',
          'type': 'ADD_NOTE',
          'payload': {'text': 'intrusive'},
          'createdAt': DateTime(2026, 5, 26, 10).toIso8601String(),
        },
      ]);

      expect(report.insertedEvents, 0);
      expect(report.duplicateEvents, 0);
      expect(report.filteredPairMismatchEvents, 1);
      expect(repo.events, isEmpty);
    });

    test(
      'collectMissingImageFiles returns existing image files only',
      () async {
        final tmp = await Directory.systemTemp.createTemp('pairnest_sync_test');
        addTearDown(() => tmp.delete(recursive: true));
        final existing = File(p.join(tmp.path, 'a.jpg'));
        await existing.writeAsBytes([1, 2, 3]);

        final repo = InMemorySyncRepository([
          buildEvent(
            id: 'img-1',
            pairId: 'pair-1',
            deviceId: 'device-a',
            type: EventType.addImage,
            payload: {'imagePath': existing.path},
            createdAt: DateTime(2026, 5, 26, 9),
          ),
          buildEvent(
            id: 'img-2',
            pairId: 'pair-1',
            deviceId: 'device-a',
            type: EventType.addImage,
            payload: {'imagePath': p.join(tmp.path, 'missing.jpg')},
            createdAt: DateTime(2026, 5, 26, 9),
          ),
        ]);

        final session = SyncSession(repository: repo, profile: profile);
        final files = await session.collectMissingImageFiles([]);
        expect(files.length, 1);
        expect(files.first.imageEventId, 'img-1');
        expect(files.first.filename, 'a.jpg');
        expect(files.first.pairId, 'pair-1');
      },
    );
  });
}
