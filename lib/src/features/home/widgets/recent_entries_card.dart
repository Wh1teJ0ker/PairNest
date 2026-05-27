import 'package:flutter/material.dart';

import '../../../domain/models.dart';
import '../../../widgets/empty_state_card.dart';
import '../../../widgets/section_card.dart';

class RecentEntriesCard extends StatelessWidget {
  const RecentEntriesCard({super.key, required this.entries});

  final List<TimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      accent: const Color(0xFFE0D5C6),
      tone: SectionCardTone.muted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardEyebrow(icon: Icons.auto_stories_rounded, text: '记录回顾'),
          const SizedBox(height: 10),
          const Text('最近记录', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
            '时间轴里最近发生的事情会优先出现在这里，方便快速回看。',
            style: TextStyle(color: Color(0xFF6A625C), height: 1.5),
          ),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            const EmptyStateCard(
              icon: Icons.auto_stories_rounded,
              title: '还没有共同记录',
              subtitle: '去时间轴写下第一条今天的小事吧。',
              accent: Color(0xFFEADFCC),
            )
          else
            ...entries
                .take(3)
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5DACE)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1E6DA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.north_east_rounded,
                              size: 14,
                              color: Color(0xFF8D6847),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${entry.date.month}/${entry.date.day}',
                                  style: const TextStyle(
                                    color: Color(0xFF776B63),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry.text,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(height: 1.4),
                                ),
                                if (entry.tags.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: entry.tags.take(3).map((tag) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3EDE5),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          tag,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
