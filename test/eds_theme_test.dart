import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Required for `rootBundle` in the asset-loading test below.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    EdsTheme.instance.tokens = const EdsDesignTokens();
  });

  test('generic presets expose the documented ids', () {
    expect(
      EdsPresetTheme.allPresets.map((preset) => preset.id).toList(),
      ['default', 'orange', 'purple'],
    );
  });

  test('blue is an alias of the default preset', () {
    expect(EdsPresetTheme.blue, same(EdsPresetTheme.defaultTheme));
  });

  test('purple preset ships its own semantic colors', () {
    expect(
      EdsColorHex.toHex(EdsPresetTheme.purple.tokens.colors.success),
      '#10B981',
    );
  });

  test('configure applies the tokens returned by the closure', () {
    EdsTheme.instance.configure((tokens) {
      return tokens.copyWith(
        colors: tokens.colors.copyWith(
          primary: EdsColorHex.parseRgb('#3185FF'),
        ),
        spacing: tokens.spacing.copyWith(md: 16),
      );
    });

    expect(
      EdsColorHex.toHex(EdsTheme.instance.colors.primary),
      '#3185FF',
    );
    expect(EdsTheme.instance.spacing.md, 16);
  });

  test('configureJsonString decodes and notifies listeners', () {
    var notified = false;
    EdsTheme.instance.tokensListenable.addListener(() => notified = true);

    EdsTheme.instance.configureJsonString('{"colors": {"primary": "#FF6B00"}}');

    expect(
      EdsColorHex.toHex(EdsTheme.instance.colors.primary),
      '#FF6B00',
    );
    expect(notified, isTrue);
  });

  test('configureJsonString wraps decode errors in EdsThemeException', () {
    expect(
      () => EdsTheme.instance.configureJsonString('not json'),
      throwsA(isA<EdsThemeException>()),
    );
  });

  test('applyPreset installs the preset tokens', () {
    EdsTheme.instance.applyPreset(EdsPresetTheme.orange);

    expect(
      EdsTheme.instance.colors.primary,
      EdsPresetTheme.orange.tokens.colors.primary,
    );
  });

  test('exportJsonString round-trips the current tokens', () {
    EdsTheme.instance.configureJsonString(
      '{"colors": {"primary": "#123456"},'
      ' "adaptiveLayout": {"readableContentMaxWidth": 920}}',
    );

    final decoded = decodeThemeJson(EdsTheme.instance.exportJsonString());

    expect(EdsColorHex.toHex(decoded.colors.primary), '#123456');
    expect(decoded.adaptiveLayout.readableContentMaxWidth, 920);
  });

  test('exportJsonString sorts keys and pretty-prints', () {
    final exported = EdsTheme.instance.exportJsonString();

    expect(exported, contains('\n  "colors"'));
    final colorsPos = exported.indexOf('"colors"');
    final spacingPos = exported.indexOf('"spacing"');
    expect(spacingPos, greaterThan(colorsPos));
  });

  test('applyDefaultThemeFromPackage loads the bundled default theme',
      () async {
    await EdsTheme.instance.applyDefaultThemeFromPackage();

    expect(
      EdsColorHex.toHex(EdsTheme.instance.colors.primary),
      '#3185FF',
    );
    expect(EdsTheme.instance.spacing.md, 16);
    expect(EdsTheme.instance.adaptiveLayout.readableContentMaxWidth, 880);
  });
}
