import 'package:flutter/painting.dart';

import 'eds_color_hex.dart';

/// All configurable colors.
///
/// The Swift source package defaults to dynamic system colors (`.blue`,
/// `.green`, …). Flutter has no dynamic system palette, so the deterministic
/// EDS default palette is used instead — identical to `EDSPresetTheme.default`
/// and `EDSDefaultTheme.json`, which keeps `EdsDesignTokens()` == the default
/// preset and the bundled default theme file.
///
/// JSON coding goes through hex strings with keys identical to the Swift
/// `CodingKeys` (`primary`, `accent`, …).
class EdsColorTokens {
  const EdsColorTokens({
    this.primary = const Color(0xFF3185FF),
    this.accent = const Color(0xFF3185FF),
    this.success = const Color(0xFF27B15A),
    this.warning = const Color(0xFFF9B135),
    this.danger = const Color(0xFFE54444),
  });

  final Color primary;
  final Color accent;
  final Color success;
  final Color warning;
  final Color danger;

  // Derived colors (brightness independent).

  /// 12% alpha version of [primary].
  Color get primarySoft => primary.withValues(alpha: 0.12);

  /// 12% alpha version of [accent].
  ///
  /// Alias for [primarySoft] since 0.3.1: the package no longer reads [accent]
  /// internally. New code should use [primarySoft].
  Color get accentSoft => primarySoft;

  /// 12% alpha version of [success].
  Color get successSoft => success.withValues(alpha: 0.12);

  /// 12% alpha version of [warning].
  Color get warningSoft => warning.withValues(alpha: 0.12);

  /// 12% alpha version of [danger].
  Color get dangerSoft => danger.withValues(alpha: 0.12);

  EdsColorTokens copyWith({
    Color? primary,
    Color? accent,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return EdsColorTokens(
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  factory EdsColorTokens.fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return const EdsColorTokens();
    }
    const defaults = EdsColorTokens();
    return EdsColorTokens(
      primary: _readColor(json, 'primary', defaults.primary),
      accent: _readColor(json, 'accent', defaults.accent),
      success: _readColor(json, 'success', defaults.success),
      warning: _readColor(json, 'warning', defaults.warning),
      danger: _readColor(json, 'danger', defaults.danger),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'primary': EdsColorHex.toHex(primary),
      'accent': EdsColorHex.toHex(accent),
      'success': EdsColorHex.toHex(success),
      'warning': EdsColorHex.toHex(warning),
      'danger': EdsColorHex.toHex(danger),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is EdsColorTokens &&
        other.primary == primary &&
        other.accent == accent &&
        other.success == success &&
        other.warning == warning &&
        other.danger == danger;
  }

  @override
  int get hashCode => Object.hash(primary, accent, success, warning, danger);
}

/// The 8-step spacing scale.
class EdsSpacingTokens {
  const EdsSpacingTokens({
    this.xxs = 4,
    this.xs = 8,
    this.sm = 12,
    this.md = 16,
    this.lg = 20,
    this.xl = 24,
    this.xxl = 32,
    this.xxxl = 40,
  });

  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;

  EdsSpacingTokens copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
  }) {
    return EdsSpacingTokens(
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
    );
  }

  factory EdsSpacingTokens.fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return const EdsSpacingTokens();
    }
    const defaults = EdsSpacingTokens();
    return EdsSpacingTokens(
      xxs: _readDouble(json, 'xxs', defaults.xxs),
      xs: _readDouble(json, 'xs', defaults.xs),
      sm: _readDouble(json, 'sm', defaults.sm),
      md: _readDouble(json, 'md', defaults.md),
      lg: _readDouble(json, 'lg', defaults.lg),
      xl: _readDouble(json, 'xl', defaults.xl),
      xxl: _readDouble(json, 'xxl', defaults.xxl),
      xxxl: _readDouble(json, 'xxxl', defaults.xxxl),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'xxs': _jsonNum(xxs),
      'xs': _jsonNum(xs),
      'sm': _jsonNum(sm),
      'md': _jsonNum(md),
      'lg': _jsonNum(lg),
      'xl': _jsonNum(xl),
      'xxl': _jsonNum(xxl),
      'xxxl': _jsonNum(xxxl),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is EdsSpacingTokens &&
        other.xxs == xxs &&
        other.xs == xs &&
        other.sm == sm &&
        other.md == md &&
        other.lg == lg &&
        other.xl == xl &&
        other.xxl == xxl &&
        other.xxxl == xxxl;
  }

  @override
  int get hashCode => Object.hash(xxs, xs, sm, md, lg, xl, xxl, xxxl);
}

