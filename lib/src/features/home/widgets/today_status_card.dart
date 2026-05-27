import 'package:flutter/material.dart';

import '../../../domain/models.dart';
import '../../../widgets/section_card.dart';

class TodayStatusCard extends StatelessWidget {
  const TodayStatusCard({super.key, required this.status});

  final TodayStatus status;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      accent: const Color(0xFFD7CDC2),
      tone: SectionCardTone.muted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardEyebrow(icon: Icons.radar_rounded, text: '当日摘要'),
          const SizedBox(height: 10),
          const Text('今日状态', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
            '签到、记录、任务和心情都会在这里汇总成当天的状态概览。',
            style: TextStyle(color: Color(0xFF6A625D), height: 1.5),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusChip(
                text: status.checkinDone ? '已签到' : '未签到',
                color: status.checkinDone
                    ? const Color(0xFFE7EEE6)
                    : const Color(0xFFF3E6E2),
                icon: status.checkinDone
                    ? Icons.verified_rounded
                    : Icons.pending_actions_rounded,
              ),
              _StatusChip(
                text: '记录 ${status.noteCount} 条',
                color: const Color(0xFFEDE8E0),
                icon: Icons.notes_rounded,
              ),
              _StatusChip(
                text: '任务 ${status.completedTaskCount} 项',
                color: const Color(0xFFE8ECE4),
                icon: Icons.task_alt_rounded,
              ),
              _StatusChip(
                text: status.latestMood == null
                    ? '心情未记录'
                    : '心情 ${status.latestMood}',
                color: const Color(0xFFECE7E2),
                icon: Icons.sentiment_satisfied_alt_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.text,
    required this.color,
    required this.icon,
  });

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2D6C9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF5F5852)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4F4843),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardEyebrow extends StatelessWidget {
  const _CardEyebrow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF8B6C55)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF8B6C55),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.35,
          ),
        ),
      ],
    );
  }
}
