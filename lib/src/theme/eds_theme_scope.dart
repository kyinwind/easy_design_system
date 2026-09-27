import 'package:flutter/material.dart';

import '../color/eds_color_seeds.dart';
import '../color/eds_semantic_overrides.dart';
import '../tokens/eds_color_scheme.dart';
import '../tokens/eds_design_tokens.dart';
import 'eds_preset_theme.dart';
import 'eds_resolved_theme.dart';
import 'eds_theme.dart';
import 'eds_theme_data.dart';
import 'eds_theme_resolver.dart';

class _EdsThemeScopeData extends InheritedWidget {
  const _EdsThemeScopeData({
    required this.resolvedTheme,
    required this.explicitBrightness,
    required super.child,
  });

  final EdsResolvedTheme resolvedTheme;
  final Brightness? explicitBrightness;

  @override
  bool updateShouldNotify(_EdsThemeScopeData oldWidget) =>
      resolvedTheme.configuration != oldWidget.resolvedTheme.configuration ||
      resolvedTheme.brightness != oldWidget.resolvedTheme.brightness ||
      explicitBrightness != oldWidget.explicitBrightness;
}

/// Injects and resolves EDS theme configuration for a subtree.
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
    this.semanticOverrides,
    this.tokens,
    this.brightness,
    required this.child,
  }) : assert(
          theme == null || preset == null,
          'Provide either theme or preset, not both.',
        );

  final EdsThemeData? theme;
  final EdsPresetTheme? preset;
  final EdsColorSeedOverrides? seeds;
  final EdsSemanticOverrides? semanticOverrides;
  final EdsDesignTokens? tokens;
  final Brightness? brightness;
  final Widget child;

  EdsThemeData _applyOverrides(EdsThemeData base) {
    var value = base;
    final seedOverrides = seeds;
    if (seedOverrides != null) {
      value = value.withSeedOverrides(seedOverrides);
    }
    final semanticPatch = semanticOverrides;
    if (semanticPatch != null) {
      value = value.copyWith(
        semanticOverrides: value.semanticOverrides.merge(semanticPatch),
      );
    }
    final tokenOverrides = tokens;
    if (tokenOverrides != null) {
      value = value.copyWith(tokens: tokenOverrides);
    }
    return value;
  }

  Widget _buildResolved(
    BuildContext context,
    EdsThemeData configuration, {
    Brightness? inheritedExplicitBrightness,
  }) {
    final explicit = brightness ?? inheritedExplicitBrightness;
    final effectiveBrightness =
        explicit ?? Theme.maybeBrightnessOf(context) ?? Brightness.light;
    final resolved = EdsThemeResolver.resolve(
      theme: _applyOverrides(configuration),
      brightness: effectiveBrightness,
    );

    return _EdsThemeScopeData(
      resolvedTheme: resolved,
      explicitBrightness: explicit,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final explicitBase = theme ?? preset?.theme;
    if (explicitBase != null) {
      return _buildResolved(context, explicitBase);
    }

    final inherited =
        context.dependOnInheritedWidgetOfExactType<_EdsThemeScopeData>();
    if (inherited != null) {
      return _buildResolved(
        context,
        inherited.resolvedTheme.configuration,
        inheritedExplicitBrightness: inherited.explicitBrightness,
      );
    }

    return ValueListenableBuilder<EdsThemeData>(
      valueListenable: EdsTheme.instance.themeListenable,
      builder: (context, value, _) => _buildResolved(context, value),
    );
  }
}

extension EdsThemeContextX on BuildContext {
  EdsResolvedTheme get edsResolvedTheme {
    final scope = dependOnInheritedWidgetOfExactType<_EdsThemeScopeData>();
    if (scope != null) return scope.resolvedTheme;

    final effectiveBrightness =
        Theme.maybeBrightnessOf(this) ?? Brightness.light;
    return EdsThemeResolver.resolve(
      theme: EdsTheme.instance.themeData,
      brightness: effectiveBrightness,
    );
  }

  EdsThemeData get edsThemeData => edsResolvedTheme.configuration;
  EdsDesignTokens get edsTokens => edsResolvedTheme.tokens;
  EdsColorSeeds get edsSeeds => edsResolvedTheme.seeds;
  EdsColorScheme get edsScheme => edsResolvedTheme.colorScheme;
  Brightness get edsBrightness => edsResolvedTheme.brightness;
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
