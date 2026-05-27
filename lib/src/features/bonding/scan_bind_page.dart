import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/projection_refresh.dart';
import '../../app/providers.dart';
import '../../core/permissions.dart';
import '../../widgets/app_feedback.dart';
import 'pair_invite.dart';

class ScanBindPage extends ConsumerStatefulWidget {
  const ScanBindPage({super.key});

  @override
  ConsumerState<ScanBindPage> createState() => _ScanBindPageState();
}

class _ScanBindPageState extends ConsumerState<ScanBindPage> {
  static const _duplicateLock = Duration(seconds: 2);

  final _controller = MobileScannerController(
    autoStart: false,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
    torchEnabled: false,
  );

  bool _handling = false;
  bool _cameraDenied = false;
  bool _showInvalidHint = false;
  String _statusText = '将邀请码放入取景框内';
  String? _lastDetectedRaw;
  DateTime? _lastDetectedAt;
  Timer? _invalidHintTimer;

  @override
  void initState() {
    super.initState();
    _prepareCamera();
  }

  @override
  void dispose() {
    _invalidHintTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('扫码加入同频'),
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iconAction(
                      icon: state.torchState == TorchState.on
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      label: '手电筒',
                      onTap: state.torchState == TorchState.unavailable
                          ? null
                          : _toggleTorch,
                    ),
                    const SizedBox(width: 8),
                    _iconAction(
                      icon: Icons.cameraswitch_rounded,
                      label: '切换镜头',
                      onTap:
                          state.availableCameras != null &&
                              state.availableCameras! < 2
                          ? null
                          : _switchCamera,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF24171C), Color(0xFF0E1118)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scanWindow = _scanWindowFor(constraints.biggest);
              return Stack(
                children: [
                  Positioned.fill(
                    child: _cameraDenied
                        ? _permissionFallback()
                        : MobileScanner(
                            controller: _controller,
                            scanWindow: scanWindow,
                            fit: BoxFit.cover,
                            tapToFocus: true,
                            placeholderBuilder: (_) => const ColoredBox(
                              color: Color(0xFF171A21),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFF2B4C1),
                                ),
                              ),
                            ),
                            overlayBuilder: (context, _) =>
                                _ScannerOverlay(scanWindow: scanWindow),
                            errorBuilder: (_, error) => _cameraError(error),
                            onDetect: _onDetect,
                          ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.18),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.44),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 84,
                    left: 20,
                    right: 20,
                    child: _HeaderCard(
                      statusText: _statusText,
                      showInvalidHint: _showInvalidHint,
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 18,
                    child: _BottomInstructionCard(onManualTap: _showManualHint),
                  ),
                  if (_handling)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                          ),
                          child: const Center(child: _ScanningLockPanel()),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _cameraError(MobileScannerException error) {
    return ColoredBox(
      color: const Color(0xFF12141A),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videocam_off_rounded,
                color: Color(0xFFF2B4C1),
                size: 34,
              ),
              const SizedBox(height: 12),
              Text(
                '相机初始化失败',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.errorDetails?.message ?? '请检查相机权限后重试。',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFD3D7E2)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconAction({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: enabled
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: enabled ? 0.22 : 0.08),
            ),
          ),
          child: Icon(
            icon,
            color: enabled ? Colors.white : Colors.white54,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _permissionFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE3E6).withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Color(0xFFF2B4C1),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '需要相机权限才能扫码加入',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '打开系统设置授予相机权限后，返回此页面即可继续。',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFD3D7E2), height: 1.4),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _prepareCamera,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('重新检查权限'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final raw = capture.barcodes.firstOrNull?.rawValue?.trim();
    if (raw == null || raw.isEmpty || _handling) {
      return;
    }

    final now = DateTime.now();
    if (_lastDetectedRaw == raw &&
        _lastDetectedAt != null &&
        now.difference(_lastDetectedAt!) < _duplicateLock) {
      return;
    }
    _lastDetectedRaw = raw;
    _lastDetectedAt = now;

    PairInvite invite;
    try {
      invite = PairInvite.fromRaw(raw);
    } on FormatException {
      _showInvalidInviteHint();
      return;
    }

    await _handleInvite(invite);
  }

  Future<void> _handleInvite(PairInvite invite) async {
    if (_handling) {
      return;
    }

    setState(() {
      _handling = true;
      _statusText = '已识别邀请码，正在确认身份';
      _showInvalidHint = false;
    });

    try {
      await _safeStopCamera();

      if (!mounted) {
        return;
      }

      final currentProfile = ref.read(profileProvider).valueOrNull;
      if (!isInviteCompatibleWithProfile(
        invite: invite,
        currentProfile: currentProfile,
      )) {
        AppFeedback.info(
          context,
          '当前设备已经加入其他同频空间，不能直接扫码覆盖，请先保留现有关系或清理本地数据后再加入新空间。',
        );
        await _resumeScanner(statusText: '当前设备已在其他空间中');
        return;
      }
      if (currentProfile != null && currentProfile.pairId == invite.pairId) {
        AppFeedback.info(context, '当前设备已经在这个同频空间中，无需重复扫码加入。');
        Navigator.of(context).pop(false);
        return;
      }

      final myName = await _promptForMyName(invite);
      if (myName == null || myName.isEmpty) {
        await _resumeScanner(statusText: '已取消加入，继续扫描邀请码');
        return;
      }

      await ref
          .read(profileProvider.notifier)
          .joinByInvite(
            myName: myName,
            pairId: invite.pairId,
            partnerName: invite.hostName,
            startedAt: invite.startedAt,
          );
      ref.invalidateAllPairScopedProjections();

      if (!mounted) {
        return;
      }

      AppFeedback.success(context, '已加入 ${invite.hostName} 创建的同频空间');
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppFeedback.error(context, '加入失败: $error');
      await _resumeScanner(statusText: '加入失败，请重新扫描');
    }
  }

  Future<String?> _promptForMyName(PairInvite invite) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认加入信息'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('你将加入 ${invite.hostName} 创建的同频空间。'),
              const SizedBox(height: 6),
              Text(
                '对方昵称预设为 ${invite.partnerName}，后续双方还需要在 Nearby 同步页靠近完成双端确认。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                textInputAction: TextInputAction.done,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '你的昵称',
                  hintText: '例如：小明',
                  prefixIcon: Icon(Icons.badge_rounded),
                ),
                onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('确认加入'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _prepareCamera() async {
    final granted = await Permissions.ensureCamera();
    if (!mounted) {
      return;
    }

    if (!granted) {
      setState(() {
        _cameraDenied = true;
        _statusText = '请先授予相机权限';
      });
      AppFeedback.info(context, '需要相机权限才能扫码绑定');
      return;
    }

    setState(() {
      _cameraDenied = false;
      _statusText = '将邀请码放入取景框内';
    });

    try {
      await _controller.start();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _statusText = '相机启动失败，请稍后重试');
    }
  }

  Future<void> _resumeScanner({required String statusText}) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _handling = false;
      _statusText = statusText;
    });

    try {
      await _controller.start();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _statusText = '相机恢复失败，请返回后重试');
    }
  }

  Future<void> _safeStopCamera() async {
    try {
      await _controller.stop();
    } catch (_) {
      // ignore stop failures so the pairing flow can continue.
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppFeedback.info(context, '当前设备不支持手电筒控制');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _controller.switchCamera();
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppFeedback.info(context, '当前设备无法切换镜头');
    }
  }

  void _showInvalidInviteHint() {
    _invalidHintTimer?.cancel();
    if (!mounted) {
      return;
    }
    setState(() {
      _showInvalidHint = true;
      _statusText = '识别到的不是同频邀请码，请对准对方展示的二维码';
    });
    _invalidHintTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showInvalidHint = false;
        if (!_handling) {
          _statusText = '将邀请码放入取景框内';
        }
      });
    });
  }

  void _showManualHint() {
    AppFeedback.info(context, '当前版本仅支持扫码加入；如识别不稳定，请提高屏幕亮度并保持二维码完整显示。');
  }

  Rect _scanWindowFor(Size size) {
    final width = size.width * 0.72;
    final windowSize = width.clamp(220.0, 310.0).toDouble();
    final maxTop = size.height - windowSize - 180;
    final top = maxTop <= 120
        ? math.max(96.0, (size.height - windowSize) / 2 - 12)
        : (size.height * 0.25).clamp(120.0, maxTop).toDouble();
    return Rect.fromCenter(
      center: Offset(size.width / 2, top + windowSize / 2),
      width: windowSize,
      height: windowSize,
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.statusText, required this.showInvalidHint});

  final String statusText;
  final bool showInvalidHint;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      showInvalidHint
                          ? Icons.error_outline_rounded
                          : Icons.center_focus_strong_rounded,
                      size: 15,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '扫码状态',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: showInvalidHint
                            ? const Color(0xFFAC5149).withValues(alpha: 0.2)
                            : const Color(0xFFF6BBC8).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        showInvalidHint
                            ? Icons.error_outline_rounded
                            : Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '扫码加入同频',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    height: 1.45,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HintChip(
                      icon: Icons.visibility_rounded,
                      text: '无需贴近，只要能扫到二维码',
                    ),
                    _HintChip(
                      icon: Icons.near_me_rounded,
                      text: '双端确认需后续 Nearby 靠近同步',
                    ),
                    _HintChip(
                      icon: Icons.verified_user_rounded,
                      text: '加入成功后会刷新首页和同步状态',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomInstructionCard extends StatelessWidget {
  const _BottomInstructionCard({required this.onManualTap});

  final VoidCallback onManualTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF151922).withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tips_and_updates_rounded,
                      size: 15,
                      color: Color(0xFFD6DAE4),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '操作说明',
                      style: TextStyle(
                        color: Color(0xFFD6DAE4),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '使用说明',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. 让对方在“创建同频空间”页面展示邀请码。\n2. 保持二维码完整、屏幕亮度充足。\n3. 扫码加入后，双方还需要去 Nearby 同步页完成一次靠近同步。',
                  style: TextStyle(
                    color: Color(0xFFD2D7E1),
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: onManualTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates_rounded,
                          color: Color(0xFFF2B4C1),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '识别不稳定时，优先调整角度、距离和亮度，再确认二维码完整显示',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanningLockPanel extends StatelessWidget {
  const _ScanningLockPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF121826).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: Color(0xFFF2B4C1),
            ),
          ),
          SizedBox(width: 12),
          Text(
            '正在锁定邀请码，请稍候',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  const _HintChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFFD6DE), size: 15),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatefulWidget {
  const _ScannerOverlay({required this.scanWindow});

  final Rect scanWindow;

  @override
  State<_ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<_ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final lineY = lerpDouble(
          widget.scanWindow.top + 18,
          widget.scanWindow.bottom - 18,
          Curves.easeInOut.transform(_controller.value),
        )!;
        return CustomPaint(
          painter: _ScannerOverlayPainter(
            scanWindow: widget.scanWindow,
            lineY: lineY,
          ),
        );
      },
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  _ScannerOverlayPainter({required this.scanWindow, required this.lineY});

  final Rect scanWindow;
  final double lineY;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.58)
      ..style = PaintingStyle.fill;

    final fullPath = Path()..addRect(Offset.zero & size);
    final cutout = Path()
      ..addRRect(
        RRect.fromRectAndRadius(scanWindow, const Radius.circular(30)),
      );

    canvas.drawPath(
      Path.combine(PathOperation.difference, fullPath, cutout),
      overlayPaint,
    );

    final borderPaint = Paint()
      ..color = const Color(0xFFF7CFD7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanWindow, const Radius.circular(30)),
      borderPaint,
    );

    final linePaint = Paint()
      ..shader =
          const LinearGradient(
            colors: [Color(0x00F7CFD7), Color(0xFFF7CFD7), Color(0x00F7CFD7)],
          ).createShader(
            Rect.fromLTWH(scanWindow.left, lineY - 1, scanWindow.width, 2),
          )
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(scanWindow.left + 18, lineY),
      Offset(scanWindow.right - 18, lineY),
      linePaint,
    );

    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;
    canvas.drawLine(
      scanWindow.topLeft + const Offset(0, cornerLength),
      scanWindow.topLeft,
      cornerPaint,
    );
    canvas.drawLine(
      scanWindow.topLeft,
      scanWindow.topLeft + const Offset(cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanWindow.topRight + const Offset(-cornerLength, 0),
      scanWindow.topRight,
      cornerPaint,
    );
    canvas.drawLine(
      scanWindow.topRight,
      scanWindow.topRight + const Offset(0, cornerLength),
      cornerPaint,
    );
    canvas.drawLine(
      scanWindow.bottomLeft + const Offset(0, -cornerLength),
      scanWindow.bottomLeft,
      cornerPaint,
    );
    canvas.drawLine(
      scanWindow.bottomLeft,
      scanWindow.bottomLeft + const Offset(cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanWindow.bottomRight + const Offset(-cornerLength, 0),
      scanWindow.bottomRight,
      cornerPaint,
    );
    canvas.drawLine(
      scanWindow.bottomRight + const Offset(0, -cornerLength),
      scanWindow.bottomRight,
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanWindow != scanWindow || oldDelegate.lineY != lineY;
  }
}
