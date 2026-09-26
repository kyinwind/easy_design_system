import 'package:flutter/material.dart';

import '../adaptive/eds_size_class.dart';
import '../primitives/eds_font.dart';
import '../theme/eds_theme_scope.dart';
import '../tokens/eds_color_scheme.dart';
import 'eds_button.dart';
import 'eds_group.dart';
import 'eds_sidebar.dart';

/// An empty-state placeholder, mirroring Swift's `EDSEmptyState`.
///
/// Deviation from Swift: `systemImage` accepts a Material [IconData]
/// instead of an SF Symbol name.
class EdsEmptyState extends StatelessWidget {
  const EdsEmptyState({
    super.key,
    this.systemImage = Icons.inbox,
    required this.title,
    this.message,
    this.actionTitle,
    this.actionSystemImage,
    this.action,
  });

  final IconData systemImage;
  final String title;
  final String? message;
  final String? actionTitle;
  final IconData? actionSystemImage;

  /// Triggered by the action button. The button renders only when both
  /// [actionTitle] and [action] are given.
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return _EdsStateContent(
      systemImage: systemImage,
      iconColor: context.edsScheme.textTertiary,
      title: title,
      message: message,
      actionTitle: actionTitle,
      actionSystemImage: actionSystemImage,
      actionRole: EdsButtonRole.soft,
      action: action,
    );
  }
}

/// An error-state placeholder with a retry affordance, mirroring Swift's
/// `EDSErrorState`.
class EdsErrorState extends StatelessWidget {
  const EdsErrorState({
    super.key,
    this.systemImage = Icons.warning,
    required this.title,
    this.message,
    this.actionTitle,
    this.actionSystemImage = Icons.refresh,
    this.action,
  });

  final IconData systemImage;
  final String title;
  final String? message;
  final String? actionTitle;
  final IconData? actionSystemImage;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return _EdsStateContent(
      systemImage: systemImage,
      iconColor: context.edsTokens.colors.danger,
      title: title,
      message: message,
      actionTitle: actionTitle,
      actionSystemImage: actionSystemImage,
      actionRole: EdsButtonRole.secondary,
      action: action,
    );
  }
}

/// A loading-state placeholder, mirroring Swift's `EDSLoadingState`.
class EdsLoadingState extends StatelessWidget {
  const EdsLoadingState({super.key, this.title = '正在处理', this.message});

  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final messageText = message;
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: tokens.spacing.md,
          children: <Widget>[
            CircularProgressIndicator(color: tokens.colors.primary),
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: tokens.spacing.xs,
              children: <Widget>[
                Text(
                  title,
                  style: tokens.typography
                      .edsTextStyle(EdsFontRole.bodyStrong)
                      .copyWith(color: scheme.textPrimary),
                ),
                if (messageText != null)
                  Text(
                    messageText,
                    textAlign: TextAlign.center,
                    style: tokens.typography
                        .edsTextStyle(EdsFontRole.caption)
                        .copyWith(color: scheme.textSecondary),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A task progress panel with a linear progress bar, mirroring Swift's
/// `EDSProgressPanel`.
class EdsProgressPanel extends StatelessWidget {
  const EdsProgressPanel(
    this.title, {
    super.key,
    this.subtitle,
    required this.fractionCompleted,
    this.statusText,
    this.systemImage = Icons.arrow_circle_down,
    this.actionTitle,
    this.actionSystemImage,
    this.action,
  });

  final String title;
  final String? subtitle;

  /// Completion fraction, clamped to 0.0–1.0.
  final double fractionCompleted;

  final String? statusText;
  final IconData systemImage;
  final String? actionTitle;
  final IconData? actionSystemImage;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;

    final Widget? actionButton = actionTitle != null && action != null
        ? EdsButton(
            actionTitle!,
            role: EdsButtonRole.soft,
            systemImage: actionSystemImage,
            action: action,
          )
        : null;

    final Widget header;
    if (context.edsIsAccessibilityTextSize) {
      header = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tokens.spacing.sm,
        children: <Widget>[
          _headerText(context),
          if (actionButton != null) actionButton,
        ],
      );
    } else {
      header = Row(
        spacing: tokens.spacing.md,
        children: <Widget>[
          Expanded(child: _headerText(context)),
          if (actionButton != null) actionButton,
        ],
      );
    }

    final statusTextValue = statusText;
    return EdsGroup(
      null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tokens.spacing.md,
        children: <Widget>[
          EdsSidebarIcon(
            icon: systemImage,
            tint: tokens.colors.primary,
            size: EdsSidebarIconSize.medium,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: tokens.spacing.sm,
              children: <Widget>[
                header,
                LinearProgressIndicator(
                  value: clampedFraction,
                  color: tokens.colors.primary,
                  backgroundColor: scheme.subtleFill,
                  minHeight: 4,
                ),
                if (statusTextValue != null)
                  Text(
                    statusTextValue,
                    style: tokens.typography
                        .edsTextStyle(EdsFontRole.caption)
                        .copyWith(color: scheme.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerText(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final subtitleText = subtitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.spacing.xxs,
      children: <Widget>[
        Text(
          title,
          style: tokens.typography
              .edsTextStyle(EdsFontRole.bodyStrong)
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
    );
  }

  double get clampedFraction => fractionCompleted.clamp(0.0, 1.0);
}

class _EdsStateContent extends StatelessWidget {
  const _EdsStateContent({
    required this.systemImage,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.actionTitle,
    required this.actionSystemImage,
    required this.actionRole,
    required this.action,
  });

  final IconData systemImage;
  final Color iconColor;
  final String title;
  final String? message;
  final String? actionTitle;
  final IconData? actionSystemImage;
  final EdsButtonRole actionRole;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final messageText = message;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: tokens.spacing.lg,
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(systemImage, size: 34, color: iconColor),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: tokens.spacing.xs,
              children: <Widget>[
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: tokens.typography
                      .edsTextStyle(EdsFontRole.sectionTitle)
                      .copyWith(color: scheme.textPrimary),
                ),
                if (messageText != null)
                  Text(
                    messageText,
                    textAlign: TextAlign.center,
                    style: tokens.typography
                        .edsTextStyle(EdsFontRole.caption)
                        .copyWith(color: scheme.textSecondary),
                  ),
              ],
            ),
            if (actionTitle != null && action != null)
              EdsButton(
                actionTitle!,
                role: actionRole,
                systemImage: actionSystemImage,
                action: action,
              ),
          ],
        ),
      ),
    );
  }
}
