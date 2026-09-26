import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Describes the primary interaction model used to resolve adaptive metrics,
/// mirroring Swift's `EDSInteractionProfile`.
///
/// Most applications should keep the default [automatic] value. Explicit
/// values are useful for previews, tests, and unusual host environments.
enum EdsInteractionProfile {
  /// Resolved per platform at access time.
  automatic,

  /// Touch-first interaction (phones, tablets).
  touch,

  /// Pointer-first interaction (desktop).
  pointer,

  /// Devices that mix touch and pointer input (tablets with keyboards,
  /// Mac Catalyst).
  hybrid;

  /// The effective profile after [automatic] is resolved for the current
  /// platform.
  ///
  /// Mirrors Swift: desktop platforms resolve to [pointer], everything else
  /// (including web on mobile browsers) resolves to [touch].
  EdsInteractionProfile get resolved {
    if (this != EdsInteractionProfile.automatic) {
      return this;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.macOS ||
      TargetPlatform.linux ||
      TargetPlatform.windows => EdsInteractionProfile.pointer,
      _ => EdsInteractionProfile.touch,
    };
  }
}

class _EdsInteractionProfileScope extends InheritedWidget {
  const _EdsInteractionProfileScope({
    required this.profile,
    required super.child,
  });

  final EdsInteractionProfile profile;

  @override
  bool updateShouldNotify(_EdsInteractionProfileScope oldWidget) =>
      profile != oldWidget.profile;
}

extension EdsInteractionProfileWidgetX on Widget {
  /// Overrides automatic interaction adaptation for this subtree, mirroring
  /// Swift's `easyDesignInteractionProfile(_:)`.
  Widget easyDesignInteractionProfile(EdsInteractionProfile profile) =>
      _EdsInteractionProfileScope(profile: profile, child: this);
}

extension EdsInteractionProfileContextX on BuildContext {
  /// The interaction profile for this subtree; [EdsInteractionProfile.automatic]
  /// when no override is set, mirroring the SwiftUI environment default.
  EdsInteractionProfile get edsInteractionProfile =>
      dependOnInheritedWidgetOfExactType<_EdsInteractionProfileScope>()
          ?.profile ??
      EdsInteractionProfile.automatic;
}
