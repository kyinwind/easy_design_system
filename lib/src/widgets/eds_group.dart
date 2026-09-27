import 'package:flutter/material.dart';

import '../color/eds_layer.dart';
import '../primitives/eds_font.dart';
import '../theme/eds_theme_scope.dart';

/// Group background style. Mirrors Swift's `EDSGroupStyle`.
enum EdsGroupStyle {
  /// Gray tinted background (default).
  filled,

  /// Subtle fill; ignores an explicitly provided [EdsGroup.background].
  subtle,

  /// No background.
  plain,
}

/// A titled content group, mirroring Swift's `EDSGroup`.
///
/// The border overlay uses the theme border color with a hairline width
/// when [showsBorder] is true.
class EdsGroup extends StatelessWidget {
  const EdsGroup(
    this.title, {
    super.key,
    this.subtitle,
    this.padding,
    this.cornerRadius,
    this.style = EdsGroupStyle.filled,
    this.showsBorder = false,
    required this.child,
  });

  final String? title;
  final String? subtitle;

  /// Inner padding. Defaults to `spacing.lg`.
  final double? padding;

  /// Corner radius. Defaults to `radius.md`.
  final double? cornerRadius;

  final EdsGroupStyle style;
  final bool showsBorder;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;

    final Color? resolvedBackground = switch (style) {
      EdsGroupStyle.filled => scheme.surfaceSunken,
      EdsGroupStyle.subtle => scheme.surfaceBase,
      EdsGroupStyle.plain => null,
    };

    final titleText = title;
    final subtitleText = subtitle;

    final Widget groupContent = SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tokens.spacing.md,
        children: <Widget>[
          if (titleText != null || subtitleText != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: tokens.spacing.xxs,
              children: <Widget>[
                if (titleText != null)
                  Text(
                    titleText,
                    style: tokens.typography
                        .edsTextStyle(EdsFontRole.bodyStrong)
                        .copyWith(color: scheme.foregroundPrimary),
                  ),
                if (subtitleText != null)
                  Text(
                    subtitleText,
                    style: tokens.typography
                        .edsTextStyle(EdsFontRole.caption)
                        .copyWith(color: scheme.foregroundSecondary),
                  ),
              ],
            ),
          child,
        ],
      ),
    );

    Widget group = Padding(
      padding: EdgeInsets.all(padding ?? tokens.spacing.lg),
      child: groupContent,
    );

    if (resolvedBackground != null) {
      group = Container(
        decoration: BoxDecoration(
          color: resolvedBackground,
          borderRadius: BorderRadius.circular(cornerRadius ?? tokens.radius.md),
        ),
        child: EdsLayerScope(
          layer: context.edsLayer.nestedChild,
          child: group,
        ),
      );
    }

    if (showsBorder) {
      group = Container(
        foregroundDecoration: BoxDecoration(
          border: Border.all(
            color: scheme.borderDefault,
            width: tokens.stroke.hairline,
          ),
          borderRadius: BorderRadius.circular(cornerRadius ?? tokens.radius.md),
        ),
        child: group,
      );
    }

    return group;
  }
}
