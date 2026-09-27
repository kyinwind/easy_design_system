import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'eds_color_seeds.dart';
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
  }) {
    final dark = brightness == Brightness.dark;

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
      borderSelected: _familyBorder(brand, dark),
      borderFocus: _familyForeground(brand, dark),
      borderDisabled: dark
          ? EdsNeutralFoundation.darkBorderDisabled
          : EdsNeutralFoundation.lightBorderDisabled,
      borderDanger: _familyBorder(danger, dark),
      brandForeground: _familyForeground(brand, dark),
      brandSurface: _familySurface(brand, dark),
      brandSurfaceStrong: _familyStrong(brand, dark),
      brandBorder: _familyBorder(brand, dark),
      brandOnStrong: _familyOnStrong(brand, dark),
      informationForeground: _familyForeground(information, dark),
      informationSurface: _familySurface(information, dark),
      informationSurfaceStrong: _familyStrong(information, dark),
      informationBorder: _familyBorder(information, dark),
      informationOnStrong: _familyOnStrong(information, dark),
      successForeground: _familyForeground(success, dark),
      successSurface: _familySurface(success, dark),
      successSurfaceStrong: _familyStrong(success, dark),
      successBorder: _familyBorder(success, dark),
      successOnStrong: _familyOnStrong(success, dark),
      warningForeground: _familyForeground(warning, dark),
      warningSurface: _familySurface(warning, dark),
      warningSurfaceStrong: _familyStrong(warning, dark),
      warningBorder: _familyBorder(warning, dark),
      warningOnStrong: _familyOnStrong(warning, dark),
      dangerForeground: _familyForeground(danger, dark),
      dangerSurface: _familySurface(danger, dark),
      dangerSurfaceStrong: _familyStrong(danger, dark),
      dangerBorder: _familyBorder(danger, dark),
      dangerOnStrong: _familyOnStrong(danger, dark),
    );

    final patch = dark ? overrides.dark : overrides.light;
    return patch == null ? generated : _apply(generated, patch);
  }

  static Color _familyForeground(EdsTonalPalette palette, bool dark) =>
      palette.tone(dark ? 80 : 40);

  static Color _familySurface(EdsTonalPalette palette, bool dark) =>
      palette.tone(dark ? 20 : 95);

  static Color _familyStrong(EdsTonalPalette palette, bool dark) =>
      palette.tone(dark ? 80 : 40);

  static Color _familyBorder(EdsTonalPalette palette, bool dark) =>
      palette.tone(dark ? 60 : 70);

  static Color _familyOnStrong(EdsTonalPalette palette, bool dark) =>
      palette.tone(dark ? 10 : 100);

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
