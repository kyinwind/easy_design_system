import 'dart:math' as math;

import '../tokens/eds_design_tokens.dart';
import 'eds_interaction_profile.dart';
import 'eds_size_class.dart';

/// Adaptive layout and interaction measurements derived from a theme and
/// profile, mirroring Swift's `EDSResolvedMetrics`.
///
/// [minimumInteractiveDimension] is zero for pointer interaction. Use
/// [interactiveHeight] with the control's visual height when sizing rows.
class EdsResolvedMetrics {
  const EdsResolvedMetrics({
    required this.pagePadding,
    required this.readableContentMaxWidth,
    required this.minimumInteractiveDimension,
    required this.supportsHoverEnhancement,
    required this.showsPersistentAuxiliaryActions,
  });

  /// Resolves adaptive metrics from [tokens], an interaction [profile] and an
  /// optional [horizontalSizeClass] (null is treated as regular, mirroring
  /// Swift's `UserInterfaceSizeClass?`).
  ///
  /// When the adaptive-layout tokens are left at their defaults the page
  /// padding is derived from the spacing scale (`md` compact / `xxl`
  /// regular), exactly like the Swift implementation.
  factory EdsResolvedMetrics.resolve({
    required EdsDesignTokens tokens,
    required EdsInteractionProfile profile,
    EdsSizeClass? horizontalSizeClass,
  }) {
    final resolvedProfile = profile.resolved;
    final isCompact = horizontalSizeClass == EdsSizeClass.compact;
    final adaptive = tokens.adaptiveLayout;
    const adaptiveDefaults = EdsAdaptiveLayoutTokens();
    final compactPagePadding =
        adaptive.compactPagePadding == adaptiveDefaults.compactPagePadding
            ? tokens.spacing.md
            : adaptive.compactPagePadding;
    final regularPagePadding =
        adaptive.regularPagePadding == adaptiveDefaults.regularPagePadding
            ? tokens.spacing.xxl
            : adaptive.regularPagePadding;

    final double minimumInteractiveDimension;
    switch (resolvedProfile) {
      case EdsInteractionProfile.touch:
        minimumInteractiveDimension = adaptive.minimumTouchTarget;
      case EdsInteractionProfile.hybrid:
        minimumInteractiveDimension = adaptive.minimumHybridTarget;
      case EdsInteractionProfile.pointer:
      case EdsInteractionProfile.automatic:
        minimumInteractiveDimension = 0;
    }

    return EdsResolvedMetrics(
      pagePadding: isCompact ? compactPagePadding : regularPagePadding,
      readableContentMaxWidth: adaptive.readableContentMaxWidth,
      minimumInteractiveDimension: minimumInteractiveDimension,
      supportsHoverEnhancement: resolvedProfile != EdsInteractionProfile.touch,
      showsPersistentAuxiliaryActions:
          resolvedProfile != EdsInteractionProfile.pointer,
    );
  }

  /// The page edge padding for the current size class.
  final double pagePadding;

  /// The maximum readable content width.
  final double readableContentMaxWidth;

  /// The minimum hit-target dimension (0 for pointer profiles).
  final double minimumInteractiveDimension;

  /// Whether hover-driven enhancements should render.
  final bool supportsHoverEnhancement;

  /// Whether auxiliary actions stay visible (pointer UIs hide them behind
  /// hover or menus).
  final bool showsPersistentAuxiliaryActions;

  /// The hit-target height for a control with the given visual height.
  double interactiveHeight(double visualHeight) =>
      math.max(visualHeight, minimumInteractiveDimension);

  @override
  bool operator ==(Object other) {
    return other is EdsResolvedMetrics &&
        other.pagePadding == pagePadding &&
        other.readableContentMaxWidth == readableContentMaxWidth &&
        other.minimumInteractiveDimension == minimumInteractiveDimension &&
        other.supportsHoverEnhancement == supportsHoverEnhancement &&
        other.showsPersistentAuxiliaryActions ==
            showsPersistentAuxiliaryActions;
  }

  @override
  int get hashCode => Object.hash(
        pagePadding,
        readableContentMaxWidth,
        minimumInteractiveDimension,
        supportsHoverEnhancement,
        showsPersistentAuxiliaryActions,
      );
}