/// Corner radii.
class EdsRadiusTokens {
  const EdsRadiusTokens({
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 24,
  });

  final double sm;
  final double md;
  final double lg;
  final double xl;

  EdsRadiusTokens copyWith({double? sm, double? md, double? lg, double? xl}) {
    return EdsRadiusTokens(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
    );
  }

  factory EdsRadiusTokens.fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return const EdsRadiusTokens();
    }
    const defaults = EdsRadiusTokens();
    return EdsRadiusTokens(
      sm: _readDouble(json, 'sm', defaults.sm),
      md: _readDouble(json, 'md', defaults.md),
      lg: _readDouble(json, 'lg', defaults.lg),
      xl: _readDouble(json, 'xl', defaults.xl),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'sm': _jsonNum(sm),
      'md': _jsonNum(md),
      'lg': _jsonNum(lg),
      'xl': _jsonNum(xl),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is EdsRadiusTokens &&
        other.sm == sm &&
        other.md == md &&
        other.lg == lg &&
        other.xl == xl;
  }

  @override
  int get hashCode => Object.hash(sm, md, lg, xl);
}

/// Numeric typography tokens. Fonts are produced at runtime by
/// `EdsTypographyFontX.edsTextStyle` (see `primitives/eds_font.dart`).
///
/// Keys match the Swift `CodingKeys` byte for byte (`heroSize`, `heroWeight`,
/// …).
class EdsTypographyTokens {
  const EdsTypographyTokens({
    this.fontFamily,
    this.fontFamilyFallback,
    this.monoFontFamily,
    this.monoFontFamilyFallback,
    this.heroSize = 30,
    this.heroWeight = 'bold',
    this.pageTitleSize = 17,
    this.pageTitleWeight = 'bold',
    this.sectionTitleSize = 15,
    this.sectionTitleWeight = 'semibold',
    this.body15Size = 15,
    this.body15Weight = 'regular',
    this.body15StrongSize = 15,
    this.body15StrongWeight = 'semibold',
    this.bodySize = 13,
    this.bodyWeight = 'regular',
    this.bodyStrongSize = 13,
    this.bodyStrongWeight = 'semibold',
    this.captionSize = 12,
    this.captionWeight = 'regular',
    this.captionStrongSize = 12,
    this.captionStrongWeight = 'semibold',
    this.monoCaptionSize = 11,
    this.monoCaptionWeight = 'regular',
  });

  /// Optional Flutter-specific UI font family. Null keeps the platform font.
  final String? fontFamily;

  /// Optional fallback families used by regular text roles.
  final List<String>? fontFamilyFallback;

  /// Optional font family used by [monoCaption].
  final String? monoFontFamily;

  /// Optional fallback families used by [monoCaption]. When null, the package
  /// built-in monospaced fallback list is used.
  final List<String>? monoFontFamilyFallback;

  final double heroSize;
  final String heroWeight;
  final double pageTitleSize;
  final String pageTitleWeight;
  final double sectionTitleSize;
  final String sectionTitleWeight;
  final double body15Size;
  final String body15Weight;
  final double body15StrongSize;
  final String body15StrongWeight;
  final double bodySize;
  final String bodyWeight;
  final double bodyStrongSize;
  final String bodyStrongWeight;
  final double captionSize;
  final String captionWeight;
  final double captionStrongSize;
  final String captionStrongWeight;
  final double monoCaptionSize;
  final String monoCaptionWeight;

