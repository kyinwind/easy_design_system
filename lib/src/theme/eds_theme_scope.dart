import 'package:flutter/material.dart';

import '../tokens/eds_design_tokens.dart';
import 'eds_preset_theme.dart';
import 'eds_theme.dart';

class _EdsTokensScope extends InheritedWidget {
  const _EdsTokensScope({
    required this.tokens,
    required this.brightness,
    required super.child,
  });

  final EdsDesignTokens tokens;

  /// Explicit brightness override, or null to resolve from `MediaQuery` at
  /// the point of consumption.
  final Brightness? brightness;

  @override
  bool updateShouldNotify(_EdsTokensScope oldWidget) =>
      tokens != oldWidget.tokens || brightness != oldWidget.brightness;
}

/// Injects design tokens (and optionally a brightness override) into a
/// subtree — the Flutter counterpart of SwiftUI's `\.edsTheme` environment
/// key and its `easyDesignTheme` modifiers.
///
/// * With explicit [tokens] (or [preset]) the subtree uses those tokens.
/// * Without explicit tokens the subtree subscribes to the global
///   `EdsTheme.instance` tokens and rebuilds when they change.
///
/// ```dart
/// EdsThemeScope(
///   child: MaterialApp(home: ...),
/// )
/// ```
class EdsThemeScope extends StatelessWidget {
  const EdsThemeScope({
    super.key,
    this.tokens,
    this.preset,
    this.brightness,
    required this.child,
  });

  /// Explicit tokens for this subtree. Takes precedence over [preset].
  final EdsDesignTokens? tokens;

  /// A preset theme for this subtree; its tokens are used when [tokens] is
  /// null.
  final EdsPresetTheme? preset;

  /// Explicit brightness override. When null, `context.edsBrightness`
  /// resolves from `MediaQuery` and defaults to light.
  final Brightness? brightness;

  /// The subtree below this scope.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final explicitTokens = tokens ?? preset?.tokens;
    if (explicitTokens != null) {
      return _EdsTokensScope(
        tokens: explicitTokens,
        brightness: brightness,
        child: child,
      );
    }
    return ValueListenableBuilder<EdsDesignTokens>(
      valueListenable: EdsTheme.instance.tokensListenable,
      builder: (context, value, _) => _EdsTokensScope(
        tokens: value,
        brightness: brightness,
        child: child,
      ),
    );
  }
}

extension EdsThemeContextX on BuildContext {
  /// The design tokens for this subtree.
  ///
  /// A value injected by `EdsThemeScope` takes precedence; without a scope
  /// this falls back to the current global `EdsTheme.instance` tokens,
  /// mirroring SwiftUI's `\.edsTheme` default.
  EdsDesignTokens get edsTokens =>
      dependOnInheritedWidgetOfExactType<_EdsTokensScope>()?.tokens ??
      EdsTheme.instance.tokens;

  /// The effective brightness for this subtree.
  ///
  /// An explicit `EdsThemeScope.brightness` wins. Otherwise an ambient
  /// Material theme is used when available so `ThemeMode.light/dark` is
  /// respected; platform brightness is the fallback, then light.
  Brightness get edsBrightness {
    final scope = dependOnInheritedWidgetOfExactType<_EdsTokensScope>();
    if (scope?.brightness != null) {
      return scope!.brightness!;
    }
    final materialTheme = Theme.maybeOf(this);
    if (materialTheme != null) {
      return materialTheme.brightness;
    }
    return MediaQuery.maybePlatformBrightnessOf(this) ?? Brightness.light;
  }
}

extension EdsThemeWidgetX on Widget {
  /// Applies design tokens to this subtree without changing its layout,
  /// mirroring Swift's `easyDesignTheme(_:)`.
  Widget easyDesignTheme(EdsDesignTokens tokens) =>
      EdsThemeScope(tokens: tokens, child: this);

  /// Applies a preset theme to this subtree, mirroring Swift's
  /// `easyDesignTheme(_ theme: EDSPresetTheme)`. Dart has no overloads, so
  /// the preset variant gets its own name.
  Widget easyDesignThemePreset(EdsPresetTheme preset) =>
      EdsThemeScope(preset: preset, child: this);
}
