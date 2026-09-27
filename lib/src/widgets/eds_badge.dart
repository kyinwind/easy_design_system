import 'package:flutter/material.dart';

import '../primitives/eds_font.dart';
import '../theme/eds_theme_scope.dart';

/// Badge style. Mirrors Swift's `EDSBadge.Style`.
enum EdsBadgeStyle {
  /// Neutral gray.
  neutral,

  /// Brand, follows the theme primary color.
  brand,

  /// Success green.
  success,

  /// Warning orange.
  warning,

  /// Danger red.
  danger,
}

/// A small capsule badge, mirroring Swift's `EDSBadge`.
///
/// Deviations from Swift:
/// - The `localized` / `verbatim` initializers collapse into this
///   constructor because Dart `Text` never performs localization-key lookup.
///   [EdsBadge.verbatim] is kept as a redirecting constructor for source
///   compatibility.
/// - Swift's `accessibilityDifferentiateWithoutColor` icon reinforcement maps
///   to `MediaQuery.accessibleNavigation`.
class EdsBadge extends StatelessWidget {
  const EdsBadge(this.text, {super.key, this.style = EdsBadgeStyle.brand});

  /// Displays the text verbatim, mirroring Swift's `init(verbatim:style:)`.
  const EdsBadge.verbatim(
    String text, {
    Key? key,
    EdsBadgeStyle style = EdsBadgeStyle.brand,
  }) : this(text, key: key, style: style);

  final String text;
  final EdsBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final (foreground, background) = switch (style) {
      EdsBadgeStyle.neutral => (
          scheme.foregroundSecondary,
          scheme.surfaceSunken,
        ),
      EdsBadgeStyle.brand => (
          scheme.brandForeground,
          scheme.brandSurface,
        ),
      EdsBadgeStyle.success => (
          scheme.successForeground,
          scheme.successSurface,
        ),
      EdsBadgeStyle.warning => (
          scheme.warningForeground,
          scheme.warningSurface,
        ),
      EdsBadgeStyle.danger => (
          scheme.dangerForeground,
          scheme.dangerSurface,
        ),
    };

    final accessible = MediaQuery.maybeAccessibleNavigationOf(context) ?? false;
    final IconData? differentiationIcon = accessible
        ? switch (style) {
            EdsBadgeStyle.success => Icons.check_circle,
            EdsBadgeStyle.warning => Icons.warning,
            EdsBadgeStyle.danger => Icons.block,
            EdsBadgeStyle.neutral || EdsBadgeStyle.brand => null,
          }
        : null;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.xs,
        vertical: tokens.spacing.xxs,
      ),
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            text,
            style: tokens.typography
                .edsTextStyle(EdsFontRole.captionStrong)
                .copyWith(color: foreground),
          ),
          if (differentiationIcon != null) ...<Widget>[
            SizedBox(width: tokens.spacing.xxs),
            ExcludeSemantics(
              child: Icon(
                differentiationIcon,
                size: tokens.typography.captionStrongSize,
                color: foreground,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
