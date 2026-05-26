import 'package:flutter_test/flutter_test.dart';
import 'package:pairnest/src/data/pair_repository.dart';
import 'package:pairnest/src/domain/models.dart';

PairEvent _event({
  required String id,
  required EventType type,
  required DateTime at,
  Map<String, dynamic> payload = const <String, dynamic>{},
}) {
  return PairEvent(
    eventId: id,
    pairId: 'pair-1',
    deviceId: 'device-a',
    type: type,
    payload: payload,
    createdAt: at,
  );
}

void main() {
  test('todayStatusFromEvents counts checkin/note/task and latest mood', () {
    final now = DateTime(2026, 5, 26, 21, 0);
    final events = <PairEvent>[
      _event(
        id: 'old-note',
        type: EventType.addNote,
        at: DateTime(2026, 5, 25, 23, 50),
      ),
      _event(
        id: 'task-1',
        type: EventType.completeTask,
        at: DateTime(2026, 5, 26, 10, 0),
        payload: {'taskTitle': '一起做饭'},
      ),
      _event(
        id: 'checkin',
        type: EventType.dailyCheckin,
        at: DateTime(2026, 5, 26, 11, 0),
      ),
      _event(
        id: 'mood-late',
        type: EventType.addMood,
        at: DateTime(2026, 5, 26, 13, 0),
        payload: {'mood': '开心'},
      ),
      _event(
        id: 'mood-early',
        type: EventType.addMood,
        at: DateTime(2026, 5, 26, 8, 0),
        payload: {'mood': '平静'},
      ),
      _event(
        id: 'note-1',
        type: EventType.addNote,
        at: DateTime(2026, 5, 26, 9, 0),
      ),
      _event(
        id: 'task-2',
        type: EventType.completeTask,
        at: DateTime(2026, 5, 26, 19, 0),
        payload: {'taskTitle': '一起散步'},
      ),
    ];

    final status = PairRepository.todayStatusFromEvents(events, now);
    expect(status.checkinDone, isTrue);
    expect(status.noteCount, 1);
    expect(status.completedTaskCount, 2);
    expect(status.latestMood, '开心');
  });

  test('todayStatusFromEvents includes events at day start boundary', () {
    final now = DateTime(2026, 5, 26, 12, 0);
    final events = <PairEvent>[
      _event(
        id: 'exact-start',
        type: EventType.addNote,
        at: DateTime(2026, 5, 26, 0, 0),
      ),
      _event(
        id: 'prev-end',
        type: EventType.addNote,
        at: DateTime(2026, 5, 25, 23, 59, 59),
      ),
      _event(
        id: 'next-start',
        type: EventType.addNote,
        at: DateTime(2026, 5, 27, 0, 0),
      ),
    ];

    final status = PairRepository.todayStatusFromEvents(events, now);
    expect(status.noteCount, 1);
  });

  test(
    'todayStatusFromEvents picks latest mood by timestamp not list order',
    () {
      final now = DateTime(2026, 5, 26, 21, 0);
      final events = <PairEvent>[
        _event(
          id: 'mood-new',
          type: EventType.addMood,
          at: DateTime(2026, 5, 26, 20, 0),
          payload: {'mood': '兴奋'},
        ),
        _event(
          id: 'mood-old',
          type: EventType.addMood,
          at: DateTime(2026, 5, 26, 9, 0),
          payload: {'mood': '平静'},
        ),
      ];

      final status = PairRepository.todayStatusFromEvents(events, now);
      expect(status.latestMood, '兴奋');
    },
  );
}
