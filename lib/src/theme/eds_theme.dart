import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../tokens/eds_design_tokens.dart';
import 'eds_preset_theme.dart';
import 'eds_theme_json.dart';

/// Theme loading/configuration failure, mirroring Swift's `EDSThemeError`.
class EdsThemeException implements Exception {
  const EdsThemeException(this.message, {this.cause});

  /// Human-readable description, e.g. `JSON 解码失败`.
  final String message;

  /// The underlying error, if any.
  final Object? cause;

  @override
  String toString() => cause == null ? message : '$message: $cause';
}

/// The unified design-system configuration entry point, mirroring Swift's
/// `EDSTheme.shared` singleton.
///
/// ```dart
/// // Configure at app startup.
/// EdsTheme.instance.configure((tokens) {
///   return tokens.copyWith(
///     colors: tokens.colors.copyWith(primary: const Color(0xFFFF6B00)),
///   );
/// });
/// ```
///
/// Dart tokens are immutable, so the Swift `inout` closure becomes a
/// copyWith-style transform: return the updated tokens from [configure]'s
/// closure.
///
/// Changing the global tokens notifies [tokensListenable], so subtrees built
/// with `EdsThemeScope` (without explicit tokens) rebuild automatically.
class EdsTheme {
  EdsTheme._();

  /// The global singleton. Configure it once at app startup.
  static final EdsTheme instance = EdsTheme._();

  final ValueNotifier<EdsDesignTokens> _tokensNotifier =
      ValueNotifier<EdsDesignTokens>(const EdsDesignTokens());

  /// The design tokens currently in effect.
  EdsDesignTokens get tokens => _tokensNotifier.value;
  set tokens(EdsDesignTokens value) => _tokensNotifier.value = value;

  /// Listenable for the current global tokens. Subscribing to this is the
  /// Dart equivalent of observing `EDSTheme.shared.tokens`.
  ValueListenable<EdsDesignTokens> get tokensListenable => _tokensNotifier;

  /// Configures tokens through a copyWith-style closure.
  ///
  /// ```dart
  /// EdsTheme.instance.configure((tokens) {
  ///   return tokens.copyWith(
  ///     spacing: tokens.spacing.copyWith(lg: 24),
  ///   );
  /// });
  /// ```
  void configure(EdsDesignTokens Function(EdsDesignTokens tokens) block) {
    tokens = block(tokens);
  }

  /// Configures tokens from a JSON string, mirroring Swift's
  /// `configure(jsonData:)`.
  ///
  /// Throws [EdsThemeException] when the document is not valid theme JSON.
  void configureJsonString(String json) {
    try {
      tokens = decodeThemeJson(json);
    } on FormatException catch (error) {
      throw EdsThemeException('JSON 解码失败', cause: error);
    }
  }

  /// Configures tokens from an asset bundle JSON document, the Flutter
  /// equivalent of Swift's `configure(jsonResource:)` (Dart has no overloads,
  /// so the asset variant gets its own name; the path is the full asset path
  /// declared in the app's `pubspec.yaml`, e.g. `assets/theme.json`).
  ///
  /// Throws [EdsThemeException] when the asset is missing or invalid.
  Future<void> configureJsonAsset(String assetPath) async {
    final String json;
    try {
      json = await rootBundle.loadString(assetPath);
    } on FlutterError catch (error) {
      throw EdsThemeException('文件未找到: $assetPath', cause: error);
    }
    configureJsonString(json);
  }

  /// Loads the default theme JSON bundled with this package.
  ///
  /// This is the Dart counterpart of Swift's
  /// `applyDefaultThemeFromPackage()` — asynchronous because Flutter asset
  /// loading is asynchronous.
  ///
  /// Throws [EdsThemeException] when the bundled resource cannot be loaded or
  /// decoded.
  Future<void> applyDefaultThemeFromPackage() async {
    // Package assets declared under `lib/` are keyed differently per
    // environment: apps importing this package load them as
    // `packages/easy_design_system/assets/...` (the `lib/` prefix is
    // stripped), while this package's own `flutter test` bundle exposes
    // both the `lib/`-prefixed variants. Try the app layout first, then the
    // test layouts.
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
        // Try the next candidate path (app vs. test asset key layouts).
      }
    }
    if (json == null) {
      throw const EdsThemeException(
        "文件未找到: 'EDSDefaultTheme.json' in package bundle",
      );
    }
    configureJsonString(json);
  }

  /// Applies a preset theme, mirroring Swift's `applyPreset(_:)`.
  void applyPreset(EdsPresetTheme preset) {
    tokens = preset.tokens;
  }

  // Convenience accessors, mirroring the Swift aliases.

  /// Color tokens.
  EdsColorTokens get colors => tokens.colors;

  /// Spacing tokens.
  EdsSpacingTokens get spacing => tokens.spacing;

  /// Corner radius tokens.
  EdsRadiusTokens get radius => tokens.radius;

  /// Typography tokens.
  EdsTypographyTokens get typography => tokens.typography;

  /// Control size tokens.
  EdsControlSizeTokens get controlSize => tokens.controlSize;

  /// Adaptive layout tokens.
  EdsAdaptiveLayoutTokens get adaptiveLayout => tokens.adaptiveLayout;

  /// Hero gradient tokens.
  EdsHeroGradient get heroGradient => tokens.heroGradient;

  /// Stroke tokens.
  EdsStrokeTokens get stroke => tokens.stroke;

  /// Shadow tokens.
  EdsShadowTokens get shadow => tokens.shadow;

  /// Exports the current tokens as a formatted JSON string, mirroring Swift's
  /// `exportJSONString()`.
  String exportJsonString() => encodeThemeJson(tokens);
}
