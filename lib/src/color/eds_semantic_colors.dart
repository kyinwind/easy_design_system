import 'package:flutter/painting.dart';

/// Full resolved semantic color set for one brightness.
class EdsSemanticColors {
  const EdsSemanticColors({
    required this.surfacePage,
    required this.surfaceBase,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.surfaceOverlay,
    required this.surfaceDisabled,
    required this.foregroundPrimary,
    required this.foregroundSecondary,
    required this.foregroundTertiary,
    required this.foregroundDisabled,
    required this.foregroundInverse,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderSelected,
    required this.borderFocus,
    required this.borderDisabled,
    required this.borderDanger,
    required this.brandForeground,
    required this.brandSurface,
    required this.brandSurfaceStrong,
    required this.brandBorder,
    required this.brandOnStrong,
    required this.informationForeground,
    required this.informationSurface,
    required this.informationSurfaceStrong,
    required this.informationBorder,
    required this.informationOnStrong,
    required this.successForeground,
    required this.successSurface,
    required this.successSurfaceStrong,
    required this.successBorder,
    required this.successOnStrong,
    required this.warningForeground,
    required this.warningSurface,
    required this.warningSurfaceStrong,
    required this.warningBorder,
    required this.warningOnStrong,
    required this.dangerForeground,
    required this.dangerSurface,
    required this.dangerSurfaceStrong,
    required this.dangerBorder,
    required this.dangerOnStrong,
  });

  final Color surfacePage;
  final Color surfaceBase;
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color surfaceOverlay;
  final Color surfaceDisabled;

  final Color foregroundPrimary;
  final Color foregroundSecondary;
  final Color foregroundTertiary;
  final Color foregroundDisabled;
  final Color foregroundInverse;

  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;
  final Color borderSelected;
  final Color borderFocus;
  final Color borderDisabled;
  final Color borderDanger;

  final Color brandForeground;
  final Color brandSurface;
  final Color brandSurfaceStrong;
  final Color brandBorder;
  final Color brandOnStrong;

  final Color informationForeground;
  final Color informationSurface;
  final Color informationSurfaceStrong;
  final Color informationBorder;
  final Color informationOnStrong;

  final Color successForeground;
  final Color successSurface;
  final Color successSurfaceStrong;
  final Color successBorder;
  final Color successOnStrong;

  final Color warningForeground;
  final Color warningSurface;
  final Color warningSurfaceStrong;
  final Color warningBorder;
  final Color warningOnStrong;

  final Color dangerForeground;
  final Color dangerSurface;
  final Color dangerSurfaceStrong;
  final Color dangerBorder;
  final Color dangerOnStrong;

  EdsSemanticColors copyWith({
    Color? surfacePage,
    Color? surfaceBase,
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? surfaceOverlay,
    Color? surfaceDisabled,
    Color? foregroundPrimary,
    Color? foregroundSecondary,
    Color? foregroundTertiary,
    Color? foregroundDisabled,
    Color? foregroundInverse,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? borderSelected,
    Color? borderFocus,
    Color? borderDisabled,
    Color? borderDanger,
    Color? brandForeground,
    Color? brandSurface,
    Color? brandSurfaceStrong,
    Color? brandBorder,
    Color? brandOnStrong,
    Color? informationForeground,
    Color? informationSurface,
    Color? informationSurfaceStrong,
    Color? informationBorder,
    Color? informationOnStrong,
    Color? successForeground,
    Color? successSurface,
    Color? successSurfaceStrong,
    Color? successBorder,
    Color? successOnStrong,
    Color? warningForeground,
    Color? warningSurface,
    Color? warningSurfaceStrong,
    Color? warningBorder,
    Color? warningOnStrong,
    Color? dangerForeground,
    Color? dangerSurface,
    Color? dangerSurfaceStrong,
    Color? dangerBorder,
    Color? dangerOnStrong,
  }) {
    return EdsSemanticColors(
      surfacePage: surfacePage ?? this.surfacePage,
      surfaceBase: surfaceBase ?? this.surfaceBase,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
      surfaceDisabled: surfaceDisabled ?? this.surfaceDisabled,
      foregroundPrimary: foregroundPrimary ?? this.foregroundPrimary,
      foregroundSecondary: foregroundSecondary ?? this.foregroundSecondary,
      foregroundTertiary: foregroundTertiary ?? this.foregroundTertiary,
      foregroundDisabled: foregroundDisabled ?? this.foregroundDisabled,
      foregroundInverse: foregroundInverse ?? this.foregroundInverse,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      borderSelected: borderSelected ?? this.borderSelected,
      borderFocus: borderFocus ?? this.borderFocus,
      borderDisabled: borderDisabled ?? this.borderDisabled,
      borderDanger: borderDanger ?? this.borderDanger,
      brandForeground: brandForeground ?? this.brandForeground,
      brandSurface: brandSurface ?? this.brandSurface,
      brandSurfaceStrong: brandSurfaceStrong ?? this.brandSurfaceStrong,
      brandBorder: brandBorder ?? this.brandBorder,
      brandOnStrong: brandOnStrong ?? this.brandOnStrong,
      informationForeground:
          informationForeground ?? this.informationForeground,
      informationSurface: informationSurface ?? this.informationSurface,
      informationSurfaceStrong:
          informationSurfaceStrong ?? this.informationSurfaceStrong,
      informationBorder: informationBorder ?? this.informationBorder,
      informationOnStrong: informationOnStrong ?? this.informationOnStrong,
      successForeground: successForeground ?? this.successForeground,
      successSurface: successSurface ?? this.successSurface,
      successSurfaceStrong:
          successSurfaceStrong ?? this.successSurfaceStrong,
      successBorder: successBorder ?? this.successBorder,
      successOnStrong: successOnStrong ?? this.successOnStrong,
      warningForeground: warningForeground ?? this.warningForeground,
      warningSurface: warningSurface ?? this.warningSurface,
      warningSurfaceStrong:
          warningSurfaceStrong ?? this.warningSurfaceStrong,
      warningBorder: warningBorder ?? this.warningBorder,
      warningOnStrong: warningOnStrong ?? this.warningOnStrong,
      dangerForeground: dangerForeground ?? this.dangerForeground,
      dangerSurface: dangerSurface ?? this.dangerSurface,
      dangerSurfaceStrong: dangerSurfaceStrong ?? this.dangerSurfaceStrong,
      dangerBorder: dangerBorder ?? this.dangerBorder,
      dangerOnStrong: dangerOnStrong ?? this.dangerOnStrong,
    );
  }
}
