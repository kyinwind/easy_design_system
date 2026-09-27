import 'package:flutter/painting.dart';

import '../tokens/eds_color_hex.dart';

/// Complete chromatic seed set used to generate EDS semantic color families.
///
/// Neutral colors are intentionally not configurable here. The neutral
/// foundation is owned by EDS and is resolved separately by ColorScheme 2.0.
class EdsColorSeeds {
  const EdsColorSeeds({
    this.brand = const Color(0xFF3185FF),
    this.information = const Color(0xFF3185FF),
    this.success = const Color(0xFF27B15A),
    this.warning = const Color(0xFFF9B135),
    this.danger = const Color(0xFFE54444),
  });

  final Color brand;
  final Color information;
  final Color success;
  final Color warning;
  final Color danger;

  EdsColorSeeds copyWith({
    Color? brand,
    Color? information,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return EdsColorSeeds(
      brand: brand ?? this.brand,
      information: information ?? this.information,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  EdsColorSeeds apply(EdsColorSeedOverrides overrides) {
    return copyWith(
      brand: overrides.brand,
      information: overrides.information,
      success: overrides.success,
      warning: overrides.warning,
      danger: overrides.danger,
    );
  }

  factory EdsColorSeeds.fromJson(Map<String, Object?>? json) {
    if (json == null) return const EdsColorSeeds();
    const defaults = EdsColorSeeds();
    return EdsColorSeeds(
      brand: _readColor(json, 'brand', defaults.brand),
      information: _readColor(json, 'information', defaults.information),
      success: _readColor(json, 'success', defaults.success),
      warning: _readColor(json, 'warning', defaults.warning),
      danger: _readColor(json, 'danger', defaults.danger),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'brand': EdsColorHex.toHex(brand),
        'information': EdsColorHex.toHex(information),
        'success': EdsColorHex.toHex(success),
        'warning': EdsColorHex.toHex(warning),
        'danger': EdsColorHex.toHex(danger),
      };

  @override
  bool operator ==(Object other) {
    return other is EdsColorSeeds &&
        other.brand == brand &&
        other.information == information &&
        other.success == success &&
        other.warning == warning &&
        other.danger == danger;
  }

  @override
  int get hashCode => Object.hash(brand, information, success, warning, danger);
}

/// Partial host overrides applied on top of a preset's complete seed set.
class EdsColorSeedOverrides {
  const EdsColorSeedOverrides({
    this.brand,
    this.information,
    this.success,
    this.warning,
    this.danger,
  });

  final Color? brand;
  final Color? information;
  final Color? success;
  final Color? warning;
  final Color? danger;

  bool get isEmpty =>
      brand == null &&
      information == null &&
      success == null &&
      warning == null &&
      danger == null;

  factory EdsColorSeedOverrides.fromJson(Map<String, Object?>? json) {
    if (json == null) return const EdsColorSeedOverrides();
    return EdsColorSeedOverrides(
      brand: _readNullableColor(json, 'brand'),
      information: _readNullableColor(json, 'information'),
      success: _readNullableColor(json, 'success'),
      warning: _readNullableColor(json, 'warning'),
      danger: _readNullableColor(json, 'danger'),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        if (brand != null) 'brand': EdsColorHex.toHex(brand!),
        if (information != null) 'information': EdsColorHex.toHex(information!),
        if (success != null) 'success': EdsColorHex.toHex(success!),
        if (warning != null) 'warning': EdsColorHex.toHex(warning!),
        if (danger != null) 'danger': EdsColorHex.toHex(danger!),
      };

  @override
  bool operator ==(Object other) {
    return other is EdsColorSeedOverrides &&
        other.brand == brand &&
        other.information == information &&
        other.success == success &&
        other.warning == warning &&
        other.danger == danger;
  }

  @override
  int get hashCode => Object.hash(brand, information, success, warning, danger);
}

Color _readColor(
  Map<String, Object?> json,
  String key,
  Color fallback,
) {
  final value = json[key];
  if (value == null) return fallback;
  if (value is String) return EdsColorHex.parseRgb(value);
  throw FormatException(
    'Expected a hex string for "$key" but found ${value.runtimeType}.',
  );
}

Color? _readNullableColor(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) return EdsColorHex.parseRgb(value);
  throw FormatException(
    'Expected a hex string for "$key" but found ${value.runtimeType}.',
  );
}
