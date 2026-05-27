import 'dart:convert';

import '../../domain/models.dart';

class PairInvite {
  const PairInvite({
    required this.pairId,
    required this.hostName,
    required this.partnerName,
    required this.startedAt,
  });

  static const type = 'pairnest_invite';

  final String pairId;
  final String hostName;
  final String partnerName;
  final DateTime startedAt;

  factory PairInvite.fromProfile(CoupleProfile profile) {
    return PairInvite(
      pairId: profile.pairId,
      hostName: profile.meName,
      partnerName: profile.partnerName,
      startedAt: profile.startedAt,
    );
  }

  factory PairInvite.fromRaw(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('二维码数据结构无效');
      }
      return PairInvite.fromMap(decoded);
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('未识别到有效的邀请码');
    }
  }

  factory PairInvite.fromMap(Map<String, dynamic> map) {
    final rawType = map['type'];
    if (rawType != type) {
      throw const FormatException('二维码类型不匹配');
    }

    final pairId = map['pairId'];
    final hostName = map['hostName'];
    final partnerName = map['partnerName'];
    final startedAt = map['startedAt'];

    if (pairId is! String ||
        hostName is! String ||
        partnerName is! String ||
        startedAt is! String ||
        pairId.trim().isEmpty ||
        hostName.trim().isEmpty ||
        partnerName.trim().isEmpty) {
      throw const FormatException('邀请码字段不完整');
    }

    return PairInvite(
      pairId: pairId.trim(),
      hostName: hostName.trim(),
      partnerName: partnerName.trim(),
      startedAt: DateTime.parse(startedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'pairId': pairId,
      'hostName': hostName,
      'partnerName': partnerName,
      'startedAt': startedAt.toIso8601String(),
    };
  }

  String toRaw() => jsonEncode(toMap());
}

bool isInviteCompatibleWithProfile({
  required PairInvite invite,
  required CoupleProfile? currentProfile,
}) {
  if (currentProfile == null) {
    return true;
  }
  return currentProfile.pairId == invite.pairId;
}
