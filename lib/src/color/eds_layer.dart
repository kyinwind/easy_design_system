import 'package:flutter/widgets.dart';

/// Finite visual context levels used by ColorScheme 2.0.
///
/// The set is intentionally small. Deeper nesting should clamp to [nested]
/// rather than creating unbounded surface colors.
enum EdsLayer {
  base,
  raised,
  nested,
  overlay,
}

class EdsLayerScope extends InheritedWidget {
  const EdsLayerScope({
    super.key,
    required this.layer,
    required super.child,
  });

  final EdsLayer layer;

  @override
  bool updateShouldNotify(EdsLayerScope oldWidget) => layer != oldWidget.layer;
}

extension EdsLayerContextX on BuildContext {
  EdsLayer get edsLayer =>
      dependOnInheritedWidgetOfExactType<EdsLayerScope>()?.layer ??
      EdsLayer.base;
}

extension EdsLayerX on EdsLayer {
  /// Moves one structural surface level deeper while clamping nested depth.
  EdsLayer get nestedChild {
    return switch (this) {
      EdsLayer.base => EdsLayer.raised,
      EdsLayer.raised => EdsLayer.nested,
      EdsLayer.nested => EdsLayer.nested,
      EdsLayer.overlay => EdsLayer.overlay,
    };
  }
}
