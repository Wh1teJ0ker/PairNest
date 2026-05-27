import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/providers.dart';
import '../../domain/models.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/section_card.dart';
import '../../widgets/staggered_column.dart';
import '../bonding/pair_invite.dart';
import '../sync/sync_panel.dart';
import 'widgets/home_growth_summary_card.dart';
import 'widgets/recent_entries_card.dart';
import 'widgets/today_status_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final pairingStatus = ref.watch(pairingStatusProvider);
    final growth = ref.watch(growthProvider);
    final timeline = ref.watch(timelineProvider);
    final anniversaries = ref.watch(anniversaryProvider);
    final todayStatus = ref.watch(todayStatusProvider);

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('同频 PairNest')),
      body: AtmosphereBackground(
        topGlow: const Color(0x1FBA8A63),
        bottomGlow: const Color(0x1A6B7F8E),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            StaggeredColumn(
              children: [
                SectionCard(
                  accent: const Color(0xFF3E3634),
                  tone: SectionCardTone.strong,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionEyebrow(
                        icon: Icons.dashboard_customize_rounded,
                        text: '主页总览',
                        tint: Color(0xFFCAA27B),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF342D2B),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF4B4341),
                              ),
                            ),
                            child: const Icon(
                              Icons.favorite_outline_rounded,
                              color: Color(0xFFE8DCCE),
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
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '本地优先 · 双端共享 · 靠近同步',
                                  style: TextStyle(
                                    color: Color(0xFFB9ABA0),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      pairingStatus.when(
                        data: (status) => status == null
                            ? const SizedBox.shrink()
                            : _pairingOverview(context, profile, status),
                        loading: () => const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(),
                        ),
                        error: (e, _) => Text('配对状态加载失败: $e'),
                      ),
                    ],
                  ),
                ),
                growth.when(
                  data: (score) => HomeGrowthSummaryCard(score: score),
                  loading: () =>
                      const SectionCard(child: LinearProgressIndicator()),
                  error: (e, _) => SectionCard(child: Text('成长加载失败: $e')),
                ),
                todayStatus.when(
                  data: (status) => TodayStatusCard(status: status),
                  loading: () =>
                      const SectionCard(child: LinearProgressIndicator()),
                  error: (e, _) => SectionCard(child: Text('今日状态加载失败: $e')),
                ),
                timeline.when(
                  data: (entries) => RecentEntriesCard(entries: entries),
                  loading: () =>
                      const SectionCard(child: LinearProgressIndicator()),
                  error: (e, _) => SectionCard(child: Text('记录加载失败: $e')),
                ),
                anniversaries.when(
                  data: (items) => SectionCard(
                    accent: const Color(0xFFE2D5C4),
                    tone: SectionCardTone.muted,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionEyebrow(
                          icon: Icons.celebration_rounded,
                          text: '重要日期',
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
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
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFE7DCCD),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: item.shouldRemind
                                                ? const Color(0xFFF1E3DA)
                                                : const Color(0xFFF0E6D9),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            item.shouldRemind
                                                ? Icons
                                                      .notifications_active_rounded
                                                : Icons.celebration_rounded,
                                            size: 16,
                                            color: item.shouldRemind
                                                ? const Color(0xFF9A5838)
                                                : const Color(0xFF8C6B42),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            '${item.title} · ${item.daysLeft} 天后',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (item.shouldRemind)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEE8E6),
                                              border: Border.all(
                                                color: const Color(0xFFE8D2C8),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: const Text(
                                              '近期提醒',
                                              style: TextStyle(
                                                color: Color(0xFFB33A2A),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
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

  Widget _pairingOverview(
    BuildContext context,
    CoupleProfile profile,
    PairingStatus status,
  ) {
    final paired = status.isPairedAcrossDevices;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: paired ? const Color(0xFF2D352E) : const Color(0xFF342D28),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: paired ? const Color(0xFF465448) : const Color(0xFF4C4136),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionEyebrow(
            icon: paired ? Icons.link_rounded : Icons.qr_code_2_rounded,
            text: paired ? '双端状态' : '匹配进度',
            tint: paired ? const Color(0xFF97BEA0) : const Color(0xFFD0A475),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  status.summaryLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            status.detailLabel,
            style: const TextStyle(
              color: Color(0xFFB8ACA2),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statusChip(
                '空间 ID ${status.shortPairId}',
                const Color(0xFF40352F),
                Icons.tag_rounded,
              ),
              _statusChip(
                '已识别设备 ${status.syncedDeviceCount}',
                const Color(0xFF353A41),
                Icons.devices_rounded,
              ),
              _statusChip(
                paired ? '双端已确认' : '待对端确认',
                paired ? const Color(0xFF354138) : const Color(0xFF41362D),
                paired ? Icons.verified_rounded : Icons.hourglass_top_rounded,
              ),
              if (status.remoteParticipantNames.isNotEmpty)
                _statusChip(
                  '已匹配 ${status.remoteParticipantNames.join(" / ")}',
                  const Color(0xFF3A343D),
                  Icons.diversity_3_rounded,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showInviteSheet(context, profile),
                  icon: const Icon(Icons.qr_code_2_rounded),
                  label: const Text('显示邀请码'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showPairingExplainSheet(context),
                  icon: const Icon(Icons.help_outline_rounded),
                  label: const Text('匹配说明'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInviteSheet(BuildContext context, CoupleProfile profile) {
    final invite = PairInvite.fromProfile(profile);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFBF8),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前邀请码',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  '让 ${profile.partnerName} 扫描此二维码加入同一个空间。',
                  style: const TextStyle(color: Colors.black54, height: 1.4),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFEEDFD8)),
                    ),
                    child: QrImageView(
                      data: invite.toRaw(),
                      size: 220,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FB),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    '注意：扫码加入后，还要在 Nearby 同步区域完成至少一次靠近同步，首页状态才会切换为双端已匹配。',
                    style: TextStyle(color: Color(0xFF4A6076), height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPairingExplainSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFFFBF8),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '匹配说明',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                const Text(
                  '1. 扫码加入：不要求两台手机靠近，只要能看见二维码即可。\n\n'
                  '2. 双端确认：需要双方在 Nearby 同步页完成一次同步，通常要靠近，因为底层依赖 Nearby Connections 的近场发现与直连。\n\n'
                  '3. 协议层：不是单独写的纯蓝牙协议，通常会组合 BLE/蓝牙做发现，再用 Wi‑Fi 或 Wi‑Fi Direct 传输数据。',
                  style: TextStyle(height: 1.55, color: Color(0xFF5D5554)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _statusChip(String text, Color color, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: const Color(0xFF514640)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFFE8DCCE)),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF4ECE4),
          ),
        ),
      ],
    ),
  );
}

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow({
    required this.icon,
    required this.text,
    this.tint = const Color(0xFF6B7481),
  });

  final IconData icon;
  final String text;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: tint),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: tint,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
