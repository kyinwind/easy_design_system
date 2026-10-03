import 'package:flutter/foundation.dart';

import '../tokens/eds_color_scheme.dart';
import 'eds_resolved_theme.dart';
import 'eds_theme_data.dart';

abstract final class EdsThemeResolver {
  static EdsResolvedTheme resolve({
    required EdsThemeData theme,
    required Brightness brightness,
  }) {
    return EdsResolvedTheme(
      configuration: theme,
      brightness: brightness,
      colorScheme: EdsColorScheme.resolve(
        seeds: theme.seeds,
        brightness: brightness,
        overrides: theme.semanticOverrides,
        style: theme.colorStyle,
      ),
    );
  }
}
