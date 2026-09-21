import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses RGB/ARGB/RGBA formats with explicit eight-digit semantics', () {
    expect(EdsColorHex.toHex(EdsColorHex.parseRgb('#FF0000')), '#FF0000');
    expect(EdsColorHex.toHex(EdsColorHex.parseArgb('#FF0000FF')), '#0000FF');
    expect(EdsColorHex.toHex(EdsColorHex.parseRgba('#FF0000FF')), '#FF0000');
    expect(
      EdsColorHex.toHex(
        EdsColorHex.parse('#FF0000FF', format: EdsColorHexFormat.rgba),
      ),
      '#FF0000',
    );
  });

  test('parseRgb rejects eight-digit input by falling back to black', () {
    expect(EdsColorHex.toHex(EdsColorHex.parseRgb('#FF0000FF')), '#000000');
  });

  test('doubles three-digit shorthand digits', () {
    expect(EdsColorHex.toHex(EdsColorHex.parseRgb('#F00')), '#FF0000');
    expect(EdsColorHex.toHex(EdsColorHex.parseRgb(' abc ')), '#AABBCC');
  });

  test('keeps alpha when parsing eight-digit ARGB', () {
    final halfRed = EdsColorHex.parseArgb('#80FF0000');
    expect(halfRed.a, closeTo(0x80 / 255, 1 / 255 / 2));
    expect(EdsColorHex.toHex(halfRed), '#FF0000');
  });

  test('0x prefix participates in the trimmed-length switch', () {
    // '0xFF0000' trims to eight characters → ARGB → alpha 0.
    final transparentRed = EdsColorHex.parseArgb('0xFF0000');
    expect(transparentRed.a, 0);
    expect(EdsColorHex.toHex(transparentRed), '#FF0000');
    // '00xFF0000' trims to ten characters → fallback black.
    expect(EdsColorHex.toHex(EdsColorHex.parseArgb('00xFF0000')), '#000000');
  });

  test('invalid input falls back to opaque black', () {
    final black = EdsColorHex.parseRgb('nope');
    expect(EdsColorHex.toHex(black), '#000000');
    expect(black.a, 1);
  });
}
