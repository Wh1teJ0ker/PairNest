import 'models.dart';

abstract class SyncRepositoryPort {
  Future<List<PairEvent>> eventsByPair(String pairId);

  List<Map<String, dynamic>> serializeEvents(List<PairEvent> events);

  List<PairEvent> deserializeEvents(List<dynamic> raw);

  Future<bool> hasEvent(String eventId);

  Future<void> appendEvent(PairEvent event);

  Future<int> crossDeviceNoteDays(String pairId);

  Future<void> mergeRemoteEvents(List<PairEvent> remoteEvents);
}
