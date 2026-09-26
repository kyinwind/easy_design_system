import 'package:flutter/material.dart';

import '../adaptive/eds_interaction_profile.dart';
import '../adaptive/eds_resolved_metrics.dart';
import '../adaptive/eds_size_class.dart';
import '../primitives/eds_font.dart';
import '../theme/eds_theme_scope.dart';
import '../tokens/eds_color_scheme.dart';
import '../tokens/eds_design_tokens.dart';

/// Visual weight of a button. Mirrors Swift's `EDSButton.Emphasis`.
///
/// Five tiers of visual weight, ordered strongest to weakest:
/// `filled` → `medium` → `outline` → `soft` → `plain`.
enum EdsButtonEmphasis {
  /// Filled: strongest visual weight.
  filled,

  /// Medium: 25% tinted background + darkened text (neutral uses textPrimary).
  medium,

  /// Outlined: transparent background + 1pt neutral border + tone-colored text
  /// (Material Design 3 outlined recipe).
  outline,

  /// Soft: 12% tinted background + tone-colored text.
  soft,

  /// Text only: weakest.
  plain,
}

/// Semantic tone of a button. Mirrors Swift's `EDSButton.Tone`.
enum EdsButtonTone {
  /// Theme accent, for regular actions.
  accent,

  /// Neutral gray.
  neutral,

  /// Destructive actions.
  danger,

  /// Success / completed.
  success,

  /// Caution.
  warning,
}

/// Size tier of a button. Mirrors Swift's `EDSButton.Size`.
enum EdsButtonSize {
  /// 28pt, dense toolbars.
  small,

  /// 34pt, the default (equals `controlSize.buttonHeight`).
  regular,

  /// 44pt, primary action areas.
  large,
}

/// Preset alias table: each role maps to a fixed emphasis/tone/size
/// combination. Mirrors Swift's `EDSButton.Role`.
enum EdsButtonRole {
  /// Filled accent. Equivalent to `filled + accent + regular`.
  primary,

  /// Medium accent (25% tinted). Equivalent to `medium + accent + regular`.
  ///
  /// Was `outline + accent` before 0.4.0; outline was retired and secondary
  /// automatically followed to medium — caller source code needs no change.
  secondary,

  /// Soft accent. Equivalent to `soft + accent + regular`.
  soft,

  /// Filled danger. Equivalent to `filled + danger + regular`.
  danger,

  /// Completed (filled green + checkmark icon). Equivalent to
  /// `filled + success + regular`.
  done,

  /// Soft neutral (12% gray background). Equivalent to `soft + neutral + regular`.
  normal,
}

/// The appearance preset for this role, mirroring Swift's
/// `EDSButton.Role.appearance`.
extension EdsButtonRoleX on EdsButtonRole {
  EdsButtonAppearance get appearance {
    return switch (this) {
      EdsButtonRole.primary => const EdsButtonAppearance(
          emphasis: EdsButtonEmphasis.filled,
          tone: EdsButtonTone.accent,
          size: EdsButtonSize.regular,
        ),
      EdsButtonRole.secondary => const EdsButtonAppearance(
          emphasis: EdsButtonEmphasis.medium,
          tone: EdsButtonTone.accent,
          size: EdsButtonSize.regular,
        ),
      EdsButtonRole.soft => const EdsButtonAppearance(
          emphasis: EdsButtonEmphasis.soft,
          tone: EdsButtonTone.accent,
          size: EdsButtonSize.regular,
        ),
      EdsButtonRole.danger => const EdsButtonAppearance(
          emphasis: EdsButtonEmphasis.filled,
          tone: EdsButtonTone.danger,
          size: EdsButtonSize.regular,
        ),
      EdsButtonRole.done => const EdsButtonAppearance(
          emphasis: EdsButtonEmphasis.filled,
          tone: EdsButtonTone.success,
          size: EdsButtonSize.regular,
        ),
      EdsButtonRole.normal => const EdsButtonAppearance(
          emphasis: EdsButtonEmphasis.soft,
          tone: EdsButtonTone.neutral,
          size: EdsButtonSize.regular,
        ),
    };
  }

