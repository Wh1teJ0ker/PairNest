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
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFDF8F4), Color(0xFFF8F3EE)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -20,
            child: _GlowCircle(size: 200, color: topGlow),
          ),
          Positioned(
            bottom: -110,
            left: -30,
            child: _GlowCircle(size: 240, color: bottomGlow),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
