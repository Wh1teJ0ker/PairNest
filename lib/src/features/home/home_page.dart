import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../widgets/section_card.dart';
import '../sync/sync_panel.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final growth = ref.watch(growthProvider);
    final timeline = ref.watch(timelineProvider);
    final anniversaries = ref.watch(anniversaryProvider);

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('PairNest')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
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
          const SizedBox(height: 12),
          growth.when(
            data: (score) => SectionCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _score('亲密度', score.intimacy),
                  _score('活跃度', score.activity),
                  _score('默契值', score.chemistry),
                ],
              ),
            ),
            loading: () => const SectionCard(child: LinearProgressIndicator()),
            error: (e, _) => SectionCard(child: Text('成长加载失败: $e')),
          ),
          const SizedBox(height: 12),
          timeline.when(
            data: (entries) => SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '最近记录',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (entries.isEmpty)
                    const Text('还没有记录，去时间轴写下第一条吧。')
                  else
                    ...entries
                        .take(3)
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '${entry.date.month}/${entry.date.day} · ${entry.text}',
                            ),
                          ),
                        ),
                ],
              ),
            ),
            loading: () => const SectionCard(child: LinearProgressIndicator()),
            error: (e, _) => SectionCard(child: Text('记录加载失败: $e')),
          ),
          const SizedBox(height: 12),
          anniversaries.when(
            data: (items) => SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '纪念日提醒',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (items.isEmpty)
                    const Text('还没有纪念日，去纪念日页添加。')
                  else
                    ...items
                        .take(3)
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text('${item.title} · ${item.daysLeft} 天后'),
                          ),
                        ),
                ],
              ),
            ),
            loading: () => const SectionCard(child: LinearProgressIndicator()),
            error: (e, _) => SectionCard(child: Text('纪念日加载失败: $e')),
          ),
          const SizedBox(height: 12),
          const SyncPanel(),
        ],
      ),
    );
  }

  Widget _score(String title, int value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 6),
        Text(
          '$value',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
