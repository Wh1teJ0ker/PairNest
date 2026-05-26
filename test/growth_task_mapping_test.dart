import 'package:flutter_test/flutter_test.dart';
import 'package:pairnest/src/data/pair_repository.dart';
import 'package:pairnest/src/domain/models.dart';

void main() {
  test('growthTaskRecordFromEvent maps COMPLETE_TASK', () {
    final event = PairEvent(
      eventId: 'task-1',
      pairId: 'pair-1',
      deviceId: 'device-a',
      type: EventType.completeTask,
      payload: {
        'taskTitle': '一起做饭',
        'completedAt': DateTime(2026, 5, 26, 20, 30).toIso8601String(),
      },
      createdAt: DateTime(2026, 5, 26, 20, 31),
    );

    final record = PairRepository.growthTaskRecordFromEvent(event);
    expect(record, isNotNull);
    expect(record!.title, '一起做饭');
    expect(record.deviceId, 'device-a');
    expect(record.completedAt, DateTime(2026, 5, 26, 20, 30));
  });

  test('growthTaskRecordFromEvent ignores empty title', () {
    final event = PairEvent(
      eventId: 'task-2',
      pairId: 'pair-1',
      deviceId: 'device-a',
      type: EventType.completeTask,
      payload: {'taskTitle': '   '},
      createdAt: DateTime(2026, 5, 26, 20, 31),
    );

    final record = PairRepository.growthTaskRecordFromEvent(event);
    expect(record, isNull);
  });
}
