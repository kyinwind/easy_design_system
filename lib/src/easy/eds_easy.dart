import 'package:flutter/widgets.dart';

import '../adaptive/eds_interaction_profile.dart';
import '../adaptive/eds_size_class.dart';
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
/// Swift additionally applies `.tint(tokens.colors.accent)` so native SwiftUI
/// controls pick up the theme accent; Flutter's Material widgets are themed
/// separately, and the package's own widgets read the scoped tokens directly,
/// so there is no direct equivalent.
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
    final effectiveTokens = tokens ?? theme?.tokens ?? context.edsTokens;
    final recipe = EdsEasyRecipe.resolve(
      style: style,
      options: options,
      tokens: effectiveTokens,
      profile: context.edsInteractionProfile,
      horizontalSizeClass: context.edsSizeClass,
    );
    final scheme = EdsColorScheme.resolve(
      effectiveTokens,
      context.edsBrightness,
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
          background: scheme.pageBackground,
          cornerRadius: recipe.cornerRadius,
          borderColor: recipe.showsBorder ? scheme.border : null,
          borderWidth: recipe.showsBorder ? effectiveTokens.stroke.hairline : 0,
          shadow: recipe.showsShadow ? effectiveTokens.shadow : null,
        ),
      ),
      EdsEasyBackgroundPolicy.subtle => current.edsSurface(
        EdsSurfaceConfiguration(
          background: scheme.subtleFill,
          cornerRadius: recipe.cornerRadius,
          borderColor: recipe.showsBorder ? scheme.border : null,
          borderWidth: recipe.showsBorder ? effectiveTokens.stroke.hairline : 0,
          shadow: recipe.showsShadow ? effectiveTokens.shadow : null,
        ),
      ),
      EdsEasyBackgroundPolicy.card => current.edsSurface(
        EdsSurfaceConfiguration(
          background: scheme.cardBackground,
          cornerRadius: recipe.cornerRadius,
          borderColor: recipe.showsBorder ? scheme.border : null,
          borderWidth: recipe.showsBorder ? effectiveTokens.stroke.hairline : 0,
          shadow: recipe.showsShadow ? effectiveTokens.shadow : null,
        ),
      ),
    };

    // Re-inject the resolved tokens so the subtree reads the same theme that
    // produced this styling (Swift: `.environment(\.edsTheme, tokens)`).
    current = EdsThemeScope(tokens: effectiveTokens, child: current);

    // Body font + foreground color (Swift: `.edsFont(.body)` +
    // `.foregroundStyle(tokens.colors.textPrimary)`).
    current = IconTheme.merge(
      data: IconThemeData(color: scheme.textPrimary),
      child: DefaultTextStyle.merge(
        style: effectiveTokens.typography
            .edsTextStyle(EdsFontRole.body)
            .copyWith(color: scheme.textPrimary),
        child: current,
      ),
    );

    return current;
  }
}
