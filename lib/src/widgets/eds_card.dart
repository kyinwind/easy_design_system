import 'package:flutter/material.dart';

import '../primitives/eds_surface.dart';
import '../theme/eds_theme_scope.dart';

/// A lightweight card container, mirroring Swift's `EDSCard`.
///
/// By default only padding is applied; the background and corner radius are
/// drawn only when [background] is explicitly given.
class EdsCard extends StatelessWidget {
  const EdsCard({
    super.key,
    this.padding,
    this.background,
    this.cornerRadius,
    required this.child,
  });

  /// Inner padding. Defaults to `spacing.lg`.
  final double? padding;

  /// Background color. Mirrors Swift's `background: some ShapeStyle`;
  /// only flat colors are supported.
  final Color? background;

  /// Corner radius. Defaults to `radius.md`.
  final double? cornerRadius;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    return EdsSurface(
      configuration: EdsSurfaceConfiguration(
        background: background,
        cornerRadius: cornerRadius ?? tokens.radius.md,
      ),
      child: Padding(
        padding: EdgeInsets.all(padding ?? tokens.spacing.lg),
        child: child,
      ),
    );
  }
}
