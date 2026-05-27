import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/projection_refresh.dart';
import '../../app/providers.dart';
import '../../domain/models.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/staggered_column.dart';
import 'widgets/anniversary_editor_card.dart';
import 'widgets/anniversary_hero_card.dart';
import 'widgets/anniversary_item_card.dart';

class AnniversaryPage extends ConsumerStatefulWidget {
  const AnniversaryPage({super.key});

  @override
  ConsumerState<AnniversaryPage> createState() => _AnniversaryPageState();
}

class _AnniversaryPageState extends ConsumerState<AnniversaryPage> {
  final _titleController = TextEditingController();
  final _kindController = TextEditingController(text: '纪念日');
  DateTime _date = DateTime.now();
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _kindController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 380;
    final profile = ref.watch(profileProvider).valueOrNull;
    final list = ref.watch(anniversaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('纪念日')),
      body: AtmosphereBackground(
        topGlow: const Color(0x26E9B97A),
        bottomGlow: const Color(0x25E07A95),
        child: profile == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.all(isCompact ? 12 : 16),
                children: [
                  StaggeredColumn(
                    children: [
                      list.when(
                        data: (items) => AnniversaryHeroCard(
                          items: items,
                          profileLoveDays: profile.loveDays,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                      AnniversaryEditorCard(
                        titleController: _titleController,
                        kindController: _kindController,
                        selectedDate: _date,
                        submitting: _submitting,
                        onPickDate: _pickDate,
                        onSave: () => _save(profile),
                      ),
                      list.when(
                        data: (items) => Column(
                          children: items.isEmpty
                              ? const [
                                  EmptyStateCard(
                                    icon: Icons.celebration_rounded,
                                    title: '还没有纪念日',
                                    subtitle: '先录入一个重要日期，主页和时间轴会同步显示。',
                                    accent: Color(0xFFF1D8B5),
                                  ),
                                ]
                              : items
                                    .map(
                                      (item) => AnniversaryItemCard(item: item),
                                    )
                                    .toList(),
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('纪念日加载失败: $e')),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
      initialDate: _date,
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save(CoupleProfile? profile) async {
    if (profile == null || _submitting) {
      return;
    }
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      AppFeedback.info(context, '请输入标题');
      return;
    }

    final kind = _kindController.text.trim().isEmpty
        ? '纪念日'
        : _kindController.text.trim();

    setState(() => _submitting = true);
    try {
      await ref
          .read(pairRepositoryProvider)
          .addAnniversary(
            profile: profile,
            title: title,
            date: _date,
            kind: kind,
          );
      if (!mounted) {
        return;
      }

      _titleController.clear();
      _kindController.text = '纪念日';
      ref.invalidateAfterAnniversary();
      AppFeedback.success(context, '纪念日已添加');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
