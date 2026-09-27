import 'dart:io';

import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

EdsThemeData decodeFixture(String name) {
  final file = File('test/fixtures/$name.json');
  return decodeThemeJson(file.readAsStringSync());
}

void main() {
  test('partial JSON falls back to token and seed defaults', () {
    final theme = decodeThemeJson('''
    {
      "colors": { "seeds": { "brand": "#FF6B00" } },
      "shadow": { "opacity": 0.08 }
    }
    ''');

    expect(EdsColorHex.toHex(theme.seeds.brand), '#FF6B00');
    expect(theme.tokens.spacing.md, 16);
    expect(theme.tokens.shadow.opacity, 0.08);
    expect(theme.tokens.adaptiveLayout.minimumTouchTarget, 44);
  });

  test('theme seeds round-trip without silent fallback', () {
    const theme = EdsThemeData(
      seeds: EdsColorSeeds(
        brand: Color(0xFF123456),
        information: Color(0xFF345678),
        success: Color(0xFF238636),
        warning: Color(0xFFD29922),
        danger: Color(0xFFCF222E),
      ),
    );

    final decoded = decodeThemeJson(encodeThemeJson(theme));

    expect(decoded.seeds, theme.seeds);
  });

  test('semantic backgrounds resolve in both brightnesses', () {
    final light = EdsColorScheme.resolve(
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
    );
    final dark = EdsColorScheme.resolve(
      seeds: const EdsColorSeeds(),
      brightness: Brightness.dark,
    );

    expect(EdsColorHex.toHex(light.surfacePage), isNot('#000000'));
    expect(EdsColorHex.toHex(light.surfaceRaised), isNot('#000000'));
    expect(EdsColorHex.toHex(dark.surfacePage), isNot('#000000'));
    expect(EdsColorHex.toHex(dark.surfaceRaised), isNot('#000000'));
  });

  test('legacy theme fixtures are rejected after ColorScheme 2.0', () {
    expect(() => decodeFixture('LegacyTheme'), throwsFormatException);
    expect(() => decodeFixture('PartialLegacyTheme'), throwsFormatException);
  });

  test('new multiplatform theme JSON preserves non-color tokens', () {
    final theme = decodeThemeJson('''
    {
      "colors": { "seeds": { "brand": "#2196F3" } },
      "adaptiveLayout": {
        "compactPagePadding": 18,
        "regularPagePadding": 30,
        "readableContentMaxWidth": 920,
        "minimumTouchTarget": 46,
        "minimumHybridTarget": 42
      }
    }
    ''');

    final decoded = decodeThemeJson(encodeThemeJson(theme));
    expect(EdsColorHex.toHex(decoded.seeds.brand), '#2196F3');
    expect(decoded.tokens.adaptiveLayout.compactPagePadding, 18);
    expect(decoded.tokens.adaptiveLayout.regularPagePadding, 30);
    expect(decoded.tokens.adaptiveLayout.readableContentMaxWidth, 920);
    expect(decoded.tokens.adaptiveLayout.minimumTouchTarget, 46);
    expect(decoded.tokens.adaptiveLayout.minimumHybridTarget, 42);
  });

  test('malformed values throw instead of silently falling back', () {
    expect(
      () => decodeThemeJson('{"colors":{"seeds":{"brand":42}}}'),
      throwsFormatException,
    );
    expect(() => decodeThemeJson('[1, 2, 3]'), throwsFormatException);
  });

  test('typography font families round-trip and resolve into text styles', () {
    const typography = EdsTypographyTokens(
      fontFamily: 'Microsoft YaHei UI',
      fontFamilyFallback: ['Segoe UI', 'sans-serif'],
      monoFontFamily: 'Cascadia Mono',
      monoFontFamilyFallback: ['Consolas'],
    );
    final theme = const EdsThemeData().copyWith(
      tokens: const EdsDesignTokens().copyWith(typography: typography),
    );
    final decoded = decodeThemeJson(encodeThemeJson(theme));

    expect(decoded.tokens.typography.fontFamily, 'Microsoft YaHei UI');
    expect(
      decoded.tokens.typography.fontFamilyFallback,
      ['Segoe UI', 'sans-serif'],
    );
    expect(decoded.tokens.typography.monoFontFamily, 'Cascadia Mono');
    expect(decoded.tokens.typography.monoFontFamilyFallback, ['Consolas']);

    final body = decoded.tokens.typography.edsTextStyle(EdsFontRole.body);
    final mono =
        decoded.tokens.typography.edsTextStyle(EdsFontRole.monoCaption);
    expect(body.fontFamily, 'Microsoft YaHei UI');
    expect(body.fontFamilyFallback, ['Segoe UI', 'sans-serif']);
    expect(mono.fontFamily, 'Cascadia Mono');
    expect(mono.fontFamilyFallback, ['Consolas']);
  });
}
