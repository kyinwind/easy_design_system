import '../tokens/eds_design_tokens.dart';

/// A semantic container scene supported by the Easy API, mirroring Swift's
/// `EDSEasyStyle`.
enum EdsEasyStyle {
  /// Page scene: readable width, page padding, no background.
  page,

  /// Content block inside a page.
  content,

  /// Vertical section spacing.
  section,

  /// Filled group surface.
  group,

  /// Card surface with border and shadow.
  card,

  /// No styling at all.
  plain,
}

/// A semantic spacing value resolved from the current design tokens,
/// mirroring Swift's `EDSSpace`.
enum EdsSpace {
  /// Use the selected style's recommended spacing.
  automatic,

  /// No spacing at all.
  none,

  /// Extra-extra-small (4 by default).
  xxs,

  /// Extra-small (8 by default).
  xs,

  /// Small (12 by default).
  sm,

  /// Medium (16 by default).
  md,

  /// Large (20 by default).
  lg,

  /// Extra-large (24 by default).
  xl,

  /// Extra-extra-large (32 by default).
  xxl,

  /// Extra-extra-extra-large (40 by default).
  xxxl,
}

extension EdsSpaceResolveX on EdsSpace {
  /// Resolves this semantic space against [spacing]; returns null for
  /// [EdsSpace.automatic] so callers can fall back to their own defaults,
  /// exactly like the Swift `resolve(in:)`.
  double? resolve(EdsSpacingTokens spacing) {
    return switch (this) {
      EdsSpace.automatic => null,
      EdsSpace.none => 0,
      EdsSpace.xxs => spacing.xxs,
      EdsSpace.xs => spacing.xs,
      EdsSpace.sm => spacing.sm,
      EdsSpace.md => spacing.md,
      EdsSpace.lg => spacing.lg,
      EdsSpace.xl => spacing.xl,
      EdsSpace.xxl => spacing.xxl,
      EdsSpace.xxxl => spacing.xxxl,
    };
  }
}

/// Controls the maximum content width of an Easy style, mirroring Swift's
/// `EDSEasyWidth`.
///
/// Swift models this as an enum with an associated value; Dart uses a sealed
/// class so `EdsEasyWidth.fixed(880)` reads like the Swift `.fixed(880)`.
sealed class EdsEasyWidth {
  const EdsEasyWidth();

  /// Use the selected style's recommended width.
  static const EdsEasyWidth automatic = EdsEasyWidthAutomatic();

  /// Fill the available width.
  static const EdsEasyWidth unlimited = EdsEasyWidthUnlimited();

  /// Limit content to a concrete width.
  const factory EdsEasyWidth.fixed(double width) = EdsEasyFixedWidth;
}

/// The `automatic` width policy.
class EdsEasyWidthAutomatic extends EdsEasyWidth {
  const EdsEasyWidthAutomatic();

  @override
  bool operator ==(Object other) => other is EdsEasyWidthAutomatic;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// The `unlimited` width policy.
class EdsEasyWidthUnlimited extends EdsEasyWidth {
  const EdsEasyWidthUnlimited();

  @override
  bool operator ==(Object other) => other is EdsEasyWidthUnlimited;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// The `fixed` width policy.
class EdsEasyFixedWidth extends EdsEasyWidth {
  const EdsEasyFixedWidth(this.width);

  /// The concrete maximum content width.
  final double width;

  @override
  bool operator ==(Object other) =>
      other is EdsEasyFixedWidth && other.width == width;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Controls whether a style draws its semantic background surface, mirroring
/// Swift's `EDSEasyVisibility`.
enum EdsEasyVisibility {
  /// Use the selected style's recommended background policy.
  automatic,

  /// Force the semantic background on.
  visible,

  /// Force the background off.
  hidden,
}

/// The small set of intentional overrides supported by the Easy API,
/// mirroring Swift's `EDSEasyOptions`.
class EdsEasyOptions {
  const EdsEasyOptions({
    this.padding = EdsSpace.automatic,
    this.maxContentWidth = EdsEasyWidth.automatic,
    this.background = EdsEasyVisibility.automatic,
  });

  /// Padding override.
  final EdsSpace padding;

  /// Maximum content width override.
  final EdsEasyWidth maxContentWidth;

  /// Background visibility override.
  final EdsEasyVisibility background;

  /// Returns a copy with the given fields replaced.
  EdsEasyOptions copyWith({
    EdsSpace? padding,
    EdsEasyWidth? maxContentWidth,
    EdsEasyVisibility? background,
  }) {
    return EdsEasyOptions(
      padding: padding ?? this.padding,
      maxContentWidth: maxContentWidth ?? this.maxContentWidth,
      background: background ?? this.background,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EdsEasyOptions &&
        other.padding == padding &&
        other.maxContentWidth == maxContentWidth &&
        other.background == background;
  }

  @override
  int get hashCode => Object.hash(padding, maxContentWidth, background);
}
