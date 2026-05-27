import 'dart:io';

import 'package:flutter/material.dart';

import '../../../domain/models.dart';

class PartnerScoreEntryCard extends StatelessWidget {
  const PartnerScoreEntryCard({
    super.key,
    required this.record,
    required this.compact,
  });

  final PartnerScoreRecord record;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final positive = record.isPositive;
    final accent = positive ? const Color(0xFFE2F4E7) : const Color(0xFFFFE6E6);
    final accentText = positive
        ? const Color(0xFF2E7A4B)
        : const Color(0xFFAF4343);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEADFD8)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  positive
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: accentText,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(record.createdAt),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              _TotalBadge(value: record.totalDelta),
            ],
          ),
          if ((record.detail ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              record.detail!,
              style: const TextStyle(height: 1.45, color: Color(0xFF544D4A)),
            ),
          ],
          if (record.hasImage) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                File(record.imagePath!),
                height: compact ? 160 : 190,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stackTrace) => Container(
                  height: compact ? 160 : 190,
                  alignment: Alignment.center,
                  color: const Color(0xFFF6F1EC),
                  child: const Text('图片加载失败'),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DeltaChip(
                label: '亲密度',
                value: record.intimacyDelta,
                positive: record.intimacyDelta >= 0,
              ),
              _DeltaChip(
                label: '活跃度',
                value: record.activityDelta,
                positive: record.activityDelta >= 0,
              ),
              _DeltaChip(
                label: '默契值',
                value: record.chemistryDelta,
                positive: record.chemistryDelta >= 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({
    required this.label,
    required this.value,
    required this.positive,
  });

  final String label;
  final int value;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: positive ? const Color(0xFFEAF5EC) : const Color(0xFFFFEEED),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label ${value >= 0 ? '+' : ''}$value',
        style: TextStyle(
          color: positive ? const Color(0xFF2E7A4B) : const Color(0xFFAF4343),
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

class _TotalBadge extends StatelessWidget {
  const _TotalBadge({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final positive = value >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: positive ? const Color(0xFFEDF8F0) : const Color(0xFFFFEFEF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '${positive ? '+' : ''}$value',
        style: TextStyle(
          color: positive ? const Color(0xFF2E7A4B) : const Color(0xFFAF4343),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