  /// The icon automatically applied when no [EdsButton.systemImage] is given.
  IconData? get defaultIcon {
    return switch (this) {
      EdsButtonRole.done => Icons.check,
      EdsButtonRole.primary ||
      EdsButtonRole.secondary ||
      EdsButtonRole.soft ||
      EdsButtonRole.danger ||
      EdsButtonRole.normal =>
        null,
    };
  }
}

/// Value object for an emphasis/tone/size combination. Publicly
/// constructable so apps can define their own presets, mirroring Swift's
/// `EDSButtonAppearance`.
class EdsButtonAppearance {
  const EdsButtonAppearance({
    this.emphasis = EdsButtonEmphasis.filled,
    this.tone = EdsButtonTone.accent,
    this.size = EdsButtonSize.regular,
  });

  final EdsButtonEmphasis emphasis;
  final EdsButtonTone tone;
  final EdsButtonSize size;

  @override
  bool operator ==(Object other) {
    return other is EdsButtonAppearance &&
        other.emphasis == emphasis &&
        other.tone == tone &&
        other.size == size;
  }

  @override
  int get hashCode => Object.hash(emphasis, tone, size);

  /// Resolves this appearance into concrete visual values.
  ///
  /// Public so tests can verify visual rules without widget tests.
  EdsResolvedButtonVisual resolve({
    required EdsDesignTokens tokens,
    required EdsColorScheme scheme,
  }) {
    final colors = tokens.colors;

    final Color toneColor = switch (tone) {
      EdsButtonTone.accent => colors.primary,
      EdsButtonTone.neutral => scheme.label,
      EdsButtonTone.danger => colors.danger,
      EdsButtonTone.success => colors.success,
      EdsButtonTone.warning => colors.warning,
    };

    final Color toneSoftColor = switch (tone) {
      EdsButtonTone.accent => colors.primarySoft,
      EdsButtonTone.neutral => scheme.label.withValues(alpha: 0.12),
      EdsButtonTone.danger => colors.dangerSoft,
      EdsButtonTone.success => colors.successSoft,
      EdsButtonTone.warning => colors.warningSoft,
    };

    final Color foreground;
    final Color? background;
    final Color? borderColor;

    switch (emphasis) {
      case EdsButtonEmphasis.filled:
        switch (tone) {
          case EdsButtonTone.neutral:
            foreground = scheme.pageBackground;
            background = scheme.label.withValues(alpha: 0.75);
          case EdsButtonTone.accent:
          case EdsButtonTone.danger:
            foreground = Colors.white;
            background = toneColor;
          case EdsButtonTone.success:
          case EdsButtonTone.warning:
            foreground = Colors.white;
            background = toneColor;
        }
        borderColor = null;
      case EdsButtonEmphasis.medium:
        foreground = tone == EdsButtonTone.neutral
            ? scheme.textPrimary
            : _darkened(toneColor, 0.7);
        background = toneColor.withValues(alpha: 0.25);
        borderColor = null;
      case EdsButtonEmphasis.outline:
        foreground =
            tone == EdsButtonTone.success ? scheme.textPrimary : toneColor;
        background = null;
        borderColor = scheme.border;
      case EdsButtonEmphasis.soft:
        foreground =
            tone == EdsButtonTone.success ? scheme.textPrimary : toneColor;
        background = toneSoftColor;
        borderColor = null;
      case EdsButtonEmphasis.plain:
        foreground = toneColor;
        background = null;
        borderColor = null;
    }

    final double height = switch (size) {
      EdsButtonSize.small => 28,
      EdsButtonSize.regular => tokens.controlSize.buttonHeight,
      EdsButtonSize.large => 44,
    };

    final double horizontalPadding = switch (size) {
      EdsButtonSize.small => tokens.spacing.sm,
      EdsButtonSize.regular => tokens.spacing.md,
      EdsButtonSize.large => tokens.spacing.lg,
    };

    final double borderWidth =
        emphasis == EdsButtonEmphasis.outline ? tokens.stroke.hairline : 1.5;

    return EdsResolvedButtonVisual(
      foreground: foreground,
      background: background,
      borderColor: borderColor,
      borderWidth: borderWidth,
      height: height,
      horizontalPadding: horizontalPadding,
    );
  }

  /// Darkens a color by multiplying each RGB channel by [factor].
  static Color _darkened(Color color, double factor) {
    return Color.from(
      alpha: color.a,
      red: color.r * factor,
      green: color.g * factor,
      blue: color.b * factor,
    );
  }
}

