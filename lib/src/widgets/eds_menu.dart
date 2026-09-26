import 'package:flutter/material.dart';

import '../primitives/eds_font.dart';
import '../theme/eds_theme_scope.dart';
import '../tokens/eds_color_scheme.dart';

/// Immutable menu item model used by [EdsMenuButton].
class EdsMenuItem<T> {
  const EdsMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  final T value;
  final String label;
  final IconData? icon;
  final bool enabled;
}

/// Generic popup menu button with EDS styling.
///
/// Flutter's [PopupMenuButton] keeps native keyboard navigation, focus and
/// semantics; EDS provides the visual language and a compact model API.
class EdsMenuButton<T> extends StatelessWidget {
  const EdsMenuButton({
    super.key,
    required this.items,
    required this.onSelected,
    required this.child,
    this.initialValue,
    this.tooltip,
    this.enabled = true,
  });

  final List<EdsMenuItem<T>> items;
  final ValueChanged<T>? onSelected;
  final Widget child;
  final T? initialValue;
  final String? tooltip;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;

    return PopupMenuButton<T>(
      initialValue: initialValue,
      enabled: enabled,
      tooltip: tooltip,
      onSelected: onSelected,
      color: scheme.cardBackground,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: scheme.border, width: tokens.stroke.hairline),
      ),
      itemBuilder: (context) => <PopupMenuEntry<T>>[
        for (final item in items)
          PopupMenuItem<T>(
            value: item.value,
            enabled: item.enabled,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: tokens.typography.bodyStrongSize,
                    color: item.enabled
                        ? scheme.textSecondary
                        : scheme.textTertiary,
                  ),
                  SizedBox(width: tokens.spacing.xs),
                ],
                Text(
                  item.label,
                  style: tokens.typography
                      .edsTextStyle(EdsFontRole.body)
                      .copyWith(
                        color: item.enabled
                            ? scheme.textPrimary
                            : scheme.textTertiary,
                      ),
                ),
              ],
            ),
          ),
      ],
      child: child,
    );
  }
}
