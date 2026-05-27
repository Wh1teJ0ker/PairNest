import 'package:flutter/material.dart';

class SyncStatusSummary extends StatelessWidget {
  const SyncStatusSummary({
    super.key,
    required this.status,
    required this.autoModeEnabled,
    required this.autoSyncFailureCount,
    required this.lastAutoSyncError,
    required this.lastSyncAt,
    required this.lastSyncInsertedEvents,
    required this.lastSyncDuplicateEvents,
    required this.lastSyncMergedFiles,
    required this.crossDeviceNoteDays,
  });

  final String status;
  final bool autoModeEnabled;
  final int autoSyncFailureCount;
  final String? lastAutoSyncError;
  final DateTime? lastSyncAt;
  final int lastSyncInsertedEvents;
  final int lastSyncDuplicateEvents;
  final int lastSyncMergedFiles;
  final int crossDeviceNoteDays;

  @override
  Widget build(BuildContext context) {
    final hasSyncRecord = lastSyncAt != null;
    final healthyAutoMode = autoModeEnabled && autoSyncFailureCount == 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE3D8CD)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Eyebrow(icon: Icons.wifi_tethering_rounded, text: '同步状态'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: healthyAutoMode
                          ? const Color(0xFFE8ECE4)
                          : const Color(0xFFF0E8DE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2D6C9)),
                    ),
                    child: Icon(
                      healthyAutoMode
                          ? Icons.sync_rounded
                          : Icons.wifi_tethering_rounded,
                      size: 18,
                      color: healthyAutoMode
                          ? const Color(0xFF546652)
                          : const Color(0xFF8A684B),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      status,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                autoModeEnabled
                    ? '系统会在附近发现设备后尝试自动收敛缺失事件。'
                    : '可手动发现设备、广播自己，并按需执行一次即时同步。',
                style: const TextStyle(
                  color: Color(0xFF665E58),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              if (autoModeEnabled) ...[
                const SizedBox(height: 10),
                Text(
                  healthyAutoMode
                      ? '自动模式运行中：靠近后会自动发现并同步'
                      : '自动模式异常 $autoSyncFailureCount 次：${lastAutoSyncError ?? '未知原因'}',
                  style: TextStyle(
                    color: healthyAutoMode
                        ? const Color(0xFF665E58)
                        : const Color(0xFF8E4B46),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
              if (hasSyncRecord) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SummaryChip(
                      icon: Icons.schedule_rounded,
                      text:
                          '最近同步 ${lastSyncAt!.hour.toString().padLeft(2, '0')}:${lastSyncAt!.minute.toString().padLeft(2, '0')}:${lastSyncAt!.second.toString().padLeft(2, '0')}',
                    ),
                    _SummaryChip(
                      icon: Icons.add_task_rounded,
                      text: '本次新增 $lastSyncInsertedEvents',
                    ),
                    _SummaryChip(
                      icon: Icons.copy_all_rounded,
                      text: '本次重复 $lastSyncDuplicateEvents',
                    ),
                    _SummaryChip(
                      icon: Icons.image_rounded,
                      text: '本次文件 $lastSyncMergedFiles',
                    ),
                    if (crossDeviceNoteDays > 0)
                      _SummaryChip(
                        icon: Icons.favorite_rounded,
                        text: '共同记录天数 $crossDeviceNoteDays',
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF3ECE4),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2D6C9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF7F6854)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF5A524C),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.icon, required this.text});

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
