import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../widgets/section_card.dart';

class SyncPanel extends ConsumerStatefulWidget {
  const SyncPanel({super.key});

  @override
  ConsumerState<SyncPanel> createState() => _SyncPanelState();
}

class _SyncPanelState extends ConsumerState<SyncPanel> {
  bool _discovering = false;
  String _status = '未同步';
  final List<String> _endpoints = <String>[];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nearby 同步',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text('状态: $_status'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: _discovering ? null : _startDiscovery,
                child: const Text('发现设备'),
              ),
              OutlinedButton(
                onPressed: _discovering ? _stopDiscovery : null,
                child: const Text('停止发现'),
              ),
              OutlinedButton(onPressed: _mockSync, child: const Text('同步缺失事件')),
            ],
          ),
          if (_endpoints.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text('发现设备:'),
            ..._endpoints.map((it) => Text('• $it')),
          ],
        ],
      ),
    );
  }

  Future<void> _startDiscovery() async {
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile == null) {
      return;
    }

    setState(() {
      _discovering = true;
      _status = '正在发现附近设备...';
      _endpoints.clear();
    });

    try {
      await ref
          .read(nearbySyncServiceProvider)
          .startDiscovery(
            localUserName: profile.meName,
            onFound: (endpointId, endpointName) {
              if (!mounted) {
                return;
              }
              setState(() {
                _endpoints.add('$endpointName ($endpointId)');
                _status = '发现 ${_endpoints.length} 台设备';
              });
            },
          );
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _status = '发现失败: $e';
        _discovering = false;
      });
    }
  }

  Future<void> _stopDiscovery() async {
    await ref.read(nearbySyncServiceProvider).stopDiscovery();
    if (!mounted) {
      return;
    }
    setState(() {
      _discovering = false;
      _status = '已停止发现';
    });
  }

  Future<void> _mockSync() async {
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile == null) {
      return;
    }

    final unsynced = await ref
        .read(pairRepositoryProvider)
        .unsyncedEvents(profile.pairId);
    if (unsynced.isEmpty) {
      setState(() => _status = '没有待同步事件');
      return;
    }

    await ref
        .read(pairRepositoryProvider)
        .markEventsSynced(unsynced.map((it) => it.eventId).toList());
    if (!mounted) {
      return;
    }
    setState(() => _status = '本地同步完成，已标记 ${unsynced.length} 条事件');
  }
}
