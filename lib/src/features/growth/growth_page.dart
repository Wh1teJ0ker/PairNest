import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../widgets/section_card.dart';

class GrowthPage extends ConsumerWidget {
  const GrowthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreAsync = ref.watch(growthProvider);
    final profile = ref.watch(profileProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('成长系统')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          scoreAsync.when(
            data: (score) => SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '共同成长值',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  _line('亲密度 intimacy', score.intimacy),
                  _line('活跃度 activity', score.activity),
                  _line('默契值 chemistry', score.chemistry),
                  const Divider(height: 24),
                  Text(
                    '总分: ${score.total}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('成长数据加载失败: $e')),
          ),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '互动奖励',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text('一起签到: +5 intimacy / +3 activity / +2 chemistry'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: profile == null
                      ? null
                      : () async {
                          await ref
                              .read(pairRepositoryProvider)
                              .checkinTogether(profile);
                          ref.invalidate(growthProvider);
                        },
                  child: const Text('一起签到'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String title, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
