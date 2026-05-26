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
  test('growth aggregation combines ADD_SCORE and note activity bonus', () {
    final events = <PairEvent>[
      _event(
        id: 'score-1',
        type: EventType.addScore,
        at: DateTime(2026, 5, 26, 9),
        payload: {'intimacy': 5, 'activity': 3, 'chemistry': 2},
      ),
      _event(
        id: 'note-1',
        type: EventType.addNote,
        at: DateTime(2026, 5, 26, 10),
      ),
      _event(
        id: 'score-2',
        type: EventType.addScore,
        at: DateTime(2026, 5, 26, 11),
        payload: {'intimacy': 4, 'activity': 2, 'chemistry': 4},
      ),
    ];

    final score = PairRepository.growthScoreFromEvents(events);
    expect(score.intimacy, 9);
    expect(score.activity, 6);
    expect(score.chemistry, 6);
    expect(score.total, 21);
  });
}
