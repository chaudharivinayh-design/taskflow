import 'package:flutter/material.dart';

enum AppStyle { zen, pulse, fusion }

extension AppStyleLabel on AppStyle {
  String get label {
    switch (this) {
      case AppStyle.zen:
        return 'Zen';
      case AppStyle.pulse:
        return 'Pulse';
      case AppStyle.fusion:
        return 'Fusion';
    }
  }

  String get description {
    switch (this) {
      case AppStyle.zen:
        return 'Calm, clean, distraction-free';
      case AppStyle.pulse:
        return 'Colourful, visual and energetic';
      case AppStyle.fusion:
        return 'A balanced mix of both';
    }
  }
}

/// Seed colors + accent palette per style. Fusion is the default and
/// blends Zen's calm neutrals with Pulse's accent energy.
class StylePalette {
  final Color seed;
  final Color accent;
  final Color secondaryAccent;
  final double cardRadius;
  final bool useGradients;

  const StylePalette({
    required this.seed,
    required this.accent,
    required this.secondaryAccent,
    required this.cardRadius,
    required this.useGradients,
  });

  static const zen = StylePalette(
    seed: Color(0xFF3E6259), // muted sage
    accent: Color(0xFF3E6259),
    secondaryAccent: Color(0xFFB7A98F), // warm sand
    cardRadius: 16,
    useGradients: false,
  );

  static const pulse = StylePalette(
    seed: Color(0xFF6C4CF1), // vivid violet
    accent: Color(0xFFFF5D8F), // hot pink
    secondaryAccent: Color(0xFF00D6C8), // teal
    cardRadius: 22,
    useGradients: true,
  );

  static const fusion = StylePalette(
    seed: Color(0xFF3E5C9A), // balanced indigo-blue
    accent: Color(0xFF3E5C9A),
    secondaryAccent: Color(0xFFFF8A5B), // warm coral highlight
    cardRadius: 18,
    useGradients: false,
  );

  static StylePalette forStyle(AppStyle style) {
    switch (style) {
      case AppStyle.zen:
        return zen;
      case AppStyle.pulse:
        return pulse;
      case AppStyle.fusion:
        return fusion;
    }
  }
}
