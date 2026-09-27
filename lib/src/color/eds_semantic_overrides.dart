import 'package:flutter/painting.dart';

/// Partial semantic color patch for one brightness.
///
/// Every field is nullable by design. Missing values continue using the
/// automatically generated ColorScheme 2.0 value.
class EdsSemanticColorOverrides {
  const EdsSemanticColorOverrides({
    this.surfacePage,
    this.surfaceBase,
    this.surfaceRaised,
    this.surfaceSunken,
    this.surfaceOverlay,
    this.surfaceDisabled,
    this.foregroundPrimary,
    this.foregroundSecondary,
    this.foregroundTertiary,
    this.foregroundDisabled,
    this.foregroundInverse,
    this.borderSubtle,
    this.borderDefault,
    this.borderStrong,
    this.borderSelected,
    this.borderFocus,
    this.borderDisabled,
    this.borderDanger,
    this.brandForeground,
    this.brandSurface,
    this.brandSurfaceStrong,
    this.brandBorder,
    this.brandOnStrong,
    this.informationForeground,
    this.informationSurface,
    this.informationSurfaceStrong,
    this.informationBorder,
    this.informationOnStrong,
    this.successForeground,
    this.successSurface,
    this.successSurfaceStrong,
    this.successBorder,
    this.successOnStrong,
    this.warningForeground,
    this.warningSurface,
    this.warningSurfaceStrong,
    this.warningBorder,
    this.warningOnStrong,
    this.dangerForeground,
    this.dangerSurface,
    this.dangerSurfaceStrong,
    this.dangerBorder,
    this.dangerOnStrong,
  });

  final Color? surfacePage;
  final Color? surfaceBase;
  final Color? surfaceRaised;
  final Color? surfaceSunken;
  final Color? surfaceOverlay;
  final Color? surfaceDisabled;

  final Color? foregroundPrimary;
  final Color? foregroundSecondary;
  final Color? foregroundTertiary;
  final Color? foregroundDisabled;
  final Color? foregroundInverse;

  final Color? borderSubtle;
  final Color? borderDefault;
  final Color? borderStrong;
  final Color? borderSelected;
  final Color? borderFocus;
  final Color? borderDisabled;
  final Color? borderDanger;

  final Color? brandForeground;
  final Color? brandSurface;
  final Color? brandSurfaceStrong;
  final Color? brandBorder;
  final Color? brandOnStrong;

  final Color? informationForeground;
  final Color? informationSurface;
  final Color? informationSurfaceStrong;
  final Color? informationBorder;
  final Color? informationOnStrong;

  final Color? successForeground;
  final Color? successSurface;
  final Color? successSurfaceStrong;
  final Color? successBorder;
  final Color? successOnStrong;

  final Color? warningForeground;
  final Color? warningSurface;
  final Color? warningSurfaceStrong;
  final Color? warningBorder;
  final Color? warningOnStrong;

  final Color? dangerForeground;
  final Color? dangerSurface;
  final Color? dangerSurfaceStrong;
  final Color? dangerBorder;
  final Color? dangerOnStrong;

  bool get isEmpty => toJson().isEmpty;

  EdsSemanticColorOverrides merge(EdsSemanticColorOverrides patch) {
    return EdsSemanticColorOverrides(
      surfacePage: patch.surfacePage ?? surfacePage,
      surfaceBase: patch.surfaceBase ?? surfaceBase,
      surfaceRaised: patch.surfaceRaised ?? surfaceRaised,
      surfaceSunken: patch.surfaceSunken ?? surfaceSunken,
      surfaceOverlay: patch.surfaceOverlay ?? surfaceOverlay,
      surfaceDisabled: patch.surfaceDisabled ?? surfaceDisabled,
      foregroundPrimary: patch.foregroundPrimary ?? foregroundPrimary,
      foregroundSecondary: patch.foregroundSecondary ?? foregroundSecondary,
      foregroundTertiary: patch.foregroundTertiary ?? foregroundTertiary,
      foregroundDisabled: patch.foregroundDisabled ?? foregroundDisabled,
      foregroundInverse: patch.foregroundInverse ?? foregroundInverse,
      borderSubtle: patch.borderSubtle ?? borderSubtle,
      borderDefault: patch.borderDefault ?? borderDefault,
      borderStrong: patch.borderStrong ?? borderStrong,
      borderSelected: patch.borderSelected ?? borderSelected,
      borderFocus: patch.borderFocus ?? borderFocus,
      borderDisabled: patch.borderDisabled ?? borderDisabled,
      borderDanger: patch.borderDanger ?? borderDanger,
      brandForeground: patch.brandForeground ?? brandForeground,
      brandSurface: patch.brandSurface ?? brandSurface,
      brandSurfaceStrong: patch.brandSurfaceStrong ?? brandSurfaceStrong,
      brandBorder: patch.brandBorder ?? brandBorder,
      brandOnStrong: patch.brandOnStrong ?? brandOnStrong,
      informationForeground:
          patch.informationForeground ?? informationForeground,
      informationSurface: patch.informationSurface ?? informationSurface,
      informationSurfaceStrong:
          patch.informationSurfaceStrong ?? informationSurfaceStrong,
      informationBorder: patch.informationBorder ?? informationBorder,
      informationOnStrong: patch.informationOnStrong ?? informationOnStrong,
      successForeground: patch.successForeground ?? successForeground,
      successSurface: patch.successSurface ?? successSurface,
      successSurfaceStrong:
          patch.successSurfaceStrong ?? successSurfaceStrong,
      successBorder: patch.successBorder ?? successBorder,
      successOnStrong: patch.successOnStrong ?? successOnStrong,
      warningForeground: patch.warningForeground ?? warningForeground,
      warningSurface: patch.warningSurface ?? warningSurface,
      warningSurfaceStrong:
          patch.warningSurfaceStrong ?? warningSurfaceStrong,
      warningBorder: patch.warningBorder ?? warningBorder,
      warningOnStrong: patch.warningOnStrong ?? warningOnStrong,
      dangerForeground: patch.dangerForeground ?? dangerForeground,
      dangerSurface: patch.dangerSurface ?? dangerSurface,
      dangerSurfaceStrong: patch.dangerSurfaceStrong ?? dangerSurfaceStrong,
      dangerBorder: patch.dangerBorder ?? dangerBorder,
      dangerOnStrong: patch.dangerOnStrong ?? dangerOnStrong,
    );
  }

