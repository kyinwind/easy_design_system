import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../color/eds_color_seeds.dart';
import '../tokens/eds_design_tokens.dart';
import 'eds_preset_theme.dart';
import 'eds_theme_data.dart';
import 'eds_theme_json.dart';

class EdsThemeException implements Exception {
  const EdsThemeException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => cause == null ? message : '$message: $cause';
}

/// Global EDS theme configuration.
///
/// ColorScheme 2.0 stores complete theme configuration here: chromatic seeds
/// plus non-color design tokens. Runtime semantic colors are resolved later by
/// the theme resolver/scope.
class EdsTheme {
  EdsTheme._();

  static final EdsTheme instance = EdsTheme._();

  final ValueNotifier<EdsThemeData> _themeNotifier =
      ValueNotifier<EdsThemeData>(EdsPresetTheme.defaultTheme.theme);

  EdsThemeData get themeData => _themeNotifier.value;
  set themeData(EdsThemeData value) => _themeNotifier.value = value;

  ValueListenable<EdsThemeData> get themeListenable => _themeNotifier;

  /// Configures the complete theme through an immutable transform.
  void configure(EdsThemeData Function(EdsThemeData theme) block) {
    themeData = block(themeData);
  }

  /// Convenience for replacing only selected chromatic seeds.
  void configureSeeds(EdsColorSeedOverrides overrides) {
    themeData = themeData.withSeedOverrides(overrides);
  }

  void configureJsonString(String json) {
    try {
      themeData = decodeThemeJson(json);
    } on FormatException catch (error) {
      throw EdsThemeException('JSON 解码失败', cause: error);
    }
  }

  Future<void> configureJsonAsset(String assetPath) async {
    final String json;
    try {
      json = await rootBundle.loadString(assetPath);
    } on FlutterError catch (error) {
      throw EdsThemeException('文件未找到: $assetPath', cause: error);
    }
    configureJsonString(json);
  }

  Future<void> applyDefaultThemeFromPackage() async {
    const candidates = <String>[
      'packages/easy_design_system/assets/eds_default_theme.json',
      'packages/easy_design_system/lib/assets/eds_default_theme.json',
      'lib/assets/eds_default_theme.json',
      'assets/eds_default_theme.json',
    ];
    String? json;
    for (final path in candidates) {
      try {
        json = await rootBundle.loadString(path);
        break;
      } on FlutterError {
        // Try the next app/test asset layout.
      }
    }
    if (json == null) {
      throw const EdsThemeException(
        "文件未找到: 'EDSDefaultTheme.json' in package bundle",
      );
    }
    configureJsonString(json);
  }

  void applyPreset(EdsPresetTheme preset) {
    themeData = preset.theme;
  }

  EdsColorSeeds get seeds => themeData.seeds;
  EdsDesignTokens get tokens => themeData.tokens;

  EdsSpacingTokens get spacing => tokens.spacing;
  EdsRadiusTokens get radius => tokens.radius;
  EdsTypographyTokens get typography => tokens.typography;
  EdsControlSizeTokens get controlSize => tokens.controlSize;
  EdsAdaptiveLayoutTokens get adaptiveLayout => tokens.adaptiveLayout;
  EdsHeroGradient get heroGradient => tokens.heroGradient;
  EdsStrokeTokens get stroke => tokens.stroke;
  EdsShadowTokens get shadow => tokens.shadow;

  String exportJsonString() => encodeThemeJson(themeData);
}
