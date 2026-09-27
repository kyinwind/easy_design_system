import 'package:flutter/material.dart';

import '../color/eds_layer.dart';
import '../primitives/eds_surface.dart';
import '../theme/eds_theme_scope.dart';

/// Semantic card presentation.
///
/// Use [plain] when only EDS spacing is wanted, or [raised] for a standard
/// card surface. Arbitrary per-instance colors are intentionally not exposed;
/// use Flutter primitives for visuals outside the EDS component language.
enum EdsCardStyle {
  plain,
  raised,
}

class EdsCard extends StatelessWidget {
  const EdsCard({
    super.key,
    this.padding,
    this.style = EdsCardStyle.plain,
    this.cornerRadius,
    required this.child,
  });

  final double? padding;
  final EdsCardStyle style;
  final double? cornerRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;

    Widget content = Padding(
      padding: EdgeInsets.all(padding ?? tokens.spacing.lg),
      child: child,
    );

    if (style == EdsCardStyle.plain) {
      return content;
    }

    final childLayer = context.edsLayer.nestedChild;
    content = EdsLayerScope(layer: childLayer, child: content);

    return EdsSurface(
      configuration: EdsSurfaceConfiguration(
        background: scheme.surfaceRaised,
        cornerRadius: cornerRadius ?? tokens.radius.md,
        borderColor: scheme.borderSubtle,
        borderWidth: tokens.stroke.hairline,
        shadow: tokens.shadow,
      ),
      child: content,
    );
  }
}