  factory EdsSemanticColorOverrides.fromJson(Map<String, Object?>? json) {
    if (json == null) return const EdsSemanticColorOverrides();

    Color? read(String key) {
      final value = json[key];
      if (value == null) return null;
      if (value is! String) {
        throw FormatException(
          'Expected a hex string for "$key" but found ${value.runtimeType}.',
        );
      }
      final hex = value.replaceFirst('#', '');
      if (hex.length != 6) {
        throw FormatException('Expected #RRGGBB for "$key".');
      }
      return Color(0xFF000000 | int.parse(hex, radix: 16));
    }

    return EdsSemanticColorOverrides(
      surfacePage: read('surfacePage'),
      surfaceBase: read('surfaceBase'),
      surfaceRaised: read('surfaceRaised'),
      surfaceSunken: read('surfaceSunken'),
      surfaceOverlay: read('surfaceOverlay'),
      surfaceDisabled: read('surfaceDisabled'),
      foregroundPrimary: read('foregroundPrimary'),
      foregroundSecondary: read('foregroundSecondary'),
      foregroundTertiary: read('foregroundTertiary'),
      foregroundDisabled: read('foregroundDisabled'),
      foregroundInverse: read('foregroundInverse'),
      borderSubtle: read('borderSubtle'),
      borderDefault: read('borderDefault'),
      borderStrong: read('borderStrong'),
      borderSelected: read('borderSelected'),
      borderFocus: read('borderFocus'),
      borderDisabled: read('borderDisabled'),
      borderDanger: read('borderDanger'),
      brandForeground: read('brandForeground'),
      brandSurface: read('brandSurface'),
      brandSurfaceStrong: read('brandSurfaceStrong'),
      brandBorder: read('brandBorder'),
      brandOnStrong: read('brandOnStrong'),
      informationForeground: read('informationForeground'),
      informationSurface: read('informationSurface'),
      informationSurfaceStrong: read('informationSurfaceStrong'),
      informationBorder: read('informationBorder'),
      informationOnStrong: read('informationOnStrong'),
      successForeground: read('successForeground'),
      successSurface: read('successSurface'),
      successSurfaceStrong: read('successSurfaceStrong'),
      successBorder: read('successBorder'),
      successOnStrong: read('successOnStrong'),
      warningForeground: read('warningForeground'),
      warningSurface: read('warningSurface'),
      warningSurfaceStrong: read('warningSurfaceStrong'),
      warningBorder: read('warningBorder'),
      warningOnStrong: read('warningOnStrong'),
      dangerForeground: read('dangerForeground'),
      dangerSurface: read('dangerSurface'),
      dangerSurfaceStrong: read('dangerSurfaceStrong'),
      dangerBorder: read('dangerBorder'),
      dangerOnStrong: read('dangerOnStrong'),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EdsSemanticColorOverrides &&
        other.toJson().toString() == toJson().toString();
  }

  @override
  int get hashCode => Object.hashAll(
        toJson().entries.map((entry) => Object.hash(entry.key, entry.value)),
      );

  Map<String, Object?> toJson() {
    String hex(Color color) =>
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

    return <String, Object?>{
      if (surfacePage != null) 'surfacePage': hex(surfacePage!),
      if (surfaceBase != null) 'surfaceBase': hex(surfaceBase!),
      if (surfaceRaised != null) 'surfaceRaised': hex(surfaceRaised!),
      if (surfaceSunken != null) 'surfaceSunken': hex(surfaceSunken!),
      if (surfaceOverlay != null) 'surfaceOverlay': hex(surfaceOverlay!),
      if (surfaceDisabled != null) 'surfaceDisabled': hex(surfaceDisabled!),
      if (foregroundPrimary != null)
        'foregroundPrimary': hex(foregroundPrimary!),
      if (foregroundSecondary != null)
        'foregroundSecondary': hex(foregroundSecondary!),
      if (foregroundTertiary != null)
        'foregroundTertiary': hex(foregroundTertiary!),
      if (foregroundDisabled != null)
        'foregroundDisabled': hex(foregroundDisabled!),
      if (foregroundInverse != null)
        'foregroundInverse': hex(foregroundInverse!),
      if (borderSubtle != null) 'borderSubtle': hex(borderSubtle!),
      if (borderDefault != null) 'borderDefault': hex(borderDefault!),
      if (borderStrong != null) 'borderStrong': hex(borderStrong!),
      if (borderSelected != null) 'borderSelected': hex(borderSelected!),
      if (borderFocus != null) 'borderFocus': hex(borderFocus!),
      if (borderDisabled != null) 'borderDisabled': hex(borderDisabled!),
      if (borderDanger != null) 'borderDanger': hex(borderDanger!),
      if (brandForeground != null) 'brandForeground': hex(brandForeground!),
      if (brandSurface != null) 'brandSurface': hex(brandSurface!),
      if (brandSurfaceStrong != null)
        'brandSurfaceStrong': hex(brandSurfaceStrong!),
      if (brandBorder != null) 'brandBorder': hex(brandBorder!),
      if (brandOnStrong != null) 'brandOnStrong': hex(brandOnStrong!),
      if (informationForeground != null)
        'informationForeground': hex(informationForeground!),
      if (informationSurface != null)
        'informationSurface': hex(informationSurface!),
      if (informationSurfaceStrong != null)
        'informationSurfaceStrong': hex(informationSurfaceStrong!),
      if (informationBorder != null)
        'informationBorder': hex(informationBorder!),
      if (informationOnStrong != null)
        'informationOnStrong': hex(informationOnStrong!),
      if (successForeground != null)
        'successForeground': hex(successForeground!),
      if (successSurface != null) 'successSurface': hex(successSurface!),
      if (successSurfaceStrong != null)
        'successSurfaceStrong': hex(successSurfaceStrong!),
      if (successBorder != null) 'successBorder': hex(successBorder!),
      if (successOnStrong != null) 'successOnStrong': hex(successOnStrong!),
      if (warningForeground != null)
        'warningForeground': hex(warningForeground!),
      if (warningSurface != null) 'warningSurface': hex(warningSurface!),
      if (warningSurfaceStrong != null)
        'warningSurfaceStrong': hex(warningSurfaceStrong!),
      if (warningBorder != null) 'warningBorder': hex(warningBorder!),
      if (warningOnStrong != null) 'warningOnStrong': hex(warningOnStrong!),
      if (dangerForeground != null)
        'dangerForeground': hex(dangerForeground!),
      if (dangerSurface != null) 'dangerSurface': hex(dangerSurface!),
      if (dangerSurfaceStrong != null)
        'dangerSurfaceStrong': hex(dangerSurfaceStrong!),
      if (dangerBorder != null) 'dangerBorder': hex(dangerBorder!),
      if (dangerOnStrong != null) 'dangerOnStrong': hex(dangerOnStrong!),
    };
  }
}

/// Brightness-specific semantic patches.
class EdsSemanticOverrides {
  const EdsSemanticOverrides({
    this.light,
    this.dark,
  });

