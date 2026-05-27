import 'package:flutter/material.dart';

class SyncActionControls extends StatelessWidget {
  const SyncActionControls({
    super.key,
    required this.autoModeEnabled,
    required this.discovering,
    required this.advertising,
    required this.connecting,
    required this.syncInFlight,
    required this.onEnableAutoMode,
    required this.onDisableAutoMode,
    required this.onStartDiscovery,
    required this.onStopDiscovery,
    required this.onStartAdvertising,
    required this.onStopAdvertising,
    required this.onSyncNow,
  });

  final bool autoModeEnabled;
  final bool discovering;
  final bool advertising;
  final bool connecting;
  final bool syncInFlight;
  final Future<void> Function() onEnableAutoMode;
  final Future<void> Function() onDisableAutoMode;
  final Future<void> Function() onStartDiscovery;
  final Future<void> Function() onStopDiscovery;
  final Future<void> Function() onStartAdvertising;
  final Future<void> Function() onStopAdvertising;
  final VoidCallback onSyncNow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.tune_rounded, size: 16, color: Color(0xFF647892)),
            SizedBox(width: 6),
            Text(
              '同步操作',
              style: TextStyle(
                color: Color(0xFF647892),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '先决定是否进入自动模式，再按需执行发现、广播和即时同步。',
          style: TextStyle(color: Color(0xFF62707D), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: autoModeEnabled ? null : onEnableAutoMode,
              icon: const Icon(Icons.auto_mode_rounded, size: 16),
              label: const Text('一键自动同步'),
            ),
            OutlinedButton(
              onPressed: autoModeEnabled ? onDisableAutoMode : null,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel_schedule_send_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('停止自动模式'),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: discovering ? null : onStartDiscovery,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.radar_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('发现设备'),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: discovering ? onStopDiscovery : null,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pause_circle_outline_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('停止发现'),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: advertising ? null : onStartAdvertising,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_tethering_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('开启可发现'),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: advertising ? onStopAdvertising : null,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.portable_wifi_off_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('停止可发现'),
                ],
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: syncInFlight || connecting ? null : onSyncNow,
              icon: const Icon(Icons.sync_rounded, size: 16),
              label: const Text('同步缺失事件'),
            ),
            if (connecting) const SizedBox(width: 8),
            if (connecting)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ],
    );
  }
}
