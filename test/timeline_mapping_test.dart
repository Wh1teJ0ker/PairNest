import 'package:flutter_test/flutter_test.dart';
import 'package:pairnest/src/data/pair_repository.dart';
import 'package:pairnest/src/domain/models.dart';

void main() {
  test('timelineEntryFromEvent maps ADD_NOTE with details', () {
    final event = PairEvent(
      eventId: 'e-note',
      pairId: 'pair-1',
      deviceId: 'device-a',
      type: EventType.addNote,
      payload: {
        'text': '一起看电影',
        'mood': '开心',
        'imagePath': '/tmp/a.jpg',
        'tags': ['生活', '约会'],
      },
      createdAt: DateTime(2026, 5, 26, 9, 30),
    );

    final entry = PairRepository.timelineEntryFromEvent(event);

    expect(entry, isNotNull);
    expect(entry!.text, '一起看电影');
    expect(entry.mood, '开心');
    expect(entry.imagePath, '/tmp/a.jpg');
    expect(entry.tags, ['生活', '约会']);
  });

  test(
    'timelineEntryFromEvent maps ADD_ANNIVERSARY to timeline text and tags',
    () {
      final event = PairEvent(
        eventId: 'e-ann',
        pairId: 'pair-1',
        deviceId: 'device-a',
        type: EventType.addAnniversary,
        payload: {
          'id': 'ann-1',
          'title': '第一次旅行',
          'date': DateTime(2026, 8, 20).toIso8601String(),
          'kind': '特殊日期',
        },
        createdAt: DateTime(2026, 5, 26, 10),
      );

      final entry = PairRepository.timelineEntryFromEvent(event);

      expect(entry, isNotNull);
      expect(entry!.text, contains('新增特殊日期：第一次旅行'));
      expect(entry.text, contains('2026.08.20'));
      expect(entry.tags, containsAll(['纪念日', '特殊日期']));
    },
  );

  test(
    'timelineEntryFromEvent returns null for anniversary with empty title',
    () {
      final event = PairEvent(
        eventId: 'e-ann-empty',
        pairId: 'pair-1',
        deviceId: 'device-a',
        type: EventType.addAnniversary,
        payload: {
          'id': 'ann-2',
          'title': '   ',
          'date': DateTime(2026, 8, 20).toIso8601String(),
          'kind': '纪念日',
        },
        createdAt: DateTime(2026, 5, 26, 10),
      );

      final entry = PairRepository.timelineEntryFromEvent(event);
      expect(entry, isNull);
    },
  );

  test('timelineEntryFromEvent ignores checkin and task-only events', () {
    final checkinEvent = PairEvent(
      eventId: 'e-checkin',
      pairId: 'pair-1',
      deviceId: 'device-a',
      type: EventType.dailyCheckin,
      payload: {'date': DateTime(2026, 5, 27, 9).toIso8601String()},
      createdAt: DateTime(2026, 5, 27, 9),
    );
    final taskEvent = PairEvent(
      eventId: 'e-task',
      pairId: 'pair-1',
      deviceId: 'device-a',
      type: EventType.completeTask,
      payload: {
        'taskTitle': '一起做晚饭',
        'completedAt': DateTime(2026, 5, 27, 20).toIso8601String(),
      },
      createdAt: DateTime(2026, 5, 27, 20),
    );

    expect(PairRepository.timelineEntryFromEvent(checkinEvent), isNull);
    expect(PairRepository.timelineEntryFromEvent(taskEvent), isNull);
  });
}
