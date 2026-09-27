import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../adaptive/eds_interaction_profile.dart';
import '../adaptive/eds_resolved_metrics.dart';
import '../adaptive/eds_size_class.dart';
import '../color/eds_color_seeds.dart';
import '../color/eds_interaction_resolver.dart';
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

  /// Medium: intermediate semantic surface between soft and filled.
  medium,

  /// Outlined: transparent background + 1pt neutral border + tone-colored text
  /// (Material Design 3 outlined recipe).
  outline,

  /// Soft: low-emphasis semantic surface + tone foreground.
  soft,

  /// Text only: weakest.
  plain,
}

/// Semantic tone of a button. Mirrors Swift's `EDSButton.Tone`.
enum EdsButtonTone {
  /// Theme brand, for regular actions.
  brand,

  /// Informational actions.
  information,

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
  /// Filled brand. Equivalent to `filled + brand + regular`.
  primary,

  /// Medium brand. Equivalent to `medium + brand + regular`.
  ///
  /// Was `outline + brand` before 0.4.0; outline was retired and secondary
  /// automatically followed to medium — caller source code needs no change.
  secondary,

  /// Soft brand. Equivalent to `soft + brand + regular`.
  soft,

  /// Filled danger. Equivalent to `filled + danger + regular`.
  danger,

  /// Completed (filled green + checkmark icon). Equivalent to
  /// `filled + success + regular`.
  done,

  /// Soft neutral. Equivalent to `soft + neutral + regular`.
  normal,
}

