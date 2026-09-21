import 'package:flutter/widgets.dart';

import '../tokens/eds_design_tokens.dart';

/// Shared surface renderer configuration used by both fine-grained containers
/// and Easy recipes, mirroring Swift's `EDSSurfaceConfiguration`.
///
/// Swift types the background as `AnyShapeStyle?`; the Flutter port uses
/// [Color] because every background the package paints is a flat color
/// (gradient-backed containers such as `EdsHeroPanel` paint their own
/// gradient directly).
class EdsSurfaceConfiguration {
  const EdsSurfaceConfiguration({
    this.background,
    this.cornerRadius = 0,
    this.borderColor,
    this.borderWidth = 0,
    this.shadow,
  });

  /// Background fill; null skips painting entirely.
  final Color? background;

  /// Corner radius of the rounded rectangle.
  final double cornerRadius;

  /// Border stroke color; null paints no border.
  final Color? borderColor;

  /// Border stroke width.
  final double borderWidth;

  /// Optional drop shadow.
  final EdsShadowTokens? shadow;

  /// Returns a copy with the given fields replaced.
  EdsSurfaceConfiguration copyWith({
    Color? background,
    double? cornerRadius,
    Color? borderColor,
    double? borderWidth,
    EdsShadowTokens? shadow,
  }) {
    return EdsSurfaceConfiguration(
      background: background ?? this.background,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EdsSurfaceConfiguration &&
        other.background == background &&
        other.cornerRadius == cornerRadius &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.shadow == shadow;
  }

  @override
  int get hashCode =>
      Object.hash(background, cornerRadius, borderColor, borderWidth, shadow);
}

/// Renders [configuration] around [child], mirroring Swift's `edsSurface`
/// view modifier: a null background short-circuits to the untouched child.
///
/// Swift additionally thickens borders under increased-contrast accessibility
/// settings; Flutter has no contrast-setting equivalent, so borders always
/// use the configured values.
class EdsSurface extends StatelessWidget {
  const EdsSurface({
    super.key,
    required this.configuration,
    required this.child,
  });

  final EdsSurfaceConfiguration configuration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final background = configuration.background;
    if (background == null) {
      return child;
    }
    final radius = BorderRadius.circular(configuration.cornerRadius);
    final shadow = configuration.shadow;
    Widget current = Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        boxShadow: shadow == null
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: shadow.shadowColor,
                  blurRadius: shadow.radius,
                  offset: Offset(shadow.x, shadow.y),
                ),
              ],
      ),
      child: child,
    );
    final borderColor = configuration.borderColor;
    if (borderColor != null && configuration.borderWidth > 0) {
      current = Container(
        foregroundDecoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: configuration.borderWidth,
          ),
          borderRadius: radius,
        ),
        child: current,
      );
    }
    return current;
  }
}

extension EdsSurfaceWidgetX on Widget {
  /// Applies a surface configuration to this subtree, mirroring Swift's
  /// `edsSurface(_:)`.
  Widget edsSurface(EdsSurfaceConfiguration configuration) =>
      EdsSurface(configuration: configuration, child: this);
}
