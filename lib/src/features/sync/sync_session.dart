import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../domain/models.dart';
import '../../domain/sync_port.dart';
import 'sync_models.dart';

class SyncSession {
  SyncSession({required this.repository, required this.profile});

  final SyncRepositoryPort repository;
  final CoupleProfile profile;

  Future<String> buildSyncRequest() async {
    final local = await repository.eventsByPair(profile.pairId);
    final ids = local.map((e) => e.eventId).toList();
    return jsonEncode({
      'kind': 'sync_request',
      'pairId': profile.pairId,
      'deviceId': profile.myDeviceId,
      'knownEventIds': ids,
    });
  }

  Future<String> buildSyncResponse(List<String> knownEventIds) async {
    final local = await repository.eventsByPair(profile.pairId);
    final localIds = local.map((event) => event.eventId).toList();
    final missing = _missingEvents(local, knownEventIds);
    return jsonEncode({
      'kind': 'sync_events',
      'pairId': profile.pairId,
      'deviceId': profile.myDeviceId,
      'events': repository.serializeEvents(missing.toList()),
      'responderKnownEventIds': localIds,
    });
  }

  Future<String> buildDeltaSyncPushPayload(
    List<String> remoteKnownEventIds,
  ) async {
    final local = await repository.eventsByPair(profile.pairId);
    final missing = _missingEvents(local, remoteKnownEventIds);
    return jsonEncode({
      'kind': 'sync_events_push',
      'pairId': profile.pairId,
      'deviceId': profile.myDeviceId,
      'events': repository.serializeEvents(missing.toList()),
    });
  }

  bool isMatchingPair(String? pairId) => pairId == profile.pairId;

  Future<void> handleSyncEvents(List<dynamic> rawEvents) async {
    final events = repository.deserializeEvents(rawEvents);
    await repository.mergeRemoteEvents(events);
  }

  Future<List<OutboundFileTransfer>> collectMissingImageFiles(
    List<String> knownEventIds,
  ) async {
    final events = await repository.eventsByPair(profile.pairId);
    final missing = _missingEvents(events, knownEventIds);
    final transfers = <OutboundFileTransfer>[];

    for (final event in missing) {
      if (event.type != EventType.addImage) {
        continue;
      }
      final imagePath = event.payload['imagePath'] as String?;
      if (imagePath == null || imagePath.isEmpty) {
        continue;
      }
      final file = File(imagePath);
      if (!await file.exists()) {
        continue;
      }
      transfers.add(
        OutboundFileTransfer(
          sourcePath: imagePath,
          filename: p.basename(imagePath),
          imageEventId: event.eventId,
          pairId: profile.pairId,
        ),
      );
    }
    return transfers;
  }

  String toRequestPayloadText() => jsonEncode({
    'kind': 'sync_request',
    'pairId': profile.pairId,
    'deviceId': profile.myDeviceId,
  });

  Future<SyncMergeReport> mergeWithReport(List<dynamic> rawEvents) async {
    final events = repository.deserializeEvents(rawEvents);
    var inserted = 0;
    var duplicate = 0;
    var pairMismatch = 0;

    for (final event in events) {
      if (!isMatchingPair(event.pairId)) {
        pairMismatch += 1;
        continue;
      }
      final exists = await repository.hasEvent(event.eventId);
      if (exists) {
        duplicate += 1;
        continue;
      }
      await repository.appendEvent(event);
      inserted += 1;
    }

    final crossDays = await repository.crossDeviceNoteDays(profile.pairId);
    return SyncMergeReport(
      insertedEvents: inserted,
      duplicateEvents: duplicate,
      filteredPairMismatchEvents: pairMismatch,
      crossDeviceNoteDays: crossDays,
    );
  }

  Iterable<PairEvent> _missingEvents(
    List<PairEvent> local,
    List<String> knownEventIds,
  ) {
    final known = knownEventIds.toSet();
    return local.where((event) => !known.contains(event.eventId));
  }
}
