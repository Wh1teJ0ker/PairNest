import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/providers.dart';
import '../../core/permissions.dart';
import '../../widgets/app_feedback.dart';

class ScanBindPage extends ConsumerStatefulWidget {
  const ScanBindPage({super.key});

  @override
  ConsumerState<ScanBindPage> createState() => _ScanBindPageState();
}

class _ScanBindPageState extends ConsumerState<ScanBindPage> {
  final _controller = MobileScannerController();
  bool _handling = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('扫码绑定')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcode = capture.barcodes.firstOrNull;
              final raw = barcode?.rawValue;
              if (raw == null || raw.isEmpty) {
                return;
              }
              _handleScan(raw);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black.withValues(alpha: 0.55),
              padding: const EdgeInsets.all(12),
              child: const Row(
                children: [
                  Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '扫描对方展示的 PairNest 二维码即可加入双人空间',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _prepareCamera();
  }

  Future<void> _handleScan(String raw) async {
    if (_handling) {
      return;
    }

    _handling = true;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['type'] != 'pairnest_invite') {
        throw const FormatException('二维码类型不匹配');
      }

      final pairId = map['pairId'] as String;
      final partnerName = map['hostName'] as String;
      final startedAt = DateTime.parse(map['startedAt'] as String);

      await _controller.stop();

      if (!mounted) {
        return;
      }

      final myNameController = TextEditingController();
      final myName = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('填写你的昵称'),
            content: TextField(
              controller: myNameController,
              decoration: const InputDecoration(
                labelText: '你的昵称',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pop(myNameController.text.trim()),
                child: const Text('加入'),
              ),
            ],
          );
        },
      );

      if (myName == null || myName.isEmpty) {
        _handling = false;
        await _controller.start();
        return;
      }

      await ref
          .read(profileProvider.notifier)
          .joinByInvite(
            myName: myName,
            pairId: pairId,
            partnerName: partnerName,
            startedAt: startedAt,
          );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }
      AppFeedback.error(context, '扫码失败: $e');
      _handling = false;
      await _controller.start();
    }
  }

  Future<void> _prepareCamera() async {
    final granted = await Permissions.ensureCamera();
    if (!mounted || granted) {
      return;
    }
    AppFeedback.info(context, '需要相机权限才能扫码绑定');
  }
}