  EdsTypographyTokens copyWith({
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? monoFontFamily,
    List<String>? monoFontFamilyFallback,
    double? heroSize,
    String? heroWeight,
    double? pageTitleSize,
    String? pageTitleWeight,
    double? sectionTitleSize,
    String? sectionTitleWeight,
    double? body15Size,
    String? body15Weight,
    double? body15StrongSize,
    String? body15StrongWeight,
    double? bodySize,
    String? bodyWeight,
    double? bodyStrongSize,
    String? bodyStrongWeight,
    double? captionSize,
    String? captionWeight,
    double? captionStrongSize,
    String? captionStrongWeight,
    double? monoCaptionSize,
    String? monoCaptionWeight,
  }) {
    return EdsTypographyTokens(
      fontFamily: fontFamily ?? this.fontFamily,
      fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
      monoFontFamily: monoFontFamily ?? this.monoFontFamily,
      monoFontFamilyFallback:
          monoFontFamilyFallback ?? this.monoFontFamilyFallback,
      heroSize: heroSize ?? this.heroSize,
      heroWeight: heroWeight ?? this.heroWeight,
      pageTitleSize: pageTitleSize ?? this.pageTitleSize,
      pageTitleWeight: pageTitleWeight ?? this.pageTitleWeight,
      sectionTitleSize: sectionTitleSize ?? this.sectionTitleSize,
      sectionTitleWeight: sectionTitleWeight ?? this.sectionTitleWeight,
      body15Size: body15Size ?? this.body15Size,
      body15Weight: body15Weight ?? this.body15Weight,
      body15StrongSize: body15StrongSize ?? this.body15StrongSize,
      body15StrongWeight: body15StrongWeight ?? this.body15StrongWeight,
      bodySize: bodySize ?? this.bodySize,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      bodyStrongSize: bodyStrongSize ?? this.bodyStrongSize,
      bodyStrongWeight: bodyStrongWeight ?? this.bodyStrongWeight,
      captionSize: captionSize ?? this.captionSize,
      captionWeight: captionWeight ?? this.captionWeight,
      captionStrongSize: captionStrongSize ?? this.captionStrongSize,
      captionStrongWeight: captionStrongWeight ?? this.captionStrongWeight,
      monoCaptionSize: monoCaptionSize ?? this.monoCaptionSize,
      monoCaptionWeight: monoCaptionWeight ?? this.monoCaptionWeight,
    );
  }