  final EdsSemanticColorOverrides? light;
  final EdsSemanticColorOverrides? dark;

  EdsSemanticOverrides merge(EdsSemanticOverrides patch) {
    EdsSemanticColorOverrides? mergeSide(
      EdsSemanticColorOverrides? base,
      EdsSemanticColorOverrides? next,
    ) {
      if (next == null) return base;
      return (base ?? const EdsSemanticColorOverrides()).merge(next);
    }

    return EdsSemanticOverrides(
      light: mergeSide(light, patch.light),
      dark: mergeSide(dark, patch.dark),
    );
  }

  factory EdsSemanticOverrides.fromJson(Map<String, Object?>? json) {
    if (json == null) return const EdsSemanticOverrides();

    Map<String, Object?>? group(String key) {
      final value = json[key];
      if (value == null) return null;
      if (value is Map<String, Object?>) return value;
      throw FormatException(
        'Expected an object for "$key" but found ${value.runtimeType}.',
      );
    }

    return EdsSemanticOverrides(
      light: EdsSemanticColorOverrides.fromJson(group('light')),
      dark: EdsSemanticColorOverrides.fromJson(group('dark')),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        if (light != null && !light!.isEmpty) 'light': light!.toJson(),
        if (dark != null && !dark!.isEmpty) 'dark': dark!.toJson(),
      };
  @override
  bool operator ==(Object other) =>
      other is EdsSemanticOverrides &&
      other.light == light &&
      other.dark == dark;

  @override
  int get hashCode => Object.hash(light, dark);

}
