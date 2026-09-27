import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    EdsTheme.instance.themeData = EdsPresetTheme.defaultTheme.theme;
  });

  test('generic presets expose the documented ids', () {
    expect(EdsPresetTheme.allPresets.map((preset) => preset.id).toList(), [
      'default',
      'orange',
      'purple',
    ]);
  });

  test('blue is an alias of the default preset', () {
    expect(EdsPresetTheme.blue, same(EdsPresetTheme.defaultTheme));
  });

  test('purple preset changes brand but keeps default status seeds', () {
    expect(
        EdsColorHex.toHex(EdsPresetTheme.purple.theme.seeds.brand), '#8B5CF6');
    expect(
      EdsColorHex.toHex(EdsPresetTheme.purple.theme.seeds.success),
      '#27B15A',
    );
  });

  test('configure updates seeds and non-color tokens', () {
    EdsTheme.instance.configure((theme) {
      return theme.copyWith(
        seeds: theme.seeds.copyWith(
          brand: EdsColorHex.parseRgb('#3185FF'),
        ),
        tokens: theme.tokens.copyWith(
          spacing: theme.tokens.spacing.copyWith(md: 18),
        ),
      );
    });

    expect(EdsColorHex.toHex(EdsTheme.instance.seeds.brand), '#3185FF');
    expect(EdsTheme.instance.spacing.md, 18);
  });

  test('configureTheme applies preset, seed and semantic overrides', () {
    EdsTheme.instance.configureTheme(
      preset: EdsPresetTheme.orange,
      seeds: const EdsColorSeedOverrides(
        brand: Color(0xFF8B5CF6),
      ),
      semanticOverrides: const EdsSemanticOverrides(
        light: EdsSemanticColorOverrides(
          surfaceRaised: Color(0xFFFDFDFD),
        ),
      ),
    );

    expect(EdsTheme.instance.seeds.brand, const Color(0xFF8B5CF6));
    expect(
      EdsTheme.instance.themeData.semanticOverrides.light?.surfaceRaised,
      const Color(0xFFFDFDFD),
    );
    expect(
      EdsTheme.instance.heroGradient,
      EdsPresetTheme.orange.theme.tokens.heroGradient,
    );
  });

  test('configureJsonString decodes and notifies listeners', () {
    var notified = false;
    EdsTheme.instance.themeListenable.addListener(() => notified = true);

    EdsTheme.instance.configureJsonString(
      '{"colors":{"seeds":{"brand":"#FF6B00"}}}',
    );

    expect(EdsColorHex.toHex(EdsTheme.instance.seeds.brand), '#FF6B00');
    expect(notified, isTrue);
  });

  test('configureJsonString wraps decode errors in EdsThemeException', () {
    expect(
      () => EdsTheme.instance.configureJsonString('not json'),
      throwsA(isA<EdsThemeException>()),
    );
  });

  test('legacy colors JSON is rejected', () {
    expect(
      () => EdsTheme.instance.configureJsonString(
        '{"colors":{"primary":"#FF6B00"}}',
      ),
      throwsA(isA<EdsThemeException>()),
    );
  });

  test('applyPreset installs the preset theme', () {
    EdsTheme.instance.applyPreset(EdsPresetTheme.orange);

    expect(
      EdsTheme.instance.seeds.brand,
      EdsPresetTheme.orange.theme.seeds.brand,
    );
  });

  test('exportJsonString round-trips current configuration', () {
    EdsTheme.instance.configureJsonString(
      '{"colors":{"seeds":{"brand":"#123456"}},'
      '"adaptiveLayout":{"readableContentMaxWidth":920}}',
    );

    final decoded = decodeThemeJson(EdsTheme.instance.exportJsonString());

    expect(EdsColorHex.toHex(decoded.seeds.brand), '#123456');
    expect(decoded.tokens.adaptiveLayout.readableContentMaxWidth, 920);
  });

  test('exportJsonString sorts keys and pretty-prints', () {
    final exported = EdsTheme.instance.exportJsonString();

    expect(exported, contains('\n  "colors"'));
    final colorsPos = exported.indexOf('"colors"');
    final spacingPos = exported.indexOf('"spacing"');
    expect(spacingPos, greaterThan(colorsPos));
  });

  test('applyDefaultThemeFromPackage loads bundled full theme', () async {
    await EdsTheme.instance.applyDefaultThemeFromPackage();

    expect(EdsColorHex.toHex(EdsTheme.instance.seeds.brand), '#3185FF');
    expect(EdsTheme.instance.spacing.md, 16);
    expect(EdsTheme.instance.adaptiveLayout.readableContentMaxWidth, 880);
    expect(EdsTheme.instance.stroke.hairline, 1);
    expect(EdsTheme.instance.shadow.opacity, 0.06);
  });
}
