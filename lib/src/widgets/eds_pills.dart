import 'package:flutter/material.dart';

import '../adaptive/eds_interaction_profile.dart';
import '../adaptive/eds_resolved_metrics.dart';
import '../adaptive/eds_size_class.dart';
import '../primitives/eds_font.dart';
import '../theme/eds_theme_scope.dart';
import '../tokens/eds_design_tokens.dart';

/// A simple flow layout: children wrap across the available width,
/// mirroring Swift's `EDSFlowLayout`.
///
/// Deviation from Swift: the custom `Layout` protocol implementation maps
/// to Flutter's [Wrap], and the default spacing is read from the scoped
/// theme at build time instead of from `EDSTheme.shared` at construction
/// time.
class EdsFlowLayout extends StatelessWidget {
  const EdsFlowLayout({
    super.key,
    this.horizontalSpacing,
    this.verticalSpacing,
    required this.children,
  });

  /// Horizontal spacing between items. Defaults to `spacing.sm`.
  final double? horizontalSpacing;

  /// Vertical spacing between rows. Defaults to `spacing.sm`.
  final double? verticalSpacing;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    return Wrap(
      spacing: horizontalSpacing ?? tokens.spacing.sm,
      runSpacing: verticalSpacing ?? tokens.spacing.sm,
      children: children,
    );
  }
}

/// The visual tone of a pill, mirroring Swift's `EDSPillTone`.
class EdsPillTone {
  EdsPillTone({
    required this.background,
    required this.foreground,
    Color? border,
  }) : border = border ?? foreground.withValues(alpha: 0.16);

  final Color background;
  final Color foreground;

  /// Pill outline color. Defaults to `foreground` at 16% opacity.
  final Color border;

  /// The default 12-color palette, identical to Swift's
  /// `EDSPillTone.defaultPalette`.
  static final List<EdsPillTone> defaultPalette = <EdsPillTone>[
    EdsPillTone(
        background: const Color(0xFFEAF2FF),
        foreground: const Color(0xFF246BCE)),
    EdsPillTone(
        background: const Color(0xFFEAF8F0),
        foreground: const Color(0xFF218B4E)),
    EdsPillTone(
        background: const Color(0xFFFFF4E6),
        foreground: const Color(0xFFB76100)),
    EdsPillTone(
        background: const Color(0xFFF3EDFF),
        foreground: const Color(0xFF6F42C1)),
    EdsPillTone(
        background: const Color(0xFFEAF7FA),
        foreground: const Color(0xFF087990)),
    EdsPillTone(
        background: const Color(0xFFFDECEF),
        foreground: const Color(0xFFC7354D)),
    EdsPillTone(
        background: const Color(0xFFFFF0F7),
        foreground: const Color(0xFFB83280)),
    EdsPillTone(
        background: const Color(0xFFEEF2FF),
        foreground: const Color(0xFF4F46E5)),
    EdsPillTone(
        background: const Color(0xFFECFDF5),
        foreground: const Color(0xFF047857)),
    EdsPillTone(
        background: const Color(0xFFFEFCE8),
        foreground: const Color(0xFFA16207)),
    EdsPillTone(
        background: const Color(0xFFF1F5F9),
        foreground: const Color(0xFF475569)),
    EdsPillTone(
        background: const Color(0xFFF0FDFA),
        foreground: const Color(0xFF0F766E)),
  ];

  @override
  bool operator ==(Object other) {
    return other is EdsPillTone &&
        other.background == background &&
        other.foreground == foreground &&
        other.border == border;
  }

  @override
  int get hashCode => Object.hash(background, foreground, border);
}

/// A single pill chip, mirroring Swift's `EDSPill`.
///
/// The remove button occupies its minimum interactive target even when
/// hidden, matching the Swift layout behavior.
class EdsPill extends StatefulWidget {
  const EdsPill(
    this.title, {
    super.key,
    required this.tone,
    this.minWidth,
    this.showsRemoveButton = false,
    this.action,
    this.onRemove,
    this.removeSemanticLabel,
    this.removeSemanticHint,
  });

  final String title;
  final EdsPillTone tone;

  /// Minimum content width before padding.
  final double? minWidth;
  final bool showsRemoveButton;

  /// Triggered when the pill body is tapped.
  final VoidCallback? action;

  /// Triggered by the remove affordance.
  final VoidCallback? onRemove;

  /// Accessibility label for the remove affordance. When omitted the
  /// backwards-compatible Chinese label is used.
  final String? removeSemanticLabel;

  /// Accessibility hint for the remove affordance. When omitted the
  /// backwards-compatible Chinese hint is used.
  final String? removeSemanticHint;

  @override
  State<EdsPill> createState() => _EdsPillState();
}

