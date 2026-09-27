import 'package:flutter/material.dart';

import '../primitives/eds_font.dart';
import '../theme/eds_theme_scope.dart';
import '../tokens/eds_color_scheme.dart';

/// A labeled switch row, mirroring Swift's `EDSToggle`.
///
/// Deviations from Swift:
/// - Swift's `Binding<Bool>` maps to [isOn] plus [onChanged].
/// - The selected switch track follows the scoped Brand semantic color.
class EdsToggle extends StatelessWidget {
  const EdsToggle({
    super.key,
    required this.isOn,
    this.onChanged,
    required this.label,
  });

  final bool isOn;

  /// Invoked with the new value when the user toggles the switch.
  final ValueChanged<bool>? onChanged;

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Rows hand non-flex children unbounded width constraints; SwiftUI's
        // HStack instead sizes a view to its ideal width. When this toggle is
        // placed in such a slot (e.g. `EdsSettingRow.trailing`) the row must
        // shrink-wrap instead of expanding via `Spacer`.
        final expands = constraints.maxWidth.isFinite;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: tokens.spacing.sm),
          child: Row(
            mainAxisSize: expands ? MainAxisSize.max : MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: Text(
                  label,
                  style: tokens.typography
                      .edsTextStyle(EdsFontRole.body)
                      .copyWith(color: context.edsScheme.foregroundPrimary),
                ),
              ),
              if (expands) const Spacer(),
              if (!expands) SizedBox(width: tokens.spacing.xs),
              SwitchTheme(
                data: SwitchTheme.of(context).copyWith(
                  trackColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? context.edsScheme.brandSurfaceStrong
                        : null,
                  ),
                ),
                child: Switch(value: isOn, onChanged: onChanged),
              ),
            ],
          ),
        );
      },
    );
  }
}
