import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'eds_color_seeds.dart';
import 'eds_color_style.dart';
import 'eds_neutral_foundation.dart';
import 'eds_semantic_colors.dart';
import 'eds_semantic_overrides.dart';
import 'eds_tonal_palette.dart';

/// Deterministic Seed -> Palette -> Semantic Role resolver.
abstract final class EdsColorResolver {
  static EdsSemanticColors resolve({
    required EdsColorSeeds seeds,
    required Brightness brightness,
    EdsSemanticOverrides overrides = const EdsSemanticOverrides(),
    EdsColorStyle style = EdsColorStyle.defaultStyle,
  }) {
    final dark = brightness == Brightness.dark;
    final tones = dark ? style.dark : style.light;

    final brand = EdsTonalPalette.fromSeed(seeds.brand);
    final information = EdsTonalPalette.fromSeed(seeds.information);
    final success = EdsTonalPalette.fromSeed(seeds.success);
    final warning = EdsTonalPalette.fromSeed(seeds.warning);
    final danger = EdsTonalPalette.fromSeed(seeds.danger);

    final generated = EdsSemanticColors(
      surfacePage: dark
          ? EdsNeutralFoundation.darkSurfacePage
          : EdsNeutralFoundation.lightSurfacePage,
      surfaceBase: dark
          ? EdsNeutralFoundation.darkSurfaceBase
          : EdsNeutralFoundation.lightSurfaceBase,
      surfaceRaised: dark
          ? EdsNeutralFoundation.darkSurfaceRaised
          : EdsNeutralFoundation.lightSurfaceRaised,
      surfaceSunken: dark
          ? EdsNeutralFoundation.darkSurfaceSunken
          : EdsNeutralFoundation.lightSurfaceSunken,
      surfaceOverlay: dark
          ? EdsNeutralFoundation.darkSurfaceOverlay
          : EdsNeutralFoundation.lightSurfaceOverlay,
      surfaceDisabled: dark
          ? EdsNeutralFoundation.darkSurfaceDisabled
          : EdsNeutralFoundation.lightSurfaceDisabled,
      foregroundPrimary: dark
          ? EdsNeutralFoundation.darkForegroundPrimary
          : EdsNeutralFoundation.lightForegroundPrimary,
      foregroundSecondary: dark
          ? EdsNeutralFoundation.darkForegroundSecondary
          : EdsNeutralFoundation.lightForegroundSecondary,
      foregroundTertiary: dark
          ? EdsNeutralFoundation.darkForegroundTertiary
          : EdsNeutralFoundation.lightForegroundTertiary,
      foregroundDisabled: dark
          ? EdsNeutralFoundation.darkForegroundDisabled
          : EdsNeutralFoundation.lightForegroundDisabled,
      foregroundInverse: dark
          ? EdsNeutralFoundation.darkForegroundInverse
          : EdsNeutralFoundation.lightForegroundInverse,
      borderSubtle: dark
          ? EdsNeutralFoundation.darkBorderSubtle
          : EdsNeutralFoundation.lightBorderSubtle,
      borderDefault: dark
          ? EdsNeutralFoundation.darkBorderDefault
          : EdsNeutralFoundation.lightBorderDefault,
      borderStrong: dark
          ? EdsNeutralFoundation.darkBorderStrong
          : EdsNeutralFoundation.lightBorderStrong,
      borderSelected: _familyBorder(brand, tones),
      borderFocus: _familyForeground(brand, tones),
      borderDisabled: dark
          ? EdsNeutralFoundation.darkBorderDisabled
          : EdsNeutralFoundation.lightBorderDisabled,
      borderDanger: _familyBorder(danger, tones),
      brandForeground: _familyForeground(brand, tones),
      brandSurface: _familySurface(brand, tones),
      brandSurfaceStrong: _familyStrong(brand, tones),
      brandBorder: _familyBorder(brand, tones),
      brandOnStrong: _familyOnStrong(brand, tones),
      informationForeground: _familyForeground(information, tones),
      informationSurface: _familySurface(information, tones),
      informationSurfaceStrong: _familyStrong(information, tones),
      informationBorder: _familyBorder(information, tones),
      informationOnStrong: _familyOnStrong(information, tones),
      successForeground: _familyForeground(success, tones),
      successSurface: _familySurface(success, tones),
      successSurfaceStrong: _familyStrong(success, tones),
      successBorder: _familyBorder(success, tones),
      successOnStrong: _familyOnStrong(success, tones),
      warningForeground: _familyForeground(warning, tones),
      warningSurface: _familySurface(warning, tones),
      warningSurfaceStrong: _familyStrong(warning, tones),
      warningBorder: _familyBorder(warning, tones),
      warningOnStrong: _familyOnStrong(warning, tones),
      dangerForeground: _familyForeground(danger, tones),
      dangerSurface: _familySurface(danger, tones),
      dangerSurfaceStrong: _familyStrong(danger, tones),
      dangerBorder: _familyBorder(danger, tones),
      dangerOnStrong: _familyOnStrong(danger, tones),
    );

    final styled =
        _applyContentColors(generated, style.contentColors, brightness);
    final patch = dark ? overrides.dark : overrides.light;
    return patch == null ? styled : _apply(styled, patch);
  }

