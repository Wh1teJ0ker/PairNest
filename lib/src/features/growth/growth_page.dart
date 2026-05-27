import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/projection_refresh.dart';
import '../../app/providers.dart';
import '../../data/pair_repository.dart';
import '../../domain/models.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/section_card.dart';
import '../../widgets/staggered_column.dart';
import 'widgets/partner_score_entry_card.dart';
import 'widgets/partner_score_sheet.dart';

class GrowthPage extends ConsumerStatefulWidget {
  const GrowthPage({super.key});

  @override
  ConsumerState<GrowthPage> createState() => _GrowthPageState();
}

class _GrowthPageState extends ConsumerState<GrowthPage> {
  final _taskController = TextEditingController();
  bool _checkinSubmitting = false;
  bool _checkinInteractionLocked = false;
  bool _taskSubmitting = false;
  bool _partnerScoreSubmitting = false;
  DateTime? _lastCheckinLockedAt;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 390;
    final scoreAsync = ref.watch(growthProvider);
    final taskHistoryAsync = ref.watch(growthTaskHistoryProvider);
    final partnerScoreHistoryAsync = ref.watch(partnerScoreHistoryProvider);
    final profile = ref.watch(profileProvider).valueOrNull;
    final todayStatusAsync = ref.watch(todayStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('成长系统')),
      body: AtmosphereBackground(
        topGlow: const Color(0x186B7F8E),
        bottomGlow: const Color(0x18B68B65),
        child: ListView(
          padding: EdgeInsets.all(compact ? 12 : 16),
          children: [
            StaggeredColumn(
              children: [
                _GrowthHeroCard(scoreAsync: scoreAsync, compact: compact),
                _InteractionHubCard(
                  profile: profile,
                  taskController: _taskController,
                  compact: compact,
                  todayStatusAsync: todayStatusAsync,
                  checkinSubmitting: _checkinSubmitting,
                  checkinInteractionLocked: _checkinInteractionLocked,
                  checkinLockedForToday: _isCheckinLockedForToday(),
                  taskSubmitting: _taskSubmitting,
                  partnerScoreSubmitting: _partnerScoreSubmitting,
                  onCheckin: profile == null
                      ? null
                      : () => _submitCheckin(profile),
                  onQuickTaskTap: _fillQuickTask,
                  onTaskSubmit: profile == null
                      ? null
                      : () => _submitTask(profile),
                  onPartnerScore: profile == null
                      ? null
                      : () => _openPartnerScore(profile),
                ),
                SectionCard(
                  accent: const Color(0xFFE0D5C8),
                  tone: SectionCardTone.muted,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _PanelEyebrow(
                        icon: Icons.balance_rounded,
                        text: '反馈历史',
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '最近奖惩记录',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      partnerScoreHistoryAsync.when(
                        data: (records) => records.isEmpty
                            ? const EmptyStateCard(
                                icon: Icons.balance_rounded,
                                title: '还没有奖惩记录',
                                subtitle: '记录一次具体事件，可以让成长反馈更真实。',
                                accent: Color(0xFFD8E7F6),
                              )
                            : Column(
                                children: records
                                    .map(
                                      (record) => PartnerScoreEntryCard(
                                        record: record,
                                        compact: compact,
                                      ),
                                    )
                                    .toList(),
                              ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('奖惩记录加载失败: $e'),
                      ),
                    ],
                  ),
                ),
                taskHistoryAsync.when(
                  data: (tasks) => SectionCard(
                    accent: const Color(0xFFE0D5C8),
                    tone: SectionCardTone.muted,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _PanelEyebrow(
                          icon: Icons.history_rounded,
                          text: '任务沉淀',
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '最近完成任务',
                          style: TextStyle(fontWeight: FontWeight.w700),
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
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFE5DACE),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        size: 16,
                                        color: Color(0xFF8E6A49),
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
                                              color: Color(0xFF786E68),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
                    subtitle: '完成绑定后即可解锁签到、任务和奖惩记录。',
                    accent: Color(0xFFFFD8DE),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _fillQuickTask(String title) {
    _taskController.text = title;
  }

  Future<void> _openPartnerScore(CoupleProfile profile) async {
    if (_partnerScoreSubmitting) {
      return;
    }
    final draft = await showPartnerScoreSheet(context);
    if (draft == null) {
      return;
    }

    setState(() => _partnerScoreSubmitting = true);
    try {
      await ref
          .read(pairRepositoryProvider)
          .addPartnerScoreRecord(
            profile: profile,
            title: draft.title,
            detail: draft.detail,
            intimacyDelta: draft.intimacyDelta,
            activityDelta: draft.activityDelta,
            chemistryDelta: draft.chemistryDelta,
            imagePath: draft.imagePath,
          );
      ref.invalidateAfterPartnerScoreRecord();
      if (!mounted) {
        return;
      }
      AppFeedback.success(context, '奖惩记录已保存');
    } finally {
      if (mounted) {
        setState(() => _partnerScoreSubmitting = false);
      }
    }
  }

  Future<void> _submitCheckin(CoupleProfile profile) async {
    if (_checkinInteractionLocked ||
        _checkinSubmitting ||
        _isCheckinLockedForToday()) {
      return;
    }

    _setCheckinInteractionLocked(true);
    final latestStatus = ref.read(todayStatusProvider).valueOrNull;
    if (latestStatus?.checkinDone ?? false) {
      _markCheckinLockedForToday();
      if (mounted) {
        AppFeedback.info(context, '今天已经签到过了');
      }
      return;
    }

    _markCheckinLockedForToday();
    setState(() => _checkinSubmitting = true);
    try {
      await ref.read(pairRepositoryProvider).checkinTogether(profile);
      ref.invalidateAfterCheckin();
      if (!mounted) {
        return;
      }
      AppFeedback.success(context, '签到成功，成长值已更新');
    } on DuplicateDailyCheckinException {
      _markCheckinLockedForToday();
      ref.invalidateAfterCheckin();
      if (!mounted) {
        return;
      }
      AppFeedback.info(context, '今天已经签到过了');
    } catch (_) {
      _setCheckinInteractionLocked(false);
      _clearCheckinLock();
      if (!mounted) {
        return;
      }
      AppFeedback.error(context, '签到失败，请稍后重试');
    } finally {
      if (mounted) {
        setState(() => _checkinSubmitting = false);
      }
    }
  }

  Future<void> _submitTask(CoupleProfile profile) async {
    if (_taskSubmitting) {
      return;
    }
    final task = _taskController.text.trim();
    if (task.isEmpty) {
      if (!mounted) {
        return;
      }
      AppFeedback.info(context, '请先填写任务名称');
      return;
    }
    setState(() => _taskSubmitting = true);
    try {
      await ref
          .read(pairRepositoryProvider)
          .completeTaskTogether(profile: profile, taskTitle: task);
      _taskController.clear();
      ref.invalidateAfterTaskCompletion();
      if (!mounted) {
        return;
      }
      AppFeedback.success(context, '任务已完成，成长值已增加');
    } finally {
      if (mounted) {
        setState(() => _taskSubmitting = false);
      }
    }
  }

  String _formatDateTime(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  void _markCheckinLockedForToday() {
    if (!mounted) {
      _lastCheckinLockedAt = DateTime.now();
      return;
    }
    setState(() => _lastCheckinLockedAt = DateTime.now());
  }

  void _clearCheckinLock() {
    if (!mounted) {
      _lastCheckinLockedAt = null;
      return;
    }
    setState(() => _lastCheckinLockedAt = null);
  }

  void _setCheckinInteractionLocked(bool value) {
    if (!mounted) {
      _checkinInteractionLocked = value;
      return;
    }
    setState(() => _checkinInteractionLocked = value);
  }

  bool _isCheckinLockedForToday() {
    final lockedAt = _lastCheckinLockedAt;
    if (lockedAt == null) {
      return false;
    }
    final now = DateTime.now();
    return _isSameCalendarDay(lockedAt, now);
  }

  static bool _isSameCalendarDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}

class _GrowthHeroCard extends StatelessWidget {
  const _GrowthHeroCard({required this.scoreAsync, required this.compact});

  final AsyncValue<GrowthScore> scoreAsync;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF272120),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF3B3432)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x160F0B08),
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: scoreAsync.when(
        data: (score) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.stacked_line_chart_rounded,
                  color: Color(0xFFCAA27B),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  '共同成长值',
                  style: TextStyle(
                    color: Color(0xFFCAA27B),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.35,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${score.total}',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '成长值来自签到、任务和具体事件反馈，越真实越有参考价值。',
              style: TextStyle(color: Color(0xFFD4C8BD), height: 1.5),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ScoreMetric(
                    icon: Icons.favorite_rounded,
                    label: '亲密度',
                    value: score.intimacy,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ScoreMetric(
                    icon: Icons.local_fire_department_rounded,
                    label: '活跃度',
                    value: score.activity,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ScoreMetric(
                    icon: Icons.diversity_3_rounded,
                    label: '默契值',
                    value: score.chemistry,
                  ),
                ),
              ],
            ),
          ],
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (e, _) =>
            Text('成长数据加载失败: $e', style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _InteractionHubCard extends StatelessWidget {
  const _InteractionHubCard({
    required this.profile,
    required this.taskController,
    required this.compact,
    required this.todayStatusAsync,
    required this.checkinSubmitting,
    required this.checkinInteractionLocked,
    required this.checkinLockedForToday,
    required this.taskSubmitting,
    required this.partnerScoreSubmitting,
    required this.onCheckin,
    required this.onQuickTaskTap,
    required this.onTaskSubmit,
    required this.onPartnerScore,
  });

  final CoupleProfile? profile;
  final TextEditingController taskController;
  final bool compact;
  final AsyncValue<TodayStatus> todayStatusAsync;
  final bool checkinSubmitting;
  final bool checkinInteractionLocked;
  final bool checkinLockedForToday;
  final bool taskSubmitting;
  final bool partnerScoreSubmitting;
  final Future<void> Function()? onCheckin;
  final void Function(String title) onQuickTaskTap;
  final Future<void> Function()? onTaskSubmit;
  final Future<void> Function()? onPartnerScore;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      accent: const Color(0xFFE0D5C8),
      tone: SectionCardTone.muted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelEyebrow(icon: Icons.tune_rounded, text: '今日互动'),
          const SizedBox(height: 10),
          const Text('互动中心', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text(
            '把每天发生的具体事情沉淀成奖励、提醒或轻微扣分，比只看总分更有意义。',
            style: TextStyle(color: Color(0xFF6A625D), height: 1.5),
          ),
          const SizedBox(height: 16),
          todayStatusAsync.when(
            data: (status) {
              final alreadyCheckedIn =
                  status.checkinDone ||
                  checkinLockedForToday ||
                  checkinInteractionLocked;
              return _ActionPanel(
                title: '一起签到',
                subtitle: alreadyCheckedIn
                    ? '今日奖励已经领取，明天再来。'
                    : '同一天只能签到一次，避免重复刷分。',
                icon: Icons.check_circle_rounded,
                accentColor: const Color(0xFFF0E5DB),
                child: FilledButton.icon(
                  onPressed:
                      profile == null || alreadyCheckedIn || checkinSubmitting
                      ? null
                      : onCheckin,
                  icon: checkinSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          alreadyCheckedIn
                              ? Icons.verified_rounded
                              : Icons.check_circle_rounded,
                        ),
                  label: Text(
                    checkinSubmitting
                        ? '签到中...'
                        : alreadyCheckedIn
                        ? '今天已签到'
                        : '一起签到',
                  ),
                ),
              );
            },
            loading: () => const _ActionPanel(
              title: '一起签到',
              subtitle: '正在加载签到状态...',
              icon: Icons.check_circle_rounded,
              accentColor: Color(0xFFF0E5DB),
              child: LinearProgressIndicator(),
            ),
            error: (e, _) => Text('签到状态加载失败: $e'),
          ),
          const SizedBox(height: 14),
          _ActionPanel(
            title: '奖惩记录',
            subtitle: '针对具体事情为对方加分或减分，可附一张图片作为证据或纪念。',
            icon: Icons.balance_rounded,
            accentColor: const Color(0xFFE8E1D8),
            child: FilledButton.icon(
              onPressed: profile == null || partnerScoreSubmitting
                  ? null
                  : onPartnerScore,
              icon: partnerScoreSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add_chart_rounded),
              label: Text(partnerScoreSubmitting ? '保存中...' : '新增奖惩记录'),
            ),
          ),
          const SizedBox(height: 14),
          _ActionPanel(
            title: '共同任务',
            subtitle: '适合把日常约定和完成情况沉淀成正向反馈。',
            icon: Icons.task_alt_rounded,
            accentColor: const Color(0xFFEBE5DB),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _quickTaskChip('一起散步', onQuickTaskTap, taskSubmitting),
                    _quickTaskChip('一起做饭', onQuickTaskTap, taskSubmitting),
                    _quickTaskChip('一起观影', onQuickTaskTap, taskSubmitting),
                    _quickTaskChip('一起运动', onQuickTaskTap, taskSubmitting),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: taskController,
                  enabled: !taskSubmitting,
                  decoration: const InputDecoration(
                    labelText: '任务名称（例如：一起做饭）',
                    prefixIcon: Icon(Icons.edit_calendar_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  onPressed: profile == null || taskSubmitting
                      ? null
                      : onTaskSubmit,
                  icon: taskSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.celebration_rounded),
                  label: Text(taskSubmitting ? '提交中...' : '完成任务并加分'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickTaskChip(
    String title,
    void Function(String) onQuickTaskTap,
    bool disabled,
  ) {
    return ActionChip(
      avatar: const Icon(Icons.add_task_rounded, size: 16),
      label: Text(title),
      side: const BorderSide(color: Color(0xFFE0D5C8)),
      backgroundColor: const Color(0xFFF6F0E9),
      onPressed: disabled ? null : () => onQuickTaskTap(title),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4D9CD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelEyebrow(icon: icon, text: title),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0D5C8)),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF6D5645)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF6A625D), height: 1.5),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PanelEyebrow extends StatelessWidget {
  const _PanelEyebrow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF8B6C55)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF8B6C55),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.35,
          ),
        ),
      ],
    );
  }
}

class _ScoreMetric extends StatelessWidget {
  const _ScoreMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF312B29),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF433C3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFE8DCCE), size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Color(0xFFB7AA9D), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: const TextStyle(
              color: Color(0xFFF8F4EF),
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
