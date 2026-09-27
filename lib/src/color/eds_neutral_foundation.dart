import 'package:flutter/painting.dart';

/// Fixed EDS neutral foundation.
///
/// These values are intentionally independent from host chromatic seeds.
/// Semantic overrides may still replace the final resolved roles.
abstract final class EdsNeutralFoundation {
  static const Color lightSurfacePage = Color(0xFFF7F7F7);
  static const Color lightSurfaceBase = Color(0xFFFFFFFF);
  static const Color lightSurfaceRaised = Color(0xFFFFFFFF);
  static const Color lightSurfaceSunken = Color(0xFFF1F1F2);
  static const Color lightSurfaceOverlay = Color(0xFFFFFFFF);
  static const Color lightSurfaceDisabled = Color(0xFFF0F0F1);

  static const Color lightForegroundPrimary = Color(0xFF111113);
  static const Color lightForegroundSecondary = Color(0xFF626267);
  static const Color lightForegroundTertiary = Color(0xFF8A8A90);
  static const Color lightForegroundDisabled = Color(0xFFB3B3B8);
  static const Color lightForegroundInverse = Color(0xFFFFFFFF);

  static const Color lightBorderSubtle = Color(0xFFE7E7E9);
  static const Color lightBorderDefault = Color(0xFFD7D7DA);
  static const Color lightBorderStrong = Color(0xFFB8B8BE);
  static const Color lightBorderDisabled = Color(0xFFE4E4E6);

  static const Color darkSurfacePage = Color(0xFF1E1E20);
  static const Color darkSurfaceBase = Color(0xFF242426);
  static const Color darkSurfaceRaised = Color(0xFF2A2A2C);
  static const Color darkSurfaceSunken = Color(0xFF18181A);
  static const Color darkSurfaceOverlay = Color(0xFF303034);
  static const Color darkSurfaceDisabled = Color(0xFF27272A);

  static const Color darkForegroundPrimary = Color(0xFFF5F5F6);
  static const Color darkForegroundSecondary = Color(0xFFB6B6BC);
  static const Color darkForegroundTertiary = Color(0xFF8D8D95);
  static const Color darkForegroundDisabled = Color(0xFF66666D);
  static const Color darkForegroundInverse = Color(0xFF111113);

  static const Color darkBorderSubtle = Color(0xFF333337);
  static const Color darkBorderDefault = Color(0xFF44444A);
  static const Color darkBorderStrong = Color(0xFF64646C);
  static const Color darkBorderDisabled = Color(0xFF343438);
}
