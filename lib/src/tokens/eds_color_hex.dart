import 'package:flutter/painting.dart';

/// How the alpha channel is laid out in an eight-digit hex color string.
enum EdsColorHexFormat {
  /// `#AARRGGBB`, e.g. `#FFFF0000` is opaque red.
  argb,

  /// `#RRGGBBAA`, e.g. `#FF0000FF` is opaque red.
  rgba,
}

/// Hex-string parsing/formatting aligned with the Swift source package
/// (`Color(hexRGB:)` family).
///
/// Parsing rules (identical to Swift):
/// * Leading/trailing non-alphanumeric characters are trimmed.
/// * The value is parsed from the leading hex-digit run of the trimmed string.
/// * The length switch uses the trimmed string length:
///   * 3 → `#RGB` (each digit doubled), alpha 255.
///   * 6 → `#RRGGBB`, alpha 255.
///   * 8 → `#AARRGGBB` or `#RRGGBBAA` depending on [format]; only accepted by
///     the entry points that allow eight-digit input.
///   * anything else → opaque black `#000000`.
abstract final class EdsColorHex {
  /// Parses `#RGB` or `#RRGGBB`. Eight-digit strings fall back to black,
  /// mirroring Swift's `Color(hexRGB:)`.
  static Color parseRgb(String hex) =>
      _parse(hex, EdsColorHexFormat.argb, allowsEightDigitHex: false);

  /// Parses `#RGB`, `#RRGGBB` or `#AARRGGBB`, mirroring Swift's
  /// `Color(hexARGB:)`.
  static Color parseArgb(String hex) =>
      _parse(hex, EdsColorHexFormat.argb, allowsEightDigitHex: true);

  /// Parses `#RGB`, `#RRGGBB` or `#RRGGBBAA`, mirroring Swift's
  /// `Color(hexRGBA:)`.
  static Color parseRgba(String hex) =>
      _parse(hex, EdsColorHexFormat.rgba, allowsEightDigitHex: true);

  /// Parses a hex string with an explicit eight-digit alpha layout.
  static Color parse(
    String hex, {
    EdsColorHexFormat format = EdsColorHexFormat.argb,
  }) =>
      _parse(hex, format, allowsEightDigitHex: true);

  /// Formats a color as `#RRGGBB` (uppercase). Alpha is dropped, matching
  /// Swift's `Color.toHex()`.
  static String toHex(Color color) {
    int channel(double value) => (value * 255.0).round().clamp(0, 255);
    return '#${_hex2(channel(color.r))}'
        '${_hex2(channel(color.g))}'
        '${_hex2(channel(color.b))}';
  }

  static String _hex2(int value) =>
      value.toRadixString(16).toUpperCase().padLeft(2, '0');

  static Color _parse(
    String hex,
    EdsColorHexFormat format, {
    required bool allowsEightDigitHex,
  }) {
    // Trim characters that are not alphanumeric from both ends, mirroring
    // `CharacterSet.alphanumerics.inverted` in Swift. ASCII-only is enough for
    // well-formed hex input.
    final trimmed = hex.replaceAll(
      RegExp(r'^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$'),
      '',
    );

    // Scanner.scanHexInt64 skips an optional `0x`/`0X` prefix, then reads the
    // leading hex-digit run and yields 0 when the string does not start with a
    // hex digit. Capped at 15 digits to stay inside a signed 64-bit integer.
    var scanTarget = trimmed;
    if (scanTarget.startsWith('0x') || scanTarget.startsWith('0X')) {
      scanTarget = scanTarget.substring(2);
    }
    final match = RegExp(r'^[0-9a-fA-F]{1,15}').firstMatch(scanTarget);
    var value = 0;
    if (match != null) {
      value = int.parse(match.group(0)!, radix: 16);
    }

    final int a;
    final int r;
    final int g;
    final int b;
    // The length switch uses the trimmed string length *including* any `0x`
    // prefix, mirroring Swift's `hex.count`.
    switch (trimmed.length) {
      case 3:
        a = 255;
        r = (value >> 8) * 17;
        g = (value >> 4 & 0xF) * 17;
        b = (value & 0xF) * 17;
      case 6:
        a = 255;
        r = value >> 16;
        g = value >> 8 & 0xFF;
        b = value & 0xFF;
      case 8 when allowsEightDigitHex:
        switch (format) {
          case EdsColorHexFormat.argb:
            a = value >> 24;
            r = value >> 16 & 0xFF;
            g = value >> 8 & 0xFF;
            b = value & 0xFF;
          case EdsColorHexFormat.rgba:
            a = value & 0xFF;
            r = value >> 24;
            g = value >> 16 & 0xFF;
            b = value >> 8 & 0xFF;
        }
      default:
        a = 255;
        r = 0;
        g = 0;
        b = 0;
    }

    return Color.fromARGB(a, r, g, b);
  }
}
