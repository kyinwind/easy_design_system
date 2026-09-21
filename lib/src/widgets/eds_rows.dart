import 'package:flutter/material.dart';

import '../adaptive/eds_interaction_profile.dart';
import '../adaptive/eds_resolved_metrics.dart';
import '../adaptive/eds_size_class.dart';
import '../primitives/eds_font.dart';
import '../theme/eds_theme_scope.dart';
import '../tokens/eds_color_scheme.dart';
import 'eds_text.dart';

/// A settings row with a title, optional subtitle and trailing widget,
/// mirroring Swift's `EDSSettingRow`.
///
/// Deviation from Swift: [trailing] is optional; SwiftUI callers pass an
/// explicit `EmptyView`.
///
/// Under accessibility text sizes the trailing widget stacks below the
/// labels instead of trailing horizontally.
class EdsSettingRow extends StatelessWidget {
  const EdsSettingRow(this.title, {super.key, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final metrics = EdsResolvedMetrics.resolve(
      tokens: tokens,
      profile: context.edsInteractionProfile,
      horizontalSizeClass: context.edsSizeClass,
    );

    final subtitleText = subtitle;
    final labels = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.spacing.xxs,
      children: <Widget>[
        Text(
          title,
          style: tokens.typography
              .edsTextStyle(EdsFontRole.bodyStrong)
              .copyWith(color: scheme.textPrimary),
        ),
        if (subtitleText != null && subtitleText.isNotEmpty)
          Text(
            subtitleText,
            style: tokens.typography
                .edsTextStyle(EdsFontRole.caption)
                .copyWith(color: scheme.textSecondary),
          ),
      ],
    );

    final Widget content;
    if (context.edsIsAccessibilityTextSize) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tokens.spacing.sm,
        children: <Widget>[
          labels,
          if (trailing != null)
            SizedBox(
              width: double.infinity,
              child: Align(alignment: Alignment.centerRight, child: trailing),
            ),
        ],
      );
    } else {
      content = Row(
        children: <Widget>[
          Expanded(child: labels),
          SizedBox(width: tokens.spacing.md),
          if (trailing != null) trailing!,
        ],
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: metrics.interactiveHeight(tokens.controlSize.rowMinHeight),
      ),
      child: Align(
        alignment: Alignment.center,
        widthFactor: 1.0,
        child: content,
      ),
    );
  }
}

/// A row showing a label and a value, mirroring Swift's `EDSValueRow`.
class EdsValueRow extends StatelessWidget {
  const EdsValueRow(this.title, {super.key, required this.value, this.tone});

  final String title;
  final String value;

  /// Optional color override for the value text.
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final metrics = EdsResolvedMetrics.resolve(
      tokens: tokens,
      profile: context.edsInteractionProfile,
      horizontalSizeClass: context.edsSizeClass,
    );

    final titleText = Text(
      title,
      style: tokens.typography
          .edsTextStyle(EdsFontRole.body)
          .copyWith(color: scheme.textSecondary),
    );
    final valueText = Text(
      value,
      style: tokens.typography
          .edsTextStyle(EdsFontRole.bodyStrong)
          .copyWith(color: tone ?? scheme.textPrimary),
    );

    final Widget content;
    if (context.edsIsAccessibilityTextSize) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tokens.spacing.xxs,
        children: <Widget>[titleText, valueText],
      );
    } else {
      content = Row(
        children: <Widget>[
          Expanded(child: titleText),
          valueText,
        ],
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: metrics.interactiveHeight(28)),
      child: Align(
        alignment: Alignment.center,
        widthFactor: 1.0,
        child: content,
      ),
    );
  }
}

/// An inline form field: a label above arbitrary content, mirroring
/// Swift's `EDSInlineField`.
class EdsInlineField extends StatelessWidget {
  const EdsInlineField(this.label, {super.key, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.spacing.xs,
      children: <Widget>[
        EdsLabelText(label),
        child,
      ],
    );
  }
}

/// A row with a leading icon block, title, subtitle and trailing content,
/// mirroring Swift's `EDSMultilineSubtitleRow`.
///
/// Deviation from Swift: the macOS `NSImage` / iOS SF Symbol initializers
/// collapse into one constructor — [icon] is a custom widget rendered at
/// 28x28, while [systemIcon] and [iconColor] must both be provided to
/// render the tinted icon block.
class EdsMultilineSubtitleRow extends StatelessWidget {
  const EdsMultilineSubtitleRow({
    super.key,
    this.icon,
    this.systemIcon,
    this.iconColor,
    this.title,
    this.subtitle,
    this.child,
  });

  /// Custom icon widget rendered at 28x28, mirroring Swift's
  /// `init(icon:title:subtitle:content:)`.
  final Widget? icon;

  /// Material icon data. Rendered inside the [iconColor] tinted block only
  /// when [iconColor] is also given.
  final IconData? systemIcon;

  final Color? iconColor;
  final String? title;
  final String? subtitle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;

    final Widget? iconView;
    if (icon != null) {
      iconView = SizedBox(
        width: 28,
        height: 28,
        child: FittedBox(fit: BoxFit.fill, child: icon),
      );
    } else if (systemIcon != null && iconColor != null) {
      iconView = Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Icon(systemIcon, size: 14, color: Colors.white),
        ),
      );
    } else {
      iconView = null;
    }

    final titleText = title;
    final subtitleText = subtitle;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (iconView != null) iconView,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                if (titleText != null)
                  Text(
                    titleText,
                    style: tokens.typography
                        .edsTextStyle(EdsFontRole.body)
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
          if (child != null) child!,
        ],
      ),
    );
  }
}
