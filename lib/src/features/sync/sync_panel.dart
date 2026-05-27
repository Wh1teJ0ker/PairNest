import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/projection_refresh.dart';
import '../../app/providers.dart';
import '../../core/permissions.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/section_card.dart';
import 'sync_session.dart';
import 'sync_models.dart';
import 'widgets/discovered_endpoints_list.dart';
import 'widgets/pairing_status_card.dart';
import 'widgets/sync_action_controls.dart';
import 'widgets/sync_status_summary.dart';

class SyncPanel extends ConsumerStatefulWidget {
  const SyncPanel({super.key});

  @override
  ConsumerState<SyncPanel> createState() => _SyncPanelState();
}

class _SyncPanelState extends ConsumerState<SyncPanel> {
  static const _autoSyncGap = Duration(seconds: 12);
  static const _autoSyncTick = Duration(seconds: 20);

  bool _discovering = false;
  bool _advertising = false;
  bool _autoModeEnabled = false;
  String _status = '未同步';
  final List<String> _endpoints = <String>[];
  String? _selectedEndpointId;
  Timer? _autoSyncTimer;
  final Map<int, String> _pendingFileMeta = <int, String>{};
  final Map<int, String> _pendingFileEventMap = <int, String>{};
  final Map<int, String> _pendingFileUri = <int, String>{};
  DateTime? _lastSyncAt;
  int _lastSyncInsertedEvents = 0;
  int _lastSyncMergedFiles = 0;
  int _lastSyncDuplicateEvents = 0;
  int _crossDeviceNoteDays = 0;
  bool _connecting = false;
  bool _syncInFlight = false;
  DateTime? _lastAutoSyncAttemptAt;
  DateTime? _lastReversePushAt;
  int _autoSyncFailureCount = 0;
  String? _lastAutoSyncError;

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pairingStatus = ref.watch(pairingStatusProvider).valueOrNull;
    return SectionCard(
      accent: const Color(0xFFCEE2F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.near_me_rounded, size: 20),
              SizedBox(width: 8),
              Text('Nearby 同步', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          SyncStatusSummary(
            status: _status,
            autoModeEnabled: _autoModeEnabled,
            autoSyncFailureCount: _autoSyncFailureCount,
            lastAutoSyncError: _lastAutoSyncError,
            lastSyncAt: _lastSyncAt,
            lastSyncInsertedEvents: _lastSyncInsertedEvents,
            lastSyncDuplicateEvents: _lastSyncDuplicateEvents,
            lastSyncMergedFiles: _lastSyncMergedFiles,
            crossDeviceNoteDays: _crossDeviceNoteDays,
          ),
          if (pairingStatus != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: PairingStatusCard(status: pairingStatus),
            ),
          const SizedBox(height: 8),
          SyncActionControls(
            autoModeEnabled: _autoModeEnabled,
            discovering: _discovering,
            advertising: _advertising,
            connecting: _connecting,
            syncInFlight: _syncInFlight,
            onEnableAutoMode: _enableAutoMode,
            onDisableAutoMode: _disableAutoMode,
            onStartDiscovery: _startDiscovery,
            onStopDiscovery: _stopDiscovery,
            onStartAdvertising: _startAdvertising,
            onStopAdvertising: _stopAdvertising,
            onSyncNow: () => _syncNow(showSuccessToast: true),
          ),
          DiscoveredEndpointsList(
            endpoints: _endpoints,
            selectedEndpointId: _selectedEndpointId,
            onSelect: (endpointId) {
              setState(() {
                _selectedEndpointId = endpointId;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _startDiscovery() async {
    await _startDiscoveryInternal(showToast: true);
  }

  Future<void> _stopDiscovery() async {
    await ref.read(nearbySyncServiceProvider).stopDiscovery();
    if (!mounted) {
      return;
    }
    setState(() {
      _discovering = false;
      _endpoints.clear();
      _selectedEndpointId = null;
      _status = '已停止发现';
    });
    AppFeedback.info(context, '已停止发现');
  }

  Future<void> _startAdvertising() async {
    await _startAdvertisingInternal(showToast: true);
  }

  Future<void> _startDiscoveryInternal({required bool showToast}) async {
    if (_discovering) {
      return;
    }
    final granted = await Permissions.ensureNearby();
    if (!granted) {
      if (!mounted) {
        return;
      }
      setState(() => _status = '缺少 Nearby 相关权限');
      if (showToast) {
        AppFeedback.info(context, '缺少 Nearby 相关权限');
      }
      return;
    }
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
                final display = '$endpointName ($endpointId)';
                _endpoints.removeWhere((it) => it.endsWith('($endpointId)'));
                _endpoints.add(display);
                _status = '发现 ${_endpoints.length} 台设备';
                _selectedEndpointId ??= endpointId;
              });
              if (_autoModeEnabled) {
                _scheduleAutoSync();
              }
            },
            onLost: (endpointId) {
              if (!mounted) {
                return;
              }
              setState(() {
                _endpoints.removeWhere((it) => it.endsWith('($endpointId)'));
                if (_selectedEndpointId == endpointId) {
                  _selectedEndpointId = _endpoints.isEmpty
                      ? null
                      : DiscoveredEndpointsList.endpointIdFromDisplay(
                          _endpoints.first,
                        );
                }
                _status = _endpoints.isEmpty
                    ? '附近设备已离开'
                    : '当前可用设备 ${_endpoints.length} 台';
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
      if (showToast) {
        AppFeedback.error(context, '发现失败: $e');
      }
    }
  }

  Future<void> _startAdvertisingInternal({required bool showToast}) async {
    if (_advertising) {
      return;
    }
    final granted = await Permissions.ensureNearby();
    if (!granted) {
      if (!mounted) {
        return;
      }
      setState(() => _status = '缺少 Nearby 相关权限');
      if (showToast) {
        AppFeedback.info(context, '缺少 Nearby 相关权限');
      }
      return;
    }
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile == null) {
      return;
    }
    final session = SyncSession(
      repository: ref.read(pairRepositoryProvider),
      profile: profile,
    );

    await ref
        .read(nearbySyncServiceProvider)
        .startAdvertising(
          localUserName: profile.meName,
          onConnectionInitiated: (endpointId, endpointName) {
            if (!mounted) {
              return;
            }
            setState(() {
              _status = '连接请求: $endpointName';
            });
          },
          onConnected: (endpointId) {
            if (!mounted) {
              return;
            }
            setState(() {
              _status = '已连接 $endpointId';
            });
            if (_autoModeEnabled) {
              _scheduleAutoSync();
            }
          },
          onDisconnected: (endpointId) {
            if (!mounted) {
              return;
            }
            setState(() {
              _status = '连接断开 $endpointId';
            });
          },
          onBytesMessage: (endpointId, message) async {
            await _handleSyncMessage(endpointId, message, session);
          },
          onFileReceived: (endpointId, transfer) async {
            await _onFileTransfer(endpointId, transfer);
          },
        );

    if (!mounted) {
      return;
    }
    setState(() {
      _advertising = true;
      _status = '已开启 Nearby 广播';
    });
    if (showToast) {
      AppFeedback.success(context, '可发现已开启');
    }
    _ensureAutoTimer();
  }

  Future<void> _stopAdvertising() async {
    await ref.read(nearbySyncServiceProvider).stopAdvertising();
    if (!mounted) {
      return;
    }
    setState(() {
      _advertising = false;
      _status = '已停止广播';
    });
    AppFeedback.info(context, '已停止可发现');
    if (!_autoModeEnabled) {
      _autoSyncTimer?.cancel();
      _autoSyncTimer = null;
    }
  }

  Future<void> _enableAutoMode() async {
    if (_autoModeEnabled) {
      return;
    }
    setState(() {
      _autoModeEnabled = true;
      _autoSyncFailureCount = 0;
      _lastAutoSyncError = null;
      _status = '正在启动自动同步模式...';
    });
    _ensureAutoTimer();
    final advertisingStarted = await _tryStartAdvertisingForAutoMode();
    final discoveryStarted = await _tryStartDiscoveryForAutoMode();
    if (!mounted) {
      return;
    }
    if (!advertisingStarted && !discoveryStarted) {
      setState(() {
        _autoModeEnabled = false;
        _status = '自动同步模式启动失败';
        _lastAutoSyncError = '广播和发现都未启动';
      });
      _autoSyncTimer?.cancel();
      _autoSyncTimer = null;
      AppFeedback.error(context, '自动同步模式启动失败，请检查权限或 Nearby 服务');
      return;
    }
    setState(() {
      _status = '自动模式已开启，等待附近设备';
    });
    AppFeedback.success(context, '自动同步模式已开启');
  }

  Future<void> _disableAutoMode() async {
    if (!_autoModeEnabled) {
      return;
    }
    setState(() {
      _autoModeEnabled = false;
      _status = '正在关闭自动同步模式...';
    });
    await ref.read(nearbySyncServiceProvider).stopDiscovery();
    await ref.read(nearbySyncServiceProvider).stopAdvertising();
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    if (!mounted) {
      return;
    }
    setState(() {
      _discovering = false;
      _advertising = false;
      _status = '自动同步模式已关闭';
    });
    AppFeedback.info(context, '自动同步模式已关闭');
  }

  Future<void> _syncNow({required bool showSuccessToast}) async {
    if (_syncInFlight) {
      return;
    }
    _syncInFlight = true;
    try {
      final granted = await Permissions.ensureNearby();
      if (!granted) {
        if (mounted) {
          setState(() => _status = '缺少 Nearby 相关权限');
          AppFeedback.info(context, '缺少 Nearby 相关权限');
        }
        return;
      }
      final profile = ref.read(profileProvider).valueOrNull;
      if (profile == null) {
        return;
      }
      final endpointId = _selectedEndpointId;
      if (endpointId == null || endpointId.isEmpty) {
        if (mounted) {
          setState(() => _status = '请先选择发现到的设备');
          if (showSuccessToast) {
            AppFeedback.info(context, '请先选择发现到的设备');
          }
        }
        _trackAutoSyncFailure('未发现可同步设备');
        return;
      }

      final session = SyncSession(
        repository: ref.read(pairRepositoryProvider),
        profile: profile,
      );
      if (mounted) {
        setState(() {
          _connecting = true;
        });
      }
      try {
        await ref
            .read(nearbySyncServiceProvider)
            .requestConnection(
              localUserName: profile.meName,
              endpointId: endpointId,
              onConnected: (_) {},
              onBytesMessage: (from, message) async {
                await _handleSyncMessage(from, message, session);
              },
              onFileReceived: (from, transfer) async {
                await _onFileTransfer(from, transfer);
              },
            );
      } catch (e) {
        if (mounted) {
          setState(() {
            _status = '连接失败: $e';
          });
          if (showSuccessToast) {
            AppFeedback.error(context, '连接失败: $e');
          }
        }
        _trackAutoSyncFailure('连接失败');
        return;
      }
      final requestText = await session.buildSyncRequest();
      try {
        await ref.read(nearbySyncServiceProvider).sendJson(endpointId, {
          'kind': 'sync_request_raw',
          'raw': requestText,
        });
      } catch (e) {
        if (mounted) {
          setState(() {
            _status = '发送同步请求失败: $e';
          });
          if (showSuccessToast) {
            AppFeedback.error(context, '发送同步请求失败: $e');
          }
        }
        _trackAutoSyncFailure('发送同步请求失败');
        return;
      }
      if (mounted) {
        setState(() {
          _status = '同步请求已发送，等待对端回传缺失事件';
        });
        if (showSuccessToast) {
          AppFeedback.success(context, '同步请求已发送');
        }
      }
      _trackAutoSyncSuccess();
      _invalidateProjectionProviders();
    } finally {
      _syncInFlight = false;
      if (mounted) {
        setState(() {
          _connecting = false;
        });
      } else {
        _connecting = false;
      }
    }
  }

  Future<void> _handleSyncMessage(
    String endpointId,
    Map<String, dynamic> message,
    SyncSession session,
  ) async {
    final nearby = ref.read(nearbySyncServiceProvider);
    final kind = message['kind'] as String?;
    if (kind == 'sync_request' || kind == 'sync_request_raw') {
      final req = kind == 'sync_request_raw'
          ? jsonDecode(message['raw'] as String) as Map<String, dynamic>
          : message;
      final pairId = req['pairId'] as String?;
      if (!session.isMatchingPair(pairId)) {
        if (!mounted) {
          return;
        }
        setState(() {
          _status = '已忽略不同情侣空间的同步请求';
        });
        return;
      }
      final known = (req['knownEventIds'] as List<dynamic>? ?? <dynamic>[])
          .map((e) => e.toString())
          .toList();
      final rawResponse = await session.buildSyncResponse(known);
      await nearby.sendJson(endpointId, {
        'kind': 'sync_events_raw',
        'raw': rawResponse,
      });
      final files = await session.collectMissingImageFiles(known);
      for (final file in files) {
        await nearby.sendFile(endpointId, file);
      }
      return;
    }

    if (kind == 'file_meta') {
      final payloadId = (message['payloadId'] as num?)?.toInt();
      final filename = message['filename'] as String?;
      final imageEventId = message['imageEventId'] as String?;
      final pairId = message['pairId'] as String?;
      if (!session.isMatchingPair(pairId)) {
        if (!mounted) {
          return;
        }
        setState(() {
          _status = '已忽略不同情侣空间的文件同步元数据';
        });
        return;
      }
      if (payloadId == null || filename == null || imageEventId == null) {
        return;
      }
      _pendingFileMeta[payloadId] = filename;
      _pendingFileEventMap[payloadId] = imageEventId;
      await _tryFinalizeInboundFile(payloadId);
      return;
    }

    if (kind == 'sync_events' || kind == 'sync_events_raw') {
      final body = kind == 'sync_events_raw'
          ? jsonDecode(message['raw'] as String) as Map<String, dynamic>
          : message;
      final pairId = body['pairId'] as String?;
      if (!session.isMatchingPair(pairId)) {
        if (!mounted) {
          return;
        }
        setState(() {
          _status = '已忽略不同情侣空间的同步数据';
        });
        return;
      }
      final events = body['events'] as List<dynamic>? ?? <dynamic>[];
      final responderKnown =
          (body['responderKnownEventIds'] as List<dynamic>? ?? <dynamic>[])
              .map((e) => e.toString())
              .toList();
      final report = await session.mergeWithReport(events);
      if (!mounted) {
        return;
      }
      setState(() {
        final mismatch = report.filteredPairMismatchEvents;
        _status = mismatch > 0
            ? '接收 ${events.length} 条，已合并并过滤跨空间事件 $mismatch 条'
            : '接收并合并 ${events.length} 条事件';
        _lastSyncAt = DateTime.now();
        _lastSyncInsertedEvents = report.insertedEvents;
        _lastSyncDuplicateEvents = report.duplicateEvents;
        _lastSyncMergedFiles = 0;
        _crossDeviceNoteDays = report.crossDeviceNoteDays;
      });
      _trackAutoSyncSuccess();
      _invalidateProjectionProviders();
      await _maybePushBackLocalEvents(
        endpointId: endpointId,
        session: session,
        report: report,
        remoteKnownEventIds: responderKnown,
      );
      return;
    }

    if (kind == 'sync_events_push') {
      final body = message['raw'] is String
          ? jsonDecode(message['raw'] as String) as Map<String, dynamic>
          : message;
      final pairId = body['pairId'] as String?;
      if (!session.isMatchingPair(pairId)) {
        return;
      }
      final events = body['events'] as List<dynamic>? ?? <dynamic>[];
      final report = await session.mergeWithReport(events);
      if (!mounted) {
        return;
      }
      setState(() {
        _status =
            '双向收敛：新增 ${report.insertedEvents} / 重复 ${report.duplicateEvents}';
        _lastSyncAt = DateTime.now();
        _lastSyncInsertedEvents = report.insertedEvents;
        _lastSyncDuplicateEvents = report.duplicateEvents;
        _lastSyncMergedFiles = 0;
        _crossDeviceNoteDays = report.crossDeviceNoteDays;
      });
      _trackAutoSyncSuccess();
      _invalidateProjectionProviders();
    }
  }

  Future<void> _maybePushBackLocalEvents({
    required String endpointId,
    required SyncSession session,
    required SyncMergeReport report,
    required List<String> remoteKnownEventIds,
  }) async {
    if (report.insertedEvents <= 0) {
      return;
    }
    final now = DateTime.now();
    if (_lastReversePushAt != null &&
        now.difference(_lastReversePushAt!) < const Duration(seconds: 8)) {
      return;
    }
    _lastReversePushAt = now;
    final raw = await session.buildDeltaSyncPushPayload(remoteKnownEventIds);
    await ref.read(nearbySyncServiceProvider).sendJson(endpointId, {
      'kind': 'sync_events_push',
      'raw': raw,
    });
    final files = await session.collectMissingImageFiles(remoteKnownEventIds);
    for (final file in files) {
      await ref.read(nearbySyncServiceProvider).sendFile(endpointId, file);
    }
  }

  Future<void> _onFileTransfer(
    String endpointId,
    InboundFileTransfer transfer,
  ) async {
    _pendingFileUri[transfer.payloadId] = transfer.uri;
    await _tryFinalizeInboundFile(transfer.payloadId);
    if (!mounted) {
      return;
    }
    setState(() => _status = '接收文件中: ${transfer.payloadId}');
  }

  Future<void> _tryFinalizeInboundFile(int payloadId) async {
    final filename = _pendingFileMeta[payloadId];
    final uri = _pendingFileUri[payloadId];
    final imageEventId = _pendingFileEventMap[payloadId];
    if (filename == null || uri == null || imageEventId == null) {
      return;
    }
    final moved = await ref
        .read(nearbySyncServiceProvider)
        .moveInboundFile(sourceUri: uri, filename: filename);
    if (moved == null) {
      return;
    }

    await ref
        .read(pairRepositoryProvider)
        .updateEventImagePath(eventId: imageEventId, imagePath: moved);
    await ref
        .read(pairRepositoryProvider)
        .updateLinkedImagePath(imageEventId: imageEventId, imagePath: moved);

    _pendingFileMeta.remove(payloadId);
    _pendingFileUri.remove(payloadId);
    _pendingFileEventMap.remove(payloadId);

    if (!mounted) {
      return;
    }
    setState(() {
      _status = '图片同步完成: $filename';
      _lastSyncAt = DateTime.now();
      _lastSyncMergedFiles += 1;
    });
    _trackAutoSyncSuccess();
    ref.invalidateAfterInboundSyncImage();
  }

  void _invalidateProjectionProviders() {
    ref.invalidateAllPairScopedProjections();
  }

  void _scheduleAutoSync() {
    if (!_autoModeEnabled) {
      return;
    }
    final endpointId = _selectedEndpointId;
    if (endpointId == null || endpointId.isEmpty) {
      return;
    }
    if (_syncInFlight) {
      return;
    }
    final now = DateTime.now();
    if (_lastAutoSyncAttemptAt != null &&
        now.difference(_lastAutoSyncAttemptAt!) < _autoSyncGap) {
      return;
    }
    _lastAutoSyncAttemptAt = now;
    unawaited(_syncNow(showSuccessToast: false));
  }

  Future<bool> _tryStartAdvertisingForAutoMode() async {
    final before = _advertising;
    await _startAdvertisingInternal(showToast: false);
    return _advertising || before;
  }

  Future<bool> _tryStartDiscoveryForAutoMode() async {
    final before = _discovering;
    await _startDiscoveryInternal(showToast: false);
    return _discovering || before;
  }

  void _ensureAutoTimer() {
    _autoSyncTimer ??= Timer.periodic(_autoSyncTick, (_) async {
      if (_autoModeEnabled) {
        if (!_advertising) {
          await _startAdvertisingInternal(showToast: false);
        }
        if (!_discovering) {
          await _startDiscoveryInternal(showToast: false);
        }
      }
      _scheduleAutoSync();
    });
  }

  void _trackAutoSyncFailure(String error) {
    if (!_autoModeEnabled || !mounted) {
      return;
    }
    setState(() {
      _autoSyncFailureCount += 1;
      _lastAutoSyncError = error;
    });
  }

  void _trackAutoSyncSuccess() {
    if (!_autoModeEnabled || !mounted) {
      return;
    }
    if (_autoSyncFailureCount == 0 && _lastAutoSyncError == null) {
      return;
    }
    setState(() {
      _autoSyncFailureCount = 0;
      _lastAutoSyncError = null;
    });
  }
}
