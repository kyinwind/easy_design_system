import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../color/eds_color_resolver.dart';
import '../color/eds_color_seeds.dart';
import '../color/eds_color_style.dart';
import '../color/eds_semantic_colors.dart';
import '../color/eds_semantic_overrides.dart';

/// Public resolved ColorScheme 2.0 view for one brightness.
class EdsColorScheme {
  const EdsColorScheme._(this._colors);

  final EdsSemanticColors _colors;

  factory EdsColorScheme.resolve({
    required EdsColorSeeds seeds,
    required Brightness brightness,
    EdsSemanticOverrides overrides = const EdsSemanticOverrides(),
    EdsColorStyle style = EdsColorStyle.defaultStyle,
  }) {
    return EdsColorScheme._(
      EdsColorResolver.resolve(
        seeds: seeds,
        brightness: brightness,
        overrides: overrides,
        style: style,
      ),
    );
  }

  Color get surfacePage => _colors.surfacePage;
  Color get surfaceBase => _colors.surfaceBase;
  Color get surfaceRaised => _colors.surfaceRaised;
  Color get surfaceSunken => _colors.surfaceSunken;
  Color get surfaceOverlay => _colors.surfaceOverlay;
  Color get surfaceDisabled => _colors.surfaceDisabled;

  Color get foregroundPrimary => _colors.foregroundPrimary;
  Color get foregroundSecondary => _colors.foregroundSecondary;
  Color get foregroundTertiary => _colors.foregroundTertiary;
  Color get foregroundDisabled => _colors.foregroundDisabled;
  Color get foregroundInverse => _colors.foregroundInverse;

  Color get borderSubtle => _colors.borderSubtle;
  Color get borderDefault => _colors.borderDefault;
  Color get borderStrong => _colors.borderStrong;
  Color get borderSelected => _colors.borderSelected;
  Color get borderFocus => _colors.borderFocus;
  Color get borderDisabled => _colors.borderDisabled;
  Color get borderDanger => _colors.borderDanger;

  Color get brandForeground => _colors.brandForeground;
  Color get brandSurface => _colors.brandSurface;
  Color get brandSurfaceStrong => _colors.brandSurfaceStrong;
  Color get brandBorder => _colors.brandBorder;
  Color get brandOnStrong => _colors.brandOnStrong;

  Color get informationForeground => _colors.informationForeground;
  Color get informationSurface => _colors.informationSurface;
  Color get informationSurfaceStrong => _colors.informationSurfaceStrong;
  Color get informationBorder => _colors.informationBorder;
  Color get informationOnStrong => _colors.informationOnStrong;

  Color get successForeground => _colors.successForeground;
  Color get successSurface => _colors.successSurface;
  Color get successSurfaceStrong => _colors.successSurfaceStrong;
  Color get successBorder => _colors.successBorder;
  Color get successOnStrong => _colors.successOnStrong;

  Color get warningForeground => _colors.warningForeground;
  Color get warningSurface => _colors.warningSurface;
  Color get warningSurfaceStrong => _colors.warningSurfaceStrong;
  Color get warningBorder => _colors.warningBorder;
  Color get warningOnStrong => _colors.warningOnStrong;

  Color get dangerForeground => _colors.dangerForeground;
  Color get dangerSurface => _colors.dangerSurface;
  Color get dangerSurfaceStrong => _colors.dangerSurfaceStrong;
  Color get dangerBorder => _colors.dangerBorder;
  Color get dangerOnStrong => _colors.dangerOnStrong;
}
