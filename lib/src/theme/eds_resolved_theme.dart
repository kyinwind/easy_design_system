import 'package:flutter/foundation.dart';

import '../color/eds_color_seeds.dart';
import '../tokens/eds_color_scheme.dart';
import '../tokens/eds_design_tokens.dart';
import 'eds_theme_data.dart';

/// Runtime EDS theme resolved for a concrete brightness.
class EdsResolvedTheme {
  const EdsResolvedTheme({
    required this.configuration,
    required this.brightness,
    required this.colorScheme,
  });

  final EdsThemeData configuration;
  final Brightness brightness;
  final EdsColorScheme colorScheme;

  EdsColorSeeds get seeds => configuration.seeds;
  EdsDesignTokens get tokens => configuration.tokens;
}
