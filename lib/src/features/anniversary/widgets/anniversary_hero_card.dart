import 'package:flutter/material.dart';

import '../../../domain/models.dart';

class AnniversaryHeroCard extends StatelessWidget {
  const AnniversaryHeroCard({
    super.key,
    required this.items,
    required this.profileLoveDays,
  });

  final List<AnniversaryItem> items;
  final int profileLoveDays;

  @override
  Widget build(BuildContext context) {
    final reminderCount = items.where((item) => item.shouldRemind).length;
    final nextItem = items.isEmpty ? null : items.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A2E2A), Color(0xFF9C6B42)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1E4B2E27),
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.celebration_rounded, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                '纪念日档案',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${items.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            nextItem == null
                ? '把重要日子收进来，后续提醒和回顾会更完整。'
                : '下一次提醒是「${nextItem.title}」，还有 ${nextItem.daysLeft} 天。',
            style: const TextStyle(color: Color(0xFFF3E6DA), height: 1.45),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  icon: Icons.notifications_active_rounded,
                  label: '近期提醒',
                  value: '$reminderCount',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetric(
                  icon: Icons.favorite_rounded,
                  label: '相伴天数',
                  value: '$profileLoveDays',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x18FFFFFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Color(0xFFEADDD1), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
