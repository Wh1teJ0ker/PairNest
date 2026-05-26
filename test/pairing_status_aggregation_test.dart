import 'package:flutter_test/flutter_test.dart';
import 'package:pairnest/src/data/pair_repository.dart';
import 'package:pairnest/src/domain/models.dart';

PairEvent _bindEvent({
  required String eventId,
  required String deviceId,
  required String meName,
  required String partnerName,
  required DateTime createdAt,
}) {
  return PairEvent(
    eventId: eventId,
    pairId: 'pair-1',
    deviceId: deviceId,
    type: EventType.bindPair,
    payload: {
      'meName': meName,
      'partnerName': partnerName,
      'startedAt': DateTime(2026, 5, 1).toIso8601String(),
    },
    createdAt: createdAt,
  );
}

void main() {
  final profile = CoupleProfile(
    pairId: 'pair-1',
    myDeviceId: 'device-a',
    meName: '小王',
    partnerName: '小李',
    startedAt: DateTime(2026, 5, 1),
  );

  test(
    'pairingStatusFromEvents reports waiting state for single-device bind',
    () {
      final status = PairRepository.pairingStatusFromEvents([
        _bindEvent(
          eventId: 'bind-a',
          deviceId: 'device-a',
          meName: '小王',
          partnerName: '小李',
          createdAt: DateTime(2026, 5, 26, 9),
        ),
      ], profile);

      expect(status.hasLocalBinding, isTrue);
      expect(status.hasRemoteBinding, isFalse);
      expect(status.isPairedAcrossDevices, isFalse);
      expect(status.syncedDeviceCount, 1);
      expect(status.summaryLabel, contains('等待对方设备'));
    },
  );

  test(
    'pairingStatusFromEvents reports paired state for remote bind event',
    () {
      final status = PairRepository.pairingStatusFromEvents([
        _bindEvent(
          eventId: 'bind-a',
          deviceId: 'device-a',
          meName: '小王',
          partnerName: '小李',
          createdAt: DateTime(2026, 5, 26, 9),
        ),
        _bindEvent(
          eventId: 'bind-b',
          deviceId: 'device-b',
          meName: '小李',
          partnerName: '小王',
          createdAt: DateTime(2026, 5, 26, 9, 30),
        ),
      ], profile);

      expect(status.hasRemoteBinding, isTrue);
      expect(status.isPairedAcrossDevices, isTrue);
      expect(status.remoteDeviceIds, ['device-b']);
      expect(status.remoteParticipantNames, ['小李']);
      expect(status.syncedDeviceCount, 2);
      expect(status.summaryLabel, contains('已与 小李 完成双端匹配'));
    },
  );
}
