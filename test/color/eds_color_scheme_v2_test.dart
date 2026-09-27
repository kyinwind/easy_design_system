import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorScheme 2.0', () {
    test('default seeds produce chromatic semantic families', () {
      final light = EdsColorScheme.resolve(
        seeds: const EdsColorSeeds(),
        brightness: Brightness.light,
      );
      final dark = EdsColorScheme.resolve(
        seeds: const EdsColorSeeds(),
        brightness: Brightness.dark,
      );

      expect(light.brandSurfaceStrong, isNot(light.brandSurface));
      expect(light.brandOnStrong, isNot(light.brandSurfaceStrong));
      expect(dark.brandSurfaceStrong, isNot(light.brandSurfaceStrong));
      expect(light.surfacePage, const Color(0xFFF7F7F7));
      expect(dark.surfacePage, const Color(0xFF1E1E20));
    });

    test('brand seed changes brand roles but not neutral foundation', () {
      final blue = EdsColorScheme.resolve(
        seeds: const EdsColorSeeds(),
        brightness: Brightness.light,
      );
      final purple = EdsColorScheme.resolve(
        seeds: const EdsColorSeeds(
          brand: Color(0xFF8B5CF6),
        ),
        brightness: Brightness.light,
      );

      expect(purple.brandSurfaceStrong, isNot(blue.brandSurfaceStrong));
      expect(purple.surfacePage, blue.surfacePage);
      expect(purple.foregroundPrimary, blue.foregroundPrimary);
      expect(purple.successSurfaceStrong, blue.successSurfaceStrong);
    });

    test('semantic override replaces only the selected brightness role', () {
      const overrideColor = Color(0xFF123456);
      const overrides = EdsSemanticOverrides(
        light: EdsSemanticColorOverrides(
          surfaceRaised: overrideColor,
        ),
      );

      final light = EdsColorScheme.resolve(
        seeds: const EdsColorSeeds(),
        brightness: Brightness.light,
        overrides: overrides,
      );
      final dark = EdsColorScheme.resolve(
        seeds: const EdsColorSeeds(),
        brightness: Brightness.dark,
        overrides: overrides,
      );

      expect(light.surfaceRaised, overrideColor);
      expect(dark.surfaceRaised, isNot(overrideColor));
    });
  });
}
