import 'package:flutter/painting.dart';

import '../tokens/eds_color_scheme.dart';
import 'eds_layer.dart';

/// Maps structural layer context onto semantic surface roles.
abstract final class EdsLayerResolver {
  static Color surface(EdsColorScheme scheme, EdsLayer layer) {
    return switch (layer) {
      EdsLayer.base => scheme.surfacePage,
      EdsLayer.raised => scheme.surfaceRaised,
      EdsLayer.nested => scheme.surfaceSunken,
      EdsLayer.overlay => scheme.surfaceOverlay,
    };
  }

  /// Field-like controls need contrast against their parent surface.
  static Color fieldSurface(EdsColorScheme scheme, EdsLayer layer) {
    return switch (layer) {
      EdsLayer.base => scheme.surfaceBase,
      EdsLayer.raised => scheme.surfaceSunken,
      EdsLayer.nested => scheme.surfaceBase,
      EdsLayer.overlay => scheme.surfaceBase,
    };
  }

  static Color border(EdsColorScheme scheme, EdsLayer layer) {
    return switch (layer) {
      EdsLayer.base => scheme.borderSubtle,
      EdsLayer.raised => scheme.borderDefault,
      EdsLayer.nested => scheme.borderDefault,
      EdsLayer.overlay => scheme.borderStrong,
    };
  }
}
