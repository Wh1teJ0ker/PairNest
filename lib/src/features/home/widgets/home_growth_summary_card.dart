import 'package:flutter/material.dart';

import '../../../domain/models.dart';

class HomeGrowthSummaryCard extends StatelessWidget {
  const HomeGrowthSummaryCard({super.key, required this.score});

  final GrowthScore score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF272120),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF3A3331)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x160F0B08),
            blurRadius: 22,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _GrowthEyebrow(
            icon: Icons.stacked_line_chart_rounded,
            text: '成长总览',
          ),
          const SizedBox(height: 10),
          Text(
            '${score.total}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '共同成长值',
            style: TextStyle(
              color: Color(0xFFE9DCCE),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '把签到、共同任务和奖惩事件沉淀成连续反馈，比分散记录更容易形成节奏。',
            style: TextStyle(color: Color(0xFFD6CBC1), height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Score(
                  icon: Icons.favorite_rounded,
                  title: '亲密度',
                  value: score.intimacy,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Score(
                  icon: Icons.local_fire_department_rounded,
                  title: '活跃度',
                  value: score.activity,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Score(
                  icon: Icons.diversity_3_rounded,
                  title: '默契值',
                  value: score.chemistry,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GrowthEyebrow extends StatelessWidget {
  const _GrowthEyebrow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFCAA27B), size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFCAA27B),
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 0.35,
          ),
        ),
      ],
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF312B29),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF443D3B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFE8DCCE)),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: Color(0xFFB7A99B), fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF9F6F2),
            ),
          ),
        ],
      ),
    );
  }
}
