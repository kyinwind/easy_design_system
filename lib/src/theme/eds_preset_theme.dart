import 'package:flutter/painting.dart';

import '../color/eds_color_seeds.dart';
import '../tokens/eds_design_tokens.dart';
import 'eds_theme_data.dart';

/// A built-in EDS theme preset.
///
/// A preset owns a complete theme configuration: chromatic seeds plus
/// non-color design tokens. Host overrides are applied on top of a preset.
class EdsPresetTheme {
  const EdsPresetTheme({
    required this.id,
    required this.name,
    required this.theme,
  });

  final String id;
  final String name;
  final EdsThemeData theme;

  @override
  bool operator ==(Object other) => other is EdsPresetTheme && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'EdsPresetTheme($id)';

  /// The default blue theme.
  static const EdsPresetTheme defaultTheme = EdsPresetTheme(
    id: 'default',
    name: '默认蓝色',
    theme: EdsThemeData(
      seeds: EdsColorSeeds(),
      tokens: EdsDesignTokens(
        heroGradient: EdsDesignTokens.heroGradientBlue,
      ),
    ),
  );

  /// Alias of [defaultTheme].
  static const EdsPresetTheme blue = defaultTheme;

  /// Orange brand preset. Status families keep the EDS defaults.
  static const EdsPresetTheme orange = EdsPresetTheme(
    id: 'orange',
    name: '橙色',
    theme: EdsThemeData(
      seeds: EdsColorSeeds(
        brand: Color(0xFFFF6B00),
      ),
      tokens: EdsDesignTokens(
        heroGradient: EdsDesignTokens.heroGradientOrange,
      ),
    ),
  );

  /// Purple brand preset. Status families keep the EDS defaults.
  static const EdsPresetTheme purple = EdsPresetTheme(
    id: 'purple',
    name: '紫色',
    theme: EdsThemeData(
      seeds: EdsColorSeeds(
        brand: Color(0xFF8B5CF6),
      ),
      tokens: EdsDesignTokens(
        heroGradient: EdsDesignTokens.heroGradientPurple,
      ),
    ),
  );

  static const List<EdsPresetTheme> allPresets = <EdsPresetTheme>[
    defaultTheme,
    orange,
    purple,
  ];
}