/// The appearance preset for this role, mirroring Swift's
/// `EDSButton.Role.appearance`.
extension EdsButtonRoleX on EdsButtonRole {
  EdsButtonAppearance get appearance {
    return switch (this) {
      EdsButtonRole.primary => const EdsButtonAppearance(
          emphasis: EdsButtonEmphasis.filled,
          tone: EdsButtonTone.brand,
          size: EdsButtonSize.regular,
        ),
      EdsButtonRole.secondary => const EdsButtonAppearance(
          emphasis: EdsButtonEmphasis.medium,
          tone: EdsButtonTone.brand,
          size: EdsButtonSize.regular,
        ),
      EdsButtonRole.soft => const EdsButtonAppearance(
          emphasis: EdsButtonEmphasis.soft,
          tone: EdsButtonTone.brand,
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

  /// The icon automatically applied when no [EdsButton.icon] is given.
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
    this.tone = EdsButtonTone.brand,
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

  /// Resolves this appearance into concrete semantic visual values.
  EdsResolvedButtonVisual resolve({
    required EdsDesignTokens tokens,
    required EdsColorScheme scheme,
    required EdsColorSeeds seeds,
    required Brightness brightness,
    EdsInteractionState state = EdsInteractionState.rest,
    bool enabled = true,
  }) {
    if (!enabled) {
      return EdsResolvedButtonVisual(
        foreground: scheme.foregroundDisabled,
        background: switch (emphasis) {
          EdsButtonEmphasis.filled ||
          EdsButtonEmphasis.medium ||
          EdsButtonEmphasis.soft =>
            scheme.surfaceDisabled,
          EdsButtonEmphasis.outline || EdsButtonEmphasis.plain => null,
        },
        borderColor: emphasis == EdsButtonEmphasis.outline
            ? scheme.borderDisabled
            : null,
        borderWidth: emphasis == EdsButtonEmphasis.outline
            ? tokens.stroke.hairline
            : 1.5,
        height: _height(tokens),
        horizontalPadding: _horizontalPadding(tokens),
      );
    }

    final family = _interactionFamily;
    final foreground = _toneForeground(scheme);
    final onStrong = _toneOnStrong(scheme);
    final border = _toneBorder(scheme);

    final Color resolvedForeground;
    final Color? background;
    final Color? borderColor;

    if (tone == EdsButtonTone.neutral) {
      resolvedForeground = emphasis == EdsButtonEmphasis.filled
          ? scheme.foregroundInverse
          : scheme.foregroundPrimary;
      switch (emphasis) {
        case EdsButtonEmphasis.filled:
          background = EdsInteractionResolver.neutralStrongSurface(
            brightness: brightness,
            state: state,
          );
          borderColor = null;
        case EdsButtonEmphasis.medium:
        case EdsButtonEmphasis.soft:
          background = state == EdsInteractionState.rest
              ? scheme.surfaceSunken
              : EdsInteractionResolver.neutralSurface(
                  brightness: brightness,
                  state: state,
                );
          borderColor = null;
        case EdsButtonEmphasis.outline:
          background = state == EdsInteractionState.rest
              ? null
              : EdsInteractionResolver.neutralSurface(
                  brightness: brightness,
                  state: state,
                );
          borderColor = scheme.borderDefault;
        case EdsButtonEmphasis.plain:
          background = state == EdsInteractionState.rest
              ? null
              : EdsInteractionResolver.neutralSurface(
                  brightness: brightness,
                  state: state,
                );
          borderColor = null;
      }
    } else {
      resolvedForeground =
          emphasis == EdsButtonEmphasis.filled ? onStrong : foreground;
      switch (emphasis) {
        case EdsButtonEmphasis.filled:
          background = EdsInteractionResolver.strongSurface(
            family: family!,
            seeds: seeds,
            brightness: brightness,
            state: state,
          );
          borderColor = null;
        case EdsButtonEmphasis.medium:
          background = EdsInteractionResolver.mediumSurface(
            family: family!,
            seeds: seeds,
            brightness: brightness,
            state: state,
          );
          borderColor = null;
        case EdsButtonEmphasis.soft:
          background = EdsInteractionResolver.softSurface(
            family: family!,
            seeds: seeds,
            brightness: brightness,
            state: state,
          );
          borderColor = null;
        case EdsButtonEmphasis.outline:
          background = state == EdsInteractionState.rest
              ? null
              : EdsInteractionResolver.softSurface(
                  family: family!,
                  seeds: seeds,
                  brightness: brightness,
                  state: state,
                );
          borderColor = border;
        case EdsButtonEmphasis.plain:
          background = state == EdsInteractionState.rest
              ? null
              : EdsInteractionResolver.softSurface(
                  family: family!,
                  seeds: seeds,
                  brightness: brightness,
                  state: state,
                );
          borderColor = null;
      }
    }

    return EdsResolvedButtonVisual(
      foreground: resolvedForeground,
      background: background,
      borderColor: borderColor,
      borderWidth:
          emphasis == EdsButtonEmphasis.outline ? tokens.stroke.hairline : 1.5,
      height: _height(tokens),
      horizontalPadding: _horizontalPadding(tokens),
    );
  }

  double _height(EdsDesignTokens tokens) {
    return switch (size) {
      EdsButtonSize.small => 28,
      EdsButtonSize.regular => tokens.controlSize.buttonHeight,
      EdsButtonSize.large => 44,
    };
  }

  double _horizontalPadding(EdsDesignTokens tokens) {
    return switch (size) {
      EdsButtonSize.small => tokens.spacing.sm,
      EdsButtonSize.regular => tokens.spacing.md,
      EdsButtonSize.large => tokens.spacing.lg,
    };
  }

  EdsInteractionColorFamily? get _interactionFamily {
    return switch (tone) {
      EdsButtonTone.neutral => null,
      EdsButtonTone.brand => EdsInteractionColorFamily.brand,
      EdsButtonTone.information => EdsInteractionColorFamily.information,
      EdsButtonTone.success => EdsInteractionColorFamily.success,
      EdsButtonTone.warning => EdsInteractionColorFamily.warning,
      EdsButtonTone.danger => EdsInteractionColorFamily.danger,
    };
  }

  Color _toneForeground(EdsColorScheme scheme) {
    return switch (tone) {
      EdsButtonTone.neutral => scheme.foregroundPrimary,
      EdsButtonTone.brand => scheme.brandForeground,
      EdsButtonTone.information => scheme.informationForeground,
      EdsButtonTone.success => scheme.successForeground,
      EdsButtonTone.warning => scheme.warningForeground,
      EdsButtonTone.danger => scheme.dangerForeground,
    };
  }

  Color _toneBorder(EdsColorScheme scheme) {
    return switch (tone) {
      EdsButtonTone.neutral => scheme.borderDefault,
      EdsButtonTone.brand => scheme.brandBorder,
      EdsButtonTone.information => scheme.informationBorder,
      EdsButtonTone.success => scheme.successBorder,
      EdsButtonTone.warning => scheme.warningBorder,
      EdsButtonTone.danger => scheme.dangerBorder,
    };
  }

  Color _toneOnStrong(EdsColorScheme scheme) {
    return switch (tone) {
      EdsButtonTone.neutral => scheme.foregroundInverse,
      EdsButtonTone.brand => scheme.brandOnStrong,
      EdsButtonTone.information => scheme.informationOnStrong,
      EdsButtonTone.success => scheme.successOnStrong,
      EdsButtonTone.warning => scheme.warningOnStrong,
      EdsButtonTone.danger => scheme.dangerOnStrong,
    };
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
    IconData? icon,
    @Deprecated('Use icon instead.') IconData? systemImage,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.isBusy = false,
    this.expands = false,
    this.action,
  })  : assert(
          icon == null || systemImage == null,
          'Provide either icon or systemImage, not both.',
        ),
        appearance = role.appearance,
        _title = title,
        _labelWidget = null,
        _explicitIcon = icon ?? systemImage,
        _role = role;

  /// Convenience initializer for a full-width primary/secondary action.
  ///
  /// This is equivalent to [EdsButton] with `expands: true`, while keeping
  /// the default constructor content-sized.
  factory EdsButton.fullWidth(
    String title, {
    Key? key,
    EdsButtonRole role = EdsButtonRole.primary,
    IconData? icon,
    String? tooltip,
    FocusNode? focusNode,
    bool autofocus = false,
    String? semanticLabel,
    bool isBusy = false,
    VoidCallback? action,
  }) {
    return EdsButton(
      title,
      key: key,
      role: role,
      icon: icon,
      tooltip: tooltip,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      isBusy: isBusy,
      expands: true,
      action: action,
    );
  }

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
    bool isBusy = false,
    bool expands = false,
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
      isBusy: isBusy,
      expands: expands,
    );
  }

