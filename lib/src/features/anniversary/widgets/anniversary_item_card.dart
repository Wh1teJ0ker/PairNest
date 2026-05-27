import 'package:flutter/material.dart';

import '../../../domain/models.dart';
import '../../../widgets/pressable_scale.dart';
import '../../../widgets/section_card.dart';

class AnniversaryItemCard extends StatelessWidget {
  const AnniversaryItemCard({super.key, required this.item});

  final AnniversaryItem item;

  @override
  Widget build(BuildContext context) {
    final urgent = item.shouldRemind;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PressableScale(
        child: SectionCard(
          accent: urgent ? const Color(0xFFF5C8BF) : const Color(0xFFEADCCD),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: urgent
                      ? const Color(0xFFFCE8E2)
                      : const Color(0xFFF6F0E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  urgent
                      ? Icons.notifications_active_rounded
                      : Icons.favorite_outline_rounded,
                  color: urgent
                      ? const Color(0xFFB35340)
                      : const Color(0xFF8D6C56),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _CountdownBadge(
                          daysLeft: item.daysLeft,
                          urgent: urgent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(
                          icon: Icons.bookmark_rounded,
                          label: item.kind,
                        ),
                        _MetaChip(
                          icon: Icons.event_rounded,
                          label: _formatDate(item.date),
                        ),
                      ],
                    ),
                    if (urgent) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1ED),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.alarm_rounded,
                              size: 14,
                              color: Color(0xFFB35340),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '已进入提醒窗口，建议提前安排时间或准备礼物。',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9B4A3A),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge({required this.daysLeft, required this.urgent});

  final int daysLeft;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: urgent ? const Color(0xFFFCE8E2) : const Color(0xFFF4EFE8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '倒计时 $daysLeft 天',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: urgent ? const Color(0xFFB35340) : const Color(0xFF6F5B49),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3ED),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF7D6B5A)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6F6155),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