/// The resolved visual values for a button appearance, mirroring Swift's
/// `EDSResolvedButtonVisual`.
class EdsResolvedButtonVisual {
  const EdsResolvedButtonVisual({
    required this.foreground,
    this.background,
    this.borderColor,
    required this.borderWidth,
    required this.height,
    required this.horizontalPadding,
  });

  final Color foreground;
  final Color? background;
  final Color? borderColor;
  final double borderWidth;
  final double height;
  final double horizontalPadding;
}

/// The general-purpose EDS button, mirroring Swift's `EDSButton`.
///
/// Deviations from Swift:
/// - `systemImage` accepts a Material [IconData] instead of an SF Symbol
///   name.
/// - A null [action] renders the button in its disabled state; SwiftUI uses
///   the `.disabled()` modifier instead.
/// - The three Swift initializers map to this constructor plus the
///   [EdsButton.label] and [EdsButton.dimension] factories.
class EdsButton extends StatelessWidget {
  /// Role-based initializer with a plain title.
  ///
  /// ```dart
  /// EdsButton('保存', role: EdsButtonRole.primary, action: save)
  /// ```
  EdsButton(
    String title, {
    super.key,
    EdsButtonRole role = EdsButtonRole.primary,
    IconData? systemImage,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.action,
  })  : appearance = role.appearance,
        _title = title,
        _labelWidget = null,
        _explicitIcon = systemImage,
        _role = role;

  /// Role-based initializer with a custom label widget, mirroring Swift's
  /// `EDSButton.label(_:role:action:)`.
  factory EdsButton.label(
    Widget label, {
    Key? key,
    EdsButtonRole role = EdsButtonRole.primary,
    String? tooltip,
    FocusNode? focusNode,
    bool autofocus = false,
    String? semanticLabel,
    VoidCallback? action,
  }) {
    return EdsButton._(
      key: key,
      appearance: role.appearance,
      action: action,
      labelWidget: label,
      tooltip: tooltip,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
    );
  }

  /// Three-dimensional primitive initializer, mirroring Swift's
  /// `EDSButton(_:emphasis:tone:size:systemImage:action:)`.
  ///
  /// ```dart
  /// EdsButton.dimension('忽略并删除',
  ///     emphasis: EdsButtonEmphasis.soft, tone: EdsButtonTone.danger,
  ///     action: remove)
  /// ```
  factory EdsButton.dimension(
    String title, {
    Key? key,
    required EdsButtonEmphasis emphasis,
    EdsButtonTone tone = EdsButtonTone.accent,
    EdsButtonSize size = EdsButtonSize.regular,
    IconData? systemImage,
    String? tooltip,
    FocusNode? focusNode,
    bool autofocus = false,
    String? semanticLabel,
    VoidCallback? action,
  }) {
    return EdsButton._(
      key: key,
      appearance: EdsButtonAppearance(
        emphasis: emphasis,
        tone: tone,
        size: size,
      ),
      action: action,
      title: title,
      explicitIcon: systemImage,
      tooltip: tooltip,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
    );
  }

  const EdsButton._({
    super.key,
    required this.appearance,
    required this.action,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    String? title,
    Widget? labelWidget,
    IconData? explicitIcon,
    EdsButtonRole? role,
  })  : _title = title,
        _labelWidget = labelWidget,
        _explicitIcon = explicitIcon,
        _role = role;

  final EdsButtonAppearance appearance;

  /// Triggered on tap. When null the button renders as disabled.
  final VoidCallback? action;

  /// Optional desktop hover tooltip.
  final String? tooltip;

  /// Optional focus node for keyboard focus management.
  final FocusNode? focusNode;

  /// Whether this button should request focus when first built.
  final bool autofocus;

  /// Accessibility label. Plain-title buttons fall back to their title.
  final String? semanticLabel;

  final String? _title;
  final Widget? _labelWidget;
  final IconData? _explicitIcon;
  final EdsButtonRole? _role;

  @override
  Widget build(BuildContext context) {
    return _EdsButtonBody(
      appearance: appearance,
      action: action,
      label: _labelWidget ?? _buildTitleLabel(context),
      tooltip: tooltip,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel ?? _title,
    );
  }

