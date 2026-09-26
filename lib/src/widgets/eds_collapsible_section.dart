import 'package:flutter/material.dart';

import '../primitives/eds_font.dart';
import '../theme/eds_theme_scope.dart';
import '../tokens/eds_color_scheme.dart';

/// A collapsible section with an expanding header, mirroring Swift's
/// `EDSCollapsibleSection`.
///
/// Deviation from Swift: SwiftUI's opacity + top-move expand transition is
/// approximated with [AnimatedSize]; the chevron rotates with
/// [AnimatedRotation]. Animations are disabled under
/// `MediaQuery.disableAnimations`.
class EdsCollapsibleSection extends StatefulWidget {
  const EdsCollapsibleSection(
    this.title, {
    super.key,
    required this.child,
    this.initiallyExpanded = false,
    this.isExpanded,
    this.onExpansionChanged,
  });

  final String? title;
  final Widget child;

  /// Initial state for uncontrolled usage.
  final bool initiallyExpanded;

  /// Controlled expansion state. When non-null, the caller owns the state.
  final bool? isExpanded;

  /// Called whenever the header requests an expansion state change.
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<EdsCollapsibleSection> createState() => _EdsCollapsibleSectionState();
}

class _EdsCollapsibleSectionState extends State<EdsCollapsibleSection> {
  late bool _isExpanded;

  bool get _effectiveExpanded => widget.isExpanded ?? _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded ?? widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant EdsCollapsibleSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != null &&
        widget.isExpanded != oldWidget.isExpanded) {
      _isExpanded = widget.isExpanded!;
    }
  }

  void _toggle() {
    final next = !_effectiveExpanded;
    widget.onExpansionChanged?.call(next);
    if (widget.isExpanded == null) {
      setState(() => _isExpanded = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 200);
    final title = widget.title;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.cardBackground,
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    if (title != null)
                      Expanded(
                        child: Text(
                          title,
                          style: tokens.typography
                              .edsTextStyle(EdsFontRole.sectionTitle)
                              .copyWith(color: scheme.textPrimary),
                        ),
                      )
                    else
                      const Spacer(),
                    AnimatedRotation(
                      turns: _effectiveExpanded ? 0.25 : 0,
                      duration: duration,
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.chevron_right,
                        size: 12,
                        color: scheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: duration,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: !_effectiveExpanded
                ? const SizedBox(width: double.infinity, height: 0)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (title != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: scheme.border,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,
                          children: <Widget>[widget.child],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
