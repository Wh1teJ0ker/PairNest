import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/section_card.dart';
import '../../widgets/staggered_column.dart';

class GrowthPage extends ConsumerStatefulWidget {
  const GrowthPage({super.key});

  @override
  ConsumerState<GrowthPage> createState() => _GrowthPageState();
}

class _GrowthPageState extends ConsumerState<GrowthPage> {
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 380;
    final scoreAsync = ref.watch(growthProvider);
    final taskHistoryAsync = ref.watch(growthTaskHistoryProvider);
    final profile = ref.watch(profileProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('成长系统')),
      body: AtmosphereBackground(
        topGlow: const Color(0x26D797E9),
        bottomGlow: const Color(0x24E090B7),
        child: ListView(
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          children: [
            StaggeredColumn(
              children: [
                scoreAsync.when(
                  data: (score) => SectionCard(
                    accent: const Color(0xFFE9D8F2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.insights_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '共同成长值',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _line(
                          Icons.favorite_rounded,
                          '亲密度 intimacy',
                          score.intimacy,
                        ),
                        _line(
                          Icons.local_fire_department_rounded,
                          '活跃度 activity',
                          score.activity,
                        ),
                        _line(
                          Icons.diversity_3_rounded,
                          '默契值 chemistry',
                          score.chemistry,
                        ),
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
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('成长数据加载失败: $e')),
                ),
                SectionCard(
                  accent: const Color(0xFFFFD8DE),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '互动奖励',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '一起签到: +5 intimacy / +3 activity / +2 chemistry',
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: profile == null
                            ? null
                            : () async {
                                await ref
                                    .read(pairRepositoryProvider)
                                    .checkinTogether(profile);
                                ref.invalidate(growthProvider);
                                ref.invalidate(todayStatusProvider);
                                if (!context.mounted) {
                                  return;
                                }
                                AppFeedback.success(context, '签到成功，成长值已更新');
                              },
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('一起签到'),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        '一起完成任务: +4 intimacy / +2 activity / +4 chemistry',
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _quickTaskChip('一起散步'),
                          _quickTaskChip('一起做饭'),
                          _quickTaskChip('一起观影'),
                          _quickTaskChip('一起运动'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _taskController,
                        decoration: const InputDecoration(
                          labelText: '任务名称（例如：一起做饭）',
                          prefixIcon: Icon(Icons.task_alt_rounded),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: profile == null
                            ? null
                            : () async {
                                await _submitTask(profile);
                              },
                        icon: const Icon(Icons.celebration_rounded),
                        label: const Text('完成任务并加分'),
                      ),
                    ],
                  ),
                ),
                taskHistoryAsync.when(
                  data: (tasks) => SectionCard(
                    accent: const Color(0xFFD7E8F8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.history_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '最近完成任务',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (tasks.isEmpty)
                          const EmptyStateCard(
                            icon: Icons.task_alt_rounded,
                            title: '还没有任务记录',
                            subtitle: '完成一次共同任务后会出现在这里。',
                            accent: Color(0xFFD7E8F8),
                          )
                        else
                          ...tasks.map(
                            (task) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      size: 16,
                                      color: Color(0xFF4B7EA7),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatDateTime(task.completedAt),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
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
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('任务记录加载失败: $e')),
                ),
                if (profile == null)
                  const EmptyStateCard(
                    icon: Icons.hourglass_empty_rounded,
                    title: '正在准备成长空间',
                    subtitle: '完成绑定后即可解锁签到与任务奖励。',
                    accent: Color(0xFFFFD8DE),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(IconData icon, String title, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(title),
          const Spacer(),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _quickTaskChip(String title) {
    return ActionChip(
      avatar: const Icon(Icons.add_task_rounded, size: 16),
      label: Text(title),
      onPressed: () {
        _taskController.text = title;
      },
    );
  }

  Future<void> _submitTask(CoupleProfile profile) async {
    final task = _taskController.text.trim();
    if (task.isEmpty) {
      if (!mounted) {
        return;
      }
      AppFeedback.info(context, '请先填写任务名称');
      return;
    }
    await ref
        .read(pairRepositoryProvider)
        .completeTaskTogether(profile: profile, taskTitle: task);
    _taskController.clear();
    ref.invalidate(growthProvider);
    ref.invalidate(growthTaskHistoryProvider);
    ref.invalidate(todayStatusProvider);
    if (!mounted) {
      return;
    }
    AppFeedback.success(context, '任务已完成，成长值已增加');
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