  /// Advanced custom-label initializer for Flutter-specific layouts.
  factory EdsButton.custom({
    Key? key,
    required Widget label,
    EdsButtonRole role = EdsButtonRole.primary,
    String? tooltip,
    FocusNode? focusNode,
    bool autofocus = false,
    String? semanticLabel,
    bool isBusy = false,
    bool expands = false,
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
      isBusy: isBusy,
      expands: expands,
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
  @Deprecated('Use EdsButton.styled instead.')
  factory EdsButton.dimension(
    String title, {
    Key? key,
    required EdsButtonEmphasis emphasis,
    EdsButtonTone tone = EdsButtonTone.brand,
    EdsButtonSize size = EdsButtonSize.regular,
    IconData? icon,
    @Deprecated('Use icon instead.') IconData? systemImage,
    String? tooltip,
    FocusNode? focusNode,
    bool autofocus = false,
    String? semanticLabel,
    bool isBusy = false,
    bool expands = false,
    VoidCallback? action,
  }) {
    assert(
      icon == null || systemImage == null,
      'Provide either icon or systemImage, not both.',
    );
    return EdsButton._(
      key: key,
      appearance: EdsButtonAppearance(
        emphasis: emphasis,
        tone: tone,
        size: size,
      ),
      action: action,
      title: title,
      explicitIcon: icon ?? systemImage,
      tooltip: tooltip,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      isBusy: isBusy,
      expands: expands,
    );
  }

  /// Fine-grained appearance initializer with Flutter-native naming.
  factory EdsButton.styled(
    String title, {
    Key? key,
    required EdsButtonEmphasis emphasis,
    EdsButtonTone tone = EdsButtonTone.brand,
    EdsButtonSize size = EdsButtonSize.regular,
    IconData? icon,
    String? tooltip,
    FocusNode? focusNode,
    bool autofocus = false,
    String? semanticLabel,
    bool isBusy = false,
    bool expands = false,
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
      explicitIcon: icon,
      tooltip: tooltip,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      isBusy: isBusy,
      expands: expands,
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
    this.isBusy = false,
    this.expands = false,
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

  /// Shows an inline progress indicator and prevents duplicate activation.
  final bool isBusy;

  /// Expands the button to the maximum width offered by its parent.
  final bool expands;

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
      isBusy: isBusy,
      expands: expands,
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
    required this.isBusy,
    required this.expands,
  });

  final EdsButtonAppearance appearance;
  final VoidCallback? action;
  final Widget label;
  final String? tooltip;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;
  final bool isBusy;
  final bool expands;

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
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final hasAction = widget.action != null;
    final canActivate = hasAction && !widget.isBusy;
    final showsHover =
        metrics.supportsHoverEnhancement && _isHovered && canActivate;
    final interactionState = _isPressed && canActivate
        ? EdsInteractionState.pressed
        : showsHover
            ? EdsInteractionState.hovered
            : EdsInteractionState.rest;
    final visual = widget.appearance.resolve(
      tokens: tokens,
      scheme: scheme,
      seeds: context.edsSeeds,
      brightness: context.edsBrightness,
      state: interactionState,
      enabled: hasAction,
    );
    final labelStyle = tokens.typography.edsTextStyle(EdsFontRole.bodyStrong);

    Widget effectiveLabel = widget.label;
    if (widget.isBusy) {
      effectiveLabel = Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Opacity(opacity: 0, child: widget.label),
          SizedBox(
            width: tokens.typography.bodyStrongSize,
            height: tokens.typography.bodyStrongSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: visual.foreground,
            ),
          ),
        ],
      );
    }

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
        child: effectiveLabel,
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
    current = AnimatedContainer(
      duration:
          reduceMotion ? Duration.zero : const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: visual.background,
        border: visual.borderColor == null
            ? null
            : Border.all(color: visual.borderColor!, width: visual.borderWidth),
        borderRadius: BorderRadius.circular(tokens.radius.md),
        boxShadow: _isFocused && canActivate
            ? <BoxShadow>[
                BoxShadow(
                  color: scheme.borderFocus,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: current,
    );

    Widget result = IgnorePointer(
      ignoring: !canActivate,
      child: FocusableActionDetector(
        enabled: canActivate,
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
          cursor: canActivate ? SystemMouseCursors.click : MouseCursor.defer,
          onEnter: reduceMotion ? null : (_) => _setHovered(true),
          onExit: reduceMotion ? null : (_) => _setHovered(false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTapDown: reduceMotion ? null : (_) => _setPressed(true),
            onTapUp: reduceMotion ? null : (_) => _setPressed(false),
            onTapCancel: reduceMotion ? null : () => _setPressed(false),
            onTap: widget.action,
            child: Transform.scale(
              scale: _isPressed && !reduceMotion ? 0.97 : 1.0,
              child: current,
            ),
          ),
        ),
      ),
    );

    result = Semantics(
      button: true,
      enabled: hasAction,
      liveRegion: widget.isBusy,
      label: widget.semanticLabel,
      excludeSemantics: widget.semanticLabel != null,
      onTap: canActivate ? widget.action : null,
      child: result,
    );
    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      result = Tooltip(message: widget.tooltip!, child: result);
    }
    if (widget.expands) {
      result = SizedBox(width: double.infinity, child: result);
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
