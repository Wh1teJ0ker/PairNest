import 'package:flutter/material.dart';

class StaggeredColumn extends StatefulWidget {
  const StaggeredColumn({
    super.key,
    required this.children,
    this.baseDelayMs = 40,
    this.stepDelayMs = 70,
    this.durationMs = 360,
  });

  final List<Widget> children;
  final int baseDelayMs;
  final int stepDelayMs;
  final int durationMs;

  @override
  State<StaggeredColumn> createState() => _StaggeredColumnState();
}

class _StaggeredColumnState extends State<StaggeredColumn> {
  late final List<bool> _visibleFlags = List<bool>.filled(
    widget.children.length,
    false,
  );

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.children.length; i++) {
      Future<void>.delayed(
        Duration(milliseconds: widget.baseDelayMs + widget.stepDelayMs * i),
        () {
          if (mounted) {
            setState(() => _visibleFlags[i] = true);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.children.length, (index) {
        return Padding(
          padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
          child: AnimatedSlide(
            offset: _visibleFlags[index] ? Offset.zero : const Offset(0, 0.08),
            curve: Curves.easeOutCubic,
            duration: Duration(milliseconds: widget.durationMs),
            child: AnimatedOpacity(
              opacity: _visibleFlags[index] ? 1 : 0,
              curve: Curves.easeOutCubic,
              duration: Duration(milliseconds: widget.durationMs),
              child: widget.children[index],
            ),
          ),
        );
      }),
    );
  }
}
