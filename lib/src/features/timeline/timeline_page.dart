import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models.dart';
import '../../widgets/section_card.dart';

class TimelinePage extends ConsumerStatefulWidget {
  const TimelinePage({super.key});

  @override
  ConsumerState<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends ConsumerState<TimelinePage> {
  final _textController = TextEditingController();
  final _moodController = TextEditingController();
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _moodController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final timeline = ref.watch(timelineProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('时间轴')),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SectionCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          labelText: '今天一起做了什么？',
                        ),
                        minLines: 2,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _moodController,
                        decoration: const InputDecoration(labelText: '心情（可选）'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _tagController,
                        decoration: const InputDecoration(
                          labelText: '标签（逗号分隔，可选）',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () => _addTimeline(profile),
                          child: const Text('保存记录'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                timeline.when(
                  data: (entries) => Column(
                    children: entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.date.year}.${entry.date.month.toString().padLeft(2, '0')}.${entry.date.day.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(entry.text),
                                  if ((entry.mood ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text('心情: ${entry.mood}'),
                                  ],
                                  if (entry.tags.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      children: entry.tags
                                          .map((tag) => Chip(label: Text(tag)))
                                          .toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('时间轴加载失败: $e')),
                ),
              ],
            ),
    );
  }

  Future<void> _addTimeline(CoupleProfile? profile) async {
    if (profile == null) {
      return;
    }
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先输入记录内容')));
      return;
    }

    final tags = _tagController.text
        .split(',')
        .map((it) => it.trim())
        .where((it) => it.isNotEmpty)
        .toList();

    await ref
        .read(pairRepositoryProvider)
        .addTimelineEntry(
          profile: profile,
          text: text,
          mood: _moodController.text.trim().isEmpty
              ? null
              : _moodController.text.trim(),
          tags: tags,
        );

    _textController.clear();
    _moodController.clear();
    _tagController.clear();

    ref.invalidate(timelineProvider);
    ref.invalidate(growthProvider);
  }
}
