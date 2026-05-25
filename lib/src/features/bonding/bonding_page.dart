import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/providers.dart';

class BondingPage extends ConsumerStatefulWidget {
  const BondingPage({super.key});

  @override
  ConsumerState<BondingPage> createState() => _BondingPageState();
}

class _BondingPageState extends ConsumerState<BondingPage> {
  final _meController = TextEditingController();
  final _partnerController = TextEditingController();
  DateTime _startedAt = DateTime.now();

  @override
  void dispose() {
    _meController.dispose();
    _partnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PairNest 绑定')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '双人绑定',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text('本地生成 pair_id，后续通过 Nearby 自动同步事件。'),
            const SizedBox(height: 20),
            TextField(
              controller: _meController,
              decoration: const InputDecoration(labelText: '你的昵称'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _partnerController,
              decoration: const InputDecoration(labelText: 'TA 的昵称'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('恋爱开始日: ${_dateText(_startedAt)}'),
                const Spacer(),
                TextButton(
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
                  child: const Text('选择日期'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _bind, child: const Text('确认绑定并进入')),
            const SizedBox(height: 24),
            if (_meController.text.isNotEmpty)
              Center(
                child: QrImageView(
                  data: _meController.text,
                  size: 160,
                  backgroundColor: Colors.white,
                ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写双方昵称')));
      return;
    }

    await ref
        .read(profileProvider.notifier)
        .bind(meName: me, partnerName: partner, startedAt: _startedAt);
  }

  String _dateText(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
