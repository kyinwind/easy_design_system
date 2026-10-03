import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'eds_color_seeds.dart';
import 'eds_color_style.dart';
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
    EdsColorStyle style = EdsColorStyle.defaultStyle,
  }) {
    final palette = EdsTonalPalette.fromSeed(_seed(family, seeds));
    final dark = brightness == Brightness.dark;
    final interaction = style.strongInteraction;
    final base = dark ? interaction.darkBase : interaction.lightBase;
    final delta = switch (state) {
      EdsInteractionState.rest => 0,
      EdsInteractionState.hovered =>
        dark ? interaction.darkHoveredDelta : interaction.lightHoveredDelta,
      EdsInteractionState.pressed =>
        dark ? interaction.darkPressedDelta : interaction.lightPressedDelta,
    };
    return palette.tone((base + delta).clamp(0, 100).toInt());
  }

  static Color softSurface({
    required EdsInteractionColorFamily family,
    required EdsColorSeeds seeds,
    required Brightness brightness,
    required EdsInteractionState state,
    EdsColorStyle style = EdsColorStyle.defaultStyle,
  }) {
    final palette = EdsTonalPalette.fromSeed(_seed(family, seeds));
    final dark = brightness == Brightness.dark;
    final interaction = style.softInteraction;
    final base = dark ? interaction.darkBase : interaction.lightBase;
    final delta = switch (state) {
      EdsInteractionState.rest => 0,
      EdsInteractionState.hovered =>
        dark ? interaction.darkHoveredDelta : interaction.lightHoveredDelta,
      EdsInteractionState.pressed =>
        dark ? interaction.darkPressedDelta : interaction.lightPressedDelta,
    };
    return palette.tone((base + delta).clamp(0, 100));
  }

  static Color mediumSurface({
    required EdsInteractionColorFamily family,
    required EdsColorSeeds seeds,
    required Brightness brightness,
    required EdsInteractionState state,
    EdsColorStyle style = EdsColorStyle.defaultStyle,
  }) {
    final palette = EdsTonalPalette.fromSeed(_seed(family, seeds));
    final dark = brightness == Brightness.dark;
    final interaction = style.mediumInteraction;
    final base = dark ? interaction.darkBase : interaction.lightBase;
    final delta = switch (state) {
      EdsInteractionState.rest => 0,
      EdsInteractionState.hovered =>
        dark ? interaction.darkHoveredDelta : interaction.lightHoveredDelta,
      EdsInteractionState.pressed =>
        dark ? interaction.darkPressedDelta : interaction.lightPressedDelta,
    };
    return palette.tone((base + delta).clamp(0, 100).toInt());
  }

  static Color neutralStrongSurface({
    required Brightness brightness,
    required EdsInteractionState state,
  }) {
    final dark = brightness == Brightness.dark;
    return switch (state) {
      EdsInteractionState.rest => dark
          ? EdsNeutralFoundation.darkNeutralStrongRest
          : EdsNeutralFoundation.lightNeutralStrongRest,
      EdsInteractionState.hovered => dark
          ? EdsNeutralFoundation.darkNeutralStrongHover
          : EdsNeutralFoundation.lightNeutralStrongHover,
      EdsInteractionState.pressed => dark
          ? EdsNeutralFoundation.darkNeutralStrongPressed
          : EdsNeutralFoundation.lightNeutralStrongPressed,
    };
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
}
