import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/section_card.dart';
import '../../widgets/staggered_column.dart';
import '../sync/sync_panel.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final growth = ref.watch(growthProvider);
    final timeline = ref.watch(timelineProvider);
    final anniversaries = ref.watch(anniversaryProvider);
    final todayStatus = ref.watch(todayStatusProvider);

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('PairNest')),
      body: AtmosphereBackground(
        topGlow: const Color(0x26EA8395),
        bottomGlow: const Color(0x2678B5D8),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            StaggeredColumn(
              children: [
                SectionCard(
                  accent: const Color(0xFFF1C7CE),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCE6EA),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFD95E74),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '和 ${profile.partnerName} 在一起第 ${profile.loveDays} 天',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('本地优先 · 双端共享 · 靠近同步'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                growth.when(
                  data: (score) => SectionCard(
                    accent: const Color(0xFFDDD7F3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _score(Icons.favorite_rounded, '亲密度', score.intimacy),
                        _score(
                          Icons.local_fire_department_rounded,
                          '活跃度',
                          score.activity,
                        ),
                        _score(
                          Icons.diversity_3_rounded,
                          '默契值',
                          score.chemistry,
                        ),
                      ],
                    ),
                  ),
                  loading: () =>
                      const SectionCard(child: LinearProgressIndicator()),
                  error: (e, _) => SectionCard(child: Text('成长加载失败: $e')),
                ),
                todayStatus.when(
                  data: (status) => SectionCard(
                    accent: const Color(0xFFD5E4F7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.today_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '今日状态',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _statusChip(
                              status.checkinDone ? '已签到' : '未签到',
                              status.checkinDone
                                  ? const Color(0xFFE8F4EA)
                                  : const Color(0xFFF7EAE8),
                              status.checkinDone
                                  ? Icons.verified_rounded
                                  : Icons.pending_actions_rounded,
                            ),
                            _statusChip(
                              '记录 ${status.noteCount} 条',
                              const Color(0xFFEFF1F6),
                              Icons.notes_rounded,
                            ),
                            _statusChip(
                              status.latestMood == null
                                  ? '心情未记录'
                                  : '心情 ${status.latestMood}',
                              const Color(0xFFF3EEF8),
                              Icons.sentiment_satisfied_alt_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  loading: () =>
                      const SectionCard(child: LinearProgressIndicator()),
                  error: (e, _) => SectionCard(child: Text('今日状态加载失败: $e')),
                ),
                timeline.when(
                  data: (entries) => SectionCard(
                    accent: const Color(0xFFE6DAC7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_stories_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '最近记录',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Icon(
                                          Icons.fiber_manual_record_rounded,
                                          size: 12,
                                          color: Color(0xFFAF7C56),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${entry.date.month}/${entry.date.day} · ${entry.text}',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  loading: () =>
                      const SectionCard(child: LinearProgressIndicator()),
                  error: (e, _) => SectionCard(child: Text('记录加载失败: $e')),
                ),
                anniversaries.when(
                  data: (items) => SectionCard(
                    accent: const Color(0xFFF2D8AE),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.celebration_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '纪念日提醒',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (items.isEmpty)
                          const EmptyStateCard(
                            icon: Icons.celebration_rounded,
                            title: '还没有纪念日',
                            subtitle: '去纪念日页面添加生日、恋爱纪念日或特殊日期。',
                            accent: Color(0xFFF1DEBB),
                          )
                        else
                          ...items
                              .take(3)
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.title} · ${item.daysLeft} 天后',
                                        ),
                                      ),
                                      if (item.shouldRemind)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEE8E6),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons
                                                    .notifications_active_rounded,
                                                size: 12,
                                                color: Color(0xFFB33A2A),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '近期提醒',
                                                style: TextStyle(
                                                  color: Color(0xFFB33A2A),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  loading: () =>
                      const SectionCard(child: LinearProgressIndicator()),
                  error: (e, _) => SectionCard(child: Text('纪念日加载失败: $e')),
                ),
                const SyncPanel(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _score(IconData icon, String title, int value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF7A5A6D)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 6),
        Text(
          '$value',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _statusChip(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 14), const SizedBox(width: 5), Text(text)],
      ),
    );
  }
}