class _EdsPillState extends State<EdsPill> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final metrics = EdsResolvedMetrics.resolve(
      tokens: tokens,
      profile: context.edsInteractionProfile,
      horizontalSizeClass: context.edsSizeClass,
    );
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: tokens.spacing.xxs,
      children: <Widget>[
        Text(
          widget.title,
          maxLines: 1,
          softWrap: false,
          style: tokens.typography
              .edsTextStyle(EdsFontRole.captionStrong)
              .copyWith(color: widget.tone.foreground),
        ),
        if (widget.showsRemoveButton)
          _removeButton(metrics, tokens, reduceMotion),
      ],
    );
    content = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: widget.minWidth ?? 0,
        minHeight: metrics.minimumInteractiveDimension,
      ),
      child: Align(
        alignment: Alignment.center,
        widthFactor: 1.0,
        child: content,
      ),
    );
    content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      child: content,
    );
    content = Container(
      decoration: ShapeDecoration(
        color: widget.tone.background,
        shape: StadiumBorder(
          side: BorderSide(
            color: widget.tone.border,
            width: tokens.stroke.hairline,
          ),
        ),
      ),
      child: content,
    );

    return Semantics(
      label: widget.title,
      button: widget.action != null,
      onTap: widget.action,
      child: MouseRegion(
        cursor: widget.action != null
            ? SystemMouseCursors.click
            : MouseCursor.defer,
        onEnter: reduceMotion ? null : (_) => _setHovering(true),
        onExit: reduceMotion ? null : (_) => _setHovering(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.action,
          child: content,
        ),
      ),
    );
  }

  Widget _removeButton(
    EdsResolvedMetrics metrics,
    EdsDesignTokens tokens,
    bool reduceMotion,
  ) {
    final visible = metrics.showsPersistentAuxiliaryActions || _isHovering;
    return Semantics(
      label: widget.removeSemanticLabel ?? '删除 ${widget.title}',
      hint: widget.removeSemanticHint ?? '从列表中移除',
      button: true,
      onTap: widget.onRemove,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration:
              reduceMotion ? Duration.zero : const Duration(milliseconds: 120),
          curve: Curves.easeInOut,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onRemove,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: metrics.minimumInteractiveDimension,
                minHeight: metrics.minimumInteractiveDimension,
              ),
              child: const SizedBox(
                width: 16,
                height: 16,
                child: Center(
                  child: Icon(Icons.cancel, size: 13),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setHovering(bool value) {
    if (_isHovering != value) {
      setState(() {
        _isHovering = value;
      });
    }
  }
}

/// Sort order for [EdsPillFlow]. Mirrors Swift's `EDSPillFlowSortOrder`.
enum EdsPillFlowSortOrder {
  /// Keep the order provided by the caller.
  original,

  /// Sort ascending.
  ascending,

  /// Sort descending.
  descending,
}

/// A flowing list of pill chips, mirroring Swift's `EDSPillFlow`.
///
/// The tone palette rotates by display order, producing a light
/// pseudo-random color effect.
///
/// Deviations from Swift:
/// - [palette] is nullable; `null` (or an empty list) falls back to
///   [EdsPillTone.defaultPalette].
/// - `localizedStandardCompare` is approximated with a case-insensitive
///   comparison.
class EdsPillFlow extends StatelessWidget {
  const EdsPillFlow(
    this.items, {
    super.key,
    this.sortOrder = EdsPillFlowSortOrder.original,
    this.horizontalSpacing,
    this.verticalSpacing,
    this.minItemWidth,
    this.palette,
    this.showsRemoveButton = false,
    this.onTap,
    this.onRemove,
  });

  final List<String> items;
  final EdsPillFlowSortOrder sortOrder;

  /// Horizontal spacing between pills. Defaults to `spacing.sm`.
  final double? horizontalSpacing;

  /// Vertical spacing between rows. Defaults to `spacing.sm`.
  final double? verticalSpacing;

  /// Minimum width applied to each pill.
  final double? minItemWidth;

  /// Tone palette. Defaults to [EdsPillTone.defaultPalette].
  final List<EdsPillTone>? palette;

  final bool showsRemoveButton;
  final ValueChanged<String>? onTap;
  final ValueChanged<String>? onRemove;

  @override
  Widget build(BuildContext context) {
    final effectivePalette = (palette == null || palette!.isEmpty)
        ? EdsPillTone.defaultPalette
        : palette!;
    final sorted = _sortedItems;
    return EdsFlowLayout(
      horizontalSpacing: horizontalSpacing,
      verticalSpacing: verticalSpacing,
      children: <Widget>[
        for (var index = 0; index < sorted.length; index++)
          EdsPill(
            sorted[index],
            tone: effectivePalette[index % effectivePalette.length],
            minWidth: minItemWidth,
            showsRemoveButton: showsRemoveButton,
            action: onTap == null ? null : () => onTap!(sorted[index]),
            onRemove: onRemove == null ? null : () => onRemove!(sorted[index]),
          ),
      ],
    );
  }

  List<String> get _sortedItems {
    switch (sortOrder) {
      case EdsPillFlowSortOrder.original:
        return items;
      case EdsPillFlowSortOrder.ascending:
        return <String>[...items]..sort(
            (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
          );
      case EdsPillFlowSortOrder.descending:
        return <String>[...items]..sort(
            (a, b) => b.toLowerCase().compareTo(a.toLowerCase()),
          );
    }
  }
}
