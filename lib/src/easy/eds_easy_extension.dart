import 'package:flutter/widgets.dart';

import '../theme/eds_preset_theme.dart';
import '../tokens/eds_design_tokens.dart';
import 'eds_easy.dart';
import 'eds_easy_style.dart';

extension EdsEasyWidgetX on Widget {
  /// Applies the recommended EasyDesignSystem styling, mirroring Swift's
  /// `easyDesign(_:options:)`.
  ///
  /// ```dart
  /// Text('Hello').easyDesign(style: EdsEasyStyle.card)
  /// ```
  Widget easyDesign({
    EdsEasyStyle style = EdsEasyStyle.page,
    EdsEasyOptions options = const EdsEasyOptions(),
  }) {
    return EdsEasy(style: style, options: options, child: this);
  }

  /// Applies an Easy style and a preset theme to this subtree, mirroring
  /// Swift's `easyDesign(_:theme:options:)`. Dart has no overloads and
  /// `easyDesignTheme` is taken by the scope-only modifier, so the preset
  /// variant gets its own name.
  Widget easyDesignPreset(
    EdsPresetTheme preset, {
    EdsEasyStyle style = EdsEasyStyle.page,
    EdsEasyOptions options = const EdsEasyOptions(),
  }) {
    return EdsEasy(style: style, options: options, theme: preset, child: this);
  }

  /// Applies an Easy style and concrete design tokens to this subtree,
  /// mirroring Swift's `easyDesign(_:tokens:options:)`. Dart has no
  /// overloads, so the tokens variant gets its own name.
  Widget easyDesignTokens(
    EdsDesignTokens tokens, {
    EdsEasyStyle style = EdsEasyStyle.page,
    EdsEasyOptions options = const EdsEasyOptions(),
  }) {
    return EdsEasy(style: style, options: options, tokens: tokens, child: this);
  }
}
