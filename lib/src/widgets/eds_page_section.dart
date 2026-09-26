import 'package:flutter/material.dart';

import '../primitives/eds_font.dart';
import '../theme/eds_theme_scope.dart';
import '../tokens/eds_color_scheme.dart';

/// A titled page section with an optional divider, mirroring Swift's
/// `EDSPageSection`.
class EdsPageSection extends StatelessWidget {
  const EdsPageSection(
    this.title, {
    super.key,
    this.subtitle,
    this.showsDivider = false,
    required this.child,
  });

  final String title;
  final String? subtitle;

  /// Whether to draw a divider between the title block and the content.
  final bool showsDivider;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final subtitleText = subtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: tokens.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: tokens.spacing.xxs,
            children: <Widget>[
              Text(
                title,
                style: tokens.typography
                    .edsTextStyle(EdsFontRole.sectionTitle)
                    .copyWith(color: scheme.textPrimary),
              ),
              if (subtitleText != null)
                Text(
                  subtitleText,
                  style: tokens.typography
                      .edsTextStyle(EdsFontRole.caption)
                      .copyWith(color: scheme.textSecondary),
                ),
            ],
          ),
        ),
        if (showsDivider)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.spacing.md),
            child: Divider(height: 1, thickness: 1, color: scheme.border),
          ),
        child,
      ],
    );
  }
}
