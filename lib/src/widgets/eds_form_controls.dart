import 'package:flutter/material.dart';

import '../adaptive/eds_interaction_profile.dart';
import '../adaptive/eds_resolved_metrics.dart';
import '../adaptive/eds_size_class.dart';
import '../primitives/eds_font.dart';
import '../theme/eds_theme_scope.dart';
import '../tokens/eds_color_scheme.dart';

/// EDS-styled checkbox with optional text label.
///
/// The underlying Flutter [Checkbox] keeps the platform keyboard, focus and
/// semantics behavior while EDS supplies color, typography and spacing.
class EdsCheckbox extends StatelessWidget {
  const EdsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
  });

  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final String? tooltip;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;

    Widget control = Checkbox(
      value: value,
      onChanged: onChanged,
      focusNode: focusNode,
      autofocus: autofocus,
      activeColor: tokens.colors.primary,
      checkColor: Colors.white,
      side: BorderSide(color: scheme.border, width: tokens.stroke.hairline),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.sm / 2),
      ),
    );

    final text = label;
    if (text != null && text.isNotEmpty) {
      control = Semantics(
        container: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(tokens.radius.sm),
          onTap: onChanged == null ? null : () => onChanged!(!value),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              control,
              SizedBox(width: tokens.spacing.xs),
              Flexible(
                child: Text(
                  text,
                  style: tokens.typography
                      .edsTextStyle(EdsFontRole.body)
                      .copyWith(color: scheme.textPrimary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (tooltip != null && tooltip!.isNotEmpty) {
      control = Tooltip(message: tooltip!, child: control);
    }
    return control;
  }
}

/// A generic EDS dropdown for settings and forms.
class EdsDropdown<T> extends StatelessWidget {
  const EdsDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.labelBuilder,
    this.onChanged,
    this.hint,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.isExpanded = false,
  });

  final T? value;
  final List<T> items;
  final String Function(T value) labelBuilder;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final String? tooltip;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final metrics = EdsResolvedMetrics.resolve(
      tokens: tokens,
      profile: context.edsInteractionProfile,
      horizontalSizeClass: context.edsSizeClass,
    );

    Widget result = Container(
      constraints: BoxConstraints(
        minHeight: metrics.interactiveHeight(tokens.controlSize.fieldHeight),
      ),
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing.sm),
      decoration: BoxDecoration(
        color: scheme.cardBackground,
        border: Border.all(
          color: scheme.border,
          width: tokens.stroke.hairline,
        ),
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: <DropdownMenuItem<T>>[
            for (final item in items)
              DropdownMenuItem<T>(
                value: item,
                child: Text(
                  labelBuilder(item),
                  style: tokens.typography
                      .edsTextStyle(EdsFontRole.body)
                      .copyWith(color: scheme.textPrimary),
                ),
              ),
          ],
          hint: hint == null
              ? null
              : Text(
                  hint!,
                  style: tokens.typography
                      .edsTextStyle(EdsFontRole.body)
                      .copyWith(color: scheme.textSecondary),
                ),
          onChanged: onChanged,
          focusNode: focusNode,
          autofocus: autofocus,
          isExpanded: isExpanded,
          borderRadius: BorderRadius.circular(tokens.radius.md),
          dropdownColor: scheme.cardBackground,
          iconEnabledColor: scheme.textSecondary,
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      result = Tooltip(message: tooltip!, child: result);
    }
    return result;
  }
}

/// Generic single-selection segmented control.
///
/// Uses Flutter's keyboard and semantics behavior while applying EDS tokens
/// to the container, selected state and typography.
class EdsSegmented<T> extends StatelessWidget {
  const EdsSegmented({
    super.key,
    required this.value,
    required this.values,
    required this.labelBuilder,
    this.onChanged,
    this.iconBuilder,
    this.tooltipBuilder,
  });

  final T value;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T>? onChanged;
  final Widget? Function(T value)? iconBuilder;
  final String? Function(T value)? tooltipBuilder;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;

    return SegmentedButton<T>(
      segments: <ButtonSegment<T>>[
        for (final item in values)
          ButtonSegment<T>(
            value: item,
            label: Text(labelBuilder(item)),
            icon: iconBuilder?.call(item),
            tooltip: tooltipBuilder?.call(item),
          ),
      ],
      selected: <T>{value},
      onSelectionChanged: onChanged == null
          ? null
          : (selection) {
              if (selection.isNotEmpty) {
                onChanged!(selection.first);
              }
            },
      showSelectedIcon: false,
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          tokens.typography.edsTextStyle(EdsFontRole.bodyStrong),
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? tokens.colors.primary
              : scheme.textSecondary,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? tokens.colors.primarySoft
              : scheme.cardBackground,
        ),
        side: WidgetStatePropertyAll(
          BorderSide(
            color: scheme.border,
            width: tokens.stroke.hairline,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radius.md),
          ),
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
