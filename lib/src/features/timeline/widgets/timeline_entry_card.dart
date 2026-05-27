import 'dart:io';

import 'package:flutter/material.dart';

import '../../../domain/models.dart';

class TimelineEntryCard extends StatelessWidget {
  const TimelineEntryCard({
    super.key,
    required this.entry,
    required this.compact,
  });

  final TimelineEntry entry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final category = _categoryFor(entry.tags);
    final accent = switch (category) {
      _TimelineCategory.partnerScore => const Color(0xFFF5D5DA),
      _TimelineCategory.anniversary => const Color(0xFFF0DDB9),
      _TimelineCategory.note => const Color(0xFFE7DDCF),
    };
    final icon = switch (category) {
      _TimelineCategory.partnerScore => Icons.balance_rounded,
      _TimelineCategory.anniversary => Icons.celebration_rounded,
      _TimelineCategory.note => Icons.auto_stories_rounded,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14977C74),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF6A5357)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _dateLabel(entry.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF635957),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.text,
            style: TextStyle(
              fontSize: compact ? 14.5 : 15.5,
              height: 1.45,
              fontWeight: category == _TimelineCategory.partnerScore
                  ? FontWeight.w600
                  : FontWeight.w500,
            ),
          ),
          if ((entry.imagePath ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                File(entry.imagePath!),
                height: compact ? 170 : 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stackTrace) => Container(
                  height: compact ? 170 : 200,
                  alignment: Alignment.center,
                  color: const Color(0xFFF6F1EC),
                  child: const Text('图片加载失败'),
                ),
              ),
            ),
          ],
          if ((entry.mood ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF4EEF8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sentiment_satisfied_alt_rounded,
                    size: 16,
                    color: Color(0xFF7E5E90),
                  ),
                  const SizedBox(width: 6),
                  Text('心情: ${entry.mood}'),
                ],
              ),
            ),
          ],
          if (entry.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F1EC),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(tag, style: const TextStyle(fontSize: 12.5)),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _dateLabel(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }

  _TimelineCategory _categoryFor(List<String> tags) {
    if (tags.contains('奖惩记录')) {
      return _TimelineCategory.partnerScore;
    }
    if (tags.contains('纪念日')) {
      return _TimelineCategory.anniversary;
    }
    return _TimelineCategory.note;
  }
}

enum _TimelineCategory { note, anniversary, partnerScore }
