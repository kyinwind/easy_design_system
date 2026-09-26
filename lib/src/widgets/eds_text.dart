import 'package:flutter/material.dart';

import '../primitives/eds_font.dart';
import '../theme/eds_theme_scope.dart';
import '../tokens/eds_color_scheme.dart';

/// The large page title used at the top of a page, mirroring Swift's
/// `EDSPageTitle`.
class EdsPageTitle extends StatelessWidget {
  const EdsPageTitle(this.title, {super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: tokens.typography
              .edsTextStyle(EdsFontRole.pageTitle)
              .copyWith(color: scheme.textPrimary),
        ),
        if (subtitle != null) ...<Widget>[
          SizedBox(height: tokens.spacing.xs),
          Text(
            subtitle!,
            style: tokens.typography
                .edsTextStyle(EdsFontRole.body)
                .copyWith(color: scheme.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// A section title for in-page blocks, mirroring Swift's `EDSSectionTitle`.
///
/// The String / Text initializers of the Swift version map to this
/// constructor and the [EdsSectionTitle.text] factory.
class EdsSectionTitle extends StatelessWidget {
  const EdsSectionTitle(String title, {super.key, String? subtitle})
    : _titleString = title,
      _titleText = null,
      _subtitleString = subtitle,
      _subtitleText = null;

  /// Builds a section title from pre-built [Text] widgets, mirroring
  /// Swift's `init(title: Text, subtitle: Text?)`.
  const EdsSectionTitle.text(Text title, {super.key, Text? subtitle})
    : _titleString = null,
      _titleText = title,
      _subtitleString = null,
      _subtitleText = subtitle;

  final String? _titleString;
  final Text? _titleText;
  final String? _subtitleString;
  final Text? _subtitleText;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final title = _titleText == null
        ? Text(
            _titleString!,
            style: tokens.typography
                .edsTextStyle(EdsFontRole.sectionTitle)
                .copyWith(color: scheme.textPrimary),
          )
        : DefaultTextStyle.merge(
            style: tokens.typography
                .edsTextStyle(EdsFontRole.sectionTitle)
                .copyWith(color: scheme.textPrimary),
            child: _titleText,
          );

    final Widget? subtitle = _buildSubtitle(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        title,
        if (subtitle != null) ...<Widget>[
          SizedBox(height: tokens.spacing.xxs),
          subtitle,
        ],
      ],
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final style = tokens.typography
        .edsTextStyle(EdsFontRole.caption)
        .copyWith(color: scheme.textSecondary);
    if (_subtitleText != null) {
      return DefaultTextStyle.merge(style: style, child: _subtitleText);
    }
    if (_subtitleString != null) {
      return SizedBox(
        width: double.infinity,
        child: Text(_subtitleString, style: style, textAlign: TextAlign.start),
      );
    }
    return null;
  }
}

/// A form label text, mirroring Swift's `EDSLabelText`.
class EdsLabelText extends StatelessWidget {
  const EdsLabelText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    return Text(
      text,
      style: tokens.typography
          .edsTextStyle(EdsFontRole.captionStrong)
          .copyWith(color: context.edsScheme.textSecondary),
    );
  }
}

/// A caption text, mirroring Swift's `EDSCaptionText`.
class EdsCaptionText extends StatelessWidget {
  const EdsCaptionText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    return Text(
      text,
      style: tokens.typography
          .edsTextStyle(EdsFontRole.caption)
          .copyWith(color: context.edsScheme.textSecondary),
    );
  }
}

/// A monospace text for paths and code, mirroring Swift's `EDSMonoText`.
///
/// Deviation from Swift: SwiftUI's middle truncation mode has no Flutter
/// equivalent, so this widget falls back to end ellipsis.
class EdsMonoText extends StatelessWidget {
  const EdsMonoText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: tokens.typography
          .edsTextStyle(EdsFontRole.monoCaption)
          .copyWith(color: context.edsScheme.textSecondary),
    );
  }
}