  factory EdsTypographyTokens.fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return const EdsTypographyTokens();
    }
    const defaults = EdsTypographyTokens();
    return EdsTypographyTokens(
      fontFamily: _readNullableString(json, 'fontFamily'),
      fontFamilyFallback: _readStringList(json, 'fontFamilyFallback'),
      monoFontFamily: _readNullableString(json, 'monoFontFamily'),
      monoFontFamilyFallback: _readStringList(json, 'monoFontFamilyFallback'),
      heroSize: _readDouble(json, 'heroSize', defaults.heroSize),
      heroWeight: _readString(json, 'heroWeight', defaults.heroWeight),
      pageTitleSize: _readDouble(json, 'pageTitleSize', defaults.pageTitleSize),
      pageTitleWeight:
          _readString(json, 'pageTitleWeight', defaults.pageTitleWeight),
      sectionTitleSize:
          _readDouble(json, 'sectionTitleSize', defaults.sectionTitleSize),
      sectionTitleWeight:
          _readString(json, 'sectionTitleWeight', defaults.sectionTitleWeight),
      body15Size: _readDouble(json, 'body15Size', defaults.body15Size),
      body15Weight: _readString(json, 'body15Weight', defaults.body15Weight),
      body15StrongSize:
          _readDouble(json, 'body15StrongSize', defaults.body15StrongSize),
      body15StrongWeight:
          _readString(json, 'body15StrongWeight', defaults.body15StrongWeight),
      bodySize: _readDouble(json, 'bodySize', defaults.bodySize),
      bodyWeight: _readString(json, 'bodyWeight', defaults.bodyWeight),
      bodyStrongSize:
          _readDouble(json, 'bodyStrongSize', defaults.bodyStrongSize),
      bodyStrongWeight:
          _readString(json, 'bodyStrongWeight', defaults.bodyStrongWeight),
      captionSize: _readDouble(json, 'captionSize', defaults.captionSize),
      captionWeight: _readString(json, 'captionWeight', defaults.captionWeight),
      captionStrongSize:
          _readDouble(json, 'captionStrongSize', defaults.captionStrongSize),
      captionStrongWeight: _readString(
          json, 'captionStrongWeight', defaults.captionStrongWeight),
      monoCaptionSize:
          _readDouble(json, 'monoCaptionSize', defaults.monoCaptionSize),
      monoCaptionWeight:
          _readString(json, 'monoCaptionWeight', defaults.monoCaptionWeight),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      if (fontFamily != null) 'fontFamily': fontFamily,
      if (fontFamilyFallback != null) 'fontFamilyFallback': fontFamilyFallback,
      if (monoFontFamily != null) 'monoFontFamily': monoFontFamily,
      if (monoFontFamilyFallback != null)
        'monoFontFamilyFallback': monoFontFamilyFallback,
      'heroSize': _jsonNum(heroSize),
      'heroWeight': heroWeight,
      'pageTitleSize': _jsonNum(pageTitleSize),
      'pageTitleWeight': pageTitleWeight,
      'sectionTitleSize': _jsonNum(sectionTitleSize),
      'sectionTitleWeight': sectionTitleWeight,
      'body15Size': _jsonNum(body15Size),
      'body15Weight': body15Weight,
      'body15StrongSize': _jsonNum(body15StrongSize),
      'body15StrongWeight': body15StrongWeight,
      'bodySize': _jsonNum(bodySize),
      'bodyWeight': bodyWeight,
      'bodyStrongSize': _jsonNum(bodyStrongSize),
      'bodyStrongWeight': bodyStrongWeight,
      'captionSize': _jsonNum(captionSize),
      'captionWeight': captionWeight,
      'captionStrongSize': _jsonNum(captionStrongSize),
      'captionStrongWeight': captionStrongWeight,
      'monoCaptionSize': _jsonNum(monoCaptionSize),
      'monoCaptionWeight': monoCaptionWeight,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is EdsTypographyTokens &&
        other.fontFamily == fontFamily &&
        _listEquals(other.fontFamilyFallback, fontFamilyFallback) &&
        other.monoFontFamily == monoFontFamily &&
        _listEquals(other.monoFontFamilyFallback, monoFontFamilyFallback) &&
        other.heroSize == heroSize &&
        other.heroWeight == heroWeight &&
        other.pageTitleSize == pageTitleSize &&
        other.pageTitleWeight == pageTitleWeight &&
        other.sectionTitleSize == sectionTitleSize &&
        other.sectionTitleWeight == sectionTitleWeight &&
        other.body15Size == body15Size &&
        other.body15Weight == body15Weight &&
        other.body15StrongSize == body15StrongSize &&
        other.body15StrongWeight == body15StrongWeight &&
        other.bodySize == bodySize &&
        other.bodyWeight == bodyWeight &&
        other.bodyStrongSize == bodyStrongSize &&
        other.bodyStrongWeight == bodyStrongWeight &&
        other.captionSize == captionSize &&
        other.captionWeight == captionWeight &&
        other.captionStrongSize == captionStrongSize &&
        other.captionStrongWeight == captionStrongWeight &&
        other.monoCaptionSize == monoCaptionSize &&
        other.monoCaptionWeight == monoCaptionWeight;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        heroSize,
        heroWeight,
        pageTitleSize,
        pageTitleWeight,
        sectionTitleSize,
        sectionTitleWeight,
        body15Size,
        body15Weight,
        body15StrongSize,
        body15StrongWeight,
        bodySize,
        bodyWeight,
        bodyStrongSize,
        bodyStrongWeight,
        captionSize,
        captionWeight,
        captionStrongSize,
        captionStrongWeight,
        monoCaptionSize,
        monoCaptionWeight,
      fontFamily,
      ...?fontFamilyFallback,
      monoFontFamily,
      ...?monoFontFamilyFallback,
      ]);
}

