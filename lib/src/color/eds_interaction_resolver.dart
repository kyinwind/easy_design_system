import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'eds_color_seeds.dart';
import 'eds_family_tone_map.dart';
import 'eds_neutral_foundation.dart';
import 'eds_tonal_palette.dart';

enum EdsInteractionState {
  rest,
  hovered,
  pressed,
}

enum EdsInteractionColorFamily {
  brand,
  information,
  success,
  warning,
  danger,
}

/// Internal state-color resolver.
///
/// Selection remains a component semantic state; this resolver handles
/// interaction changes such as hover/press after the component has chosen its
/// semantic family.
abstract final class EdsInteractionResolver {
  static Color strongSurface({
    required EdsInteractionColorFamily family,
    required EdsColorSeeds seeds,
    required Brightness brightness,
    required EdsInteractionState state,
  }) {
    final palette = EdsTonalPalette.fromSeed(_seed(family, seeds));
    final map = _map(family);
    final dark = brightness == Brightness.dark;
    final base = dark ? map.darkStrong : map.lightStrong;
    final delta = switch (state) {
      EdsInteractionState.rest => 0,
      EdsInteractionState.hovered => dark ? 5 : -5,
      EdsInteractionState.pressed => dark ? 10 : -10,
    };
    return palette.tone((base + delta).clamp(0, 100).toInt());
  }

  static Color softSurface({
    required EdsInteractionColorFamily family,
    required EdsColorSeeds seeds,
    required Brightness brightness,
    required EdsInteractionState state,
  }) {
    final palette = EdsTonalPalette.fromSeed(_seed(family, seeds));
    final map = _map(family);
    final dark = brightness == Brightness.dark;
    final base = dark ? map.darkSurface : map.lightSurface;
    final delta = switch (state) {
      EdsInteractionState.rest => 0,
      EdsInteractionState.hovered => dark ? 4 : -3,
      EdsInteractionState.pressed => dark ? 8 : -6,
    };
    return palette.tone((base + delta).clamp(0, 100));
  }

  static Color neutralSurface({
    required Brightness brightness,
    required EdsInteractionState state,
  }) {
    final dark = brightness == Brightness.dark;
    return switch (state) {
      EdsInteractionState.rest => dark
          ? EdsNeutralFoundation.darkSurfaceBase
          : EdsNeutralFoundation.lightSurfaceBase,
      EdsInteractionState.hovered => dark
          ? EdsNeutralFoundation.darkInteractionHover
          : EdsNeutralFoundation.lightInteractionHover,
      EdsInteractionState.pressed => dark
          ? EdsNeutralFoundation.darkInteractionPressed
          : EdsNeutralFoundation.lightInteractionPressed,
    };
  }

  static Color _seed(
    EdsInteractionColorFamily family,
    EdsColorSeeds seeds,
  ) {
    return switch (family) {
      EdsInteractionColorFamily.brand => seeds.brand,
      EdsInteractionColorFamily.information => seeds.information,
      EdsInteractionColorFamily.success => seeds.success,
      EdsInteractionColorFamily.warning => seeds.warning,
      EdsInteractionColorFamily.danger => seeds.danger,
    };
  }

  static EdsFamilyToneMap _map(EdsInteractionColorFamily family) {
    return switch (family) {
      EdsInteractionColorFamily.brand => EdsFamilyToneMap.brand,
      EdsInteractionColorFamily.information => EdsFamilyToneMap.information,
      EdsInteractionColorFamily.success => EdsFamilyToneMap.success,
      EdsInteractionColorFamily.warning => EdsFamilyToneMap.warning,
      EdsInteractionColorFamily.danger => EdsFamilyToneMap.danger,
    };
  }
}
