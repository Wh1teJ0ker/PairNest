import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/providers.dart';
import '../../core/permissions.dart';
import '../../domain/models.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/section_card.dart';
import '../../widgets/staggered_column.dart';

class TimelinePage extends ConsumerStatefulWidget {
  const TimelinePage({super.key});

  @override
  ConsumerState<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends ConsumerState<TimelinePage> {
  final _textController = TextEditingController();
  final _moodController = TextEditingController();
  final _tagController = TextEditingController();
  String? _pickedImagePath;

  @override
  void dispose() {
    _textController.dispose();
    _moodController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 380;
    final profile = ref.watch(profileProvider).valueOrNull;
    final timeline = ref.watch(timelineProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('共同时间轴')),
      body: AtmosphereBackground(
        topGlow: const Color(0x259C7BDC),
        bottomGlow: const Color(0x24E5A187),
        child: profile == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.all(isCompact ? 12 : 16),
                children: [
                  StaggeredColumn(
                    children: [
                      SectionCard(
                        accent: const Color(0xFFDDD7F3),
                        child: Column(
                          children: [
                            TextField(
                              controller: _textController,
                              decoration: const InputDecoration(
                                labelText: '今天一起做了什么？',
                                prefixIcon: Icon(Icons.edit_note_rounded),
                              ),
                              minLines: 2,
                              maxLines: 4,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _moodController,
                              decoration: const InputDecoration(
                                labelText: '心情（可选）',
                                prefixIcon: Icon(Icons.mood_rounded),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _tagController,
                              decoration: const InputDecoration(
                                labelText: '标签（逗号分隔，可选）',
                                prefixIcon: Icon(Icons.sell_rounded),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.image_outlined),
                                  label: const Text('选择图片'),
                                ),
                                const SizedBox(width: 8),
                                if (_pickedImagePath != null)
                                  Expanded(
                                    child: Text(
                                      '已选图片: ${_pickedImagePath!.split('/').last}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                            if (_pickedImagePath != null) ...[
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(_pickedImagePath!),
                                  height: isCompact ? 108 : 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () => _addTimeline(profile),
                                icon: const Icon(Icons.bookmark_added_rounded),
                                label: const Text('保存记录'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      timeline.when(
                        data: (entries) => Column(
                          children: entries.isEmpty
                              ? const [
                                  EmptyStateCard(
                                    icon: Icons.edit_note_rounded,
                                    title: '时间轴还是空白',
                                    subtitle: '写下一条记录，PairNest 会把回忆留在这里。',
                                    accent: Color(0xFFE7DDCF),
                                  ),
                                ]
                              : entries
                                    .map(
                                      (entry) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        child: SectionCard(
                                          accent: const Color(0xFFE7DDCF),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.schedule_rounded,
                                                    size: 16,
                                                    color: Colors.black54,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '${entry.date.year}.${entry.date.month.toString().padLeft(2, '0')}.${entry.date.day.toString().padLeft(2, '0')}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                entry.text,
                                                style: TextStyle(
                                                  fontSize: isCompact
                                                      ? 14.5
                                                      : 15.5,
                                                  height: 1.35,
                                                ),
                                              ),
                                              if ((entry.imagePath ?? '')
                                                  .isNotEmpty) ...[
                                                const SizedBox(height: 8),
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Image.file(
                                                    File(entry.imagePath!),
                                                    height: isCompact
                                                        ? 136
                                                        : 160,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => const Text(
                                                          '图片加载失败',
                                                        ),
                                                  ),
                                                ),
                                              ],
                                              if ((entry.mood ?? '')
                                                  .isNotEmpty) ...[
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .sentiment_satisfied_alt_rounded,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text('心情: ${entry.mood}'),
                                                  ],
                                                ),
                                              ],
                                              if (entry.tags.isNotEmpty) ...[
                                                const SizedBox(height: 6),
                                                Wrap(
                                                  spacing: 6,
                                                  children: entry.tags
                                                      .map(
                                                        (tag) => Chip(
                                                          label: Text(tag),
                                                        ),
                                                      )
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
                ],
              ),
      ),
    );
  }

  Future<void> _addTimeline(CoupleProfile? profile) async {
    if (profile == null) {
      return;
    }
    final text = _textController.text.trim();
    if (text.isEmpty) {
      AppFeedback.info(context, '请先输入记录内容');
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
          imagePath: _pickedImagePath,
        );

    _textController.clear();
    _moodController.clear();
    _tagController.clear();
    _pickedImagePath = null;

    ref.invalidate(timelineProvider);
    ref.invalidate(growthProvider);
    if (mounted) {
      AppFeedback.success(context, '记录已保存');
    }
  }

  Future<void> _pickImage() async {
    final granted = await Permissions.ensureGalleryRead();
    if (!granted) {
      if (!mounted) {
        return;
      }
      AppFeedback.info(context, '需要相册权限才能选择图片');
      return;
    }
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) {
      return;
    }
    setState(() {
      _pickedImagePath = image.path;
    });
  }
}
