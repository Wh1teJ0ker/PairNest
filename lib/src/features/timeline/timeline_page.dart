import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/projection_refresh.dart';
import '../../app/providers.dart';
import '../../core/permissions.dart';
import '../../domain/models.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/staggered_column.dart';
import 'widgets/timeline_editor_card.dart';
import 'widgets/timeline_entry_card.dart';

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
  bool _submitting = false;

  @override
  void dispose() {
    _textController.dispose();
    _moodController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 390;
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
                padding: EdgeInsets.all(compact ? 12 : 16),
                children: [
                  StaggeredColumn(
                    children: [
                      TimelineEditorCard(
                        textController: _textController,
                        moodController: _moodController,
                        tagController: _tagController,
                        pickedImagePath: _pickedImagePath,
                        submitting: _submitting,
                        onPickImage: _pickImage,
                        onClearImage: () =>
                            setState(() => _pickedImagePath = null),
                        onSubmit: () => _addTimeline(profile),
                      ),
                      timeline.when(
                        data: (entries) => entries.isEmpty
                            ? const EmptyStateCard(
                                icon: Icons.edit_note_rounded,
                                title: '时间轴还是空白',
                                subtitle: '写下一条记录，奖惩、纪念日和共同回忆都会沉淀在这里。',
                                accent: Color(0xFFE7DDCF),
                              )
                            : Column(
                                children: entries
                                    .map(
                                      (entry) => TimelineEntryCard(
                                        entry: entry,
                                        compact: compact,
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
    if (profile == null || _submitting) {
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

    setState(() => _submitting = true);
    try {
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
      if (mounted) {
        setState(() => _pickedImagePath = null);
      }

      ref.invalidateAfterTimelineEntry();
      if (mounted) {
        AppFeedback.success(context, '记录已保存');
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
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
    if (image == null || !mounted) {
      return;
    }
    setState(() {
      _pickedImagePath = image.path;
    });
  }
}
