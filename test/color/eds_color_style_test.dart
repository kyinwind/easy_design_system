import 'dart:io';

import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('three bundled color style JSON files match public built-ins', () {
    const files = <String, EdsColorStyle>{
      'lib/assets/eds_default_color_style.json': EdsColorStyle.defaultStyle,
      'lib/assets/eds_vivid_color_style.json': EdsColorStyle.vivid,
      'lib/assets/eds_elegant_color_style.json': EdsColorStyle.elegant,
    };
    for (final entry in files.entries) {
      final loaded = EdsColorStyle.fromJsonString(
        File(entry.key).readAsStringSync(),
      );
      expect(loaded, entry.value, reason: entry.key);
    }
    expect(
      EdsColorStyle.allBuiltIn.map((style) => style.id).toSet(),
      hasLength(EdsColorStyle.allBuiltIn.length),
    );
  });

  test('same orange seed produces distinct strong surfaces by style', () {
    const seeds = EdsColorSeeds(brand: Color(0xFFFF6B00));
    final colors = <Color>{
      for (final style in EdsColorStyle.allBuiltIn)
        EdsColorScheme.resolve(
          seeds: seeds,
          brightness: Brightness.dark,
          style: style,
        ).brandSurfaceStrong,
    };
    expect(colors, hasLength(3));
  });

  test('content colors override generated values and preserve omissions', () {
    final style = EdsColorStyle(
      id: 'custom',
      name: 'Custom',
      light: const EdsToneSet(
        foreground: 35,
        surface: 95,
        strong: 49,
        border: 55,
        onStrong: 100,
      ),
      dark: const EdsToneSet(
        foreground: 85,
        surface: 20,
        strong: 70,
        border: 60,
        onStrong: 10,
      ),
      strongInteraction: EdsColorStyle.defaultStyle.strongInteraction,
      softInteraction: EdsColorStyle.defaultStyle.softInteraction,
      mediumInteraction: EdsColorStyle.defaultStyle.mediumInteraction,
      contentColors: const EdsContentColorOverrides(
        light: <EdsContentColorRole, Color>{
          EdsContentColorRole.foregroundPrimary: Color(0xFF123456),
          EdsContentColorRole.brandOnStrong: Color(0xFFFEDCBA),
        },
        dark: <EdsContentColorRole, Color>{
          EdsContentColorRole.foregroundPrimary: Color(0xFFABCDEF),
        },
      ),
    );
    final styled = EdsColorScheme.resolve(
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
      style: style,
    );
    final generated = EdsColorScheme.resolve(
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
    );
    expect(styled.foregroundPrimary, const Color(0xFF123456));
    expect(styled.brandOnStrong, const Color(0xFFFEDCBA));
    expect(styled.successOnStrong, generated.successOnStrong);
    expect(
      EdsColorScheme.resolve(
        seeds: const EdsColorSeeds(),
        brightness: Brightness.dark,
        style: style,
      ).foregroundPrimary,
      const Color(0xFFABCDEF),
    );
  });

  test('theme JSON defaults missing style and rejects unknown style', () {
    expect(
      decodeThemeJson('{"colors":{"seeds":{"brand":"#3185FF"}}}').colorStyle,
      EdsColorStyle.defaultStyle,
    );
    expect(
      () => decodeThemeJson(
        '{"colors":{"style":"missing","seeds":{"brand":"#3185FF"}}}',
      ),
      throwsFormatException,
    );
  });

  test('theme semantic override has priority over style content color', () {
    final style = EdsColorStyle(
      id: 'custom',
      name: 'Custom',
      light: EdsColorStyle.defaultStyle.light,
      dark: EdsColorStyle.defaultStyle.dark,
      strongInteraction: EdsColorStyle.defaultStyle.strongInteraction,
      softInteraction: EdsColorStyle.defaultStyle.softInteraction,
      mediumInteraction: EdsColorStyle.defaultStyle.mediumInteraction,
      contentColors: const EdsContentColorOverrides(
        light: <EdsContentColorRole, Color>{
          EdsContentColorRole.foregroundPrimary: Color(0xFF123456),
        },
      ),
    );
    final colors = EdsColorScheme.resolve(
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
      style: style,
      overrides: const EdsSemanticOverrides(
        light: EdsSemanticColorOverrides(
          foregroundPrimary: Color(0xFF654321),
        ),
      ),
    );
    expect(colors.foregroundPrimary, const Color(0xFF654321));
  });

  test('style parser rejects bad tone and unsupported content role', () {
    final valid = EdsColorStyle.defaultStyle.toJson();
    final badTone = Map<String, Object?>.from(valid)
      ..['light'] = <String, Object?>{
        ...EdsColorStyle.defaultStyle.light.toJson(),
        'strong': 101,
      };
    expect(() => EdsColorStyle.fromJson(badTone), throwsFormatException);

    final badRole = Map<String, Object?>.from(valid)
      ..['contentColors'] = <String, Object?>{
        'light': <String, Object?>{'surfacePage': '#FFFFFF'},
      };
    expect(() => EdsColorStyle.fromJson(badRole), throwsFormatException);

    final badColor = Map<String, Object?>.from(valid)
      ..['contentColors'] = <String, Object?>{
        'light': <String, Object?>{'foregroundPrimary': 'red'},
      };
    expect(() => EdsColorStyle.fromJson(badColor), throwsFormatException);
  });

  for (final style in EdsColorStyle.allBuiltIn) {
    for (final brightness in Brightness.values) {
      test('${style.id} core text contrast meets WCAG AA in $brightness', () {
        final scheme = EdsColorScheme.resolve(
          seeds: const EdsColorSeeds(),
          brightness: brightness,
          style: style,
        );
        expect(
          _contrast(scheme.foregroundPrimary, scheme.surfacePage),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(scheme.brandOnStrong, scheme.brandSurfaceStrong),
          greaterThanOrEqualTo(4.5),
        );
      });
    }
  }
}

double _contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  return (a > b ? a + 0.05 : b + 0.05) / (a > b ? b + 0.05 : a + 0.05);
}
