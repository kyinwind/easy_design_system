import 'package:flutter/widgets.dart';

import '../theme/eds_theme_scope.dart';
import 'eds_design_tokens.dart';

/// Brightness-dependent semantic colors.
///
/// The Swift package derives these from dynamic system colors
/// (`Color.primary`, `NSColor.windowBackgroundColor`, …) that resolve
/// themselves through the SwiftUI environment. Flutter has no dynamic system
/// palette, so this class resolves the same roles deterministically from a
/// brightness:
///
/// | role | light | dark |
/// |---|---|---|
/// | [label] / [textPrimary] | black | white |
/// | [textSecondary] | black 60% | white 60% |
/// | [textTertiary] | black 43.2% | white 43.2% |
/// | [pageBackground] | `#F7F7F7` | `#1E1E20` |
/// | [cardBackground] | `#FFFFFF` | `#2A2A2C` |
/// | [cardGrayBackground] | black 4.5% | white 4.5% |
/// | [subtleFill] | black 3.0% | white 3.0% |
/// | [border] | black 10% | white 10% |
class EdsColorScheme {
  const EdsColorScheme._({
    required this.label,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.pageBackground,
    required this.cardBackground,
    required this.cardGrayBackground,
    required this.subtleFill,
    required this.border,
  });

  /// Resolves the semantic color roles for [tokens] under [brightness].
  factory EdsColorScheme.resolve(
    EdsDesignTokens tokens,
    Brightness brightness,
  ) {
    final dark = brightness == Brightness.dark;
    final base = dark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    return EdsColorScheme._(
      label: base,
      textPrimary: base,
      textSecondary: base.withValues(alpha: 0.6),
      // Swift: `Color.secondary.opacity(0.72)` → 0.6 × 0.72 = 0.432.
      textTertiary: base.withValues(alpha: 0.432),
      pageBackground: dark ? const Color(0xFF1E1E20) : const Color(0xFFF7F7F7),
      cardBackground: dark ? const Color(0xFF2A2A2C) : const Color(0xFFFFFFFF),
      cardGrayBackground: base.withValues(alpha: 0.045),
      subtleFill: base.withValues(alpha: 0.030),
      border: base.withValues(alpha: 0.10),
    );
  }

  /// The unmodified foreground color (Swift `Color.primary`).
  final Color label;

  /// Primary text color (Swift `Color.primary`).
  final Color textPrimary;

  /// Secondary text color (Swift `Color.secondary`).
  final Color textSecondary;

  /// Tertiary text color (Swift `Color.secondary.opacity(0.72)`).
  final Color textTertiary;

  /// Page-level background.
  final Color pageBackground;

  /// Card-level background.
  final Color cardBackground;

  /// Filled-group background (Swift `Color.primary.opacity(0.045)`).
  final Color cardGrayBackground;

  /// Subtle fill for wells and tracks (Swift `Color.primary.opacity(0.030)`).
  final Color subtleFill;

  /// Hairline border color (Swift `Color.primary.opacity(0.10)`).
  final Color border;

  @override
  bool operator ==(Object other) {
    return other is EdsColorScheme &&
        other.label == label &&
        other.textPrimary == textPrimary &&
        other.textSecondary == textSecondary &&
        other.textTertiary == textTertiary &&
        other.pageBackground == pageBackground &&
        other.cardBackground == cardBackground &&
        other.cardGrayBackground == cardGrayBackground &&
        other.subtleFill == subtleFill &&
        other.border == border;
  }

  @override
  int get hashCode => Object.hash(
        label,
        textPrimary,
        textSecondary,
        textTertiary,
        pageBackground,
        cardBackground,
        cardGrayBackground,
        subtleFill,
        border,
      );
}

extension EdsColorSchemeContextX on BuildContext {
  /// The color scheme for this subtree, resolved from the scoped tokens and
  /// effective brightness.
  EdsColorScheme get edsScheme =>
      EdsColorScheme.resolve(edsTokens, edsBrightness);
}