/// Visual control sizes.
class EdsControlSizeTokens {
  const EdsControlSizeTokens({
    this.buttonHeight = 34,
    this.fieldHeight = 34,
    this.rowMinHeight = 52,
  });

  final double buttonHeight;
  final double fieldHeight;
  final double rowMinHeight;

  EdsControlSizeTokens copyWith({
    double? buttonHeight,
    double? fieldHeight,
    double? rowMinHeight,
  }) {
    return EdsControlSizeTokens(
      buttonHeight: buttonHeight ?? this.buttonHeight,
      fieldHeight: fieldHeight ?? this.fieldHeight,
      rowMinHeight: rowMinHeight ?? this.rowMinHeight,
    );
  }

  factory EdsControlSizeTokens.fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return const EdsControlSizeTokens();
    }
    const defaults = EdsControlSizeTokens();
    return EdsControlSizeTokens(
      buttonHeight: _readDouble(json, 'buttonHeight', defaults.buttonHeight),
      fieldHeight: _readDouble(json, 'fieldHeight', defaults.fieldHeight),
      rowMinHeight: _readDouble(json, 'rowMinHeight', defaults.rowMinHeight),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'buttonHeight': _jsonNum(buttonHeight),
      'fieldHeight': _jsonNum(fieldHeight),
      'rowMinHeight': _jsonNum(rowMinHeight),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is EdsControlSizeTokens &&
        other.buttonHeight == buttonHeight &&
        other.fieldHeight == fieldHeight &&
        other.rowMinHeight == rowMinHeight;
  }

  @override
  int get hashCode => Object.hash(buttonHeight, fieldHeight, rowMinHeight);
}

/// Cross-platform adaptive layout values. Resolved per size class and
/// interaction profile by `EdsResolvedMetrics` (adaptive layer).
class EdsAdaptiveLayoutTokens {
  const EdsAdaptiveLayoutTokens({
    this.compactPagePadding = 16,
    this.regularPagePadding = 32,
    this.readableContentMaxWidth = 880,
    this.minimumTouchTarget = 44,
    this.minimumHybridTarget = 44,
  });

  final double compactPagePadding;
  final double regularPagePadding;
  final double readableContentMaxWidth;
  final double minimumTouchTarget;
  final double minimumHybridTarget;

  EdsAdaptiveLayoutTokens copyWith({
    double? compactPagePadding,
    double? regularPagePadding,
    double? readableContentMaxWidth,
    double? minimumTouchTarget,
    double? minimumHybridTarget,
  }) {
    return EdsAdaptiveLayoutTokens(
      compactPagePadding: compactPagePadding ?? this.compactPagePadding,
      regularPagePadding: regularPagePadding ?? this.regularPagePadding,
      readableContentMaxWidth:
          readableContentMaxWidth ?? this.readableContentMaxWidth,
      minimumTouchTarget: minimumTouchTarget ?? this.minimumTouchTarget,
      minimumHybridTarget: minimumHybridTarget ?? this.minimumHybridTarget,
    );
  }

