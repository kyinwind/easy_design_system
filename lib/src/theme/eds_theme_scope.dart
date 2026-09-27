import 'package:flutter/material.dart';

import '../color/eds_color_seeds.dart';
import '../tokens/eds_design_tokens.dart';
import 'eds_preset_theme.dart';
import 'eds_theme.dart';
import 'eds_theme_data.dart';

class _EdsThemeConfigScope extends InheritedWidget {
  const _EdsThemeConfigScope({
    required this.themeData,
    required this.brightness,
    required super.child,
  });

  final EdsThemeData themeData;
  final Brightness? brightness;

  @override
  bool updateShouldNotify(_EdsThemeConfigScope oldWidget) =>
      themeData != oldWidget.themeData || brightness != oldWidget.brightness;
}

/// Injects EDS theme configuration into a subtree.
///
/// Resolution order:
/// explicit [theme] > [preset] > inherited/global theme, then optional
/// [seeds] and [tokens] overrides are applied.
class EdsThemeScope extends StatelessWidget {
  const EdsThemeScope({
    super.key,
    this.theme,
    this.preset,
    this.seeds,
    this.tokens,
    this.brightness,
    required this.child,
  }) : assert(
          theme == null || preset == null,
          'Provide either theme or preset, not both.',
        );

  /// Full explicit theme configuration.
  final EdsThemeData? theme;

  /// Preset used as the subtree base theme.
  final EdsPresetTheme? preset;

  /// Partial chromatic seed overrides applied on top of the base theme.
  final EdsColorSeedOverrides? seeds;

  /// Optional non-color token replacement for this subtree.
  final EdsDesignTokens? tokens;

  /// Explicit brightness override.
  final Brightness? brightness;

  final Widget child;

  EdsThemeData _applyOverrides(EdsThemeData base) {
    var value = base;
    final seedOverrides = seeds;
    if (seedOverrides != null) {
      value = value.withSeedOverrides(seedOverrides);
    }
    final tokenOverrides = tokens;
    if (tokenOverrides != null) {
      value = value.copyWith(tokens: tokenOverrides);
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final explicitBase = theme ?? preset?.theme;
    if (explicitBase != null) {
      return _EdsThemeConfigScope(
        themeData: _applyOverrides(explicitBase),
        brightness: brightness,
        child: child,
      );
    }

    final inherited =
        context.dependOnInheritedWidgetOfExactType<_EdsThemeConfigScope>();
    if (inherited != null) {
      return _EdsThemeConfigScope(
        themeData: _applyOverrides(inherited.themeData),
        brightness: brightness ?? inherited.brightness,
        child: child,
      );
    }

    return ValueListenableBuilder<EdsThemeData>(
      valueListenable: EdsTheme.instance.themeListenable,
      builder: (context, value, _) => _EdsThemeConfigScope(
        themeData: _applyOverrides(value),
        brightness: brightness,
        child: child,
      ),
    );
  }
}

extension EdsThemeContextX on BuildContext {
  EdsThemeData get edsThemeData =>
      dependOnInheritedWidgetOfExactType<_EdsThemeConfigScope>()?.themeData ??
      EdsTheme.instance.themeData;

  EdsDesignTokens get edsTokens => edsThemeData.tokens;

  EdsColorSeeds get edsSeeds => edsThemeData.seeds;

  Brightness get edsBrightness {
    final scope = dependOnInheritedWidgetOfExactType<_EdsThemeConfigScope>();
    if (scope?.brightness != null) {
      return scope!.brightness!;
    }
    return Theme.maybeBrightnessOf(this) ?? Brightness.light;
  }
}

extension EdsThemeWidgetX on Widget {
  /// Applies non-color design tokens locally while keeping inherited seeds.
  Widget easyDesignTheme(EdsDesignTokens tokens) =>
      EdsThemeScope(tokens: tokens, child: this);

  Widget easyDesignThemeData(EdsThemeData theme) =>
      EdsThemeScope(theme: theme, child: this);

  Widget easyDesignThemePreset(EdsPresetTheme preset) =>
      EdsThemeScope(preset: preset, child: this);
}