  Widget _buildTitleLabel(BuildContext context) {
    final tokens = context.edsTokens;
    final icon = _explicitIcon ?? _role?.defaultIcon;
    final title = _title ?? '';
    if (icon == null) {
      return Text(title);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon),
        SizedBox(width: tokens.spacing.xxs),
        Text(title),
      ],
    );
  }
}

/// Carries all button visual logic, mirroring Swift's `EDSButtonVisualBody`.
class _EdsButtonBody extends StatefulWidget {
  const _EdsButtonBody({
    required this.appearance,
    required this.action,
    required this.label,
    required this.tooltip,
    required this.focusNode,
    required this.autofocus,
    required this.semanticLabel,
  });

  final EdsButtonAppearance appearance;
  final VoidCallback? action;
  final Widget label;
  final String? tooltip;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;

  @override
  State<_EdsButtonBody> createState() => _EdsButtonBodyState();
}

class _EdsButtonBodyState extends State<_EdsButtonBody> {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final metrics = EdsResolvedMetrics.resolve(
      tokens: tokens,
      profile: context.edsInteractionProfile,
      horizontalSizeClass: context.edsSizeClass,
    );
    final visual = widget.appearance.resolve(
      tokens: tokens,
      scheme: scheme,
    );
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final enabled = widget.action != null;
    final showsHover = metrics.supportsHoverEnhancement && _isHovered;
    final double opacity = enabled ? 1.0 : 0.5;
    final labelStyle = tokens.typography.edsTextStyle(EdsFontRole.bodyStrong);

    Widget current = DefaultTextStyle.merge(
      style: labelStyle.copyWith(
        color: visual.foreground,
        overflow: TextOverflow.ellipsis,
      ),
      maxLines: 1,
      child: IconTheme.merge(
        data: IconThemeData(
          color: visual.foreground,
          size: tokens.typography.bodyStrongSize,
        ),
        child: widget.label,
      ),
    );
    current = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: metrics.interactiveHeight(visual.height),
      ),
      child: Align(
        alignment: Alignment.center,
        widthFactor: 1.0,
        child: current,
      ),
    );
    current = Padding(
      padding: EdgeInsets.symmetric(horizontal: visual.horizontalPadding),
      child: current,
    );
    final hoverBackground = showsHover
        ? Color.lerp(
            visual.background ?? Colors.transparent,
            visual.foreground,
            0.08,
          )
        : visual.background;
    current = AnimatedContainer(
      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: hoverBackground,
        border: visual.borderColor == null
            ? null
            : Border.all(
                color: visual.borderColor!,
                width: visual.borderWidth,
              ),
        borderRadius: BorderRadius.circular(tokens.radius.md),
        boxShadow: _isFocused && enabled
            ? <BoxShadow>[
                BoxShadow(
                  color: tokens.colors.primary.withValues(alpha: 0.55),
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: current,
    );

    Widget result = IgnorePointer(
      ignoring: !enabled,
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.action?.call();
              return null;
            },
          ),
        },
        onShowFocusHighlight: (value) {
          if (_isFocused != value) {
            setState(() => _isFocused = value);
          }
        },
        child: MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
          onEnter: reduceMotion ? null : (_) => _setHovered(true),
          onExit: reduceMotion ? null : (_) => _setHovered(false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: reduceMotion ? null : (_) => _setPressed(true),
            onTapUp: reduceMotion ? null : (_) => _setPressed(false),
            onTapCancel: reduceMotion ? null : () => _setPressed(false),
            onTap: widget.action,
            child: AnimatedOpacity(
              opacity: opacity,
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              child: Transform.scale(
                scale: _isPressed && !reduceMotion ? 0.97 : 1.0,
                child: current,
              ),
            ),
          ),
        ),
      ),
    );

    result = Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      onTap: enabled ? widget.action : null,
      child: result,
    );
    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      result = Tooltip(message: widget.tooltip!, child: result);
    }
    return result;
  }

  void _setHovered(bool value) {
    if (_isHovered != value) {
      setState(() {
        _isHovered = value;
      });
    }
  }

  void _setPressed(bool value) {
    if (_isPressed != value) {
      setState(() {
        _isPressed = value;
      });
    }
  }
}