  factory EdsAdaptiveLayoutTokens.fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return const EdsAdaptiveLayoutTokens();
    }
    const defaults = EdsAdaptiveLayoutTokens();
    return EdsAdaptiveLayoutTokens(
      compactPagePadding:
          _readDouble(json, 'compactPagePadding', defaults.compactPagePadding),
      regularPagePadding:
          _readDouble(json, 'regularPagePadding', defaults.regularPagePadding),
      readableContentMaxWidth: _readDouble(
          json, 'readableContentMaxWidth', defaults.readableContentMaxWidth),
      minimumTouchTarget:
          _readDouble(json, 'minimumTouchTarget', defaults.minimumTouchTarget),
      minimumHybridTarget: _readDouble(
          json, 'minimumHybridTarget', defaults.minimumHybridTarget),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'compactPagePadding': _jsonNum(compactPagePadding),
      'regularPagePadding': _jsonNum(regularPagePadding),
      'readableContentMaxWidth': _jsonNum(readableContentMaxWidth),
      'minimumTouchTarget': _jsonNum(minimumTouchTarget),
      'minimumHybridTarget': _jsonNum(minimumHybridTarget),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is EdsAdaptiveLayoutTokens &&
        other.compactPagePadding == compactPagePadding &&
        other.regularPagePadding == regularPagePadding &&
        other.readableContentMaxWidth == readableContentMaxWidth &&
        other.minimumTouchTarget == minimumTouchTarget &&
        other.minimumHybridTarget == minimumHybridTarget;
  }

  @override
  int get hashCode => Object.hash(
        compactPagePadding,
        regularPagePadding,
        readableContentMaxWidth,
        minimumTouchTarget,
        minimumHybridTarget,
      );
}

/// The hero panel gradient. Direction: top-leading → bottom-trailing.
class EdsHeroGradient {
  const EdsHeroGradient({
    this.startColor = const Color(0xFF3185FF),
    this.endColor = const Color(0xFF0A6BFF),
  });

  final Color startColor;
  final Color endColor;

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[startColor, endColor],
      );

  EdsHeroGradient copyWith({Color? startColor, Color? endColor}) {
    return EdsHeroGradient(
      startColor: startColor ?? this.startColor,
      endColor: endColor ?? this.endColor,
    );
  }

  factory EdsHeroGradient.fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return const EdsHeroGradient();
    }
    const defaults = EdsHeroGradient();
    return EdsHeroGradient(
      startColor: _readColor(json, 'startColor', defaults.startColor),
      endColor: _readColor(json, 'endColor', defaults.endColor),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'startColor': EdsColorHex.toHex(startColor),
      'endColor': EdsColorHex.toHex(endColor),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is EdsHeroGradient &&
        other.startColor == startColor &&
        other.endColor == endColor;
  }

  @override
  int get hashCode => Object.hash(startColor, endColor);
}

/// Stroke widths.
class EdsStrokeTokens {
  const EdsStrokeTokens({this.hairline = 1});

  final double hairline;

  EdsStrokeTokens copyWith({double? hairline}) {
    return EdsStrokeTokens(hairline: hairline ?? this.hairline);
  }

  factory EdsStrokeTokens.fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return const EdsStrokeTokens();
    }
    return EdsStrokeTokens(
      hairline: _readDouble(json, 'hairline', const EdsStrokeTokens().hairline),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{'hairline': _jsonNum(hairline)};
  }

  @override
  bool operator ==(Object other) =>
      other is EdsStrokeTokens && other.hairline == hairline;

  @override
  int get hashCode => hairline.hashCode;
}

/// Shadow parameters. [color] stays a hex string (like the Swift source
/// package) so the JSON schema is identical on both sides.
class EdsShadowTokens {
  const EdsShadowTokens({
    this.color = '#000000',
    this.opacity = 0.06,
    this.radius = 18,
    this.x = 0,
    this.y = 10,
  });

  /// Hex string, e.g. `#000000`.
  final String color;

  /// Opacity in 0.0 – 1.0.
  final double opacity;

  /// Blur radius.
  final double radius;

  /// Horizontal offset.
  final double x;

  /// Vertical offset.
  final double y;

  /// The shadow color with [opacity] applied, ready for `BoxShadow`.
  Color get shadowColor =>
      EdsColorHex.parseRgb(color).withValues(alpha: opacity);

