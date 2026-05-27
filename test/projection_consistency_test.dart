import 'package:flutter_test/flutter_test.dart';
import 'package:pairnest/src/data/pair_repository.dart';
import 'package:pairnest/src/domain/models.dart';

PairEvent _event({
  required String id,
  required EventType type,
  required DateTime at,
  required Map<String, dynamic> payload,
  String deviceId = 'device-a',
}) {
  return PairEvent(
    eventId: id,
    pairId: 'pair-1',
    deviceId: deviceId,
    type: type,
    payload: payload,
    createdAt: at,
  );
}

List<TimelineEntry> _timelineEntries(List<PairEvent> events) {
  return events
      .map(PairRepository.timelineEntryFromEvent)
      .whereType<TimelineEntry>()
      .toList();
}

List<GrowthTaskRecord> _taskRecords(List<PairEvent> events) {
  return events
      .map(PairRepository.growthTaskRecordFromEvent)
      .whereType<GrowthTaskRecord>()
      .toList();
}

List<PartnerScoreRecord> _partnerScoreRecords(List<PairEvent> events) {
  return events
      .map(PairRepository.partnerScoreRecordFromEvent)
      .whereType<PartnerScoreRecord>()
      .toList();
}

List<AnniversaryItem> _anniversaryItems(List<PairEvent> events) {
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

void main() {
  test(
    'timeline note event affects timeline, today status and growth together',
    () {
      final events = <PairEvent>[
        _event(
          id: 'note-1',
          type: EventType.addNote,
          at: DateTime(2026, 5, 27, 9, 30),
          payload: {
            'text': '一起吃早餐',
            'mood': '轻松',
            'tags': ['日常', '早晨'],
          },
        ),
        _event(
          id: 'mood-1',
          type: EventType.addMood,
          at: DateTime(2026, 5, 27, 9, 31),
          payload: {'mood': '轻松'},
        ),
      ];

      final timeline = _timelineEntries(events);
      final status = PairRepository.todayStatusFromEvents(
        events,
        DateTime(2026, 5, 27, 21),
      );
      final score = PairRepository.growthScoreFromEvents(events);

      expect(timeline, hasLength(1));
      expect(timeline.first.text, '一起吃早餐');
      expect(status.noteCount, 1);
      expect(status.latestMood, '轻松');
      expect(score.activity, 1);
    },
  );

  test(
    'partner feedback event affects timeline, growth and partner history together',
    () {
      final events = <PairEvent>[
        _event(
          id: 'score-feedback-1',
          type: EventType.addScore,
          at: DateTime(2026, 5, 27, 20, 0),
          payload: {
            'title': '下雨天来接我',
            'detail': '提前半小时到楼下等我。',
            'intimacy': 3,
            'activity': 1,
            'chemistry': 2,
            'reason': 'partner_feedback',
            'imagePath': '/tmp/rain.jpg',
          },
        ),
      ];

      final timeline = _timelineEntries(events);
      final score = PairRepository.growthScoreFromEvents(events);
      final history = _partnerScoreRecords(events);

      expect(timeline, hasLength(1));
      expect(timeline.first.tags, containsAll(['奖惩记录', '加分']));
      expect(score.total, 6);
      expect(history, hasLength(1));
      expect(history.first.imagePath, '/tmp/rain.jpg');
    },
  );

  test('task and checkin update growth-side projections but not timeline', () {
    final events = <PairEvent>[
      _event(
        id: 'checkin-1',
        type: EventType.dailyCheckin,
        at: DateTime(2026, 5, 27, 8, 0),
        payload: {'date': DateTime(2026, 5, 27, 8).toIso8601String()},
      ),
      _event(
        id: 'task-1',
        type: EventType.completeTask,
        at: DateTime(2026, 5, 27, 19, 0),
        payload: {
          'taskTitle': '一起做饭',
          'completedAt': DateTime(2026, 5, 27, 19).toIso8601String(),
        },
      ),
      _event(
        id: 'score-task-1',
        type: EventType.addScore,
        at: DateTime(2026, 5, 27, 19, 0, 1),
        payload: {
          'intimacy': 2,
          'activity': 2,
          'chemistry': 1,
          'reason': 'task_completion',
        },
      ),
      _event(
        id: 'score-checkin-1',
        type: EventType.addScore,
        at: DateTime(2026, 5, 27, 8, 0, 1),
        payload: {
          'intimacy': 5,
          'activity': 3,
          'chemistry': 2,
          'reason': 'checkin',
        },
      ),
    ];

    final timeline = _timelineEntries(events);
    final status = PairRepository.todayStatusFromEvents(
      events,
      DateTime(2026, 5, 27, 21),
    );
    final score = PairRepository.growthScoreFromEvents(events);
    final tasks = _taskRecords(events);

    expect(timeline, isEmpty);
    expect(status.checkinDone, isTrue);
    expect(status.completedTaskCount, 1);
    expect(score.total, 15);
    expect(tasks, hasLength(1));
    expect(tasks.first.title, '一起做饭');
  });

  test('anniversary event affects timeline and anniversary list together', () {
    final events = <PairEvent>[
      _event(
        id: 'ann-1',
        type: EventType.addAnniversary,
        at: DateTime(2026, 5, 27, 10, 0),
        payload: {
          'id': 'anniversary-1',
          'title': '第一次旅行',
          'date': DateTime(2026, 8, 20).toIso8601String(),
          'kind': '特殊日期',
          'remindDays': 7,
        },
      ),
    ];

    final timeline = _timelineEntries(events);
    final anniversaries = _anniversaryItems(events);

    expect(timeline, hasLength(1));
    expect(timeline.first.text, contains('新增特殊日期：第一次旅行'));
    expect(anniversaries, hasLength(1));
    expect(anniversaries.first.title, '第一次旅行');
    expect(anniversaries.first.kind, '特殊日期');
  });

  test(
    'remote bind event affects pairing status without changing timeline',
    () {
      final profile = CoupleProfile(
        pairId: 'pair-1',
        myDeviceId: 'device-a',
        meName: '小王',
        partnerName: '小李',
        startedAt: DateTime(2026, 5, 1),
      );
      final events = <PairEvent>[
        _event(
          id: 'bind-a',
          type: EventType.bindPair,
          at: DateTime(2026, 5, 27, 9, 0),
          payload: {
            'meName': '小王',
            'partnerName': '小李',
            'startedAt': DateTime(2026, 5, 1).toIso8601String(),
          },
          deviceId: 'device-a',
        ),
        _event(
          id: 'bind-b',
          type: EventType.bindPair,
          at: DateTime(2026, 5, 27, 9, 30),
          payload: {
            'meName': '小李',
            'partnerName': '小王',
            'startedAt': DateTime(2026, 5, 1).toIso8601String(),
          },
          deviceId: 'device-b',
        ),
      ];

      final timeline = _timelineEntries(events);
      final pairing = PairRepository.pairingStatusFromEvents(events, profile);

      expect(timeline, isEmpty);
      expect(pairing.isPairedAcrossDevices, isTrue);
      expect(pairing.remoteParticipantNames, ['小李']);
      expect(pairing.syncedDeviceCount, 2);
    },
  );
}
