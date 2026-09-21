import '../adaptive/eds_interaction_profile.dart';
import '../adaptive/eds_resolved_metrics.dart';
import '../adaptive/eds_size_class.dart';
import '../tokens/eds_design_tokens.dart';
import 'eds_easy_style.dart';

/// Which padding edges the recipe's padding applies to.
enum EdsEasyPaddingAxis {
  /// Padding on all edges.
  all,

  /// Vertical padding only.
  vertical,
}

/// The resolved width policy of an Easy recipe.
///
/// Swift models this as an internal enum with an associated value; the Dart
/// port exposes the sealed hierarchy so recipes can be asserted in tests.
sealed class EdsEasyResolvedWidth {
  const EdsEasyResolvedWidth();

  /// Leave the width untouched.
  static const EdsEasyResolvedWidth unchanged = EdsEasyResolvedWidthUnchanged();

  /// Center the content with a concrete maximum width.
  static const EdsEasyResolvedWidth fill = EdsEasyResolvedWidthFill();

  /// Fill the available width.
  const factory EdsEasyResolvedWidth.fixed(double width) =
      EdsEasyResolvedWidthFixed;
}

/// The `unchanged` width policy.
class EdsEasyResolvedWidthUnchanged extends EdsEasyResolvedWidth {
  const EdsEasyResolvedWidthUnchanged();

  @override
  bool operator ==(Object other) => other is EdsEasyResolvedWidthUnchanged;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// The `fill` width policy.
class EdsEasyResolvedWidthFill extends EdsEasyResolvedWidth {
  const EdsEasyResolvedWidthFill();

  @override
  bool operator ==(Object other) => other is EdsEasyResolvedWidthFill;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// The `fixed` width policy.
class EdsEasyResolvedWidthFixed extends EdsEasyResolvedWidth {
  const EdsEasyResolvedWidthFixed(this.width);

  /// The concrete maximum content width.
  final double width;

  @override
  bool operator ==(Object other) =>
      other is EdsEasyResolvedWidthFixed && other.width == width;

  @override
  int get hashCode => Object.hash(EdsEasyResolvedWidthFixed, width);
}

/// The resolved background policy of an Easy recipe.
enum EdsEasyBackgroundPolicy {
  /// No background; whatever the parent paints shows through.
  inherited,

  /// Page background fill.
  page,

  /// Subtle (3%) fill.
  subtle,

  /// Card background fill.
  card,
}

/// Internal, pure-value mapping from a semantic scene to concrete layout
/// rules, mirroring Swift's `EDSEasyRecipe`.
class EdsEasyRecipe {
  const EdsEasyRecipe({
    required this.padding,
    required this.paddingAxis,
    required this.width,
    required this.background,
    required this.cornerRadius,
    required this.showsBorder,
    required this.showsShadow,
  });

  /// Resolves the recipe for [style] from [tokens], an interaction [profile]
  /// and a [horizontalSizeClass], then applies the [options] overrides.
  ///
  /// Pure function: depends only on its arguments, exactly like Swift's
  /// `EDSEasyRecipe.resolve`.
  static EdsEasyRecipe resolve({
    required EdsEasyStyle style,
    EdsEasyOptions options = const EdsEasyOptions(),
    required EdsDesignTokens tokens,
    EdsInteractionProfile profile = EdsInteractionProfile.automatic,
    EdsSizeClass? horizontalSizeClass,
  }) {
    var recipe = _base(
      style: style,
      tokens: tokens,
      profile: profile,
      horizontalSizeClass: horizontalSizeClass,
    );

    final padding = options.padding.resolve(tokens.spacing);
    if (padding != null) {
      recipe = recipe._replacing(
          padding: padding, paddingAxis: EdsEasyPaddingAxis.all);
    }

    switch (options.maxContentWidth) {
      case EdsEasyWidthAutomatic():
        break;
      case EdsEasyFixedWidth(:final width):
        recipe = recipe._replacing(
          width: EdsEasyResolvedWidth.fixed(width < 0 ? 0 : width),
        );
      case EdsEasyWidthUnlimited():
        recipe = recipe._replacing(width: EdsEasyResolvedWidth.fill);
    }

    switch (options.background) {
      case EdsEasyVisibility.automatic:
        break;
      case EdsEasyVisibility.visible:
        if (recipe.background == EdsEasyBackgroundPolicy.inherited) {
          recipe = recipe._replacing(background: EdsEasyBackgroundPolicy.page);
        }
      case EdsEasyVisibility.hidden:
        recipe =
            recipe._replacing(background: EdsEasyBackgroundPolicy.inherited);
    }

    return recipe;
  }