  EdsShadowTokens copyWith({
    String? color,
    double? opacity,
    double? radius,
    double? x,
    double? y,
  }) {
    return EdsShadowTokens(
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      radius: radius ?? this.radius,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  factory EdsShadowTokens.fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return const EdsShadowTokens();
    }
    const defaults = EdsShadowTokens();
    return EdsShadowTokens(
      color: _readString(json, 'color', defaults.color),
      opacity: _readDouble(json, 'opacity', defaults.opacity),
      radius: _readDouble(json, 'radius', defaults.radius),
      x: _readDouble(json, 'x', defaults.x),
      y: _readDouble(json, 'y', defaults.y),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'color': color,
      'opacity': _jsonNum(opacity),
      'radius': _jsonNum(radius),
      'x': _jsonNum(x),
      'y': _jsonNum(y),
    };
  }

  /// Default card shadow: faint and wide.
  static const EdsShadowTokens card = EdsShadowTokens();

  /// Lighter shadow: fainter and smaller.
  static const EdsShadowTokens subtle = EdsShadowTokens(
    opacity: 0.04,
    radius: 8,
    y: 2,
  );

  /// Emphasized shadow for floating layers.
  static const EdsShadowTokens prominent = EdsShadowTokens(
    opacity: 0.15,
    radius: 24,
    y: 16,
  );

  @override
  bool operator ==(Object other) {
    return other is EdsShadowTokens &&
        other.color == color &&
        other.opacity == opacity &&
        other.radius == radius &&
        other.x == x &&
        other.y == y;
  }

  @override
  int get hashCode => Object.hash(color, opacity, radius, x, y);
}

/// The complete design token set.
///
/// JSON keys match the Swift `CodingKeys` byte for byte. Missing fields (or
/// whole groups) fall back to defaults, mirroring Swift's
/// `decodeIfPresent ?? default` behavior; present-but-wrongly-typed fields
/// throw a [FormatException] (Swift throws a `DecodingError`).
class EdsDesignTokens {
  const EdsDesignTokens({
    this.colors = const EdsColorTokens(),
    this.spacing = const EdsSpacingTokens(),
    this.radius = const EdsRadiusTokens(),
    this.typography = const EdsTypographyTokens(),
    this.controlSize = const EdsControlSizeTokens(),
    this.adaptiveLayout = const EdsAdaptiveLayoutTokens(),
    this.heroGradient = const EdsHeroGradient(),
    this.stroke = const EdsStrokeTokens(),
    this.shadow = const EdsShadowTokens(),
  });

  final EdsColorTokens colors;
  final EdsSpacingTokens spacing;
  final EdsRadiusTokens radius;
  final EdsTypographyTokens typography;
  final EdsControlSizeTokens controlSize;
  final EdsAdaptiveLayoutTokens adaptiveLayout;
  final EdsHeroGradient heroGradient;
  final EdsStrokeTokens stroke;
  final EdsShadowTokens shadow;

  EdsDesignTokens copyWith({
    EdsColorTokens? colors,
    EdsSpacingTokens? spacing,
    EdsRadiusTokens? radius,
    EdsTypographyTokens? typography,
    EdsControlSizeTokens? controlSize,
    EdsAdaptiveLayoutTokens? adaptiveLayout,
    EdsHeroGradient? heroGradient,
    EdsStrokeTokens? stroke,
    EdsShadowTokens? shadow,
  }) {
    return EdsDesignTokens(
      colors: colors ?? this.colors,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      typography: typography ?? this.typography,
      controlSize: controlSize ?? this.controlSize,
      adaptiveLayout: adaptiveLayout ?? this.adaptiveLayout,
      heroGradient: heroGradient ?? this.heroGradient,
      stroke: stroke ?? this.stroke,
      shadow: shadow ?? this.shadow,
    );
  }

