import 'package:flutter_test/flutter_test.dart';
import 'package:pairnest/src/domain/models.dart';
import 'package:pairnest/src/features/bonding/pair_invite.dart';

void main() {
  test('pair invite serializes from profile and parses back', () {
    final profile = CoupleProfile(
      pairId: 'pair-123',
      myDeviceId: 'device-1',
      meName: '阿杰',
      partnerName: '小满',
      startedAt: DateTime(2024, 2, 14, 10, 30),
    );

    final invite = PairInvite.fromProfile(profile);
    final parsed = PairInvite.fromRaw(invite.toRaw());

    expect(parsed.pairId, 'pair-123');
    expect(parsed.hostName, '阿杰');
    expect(parsed.partnerName, '小满');
    expect(parsed.startedAt, DateTime(2024, 2, 14, 10, 30));
  });

  test('pair invite rejects invalid payload', () {
    expect(
      () => PairInvite.fromRaw('{"type":"other"}'),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => PairInvite.fromRaw('not-json'),
      throwsA(isA<FormatException>()),
    );
  });

  test('pair invite compatibility rejects switching to another pair id', () {
    final currentProfile = CoupleProfile(
      pairId: 'pair-a',
      myDeviceId: 'device-1',
      meName: '阿杰',
      partnerName: '小满',
      startedAt: DateTime(2024, 2, 14, 10, 30),
    );
    final invite = PairInvite(
      pairId: 'pair-b',
      hostName: '别人',
      partnerName: '另一个人',
      startedAt: DateTime(2025, 1, 1),
    );

    expect(
      isInviteCompatibleWithProfile(
        invite: invite,
        currentProfile: currentProfile,
      ),
      isFalse,
    );
    expect(
      isInviteCompatibleWithProfile(invite: invite, currentProfile: null),
      isTrue,
    );
  });

  test('pair invite compatibility allows the same pair id', () {
    final currentProfile = CoupleProfile(
      pairId: 'pair-a',
      myDeviceId: 'device-1',
      meName: '阿杰',
      partnerName: '小满',
      startedAt: DateTime(2024, 2, 14, 10, 30),
    );
    final invite = PairInvite(
      pairId: 'pair-a',
      hostName: '阿杰',
      partnerName: '小满',
      startedAt: DateTime(2024, 2, 14, 10, 30),
    );

    expect(
      isInviteCompatibleWithProfile(
        invite: invite,
        currentProfile: currentProfile,
      ),
      isTrue,
    );
  });
}
