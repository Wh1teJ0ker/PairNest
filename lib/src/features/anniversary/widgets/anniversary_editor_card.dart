import 'package:flutter/material.dart';

import '../../../widgets/section_card.dart';

class AnniversaryEditorCard extends StatelessWidget {
  const AnniversaryEditorCard({
    super.key,
    required this.titleController,
    required this.kindController,
    required this.selectedDate,
    required this.submitting,
    required this.onPickDate,
    required this.onSave,
  });

  final TextEditingController titleController;
  final TextEditingController kindController;
  final DateTime selectedDate;
  final bool submitting;
  final Future<void> Function() onPickDate;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      accent: const Color(0xFFE8D2B6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8EEE2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF9B6A34),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '添加纪念日',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '把生日、首次见面或重要约定收进同一条时间线，后续提醒会更清晰。',
                      style: TextStyle(color: Color(0xFF6D6258), height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: titleController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: '标题',
              hintText: '例如：第一次见面',
              prefixIcon: Icon(Icons.celebration_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: kindController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: '类型',
              hintText: '例如：纪念日、生日、约定',
              prefixIcon: Icon(Icons.category_rounded),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F3EB),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8D9C6)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: Color(0xFFA06A42),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '纪念日期',
                        style: TextStyle(
                          color: Color(0xFF7A695C),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: submitting ? null : onPickDate,
                  icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                  label: const Text('更换日期'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _KindHintChip(label: '纪念日'),
              _KindHintChip(label: '生日'),
              _KindHintChip(label: '约定'),
              _KindHintChip(label: '第一次'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: submitting ? null : onSave,
              icon: submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add_circle_rounded),
              label: Text(submitting ? '保存中...' : '添加纪念日'),
            ),
          ),
        ],
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

class _KindHintChip extends StatelessWidget {
  const _KindHintChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EEE5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE6D8C8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.label_important_outline_rounded,
            size: 14,
            color: Color(0xFF8B6A4C),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7B6654),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
