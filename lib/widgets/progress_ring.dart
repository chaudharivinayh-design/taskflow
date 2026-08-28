import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0..1
  final double size;
  final String centerLabel;
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 64,
    required this.centerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0, 1),
              strokeWidth: 6,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(scheme.primary),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            centerLabel,
            style: TextStyle(
              fontSize: size * 0.24,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
