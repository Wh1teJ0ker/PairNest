import 'package:flutter/material.dart';

enum SectionCardTone { standard, muted, strong }

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.accent,
    this.tone = SectionCardTone.standard,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? accent;
  final SectionCardTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderColor = accent ?? scheme.outline;
    final backgroundColor = switch (tone) {
      SectionCardTone.standard => scheme.surface,
      SectionCardTone.muted => scheme.surfaceContainerLow,
      SectionCardTone.strong => const Color(0xFF272120),
    };
    final foregroundColor = tone == SectionCardTone.strong
        ? Colors.white
        : scheme.onSurface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: tone == SectionCardTone.strong
              ? const Color(0xFF3D3635)
              : borderColor,
        ),
        boxShadow: tone == SectionCardTone.strong
            ? const [
                BoxShadow(
                  color: Color(0x160F0B08),
                  blurRadius: 24,
                  offset: Offset(0, 14),
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x080F0B08),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: foregroundColor),
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tone == SectionCardTone.strong
                        ? const Color(0xFFBA8A63)
                        : borderColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
