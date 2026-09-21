import 'dart:io';

import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

EdsDesignTokens decodeFixture(String name) {
  final file = File('test/fixtures/$name.json');
  return decodeThemeJson(file.readAsStringSync());
}

void main() {
  test('partial JSON falls back to token defaults', () {
    final tokens = decodeThemeJson('''
    {
      "colors": { "primary": "#FF6B00" },
      "shadow": { "opacity": 0.08 }
    }
    ''');

    expect(EdsColorHex.toHex(tokens.colors.primary), '#FF6B00');
    expect(tokens.spacing.md, 16);
    expect(tokens.shadow.opacity, 0.08);
    expect(tokens.adaptiveLayout.minimumTouchTarget, 44);
  });

  test('theme colors round-trip without silent black fallback', () {
    final tokens = const EdsDesignTokens().copyWith(
      colors: const EdsColorTokens().copyWith(
        primary: EdsColorHex.parseRgb('#123456'),
        accent: EdsColorHex.parseRgb('#654321'),
        success: EdsColorHex.parseRgb('#238636'),
        warning: EdsColorHex.parseRgb('#D29922'),
        danger: EdsColorHex.parseRgb('#CF222E'),
      ),
    );

    final decoded = decodeThemeJson(encodeThemeJson(tokens));

    expect(EdsColorHex.toHex(decoded.colors.primary), '#123456');
    expect(EdsColorHex.toHex(decoded.colors.accent), '#654321');
    expect(EdsColorHex.toHex(decoded.colors.success), '#238636');
    expect(EdsColorHex.toHex(decoded.colors.warning), '#D29922');
    expect(EdsColorHex.toHex(decoded.colors.danger), '#CF222E');
  });

  test('dynamic background colors resolve without black fallback', () {
    const tokens = EdsDesignTokens();
    final light = EdsColorScheme.resolve(tokens, Brightness.light);
    final dark = EdsColorScheme.resolve(tokens, Brightness.dark);

    expect(EdsColorHex.toHex(light.pageBackground), isNot('#000000'));
    expect(EdsColorHex.toHex(light.cardBackground), isNot('#000000'));
    expect(EdsColorHex.toHex(dark.pageBackground), isNot('#000000'));
    expect(EdsColorHex.toHex(dark.cardBackground), isNot('#000000'));
  });

  test('legacy theme fixture uses adaptive defaults', () {
    final tokens = decodeFixture('LegacyTheme');

    expect(EdsColorHex.toHex(tokens.colors.primary), '#3185FF');
    expect(tokens.controlSize.buttonHeight, 34);
    expect(tokens.adaptiveLayout.compactPagePadding, 16);
    expect(tokens.adaptiveLayout.minimumTouchTarget, 44);
  });

  test('partial legacy theme fixture uses defaults', () {
    final tokens = decodeFixture('PartialLegacyTheme');

    expect(EdsColorHex.toHex(tokens.colors.primary), '#FF6B00');
    expect(tokens.spacing.md, 16);
    expect(tokens.adaptiveLayout.readableContentMaxWidth, 880);
  });

  test('multiplatform theme round-trips through JSON', () {
    final tokens = decodeFixture('MultiplatformTheme');
    final decoded = decodeThemeJson(encodeThemeJson(tokens));

    expect(EdsColorHex.toHex(decoded.colors.primary), '#2196F3');
    expect(decoded.adaptiveLayout.compactPagePadding, 18);
    expect(decoded.adaptiveLayout.regularPagePadding, 30);
    expect(decoded.adaptiveLayout.readableContentMaxWidth, 920);
    expect(decoded.adaptiveLayout.minimumTouchTarget, 46);
    expect(decoded.adaptiveLayout.minimumHybridTarget, 42);
  });

  test('malformed values throw instead of silently falling back', () {
    expect(
      () => decodeThemeJson('{"colors": {"primary": 42}}'),
      throwsFormatException,
    );
    expect(
      () => decodeThemeJson('[1, 2, 3]'),
      throwsFormatException,
    );
  });
}
