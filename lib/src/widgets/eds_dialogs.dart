import 'package:flutter/material.dart';

import '../primitives/eds_font.dart';
import '../theme/eds_theme_scope.dart';
import '../tokens/eds_color_scheme.dart';
import 'eds_button.dart';

/// Token-driven alert dialog surface.
///
/// This widget owns only dialog presentation. Showing/dismissing the dialog
/// remains the host application's responsibility through Flutter's
/// [showDialog] and [Navigator].
class EdsAlertDialog extends StatelessWidget {
  const EdsAlertDialog({
    super.key,
    this.title,
    required this.content,
    this.actions = const <Widget>[],
    this.icon,
  });

  final String? title;
  final Widget content;
  final List<Widget> actions;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final titleText = title;

    return AlertDialog(
      backgroundColor: scheme.cardBackground,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        side: BorderSide(
          color: scheme.border,
          width: tokens.stroke.hairline,
        ),
      ),
      icon: icon,
      title: titleText == null
          ? null
          : Text(
              titleText,
              style: tokens.typography
                  .edsTextStyle(EdsFontRole.pageTitle)
                  .copyWith(color: scheme.textPrimary),
            ),
      content: DefaultTextStyle.merge(
        style: tokens.typography
            .edsTextStyle(EdsFontRole.body)
            .copyWith(color: scheme.textSecondary),
        child: content,
      ),
      actions: actions,
      actionsPadding: EdgeInsets.fromLTRB(
        tokens.spacing.lg,
        0,
        tokens.spacing.lg,
        tokens.spacing.lg,
      ),
      contentPadding: EdgeInsets.fromLTRB(
        tokens.spacing.lg,
        tokens.spacing.md,
        tokens.spacing.lg,
        tokens.spacing.lg,
      ),
      titlePadding: EdgeInsets.fromLTRB(
        tokens.spacing.lg,
        tokens.spacing.lg,
        tokens.spacing.lg,
        0,
      ),
    );
  }
}

/// Common two-action confirmation dialog.
///
/// The callbacks do not automatically pop the route so hosts can perform
/// asynchronous validation before deciding when to dismiss.
class EdsConfirmDialog extends StatelessWidget {
  const EdsConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmTitle,
    this.cancelTitle = '取消',
    this.isDestructive = false,
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String message;
  final String confirmTitle;
  final String cancelTitle;
  final bool isDestructive;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return EdsAlertDialog(
      title: title,
      content: Text(message),
      actions: <Widget>[
        EdsButton(
          cancelTitle,
          role: EdsButtonRole.normal,
          action: onCancel,
        ),
        EdsButton(
          confirmTitle,
          role: isDestructive
              ? EdsButtonRole.danger
              : EdsButtonRole.primary,
          action: onConfirm,
        ),
      ],
    );
  }
}
