import '../color/eds_color_seeds.dart';
import '../tokens/eds_design_tokens.dart';

/// Complete host-configurable EDS theme configuration.
///
/// ColorScheme 2.0 separates chromatic seeds from the non-color design token
/// set. Runtime semantic colors are resolved later from this configuration,
/// brightness, semantic overrides, interaction state and layer context.
class EdsThemeData {
  const EdsThemeData({
    this.seeds = const EdsColorSeeds(),
    this.tokens = const EdsDesignTokens(),
  });

  final EdsColorSeeds seeds;
  final EdsDesignTokens tokens;

  EdsThemeData copyWith({
    EdsColorSeeds? seeds,
    EdsDesignTokens? tokens,
  }) {
    return EdsThemeData(
      seeds: seeds ?? this.seeds,
      tokens: tokens ?? this.tokens,
    );
  }

  /// Applies a partial seed patch without replacing non-color tokens.
  EdsThemeData withSeedOverrides(EdsColorSeedOverrides overrides) {
    if (overrides.isEmpty) return this;
    return copyWith(seeds: seeds.apply(overrides));
  }

  @override
  bool operator ==(Object other) {
    return other is EdsThemeData &&
        other.seeds == seeds &&
        other.tokens == tokens;
  }

  @override
  int get hashCode => Object.hash(seeds, tokens);
}