  factory EdsDesignTokens.fromJson(Map<String, Object?> json) {
    return EdsDesignTokens(
      colors: EdsColorTokens.fromJson(_readGroup(json, 'colors')),
      spacing: EdsSpacingTokens.fromJson(_readGroup(json, 'spacing')),
      radius: EdsRadiusTokens.fromJson(_readGroup(json, 'radius')),
      typography: EdsTypographyTokens.fromJson(_readGroup(json, 'typography')),
      controlSize:
          EdsControlSizeTokens.fromJson(_readGroup(json, 'controlSize')),
      adaptiveLayout:
          EdsAdaptiveLayoutTokens.fromJson(_readGroup(json, 'adaptiveLayout')),
      heroGradient: EdsHeroGradient.fromJson(_readGroup(json, 'heroGradient')),
      stroke: EdsStrokeTokens.fromJson(_readGroup(json, 'stroke')),
      shadow: EdsShadowTokens.fromJson(_readGroup(json, 'shadow')),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'colors': colors.toJson(),
      'spacing': spacing.toJson(),
      'radius': radius.toJson(),
      'typography': typography.toJson(),
      'controlSize': controlSize.toJson(),
      'adaptiveLayout': adaptiveLayout.toJson(),
      'heroGradient': heroGradient.toJson(),
      'stroke': stroke.toJson(),
      'shadow': shadow.toJson(),
    };
  }

  /// Preset hero gradients shared with the Swift package.
  static const EdsHeroGradient heroGradientBlue = EdsHeroGradient(
    startColor: Color(0xFF3185FF),
    endColor: Color(0xFF0A6BFF),
  );

  static const EdsHeroGradient heroGradientOrange = EdsHeroGradient(
    startColor: Color(0xFFFF6B00),
    endColor: Color(0xFFFF3D00),
  );

  static const EdsHeroGradient heroGradientPurple = EdsHeroGradient(
    startColor: Color(0xFF8B5CF6),
    endColor: Color(0xFF6D28D9),
  );

  @override
  bool operator ==(Object other) {
    return other is EdsDesignTokens &&
        other.colors == colors &&
        other.spacing == spacing &&
        other.radius == radius &&
        other.typography == typography &&
        other.controlSize == controlSize &&
        other.adaptiveLayout == adaptiveLayout &&
        other.heroGradient == heroGradient &&
        other.stroke == stroke &&
        other.shadow == shadow;
  }

  @override
  int get hashCode => Object.hash(
        colors,
        spacing,
        radius,
        typography,
        controlSize,
        adaptiveLayout,
        heroGradient,
        stroke,
        shadow,
      );
}

Map<String, Object?>? _readGroup(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is Map<String, Object?>) {
    return value;
  }
  throw FormatException(
      'Expected an object for "$key" but found ${value.runtimeType}.');
}

double _readDouble(Map<String, Object?> json, String key, double fallback) {
  final value = json[key];
  if (value == null) {
    return fallback;
  }
  if (value is num) {
    return value.toDouble();
  }
  throw FormatException(
      'Expected a number for "$key" but found ${value.runtimeType}.');
}

String? _readNullableString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException(
      'Expected a string for "$key" but found ${value.runtimeType}.');
}

List<String>? _readStringList(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is List && value.every((element) => element is String)) {
    return value.cast<String>();
  }
  throw FormatException(
      'Expected a string array for "$key" but found ${value.runtimeType}.');
}

bool _listEquals(List<String>? a, List<String>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

String _readString(Map<String, Object?> json, String key, String fallback) {
  final value = json[key];
  if (value == null) {
    return fallback;
  }
  if (value is String) {
    return value;
  }
  throw FormatException(
      'Expected a string for "$key" but found ${value.runtimeType}.');
}

Color _readColor(Map<String, Object?> json, String key, Color fallback) {
  final value = json[key];
  if (value == null) {
    return fallback;
  }
  if (value is String) {
    // Swift decodes through `Color(hexRGB:)`, which rejects eight-digit hex by
    // falling back to opaque black. Keep the exact same behavior.
    return EdsColorHex.parseRgb(value);
  }
  throw FormatException(
      'Expected a hex string for "$key" but found ${value.runtimeType}.');
}

/// Normalizes integral doubles to ints so exported JSON matches Swift's
/// `JSONEncoder` output byte for byte (Swift writes `4`, not `4.0`).
num _jsonNum(double value) {
  if (value.isFinite && value == value.truncateToDouble()) {
    return value.toInt();
  }
  return value;
}
