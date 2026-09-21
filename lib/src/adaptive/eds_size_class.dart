import 'package:flutter/widgets.dart';

/// A horizontal size class, the Flutter counterpart of SwiftUI's
/// `UserInterfaceSizeClass`.
///
/// Flutter has no built-in size classes; `context.edsSizeClass` derives one
/// from the window width with a 600 dp breakpoint (phones in portrait are
/// compact, tablets and desktops are regular).
enum EdsSizeClass {
  /// Width-constrained layouts (phones in portrait).
  compact,

  /// Width-regular layouts (tablets, desktops, split view).
  regular;
}

extension EdsSizeClassContextX on BuildContext {
  /// The horizontal size class for this subtree.
  ///
  /// Without a `MediaQuery` ancestor this returns
  /// [EdsSizeClass.regular], mirroring the SwiftUI behavior where a nil size
  /// class (desktop) is treated as regular.
  EdsSizeClass get edsSizeClass {
    final size = MediaQuery.maybeSizeOf(this);
    if (size == null) {
      return EdsSizeClass.regular;
    }
    return size.width < 600 ? EdsSizeClass.compact : EdsSizeClass.regular;
  }

  /// Whether the user's text size is in the accessibility range, the
  /// approximation of SwiftUI's `dynamicTypeSize.isAccessibilitySize`.
  ///
  /// A text scale factor of 1.7 or above counts as accessibility sizing.
  bool get edsIsAccessibilityTextSize {
    final scaler = MediaQuery.maybeTextScalerOf(this);
    if (scaler == null) {
      return false;
    }
    return scaler.scale(1.0) >= 1.7;
  }
}
