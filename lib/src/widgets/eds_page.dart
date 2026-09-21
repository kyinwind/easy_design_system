import 'package:flutter/material.dart';

import '../adaptive/eds_interaction_profile.dart';
import '../adaptive/eds_resolved_metrics.dart';
import '../adaptive/eds_size_class.dart';
import '../theme/eds_theme_scope.dart';
import '../tokens/eds_color_scheme.dart';
import 'eds_text.dart';

/// The standard page skeleton, mirroring Swift's `EDSPage`.
///
/// ```dart
/// EdsPage('设置', subtitle: '管理应用偏好',
///     child: EdsPageSection('通用', child: ...))
/// ```
class EdsPage extends StatelessWidget {
  const EdsPage(
    this.title, {
    super.key,
    this.subtitle,
    this.maxWidth = 880,
    this.padding,
    this.spacing,
    this.showsBackground = false,
    this.scrolls = true,
    required this.child,
  });

  final String? title;
  final String? subtitle;

  /// Maximum content width. Defaults to 880.
  final double? maxWidth;

  /// Outer page padding. Defaults to the adaptive page padding.
  final double? padding;

  /// Spacing between the title block and content. Defaults to `spacing.xl`.
  final double? spacing;

  /// Whether to paint the theme page background.
  final bool showsBackground;

  /// Whether the page scrolls.
  final bool scrolls;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget content = EdsPageStack(
      title: title,
      subtitle: subtitle,
      maxWidth: maxWidth,
      padding: padding,
      spacing: spacing,
      child: child,
    );
    if (scrolls) {
      content = SingleChildScrollView(child: content);
    }
    if (showsBackground) {
      content = ColoredBox(
        color: context.edsScheme.pageBackground,
        child: content,
      );
    }
    return SizedBox.expand(child: content);
  }
}

/// The page content stack without the scroll view, mirroring Swift's
/// `EDSPageStack`.
///
/// Use it to reuse the page title, max width, padding and section spacing
/// rules when the surrounding app already provides scrolling or a custom
/// container.
class EdsPageStack extends StatelessWidget {
  const EdsPageStack({
    super.key,
    this.title,
    this.subtitle,
    this.maxWidth = 880,
    this.padding,
    this.spacing,
    required this.child,
  });

  final String? title;
  final String? subtitle;
  final double? maxWidth;
  final double? padding;
  final double? spacing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final metrics = EdsResolvedMetrics.resolve(
      tokens: tokens,
      profile: context.edsInteractionProfile,
      horizontalSizeClass: context.edsSizeClass,
    );

    final titleText = title;
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing ?? tokens.spacing.xl,
      children: <Widget>[
        if (titleText != null) EdsPageTitle(titleText, subtitle: subtitle),
        child,
      ],
    );
    if (maxWidth != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: content,
      );
    }
    return Padding(
      padding: EdgeInsets.all(padding ?? metrics.pagePadding),
      child: Align(alignment: Alignment.topCenter, child: content),
    );
  }
}
