import 'package:flutter/widgets.dart';

import '../theme/eds_theme_scope.dart';
import '../tokens/eds_design_tokens.dart';

/// The semantic font roles, mirroring Swift's `EDSFontRole`.
enum EdsFontRole {
  /// Page hero headline.
  hero,

  /// Large page title.
  pageTitle,

  /// Section heading.
  sectionTitle,

  /// 15pt body copy.
  body15,

  /// 15pt emphasized body copy.
  body15Strong,

  /// 13pt body copy.
  body,

  /// 13pt emphasized body copy.
  bodyStrong,

  /// Small secondary copy.
  caption,

  /// Small emphasized copy.
  captionStrong,

  /// Small monospaced copy for paths and code.
  monoCaption,
}

extension EdsTypographyTokensFontX on EdsTypographyTokens {
  /// Resolves the token-based [TextStyle] for [role].
  ///
  /// This is the Flutter counterpart of the Swift package's
  /// `EDSTypographyTokens.hero` / `.pageTitle` / … font properties combined
  /// with `EDSFontRole`. Swift additionally resolves fonts through Dynamic
  /// Type text styles; Flutter's `MediaQuery.textScaler` provides that
  /// scaling, so the deterministic token sizes are used directly.
  ///
  /// The Swift `.rounded` design used by [EdsFontRole.hero] and
  /// [EdsFontRole.pageTitle] has no Flutter system equivalent and is
  /// approximated by the default typeface.
  TextStyle edsTextStyle(EdsFontRole role) {
    final regularFallback = fontFamilyFallback;
    final monoFallback = monoFontFamilyFallback ??
        const <String>['monospace', 'Menlo', 'DejaVu Sans Mono', 'Courier New'];
    return switch (role) {
      EdsFontRole.hero => TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: regularFallback,
          fontSize: heroSize,
          fontWeight: _edsFontWeight(heroWeight),
        ),
      EdsFontRole.pageTitle => TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: regularFallback,
          fontSize: pageTitleSize,
          fontWeight: _edsFontWeight(pageTitleWeight),
        ),
      EdsFontRole.sectionTitle => TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: regularFallback,
          fontSize: sectionTitleSize,
          fontWeight: _edsFontWeight(sectionTitleWeight),
        ),
      EdsFontRole.body15 => TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: regularFallback,
          fontSize: body15Size,
          fontWeight: _edsFontWeight(body15Weight),
        ),
      EdsFontRole.body15Strong => TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: regularFallback,
          fontSize: body15StrongSize,
          fontWeight: _edsFontWeight(body15StrongWeight),
        ),
      EdsFontRole.body => TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: regularFallback,
          fontSize: bodySize,
          fontWeight: _edsFontWeight(bodyWeight),
        ),
      EdsFontRole.bodyStrong => TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: regularFallback,
          fontSize: bodyStrongSize,
          fontWeight: _edsFontWeight(bodyStrongWeight),
        ),
      EdsFontRole.caption => TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: regularFallback,
          fontSize: captionSize,
          fontWeight: _edsFontWeight(captionWeight),
        ),
      EdsFontRole.captionStrong => TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: regularFallback,
          fontSize: captionStrongSize,
          fontWeight: _edsFontWeight(captionStrongWeight),
        ),
      EdsFontRole.monoCaption => TextStyle(
          fontFamily: monoFontFamily,
          fontSize: monoCaptionSize,
          fontWeight: _edsFontWeight(monoCaptionWeight),
          fontFamilyFallback: monoFallback,
        ),
    };
  }

  /// The hero font, mirroring Swift's `EDSTypographyTokens.hero`.
  TextStyle get hero => edsTextStyle(EdsFontRole.hero);

  /// The page-title font, mirroring Swift's `EDSTypographyTokens.pageTitle`.
  TextStyle get pageTitle => edsTextStyle(EdsFontRole.pageTitle);

  /// The section-title font.
  TextStyle get sectionTitle => edsTextStyle(EdsFontRole.sectionTitle);

  /// The 15pt body font.
  TextStyle get body15 => edsTextStyle(EdsFontRole.body15);

  /// The 15pt emphasized body font.
  TextStyle get body15Strong => edsTextStyle(EdsFontRole.body15Strong);

  /// The body font.
  TextStyle get body => edsTextStyle(EdsFontRole.body);

  /// The emphasized body font.
  TextStyle get bodyStrong => edsTextStyle(EdsFontRole.bodyStrong);

  /// The caption font.
  TextStyle get caption => edsTextStyle(EdsFontRole.caption);

  /// The emphasized caption font.
  TextStyle get captionStrong => edsTextStyle(EdsFontRole.captionStrong);

  /// The monospaced caption font.
  TextStyle get monoCaption => edsTextStyle(EdsFontRole.monoCaption);
}

FontWeight _edsFontWeight(String value) {
  return switch (value) {
    'bold' => FontWeight.w700,
    'semibold' => FontWeight.w600,
    'medium' => FontWeight.w500,
    'light' => FontWeight.w300,
    'thin' => FontWeight.w200,
    _ => FontWeight.w400,
  };
}

class _EdsFont extends StatelessWidget {
  const _EdsFont({required this.role, this.tokens, required this.child});

  final EdsFontRole role;
  final EdsTypographyTokens? tokens;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final effective = tokens ?? context.edsTokens.typography;
    return DefaultTextStyle.merge(
      style: effective.edsTextStyle(role),
      child: child,
    );
  }
}

extension EdsFontWidgetX on Widget {
  /// Applies the font role to this subtree, mirroring Swift's
  /// `edsFont(_:tokens:)`. Without [tokens] the scoped EasyDesignSystem theme
  /// is used, mirroring Swift's single-argument `edsFont(_:)`.
  Widget edsFont(EdsFontRole role, {EdsTypographyTokens? tokens}) {
    return _EdsFont(role: role, tokens: tokens, child: this);
  }
}
