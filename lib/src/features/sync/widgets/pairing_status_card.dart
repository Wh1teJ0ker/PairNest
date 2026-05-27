import 'package:flutter/material.dart';

import '../../../domain/models.dart';

class PairingStatusCard extends StatelessWidget {
  const PairingStatusCard({super.key, required this.status});

  final PairingStatus status;

  @override
  Widget build(BuildContext context) {
    final paired = status.isPairedAcrossDevices;
    final lastRemoteText = status.lastRemoteBoundAt == null
        ? '尚未收到对端绑定事件'
        : '最近对端绑定: ${status.lastRemoteBoundAt!.month.toString().padLeft(2, '0')}-${status.lastRemoteBoundAt!.day.toString().padLeft(2, '0')} ${status.lastRemoteBoundAt!.hour.toString().padLeft(2, '0')}:${status.lastRemoteBoundAt!.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF272120),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3B3432)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusEyebrow(
            icon: paired ? Icons.link_rounded : Icons.device_hub_rounded,
            text: paired ? '关系状态' : '等待确认',
            tint: paired ? const Color(0xFF9CBD9E) : const Color(0xFFD0A475),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                paired ? Icons.verified_user_rounded : Icons.hub_rounded,
                size: 18,
                color: paired
                    ? const Color(0xFF9CBD9E)
                    : const Color(0xFFD0A475),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  paired ? '双端配对已完成' : '当前仅完成单端绑定',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.tag_rounded,
                text: '空间 ${status.shortPairId}',
              ),
              _InfoChip(icon: Icons.badge_rounded, text: '本机 ${status.meName}'),
              _InfoChip(
                icon: Icons.devices_rounded,
                text: '设备 ${status.syncedDeviceCount}',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '匹配对象: ${status.remoteParticipantNames.isEmpty ? status.expectedPartnerName : status.remoteParticipantNames.join(" / ")}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFFF4ECE4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lastRemoteText,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFBBAFA5),
              height: 1.5,
            ),
          ),
          if (!paired)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '还需要让另一台设备扫码加入，并完成至少一次 Nearby 同步，状态才会切换为双端已匹配。',
                style: TextStyle(fontSize: 12, color: Color(0xFFD0A475)),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF342D2B),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF4A413D)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFE4D9CD)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFF4ECE4),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusEyebrow extends StatelessWidget {
  const _StatusEyebrow({
    required this.icon,
    required this.text,
    required this.tint,
  });

  final IconData icon;
  final String text;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: tint),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: tint,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