  static EdsEasyRecipe _base({
    required EdsEasyStyle style,
    required EdsDesignTokens tokens,
    required EdsInteractionProfile profile,
    required EdsSizeClass? horizontalSizeClass,
  }) {
    final metrics = EdsResolvedMetrics.resolve(
      tokens: tokens,
      profile: profile,
      horizontalSizeClass: horizontalSizeClass,
    );

    return switch (style) {
      EdsEasyStyle.page => EdsEasyRecipe(
          padding: metrics.pagePadding,
          paddingAxis: EdsEasyPaddingAxis.all,
          width: EdsEasyResolvedWidth.fixed(metrics.readableContentMaxWidth),
          background: EdsEasyBackgroundPolicy.inherited,
          cornerRadius: 0,
          showsBorder: false,
          showsShadow: false,
        ),
      EdsEasyStyle.content => EdsEasyRecipe(
          padding: tokens.spacing.md,
          paddingAxis: EdsEasyPaddingAxis.all,
          width: EdsEasyResolvedWidth.fill,
          background: EdsEasyBackgroundPolicy.inherited,
          cornerRadius: 0,
          showsBorder: false,
          showsShadow: false,
        ),
      EdsEasyStyle.section => EdsEasyRecipe(
          padding: tokens.spacing.xs,
          paddingAxis: EdsEasyPaddingAxis.vertical,
          width: EdsEasyResolvedWidth.fill,
          background: EdsEasyBackgroundPolicy.inherited,
          cornerRadius: 0,
          showsBorder: false,
          showsShadow: false,
        ),
      EdsEasyStyle.group => EdsEasyRecipe(
          padding: tokens.spacing.lg,
          paddingAxis: EdsEasyPaddingAxis.all,
          width: EdsEasyResolvedWidth.fill,
          background: EdsEasyBackgroundPolicy.subtle,
          cornerRadius: tokens.radius.md,
          showsBorder: false,
          showsShadow: false,
        ),
      EdsEasyStyle.card => EdsEasyRecipe(
          padding: tokens.spacing.lg,
          paddingAxis: EdsEasyPaddingAxis.all,
          width: EdsEasyResolvedWidth.fill,
          background: EdsEasyBackgroundPolicy.card,
          cornerRadius: tokens.radius.md,
          showsBorder: true,
          showsShadow: true,
        ),
      EdsEasyStyle.plain => const EdsEasyRecipe(
          padding: 0,
          paddingAxis: EdsEasyPaddingAxis.all,
          width: EdsEasyResolvedWidth.unchanged,
          background: EdsEasyBackgroundPolicy.inherited,
          cornerRadius: 0,
          showsBorder: false,
          showsShadow: false,
        ),
    };
  }

  /// The recipe's padding amount.
  final double padding;

  /// Which edges the padding applies to.
  final EdsEasyPaddingAxis paddingAxis;

  /// The resolved width policy.
  final EdsEasyResolvedWidth width;

  /// The resolved background policy.
  final EdsEasyBackgroundPolicy background;

  /// Surface corner radius.
  final double cornerRadius;

  /// Whether the surface draws a border.
  final bool showsBorder;

  /// Whether the surface draws a shadow.
  final bool showsShadow;

  EdsEasyRecipe _replacing({
    double? padding,
    EdsEasyPaddingAxis? paddingAxis,
    EdsEasyResolvedWidth? width,
    EdsEasyBackgroundPolicy? background,
  }) {
    return EdsEasyRecipe(
      padding: padding ?? this.padding,
      paddingAxis: paddingAxis ?? this.paddingAxis,
      width: width ?? this.width,
      background: background ?? this.background,
      cornerRadius: cornerRadius,
      showsBorder: showsBorder,
      showsShadow: showsShadow,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EdsEasyRecipe &&
        other.padding == padding &&
        other.paddingAxis == paddingAxis &&
        other.width == width &&
        other.background == background &&
        other.cornerRadius == cornerRadius &&
        other.showsBorder == showsBorder &&
        other.showsShadow == showsShadow;
  }

  @override
  int get hashCode => Object.hash(
        padding,
        paddingAxis,
        width,
        background,
        cornerRadius,
        showsBorder,
        showsShadow,
      );
}
