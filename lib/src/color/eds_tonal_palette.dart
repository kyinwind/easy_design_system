import 'package:flutter/painting.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// EDS wrapper around the underlying perceptual tonal palette engine.
///
/// Keeping the third-party type behind this wrapper prevents component/theme
/// code from depending directly on Material color APIs.
class EdsTonalPalette {
  EdsTonalPalette._(this._palette);

  final TonalPalette _palette;

  factory EdsTonalPalette.fromSeed(Color seed) {
    final hct = Hct.fromInt(seed.toARGB32());
    return EdsTonalPalette._(TonalPalette.fromHct(hct));
  }

  /// Resolves a perceptual tone in the inclusive 0..100 range.
  Color tone(int tone) {
    assert(tone >= 0 && tone <= 100);
    return Color(_palette.get(tone.clamp(0, 100).toInt()));
  }
}
