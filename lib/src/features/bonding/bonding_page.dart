import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/projection_refresh.dart';
import '../../app/providers.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/staggered_column.dart';
import 'pair_invite.dart';
import 'scan_bind_page.dart';

class BondingPage extends ConsumerStatefulWidget {
  const BondingPage({super.key});

  @override
  ConsumerState<BondingPage> createState() => _BondingPageState();
}

class _BondingPageState extends ConsumerState<BondingPage> {
  final _meController = TextEditingController();
  final _partnerController = TextEditingController();
  DateTime _startedAt = DateTime.now();
  PairInvite? _invite;
  bool _creatingInvite = false;
  bool _openingScanner = false;

  @override
  void dispose() {
    _meController.dispose();
    _partnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final compact = size.width < 390;
    final currentProfile = ref.watch(profileProvider).valueOrNull;
    final effectiveInvite =
        _invite ??
        (currentProfile == null
            ? null
            : PairInvite.fromProfile(currentProfile));
    final hasExistingSpace = currentProfile != null;

    return Scaffold(
      appBar: AppBar(title: const Text('创建同频空间')),
      body: AtmosphereBackground(
        topGlow: const Color(0x1FB68B65),
        bottomGlow: const Color(0x186B7F8E),
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, compact ? 24 : 32),
          children: [
            StaggeredColumn(
              children: [
                _HeroCard(
                  inviteReady: effectiveInvite != null,
                  hasExistingSpace: hasExistingSpace,
                  openingScanner: _openingScanner,
                  onOpenScanner: _openScanner,
                ),
                if (hasExistingSpace)
                  _ExistingSpaceNotice(
                    myName: currentProfile.meName,
                    partnerName: currentProfile.partnerName,
                  ),
                _FormCard(
                  meController: _meController,
                  partnerController: _partnerController,
                  startedAt: _startedAt,
                  creatingInvite: _creatingInvite,
                  hasExistingSpace: hasExistingSpace,
                  onPickDate: _pickDate,
                  onCreateInvite: _bind,
                ),
                _ProtocolCard(inviteReady: effectiveInvite != null),
                if (effectiveInvite != null)
                  _InvitePreviewCard(invite: effectiveInvite),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bind() async {
    final currentProfile = ref.read(profileProvider).valueOrNull;
    if (currentProfile != null) {
      setState(() {
        _invite = PairInvite.fromProfile(currentProfile);
      });
      AppFeedback.info(context, '当前设备已经在同频空间中，已显示现有邀请码');
      return;
    }

    final me = _meController.text.trim();
    final partner = _partnerController.text.trim();
    if (me.isEmpty || partner.isEmpty) {
      AppFeedback.info(context, '请先填写双方昵称');
      return;
    }

    setState(() => _creatingInvite = true);
    try {
      final profile = await ref
          .read(profileProvider.notifier)
          .bind(meName: me, partnerName: partner, startedAt: _startedAt);

      if (!mounted) {
        return;
      }

      setState(() {
        _invite = PairInvite.fromProfile(profile);
      });
      ref.invalidateAllPairScopedProjections();
      AppFeedback.success(context, '邀请码已生成，给对方扫码即可加入');
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppFeedback.error(context, '创建空间失败: $error');
    } finally {
      if (mounted) {
        setState(() => _creatingInvite = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: _startedAt,
    );
    if (picked != null) {
      setState(() => _startedAt = picked);
    }
  }

  Future<void> _openScanner() async {
    if (_openingScanner) {
      return;
    }
    setState(() => _openingScanner = true);
    try {
      final joined = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => const ScanBindPage()));
      if (!mounted) {
        return;
      }
      if (joined == true) {
        AppFeedback.success(context, '扫码绑定成功');
      }
    } finally {
      if (mounted) {
        setState(() => _openingScanner = false);
      } else {
        _openingScanner = false;
      }
    }
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.inviteReady,
    required this.hasExistingSpace,
    required this.openingScanner,
    required this.onOpenScanner,
  });

  final bool inviteReady;
  final bool hasExistingSpace;
  final bool openingScanner;
  final Future<void> Function() onOpenScanner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        color: const Color(0xFF272120),
        border: Border.all(color: const Color(0xFF3B3432)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x160F0B08),
            blurRadius: 26,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF342D2B),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF4A413D)),
                ),
                child: const Icon(
                  Icons.favorite_outline_rounded,
                  color: Color(0xFFE8DCCE),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '同频 PairNest',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '先扫码加入同一空间，再通过 Nearby 完成双端确认。',
                      style: TextStyle(color: Color(0xFFB8ACA2), height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FactChip(icon: Icons.qr_code_2_rounded, text: '扫码加入不要求设备靠近'),
              _FactChip(icon: Icons.near_me_rounded, text: 'Nearby 同步确认通常需要靠近'),
              _FactChip(
                icon: Icons.bluetooth_searching_rounded,
                text: '底层依赖 Nearby，不是手写纯蓝牙协议',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: hasExistingSpace || openingScanner
                      ? null
                      : onOpenScanner,
                  icon: openingScanner
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.qr_code_scanner_rounded),
                  label: Text(
                    hasExistingSpace
                        ? '当前已在空间中'
                        : openingScanner
                        ? '打开中...'
                        : '我是加入方',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF9B6A43),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF342D2B),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF4A413D)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        inviteReady
                            ? Icons.verified_rounded
                            : Icons.timelapse_rounded,
                        color: inviteReady
                            ? const Color(0xFF9CBD9E)
                            : const Color(0xFFD0A475),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hasExistingSpace
                              ? '当前设备已在空间中'
                              : inviteReady
                              ? '邀请码已生成'
                              : '等待生成邀请码',
                          style: const TextStyle(color: Color(0xFFF4ECE4)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.meController,
    required this.partnerController,
    required this.startedAt,
    required this.creatingInvite,
    required this.hasExistingSpace,
    required this.onPickDate,
    required this.onCreateInvite,
  });

  final TextEditingController meController;
  final TextEditingController partnerController;
  final DateTime startedAt;
  final bool creatingInvite;
  final bool hasExistingSpace;
  final Future<void> Function() onPickDate;
  final Future<void> Function() onCreateInvite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE3D8CD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '创建邀请码',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF32232A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '创建后会生成二维码，对方扫码即可加入你的同频空间。',
            style: TextStyle(color: Color(0xFF6F6463), height: 1.45),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: meController,
            enabled: !hasExistingSpace,
            decoration: const InputDecoration(
              labelText: '你的昵称',
              hintText: '例如：阿杰',
              prefixIcon: Icon(Icons.badge_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: partnerController,
            enabled: !hasExistingSpace,
            decoration: const InputDecoration(
              labelText: 'TA 的昵称',
              hintText: '例如：小满',
              prefixIcon: Icon(Icons.favorite_border_rounded),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: hasExistingSpace ? null : onPickDate,
            borderRadius: BorderRadius.circular(22),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F2EA),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE3D8CD)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0E5DB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE0D5C8)),
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      color: Color(0xFF8D6847),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '恋爱开始日',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7A6E6B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _dateText(startedAt),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2F2328),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: creatingInvite ? null : onCreateInvite,
              icon: creatingInvite
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.qr_code_2_rounded),
              label: Text(
                creatingInvite
                    ? '正在生成邀请码'
                    : hasExistingSpace
                    ? '显示当前邀请码'
                    : '生成邀请码',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExistingSpaceNotice extends StatelessWidget {
  const _ExistingSpaceNotice({required this.myName, required this.partnerName});

  final String myName;
  final String partnerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EFE7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2D6C9)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_person_rounded, color: Color(0xFF8E643D), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '当前设备已经加入同频空间。为避免误覆盖现有关系，创建入口已锁定；如需让对方加入，请直接展示当前邀请码并在同步页完成 Nearby 确认。',
              style: TextStyle(color: Color(0xFF6C5745), height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtocolCard extends StatelessWidget {
  const _ProtocolCard({required this.inviteReady});

  final bool inviteReady;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE9DDD4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E5DB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0D5C8)),
                ),
                child: const Icon(
                  Icons.hub_rounded,
                  color: Color(0xFF8D6847),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '当前配对机制',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _StepRow(
            index: '01',
            title: '扫码加入空间',
            detail: '二维码只负责把两台设备加入同一个 pair，不要求两台手机贴在一起。',
            icon: Icons.qr_code_2_rounded,
          ),
          const SizedBox(height: 10),
          const _StepRow(
            index: '02',
            title: 'Nearby 完成双端确认',
            detail: '双方还要在同步页完成至少一次 Nearby 同步，状态才会变成真正的双端已匹配。',
            icon: Icons.near_me_rounded,
          ),
          const SizedBox(height: 10),
          const _StepRow(
            index: '03',
            title: '底层协议',
            detail:
                '当前依赖 Android Nearby Connections，通常会组合 BLE/蓝牙做发现，再用 Wi‑Fi 或 Wi‑Fi Direct 传输数据。',
            icon: Icons.bluetooth_searching_rounded,
          ),
          if (!inviteReady) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8EEE6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF9D6430),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '先生成邀请码，再让另一台手机扫码加入。',
                      style: TextStyle(color: Color(0xFF7D5331)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InvitePreviewCard extends StatelessWidget {
  const _InvitePreviewCard({required this.invite});

  final PairInvite invite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE3D8CD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100F0B08),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '邀请码已生成',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '让 ${invite.partnerName} 使用“扫码加入同频”扫描下方二维码。',
                      style: const TextStyle(
                        color: Color(0xFF706665),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E5DB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0D5C8)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.tag_rounded,
                      color: Color(0xFF8D6847),
                      size: 16,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _shortId(invite.pairId),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5A4A3E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF8),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE3D8CD)),
              ),
              child: QrImageView(
                data: invite.toRaw(),
                size: 210,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF2F232A),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  color: Color(0xFF2F232A),
                  dataModuleShape: QrDataModuleShape.square,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3ECE4),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2D6C9)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.wifi_tethering_rounded,
                  color: Color(0xFF8D6847),
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '扫码成功后不代表双端已经完全匹配。请到首页的 Nearby 同步区域，让两台 Android 设备靠近并完成一次同步确认。',
                    style: TextStyle(color: Color(0xFF645B55), height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _shortId(String pairId) {
    return pairId.length <= 8
        ? pairId.toUpperCase()
        : pairId.substring(0, 8).toUpperCase();
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.title,
    required this.detail,
    required this.icon,
  });

  final String index;
  final String title;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF0E5DB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0D5C8)),
          ),
          child: Center(
            child: Text(
              index,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF8D6847),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: const Color(0xFF8D6847)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: const TextStyle(color: Color(0xFF6B625C), height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF342D2B),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF4A413D)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFE8DCCE), size: 15),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Color(0xFFF4ECE4), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

String _dateText(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
