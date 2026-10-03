import 'package:flutter/widgets.dart';

import '../adaptive/eds_interaction_profile.dart';
import '../adaptive/eds_size_class.dart';
import '../color/eds_layer.dart';
import '../primitives/eds_font.dart';
import '../primitives/eds_surface.dart';
import '../theme/eds_preset_theme.dart';
import '../theme/eds_theme_scope.dart';
import '../tokens/eds_color_scheme.dart';
import '../tokens/eds_design_tokens.dart';
import 'eds_easy_recipe.dart';
import 'eds_easy_style.dart';

/// The Easy API semantic container, mirroring Swift's `easyDesign` view
/// modifiers.
///
/// ```dart
/// Text('Hello').easyDesign(style: EdsEasyStyle.card)
/// ```
///
/// Resolution pipeline (identical to Swift):
/// padding → content width → semantic surface → re-inject tokens →
/// body font + foreground color.
///
/// Native Flutter controls are not globally recolored here. EDS components
/// read the scoped semantic scheme directly.
class EdsEasy extends StatelessWidget {
  const EdsEasy({
    super.key,
    this.style = EdsEasyStyle.page,
    this.options = const EdsEasyOptions(),
    this.tokens,
    this.theme,
    required this.child,
  });

  /// The semantic scene to apply.
  final EdsEasyStyle style;

  /// Intentional overrides.
  final EdsEasyOptions options;

  /// Explicit tokens for this subtree; wins over [theme].
  final EdsDesignTokens? tokens;

  /// A preset theme for this subtree; used when [tokens] is null.
  final EdsPresetTheme? theme;

  /// The content to style.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final baseTheme = theme?.theme ?? context.edsThemeData;
    final effectiveTheme =
        tokens == null ? baseTheme : baseTheme.copyWith(tokens: tokens);
    final effectiveTokens = effectiveTheme.tokens;
    final recipe = EdsEasyRecipe.resolve(
      style: style,
      options: options,
      tokens: effectiveTokens,
      profile: context.edsInteractionProfile,
      horizontalSizeClass: context.edsSizeClass,
    );
    final scheme = EdsColorScheme.resolve(
      seeds: effectiveTheme.seeds,
      brightness: context.edsBrightness,
      overrides: effectiveTheme.semanticOverrides,
      style: effectiveTheme.colorStyle,
    );

    Widget current = child;

    // Padding.
    if (recipe.padding != 0) {
      current = Padding(
        padding: recipe.paddingAxis == EdsEasyPaddingAxis.all
            ? EdgeInsets.all(recipe.padding)
            : EdgeInsets.symmetric(vertical: recipe.padding),
        child: current,
      );
    }

    // Content width.
    current = switch (recipe.width) {
      EdsEasyResolvedWidthUnchanged() => current,
      EdsEasyResolvedWidthFixed(:final width) => Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: current,
          ),
        ),
      EdsEasyResolvedWidthFill() => SizedBox(
          width: double.infinity,
          child: current,
        ),
    };

    // Semantic surface.
    current = switch (recipe.background) {
      EdsEasyBackgroundPolicy.inherited => current,
      EdsEasyBackgroundPolicy.page => current.edsSurface(
          EdsSurfaceConfiguration(
            background: scheme.surfacePage,
            cornerRadius: recipe.cornerRadius,
            borderColor: recipe.showsBorder ? scheme.borderSubtle : null,
            borderWidth:
                recipe.showsBorder ? effectiveTokens.stroke.hairline : 0,
            shadow: recipe.showsShadow ? effectiveTokens.shadow : null,
          ),
        ),
      EdsEasyBackgroundPolicy.subtle => current.edsSurface(
          EdsSurfaceConfiguration(
            background: scheme.surfaceSunken,
            cornerRadius: recipe.cornerRadius,
            borderColor: recipe.showsBorder ? scheme.borderSubtle : null,
            borderWidth:
                recipe.showsBorder ? effectiveTokens.stroke.hairline : 0,
            shadow: recipe.showsShadow ? effectiveTokens.shadow : null,
          ),
        ),
      EdsEasyBackgroundPolicy.card => current.edsSurface(
          EdsSurfaceConfiguration(
            background: scheme.surfaceRaised,
            cornerRadius: recipe.cornerRadius,
            borderColor: recipe.showsBorder ? scheme.borderSubtle : null,
            borderWidth:
                recipe.showsBorder ? effectiveTokens.stroke.hairline : 0,
            shadow: recipe.showsShadow ? effectiveTokens.shadow : null,
          ),
        ),
    };

    final inheritedLayer = context.edsLayer;
    current = switch (style) {
      EdsEasyStyle.page => EdsLayerScope(
          layer: EdsLayer.base,
          child: current,
        ),
      EdsEasyStyle.group || EdsEasyStyle.card => EdsLayerScope(
          layer: inheritedLayer.nestedChild,
          child: current,
        ),
      EdsEasyStyle.content ||
      EdsEasyStyle.section ||
      EdsEasyStyle.plain =>
        current,
    };

    // Re-inject the resolved tokens so the subtree reads the same theme that
    // produced this styling (Swift: `.environment(\.edsTheme, tokens)`).
    current = EdsThemeScope(theme: effectiveTheme, child: current);

    // Body font + semantic primary foreground.
    current = IconTheme.merge(
      data: IconThemeData(color: scheme.foregroundPrimary),
      child: DefaultTextStyle.merge(
        style: effectiveTokens.typography
            .edsTextStyle(EdsFontRole.body)
            .copyWith(color: scheme.foregroundPrimary),
        child: current,
      ),
    );

    return current;
  }
}
