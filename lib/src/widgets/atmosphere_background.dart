import 'package:flutter/material.dart';

class AtmosphereBackground extends StatelessWidget {
  const AtmosphereBackground({
    super.key,
    required this.child,
    this.topGlow = const Color(0x1FF08A96),
    this.bottomGlow = const Color(0x1F8BB3E7),
  });

  final Widget child;
  final Color topGlow;
  final Color bottomGlow;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF8F3ED), Color(0xFFF2ECE4)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          top: -120,
          right: -80,
          child: _AuraPlane(width: 260, height: 260, color: topGlow),
        ),
        Positioned(
          bottom: -140,
          left: -90,
          child: _AuraPlane(width: 320, height: 320, color: bottomGlow),
        ),
        const Positioned.fill(child: IgnorePointer(child: _LineTexture())),
        child,
      ],
    );
  }
}

class _AuraPlane extends StatelessWidget {
  const _AuraPlane({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class _LineTexture extends StatelessWidget {
  const _LineTexture();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineTexturePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _LineTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final vertical = Paint()
      ..color = const Color(0x0B2A221E)
      ..strokeWidth = 1;
    final horizontal = Paint()
      ..color = const Color(0x08FFFFFF)
      ..strokeWidth = 1;

    for (double x = 24; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), vertical);
    }
    for (double y = 20; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), horizontal);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