  static Color _familyForeground(
    EdsTonalPalette palette,
    EdsToneSet tones,
  ) =>
      palette.tone(tones.foreground);

  static Color _familySurface(
    EdsTonalPalette palette,
    EdsToneSet tones,
  ) =>
      palette.tone(tones.surface);

  static Color _familyStrong(
    EdsTonalPalette palette,
    EdsToneSet tones,
  ) =>
      palette.tone(tones.strong);

  static Color _familyBorder(
    EdsTonalPalette palette,
    EdsToneSet tones,
  ) =>
      palette.tone(tones.border);

  static Color _familyOnStrong(
    EdsTonalPalette palette,
    EdsToneSet tones,
  ) =>
      palette.tone(tones.onStrong);

  static EdsSemanticColors _applyContentColors(
    EdsSemanticColors base,
    EdsContentColorOverrides colors,
    Brightness brightness,
  ) {
    Color? value(EdsContentColorRole role) => colors.colorFor(role, brightness);
    return base.copyWith(
      foregroundPrimary: value(EdsContentColorRole.foregroundPrimary),
      foregroundSecondary: value(EdsContentColorRole.foregroundSecondary),
      foregroundTertiary: value(EdsContentColorRole.foregroundTertiary),
      foregroundDisabled: value(EdsContentColorRole.foregroundDisabled),
      foregroundInverse: value(EdsContentColorRole.foregroundInverse),
      brandOnStrong: value(EdsContentColorRole.brandOnStrong),
      informationOnStrong: value(EdsContentColorRole.informationOnStrong),
      successOnStrong: value(EdsContentColorRole.successOnStrong),
      warningOnStrong: value(EdsContentColorRole.warningOnStrong),
      dangerOnStrong: value(EdsContentColorRole.dangerOnStrong),
    );
  }

  static EdsSemanticColors _apply(
    EdsSemanticColors base,
    EdsSemanticColorOverrides p,
  ) {
    return base.copyWith(
      surfacePage: p.surfacePage,
      surfaceBase: p.surfaceBase,
      surfaceRaised: p.surfaceRaised,
      surfaceSunken: p.surfaceSunken,
      surfaceOverlay: p.surfaceOverlay,
      surfaceDisabled: p.surfaceDisabled,
      foregroundPrimary: p.foregroundPrimary,
      foregroundSecondary: p.foregroundSecondary,
      foregroundTertiary: p.foregroundTertiary,
      foregroundDisabled: p.foregroundDisabled,
      foregroundInverse: p.foregroundInverse,
      borderSubtle: p.borderSubtle,
      borderDefault: p.borderDefault,
      borderStrong: p.borderStrong,
      borderSelected: p.borderSelected,
      borderFocus: p.borderFocus,
      borderDisabled: p.borderDisabled,
      borderDanger: p.borderDanger,
      brandForeground: p.brandForeground,
      brandSurface: p.brandSurface,
      brandSurfaceStrong: p.brandSurfaceStrong,
      brandBorder: p.brandBorder,
      brandOnStrong: p.brandOnStrong,
      informationForeground: p.informationForeground,
      informationSurface: p.informationSurface,
      informationSurfaceStrong: p.informationSurfaceStrong,
      informationBorder: p.informationBorder,
      informationOnStrong: p.informationOnStrong,
      successForeground: p.successForeground,
      successSurface: p.successSurface,
      successSurfaceStrong: p.successSurfaceStrong,
      successBorder: p.successBorder,
      successOnStrong: p.successOnStrong,
      warningForeground: p.warningForeground,
      warningSurface: p.warningSurface,
      warningSurfaceStrong: p.warningSurfaceStrong,
      warningBorder: p.warningBorder,
      warningOnStrong: p.warningOnStrong,
      dangerForeground: p.dangerForeground,
      dangerSurface: p.dangerSurface,
      dangerSurfaceStrong: p.dangerSurfaceStrong,
      dangerBorder: p.dangerBorder,
      dangerOnStrong: p.dangerOnStrong,
    );
  }
}
