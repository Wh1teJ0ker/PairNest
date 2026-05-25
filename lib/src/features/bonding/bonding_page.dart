import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/providers.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/staggered_column.dart';
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
  String? _invitePayload;

  @override
  void dispose() {
    _meController.dispose();
    _partnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 380;
    return Scaffold(
      appBar: AppBar(title: const Text('创建双人空间')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFCEEEE), Color(0xFFF8F3EE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(isCompact ? 14 : 20),
          children: [
            StaggeredColumn(
              children: [
                const Row(
                  children: [
                    Icon(Icons.favorite_rounded, color: Color(0xFFE16C7F)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'PairNest 仅属于你们两个人',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text('本地生成 pair_id，后续通过 Nearby 自动同步事件。'),
                TextField(
                  controller: _meController,
                  decoration: const InputDecoration(
                    labelText: '你的昵称',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                ),
                TextField(
                  controller: _partnerController,
                  decoration: const InputDecoration(
                    labelText: 'TA 的昵称',
                    prefixIcon: Icon(Icons.favorite_border_rounded),
                  ),
                ),
                Card(
                  color: const Color(0xFFFFFBF7),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_available_rounded),
                        const SizedBox(width: 8),
                        Text('恋爱开始日: ${_dateText(_startedAt)}'),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                              initialDate: _startedAt,
                            );
                            if (picked != null) {
                              setState(() => _startedAt = picked);
                            }
                          },
                          icon: const Icon(
                            Icons.edit_calendar_rounded,
                            size: 18,
                          ),
                          label: const Text('选择日期'),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _bind,
                        icon: const Icon(Icons.qr_code_2_rounded),
                        label: const Text('我是发起方'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final joined = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => const ScanBindPage(),
                            ),
                          );
                          if (!context.mounted) {
                            return;
                          }
                          if (joined == true) {
                            AppFeedback.success(context, '扫码绑定成功');
                          }
                        },
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        label: const Text('我是加入方'),
                      ),
                    ),
                  ],
                ),
                if (_invitePayload != null)
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          const Text(
                            '邀请二维码',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          QrImageView(
                            data: _invitePayload!,
                            size: 170,
                            backgroundColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bind() async {
    final me = _meController.text.trim();
    final partner = _partnerController.text.trim();
    if (me.isEmpty || partner.isEmpty) {
      AppFeedback.info(context, '请填写双方昵称');
      return;
    }

    final profile = await ref
        .read(profileProvider.notifier)
        .bind(meName: me, partnerName: partner, startedAt: _startedAt);

    setState(() {
      _invitePayload = jsonEncode({
        'type': 'pairnest_invite',
        'pairId': profile.pairId,
        'hostName': me,
        'partnerName': partner,
        'startedAt': _startedAt.toIso8601String(),
      });
    });
  }

  String _dateText(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
