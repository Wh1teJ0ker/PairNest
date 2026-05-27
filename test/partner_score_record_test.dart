import 'package:flutter_test/flutter_test.dart';
import 'package:pairnest/src/data/pair_repository.dart';
import 'package:pairnest/src/domain/models.dart';

PairEvent _scoreEvent({
  required String id,
  required DateTime at,
  required Map<String, dynamic> payload,
}) {
  return PairEvent(
    eventId: id,
    pairId: 'pair-1',
    deviceId: 'device-a',
    type: EventType.addScore,
    payload: payload,
    createdAt: at,
  );
}

void main() {
  test('partnerScoreRecordFromEvent maps partner feedback score record', () {
    final event = _scoreEvent(
      id: 'score-feedback-1',
      at: DateTime(2026, 5, 27, 20, 30),
      payload: {
        'title': '记得带伞来接我',
        'detail': '下雨天专门绕路过来，值得表扬。',
        'intimacy': 4,
        'activity': 1,
        'chemistry': 3,
        'reason': 'partner_feedback',
        'imagePath': '/tmp/rain.jpg',
      },
    );

    final record = PairRepository.partnerScoreRecordFromEvent(event);

    expect(record, isNotNull);
    expect(record!.title, '记得带伞来接我');
    expect(record.detail, '下雨天专门绕路过来，值得表扬。');
    expect(record.totalDelta, 8);
    expect(record.imagePath, '/tmp/rain.jpg');
    expect(record.isPositive, isTrue);
  });

  test(
    'partner feedback score contributes negative deltas to growth score',
    () {
      final events = <PairEvent>[
        _scoreEvent(
          id: 'score-feedback-2',
          at: DateTime(2026, 5, 27, 21),
          payload: {
            'title': '忘记约定时间',
            'intimacy': -3,
            'activity': -1,
            'chemistry': -2,
            'reason': 'partner_feedback',
          },
        ),
      ];

      final score = PairRepository.growthScoreFromEvents(events);
      expect(score.intimacy, -3);
      expect(score.activity, -1);
      expect(score.chemistry, -2);
      expect(score.total, -6);
    },
  );

  test('timelineEntryFromEvent maps partner feedback score with image', () {
    final event = _scoreEvent(
      id: 'score-feedback-3',
      at: DateTime(2026, 5, 27, 22),
      payload: {
        'title': '临时放鸽子',
        'detail': '需要提醒下次提前说。',
        'intimacy': -2,
        'activity': -1,
        'chemistry': -1,
        'reason': 'partner_feedback',
        'imagePath': '/tmp/later.jpg',
      },
    );

    final entry = PairRepository.timelineEntryFromEvent(event);

    expect(entry, isNotNull);
    expect(entry!.text, contains('临时放鸽子'));
    expect(entry.text, contains('需要提醒下次提前说。'));
    expect(entry.imagePath, '/tmp/later.jpg');
    expect(entry.tags, containsAll(['奖惩记录', '减分']));
  });
}
