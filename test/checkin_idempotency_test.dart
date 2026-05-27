import 'package:flutter_test/flutter_test.dart';
import 'package:pairnest/src/data/pair_repository.dart';
import 'package:pairnest/src/domain/models.dart';

void main() {
  test(
    'todayStatusFromEvents still reports signed in for multiple checkins same day',
    () {
      final now = DateTime(2026, 5, 27, 21, 0);
      final events = <PairEvent>[
        PairEvent(
          eventId: 'checkin-1',
          pairId: 'pair-1',
          deviceId: 'device-a',
          type: EventType.dailyCheckin,
          payload: {'date': DateTime(2026, 5, 27, 9, 0).toIso8601String()},
          createdAt: DateTime(2026, 5, 27, 9, 0),
        ),
        PairEvent(
          eventId: 'checkin-2',
          pairId: 'pair-1',
          deviceId: 'device-a',
          type: EventType.dailyCheckin,
          payload: {'date': DateTime(2026, 5, 27, 20, 0).toIso8601String()},
          createdAt: DateTime(2026, 5, 27, 20, 0),
        ),
      ];

      final status = PairRepository.todayStatusFromEvents(events, now);
      expect(status.checkinDone, isTrue);
      expect(status.noteCount, 0);
      expect(status.completedTaskCount, 0);
    },
  );

  test('duplicate daily checkin exception has stable message', () {
    expect(const DuplicateDailyCheckinException().toString(), '今天已经签到过了');
  });
}
