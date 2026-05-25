import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/pressable_scale.dart';
import '../../widgets/section_card.dart';
import '../../widgets/staggered_column.dart';

class AnniversaryPage extends ConsumerStatefulWidget {
  const AnniversaryPage({super.key});

  @override
  ConsumerState<AnniversaryPage> createState() => _AnniversaryPageState();
}

class _AnniversaryPageState extends ConsumerState<AnniversaryPage> {
  final _titleController = TextEditingController();
  final _kindController = TextEditingController(text: '纪念日');
  DateTime _date = DateTime.now();

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
                      SectionCard(
                        accent: const Color(0xFFF1D8B5),
                        child: Column(
                          children: [
                            TextField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: '标题',
                                prefixIcon: Icon(Icons.emoji_events_rounded),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _kindController,
                              decoration: const InputDecoration(
                                labelText: '类型',
                                prefixIcon: Icon(Icons.category_rounded),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.event_rounded, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  '日期: ${_date.year}-${_date.month}-${_date.day}',
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(1990),
                                      lastDate: DateTime(2100),
                                      initialDate: _date,
                                    );
                                    if (picked != null) {
                                      setState(() => _date = picked);
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.edit_calendar_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('选择'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => _save(profile),
                              icon: const Icon(Icons.add_circle_rounded),
                              label: const Text('添加纪念日'),
                            ),
                          ],
                        ),
                      ),
                      list.when(
                        data: (items) => Column(
                          children: items.isEmpty
                              ? const [
                                  EmptyStateCard(
                                    icon: Icons.celebration_rounded,
                                    title: '还没有纪念日',
                                    subtitle: '添加一个值得纪念的日期，后续会自动提醒。',
                                    accent: Color(0xFFF1D8B5),
                                  ),
                                ]
                              : items
                                    .map(
                                      (item) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        child: PressableScale(
                                          child: SectionCard(
                                            accent: item.shouldRemind
                                                ? const Color(0xFFF8D1C7)
                                                : const Color(0xFFF0E6DD),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  item.shouldRemind
                                                      ? Icons
                                                            .notifications_active_rounded
                                                      : Icons.favorite_outline,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.title,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${item.kind} · ${item.date.year}.${item.date.month}.${item.date.day}',
                                                      ),
                                                      if (item.shouldRemind)
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                top: 4,
                                                              ),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .alarm_rounded,
                                                                size: 14,
                                                                color: Color(
                                                                  0xFFB33A2A,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text(
                                                                '近期提醒（7天内）',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                    0xFFB33A2A,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: item.shouldRemind
                                                        ? const Color(
                                                            0xFFFEE7E2,
                                                          )
                                                        : const Color(
                                                            0xFFF5EFE8,
                                                          ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '倒计时 ${item.daysLeft} 天',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
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

  Future<void> _save(CoupleProfile? profile) async {
    if (profile == null) {
      return;
    }
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      AppFeedback.info(context, '请输入标题');
      return;
    }

    await ref
        .read(pairRepositoryProvider)
        .addAnniversary(
          profile: profile,
          title: title,
          date: _date,
          kind: _kindController.text.trim().isEmpty
              ? '纪念日'
              : _kindController.text.trim(),
        );
    if (!mounted) {
      return;
    }

    _titleController.clear();
    ref.invalidate(anniversaryProvider);
    AppFeedback.success(context, '纪念日已添加');
  }
}
