import 'package:flutter/material.dart';

import '../adaptive/eds_interaction_profile.dart';
import '../adaptive/eds_resolved_metrics.dart';
import '../adaptive/eds_size_class.dart';
import '../color/eds_layer.dart';
import '../color/eds_layer_resolver.dart';
import '../primitives/eds_font.dart';
import '../theme/eds_theme_scope.dart';

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
      activeColor: scheme.brandSurfaceStrong,
      checkColor: scheme.brandOnStrong,
      side: BorderSide(color: scheme.borderDefault, width: tokens.stroke.hairline),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.sm / 2),
      ),
    );

    final text = label;
    if (text != null && text.isNotEmpty) {
      control = Semantics(
        container: true,
        child: Material(
          type: MaterialType.transparency,
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
                        .copyWith(color: scheme.foregroundPrimary),
                  ),
                ),
              ],
            ),
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
        color: EdsLayerResolver.fieldSurface(scheme, context.edsLayer),
        border: Border.all(color: scheme.borderDefault, width: tokens.stroke.hairline),
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
                      .copyWith(color: scheme.foregroundPrimary),
                ),
              ),
          ],
          hint: hint == null
              ? null
              : Text(
                  hint!,
                  style: tokens.typography
                      .edsTextStyle(EdsFontRole.body)
                      .copyWith(color: scheme.foregroundSecondary),
                ),
          onChanged: onChanged,
          focusNode: focusNode,
          autofocus: autofocus,
          isExpanded: isExpanded,
          borderRadius: BorderRadius.circular(tokens.radius.md),
          dropdownColor: scheme.surfaceOverlay,
          iconEnabledColor: scheme.foregroundSecondary,
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      result = Tooltip(message: tooltip!, child: result);
    }
    return result;
  }
}

/// Form-integrated counterpart to [EdsDropdown].
///
/// Use this inside a Flutter [Form] when validation, saving or automatic
/// validation is required.
class EdsDropdownFormField<T> extends StatelessWidget {
  const EdsDropdownFormField({
    super.key,
    required this.items,
    required this.labelBuilder,
    this.initialValue,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.errorBuilder,
    this.errorText,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.label,
    this.hint,
    this.focusNode,
    this.autofocus = false,
    this.isExpanded = false,
    this.enabled = true,
  });

  final T? initialValue;
  final List<T> items;
  final String Function(T value) labelBuilder;
  final ValueChanged<T?>? onChanged;
  final FormFieldSetter<T>? onSaved;
  final FormFieldValidator<T>? validator;
  final FormFieldErrorBuilder? errorBuilder;

  /// Forces an error state without running [validator].
  final String? errorText;

  final AutovalidateMode autovalidateMode;
  final String? label;
  final String? hint;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool isExpanded;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;

    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      items: <DropdownMenuItem<T>>[
        for (final item in items)
          DropdownMenuItem<T>(
            value: item,
            child: Text(
              labelBuilder(item),
              style: tokens.typography
                  .edsTextStyle(EdsFontRole.body)
                  .copyWith(color: scheme.foregroundPrimary),
            ),
          ),
      ],
      onChanged: enabled ? onChanged : null,
      onSaved: onSaved,
      validator: validator,
      errorBuilder: errorBuilder,
      forceErrorText: errorText,
      autovalidateMode: autovalidateMode,
      focusNode: focusNode,
      autofocus: autofocus,
      isExpanded: isExpanded,
      dropdownColor: scheme.surfaceOverlay,
      iconEnabledColor: scheme.foregroundSecondary,
      borderRadius: BorderRadius.circular(tokens.radius.md),
      hint: hint == null
          ? null
          : Text(
              hint!,
              style: tokens.typography
                  .edsTextStyle(EdsFontRole.body)
                  .copyWith(color: scheme.foregroundSecondary),
            ),
      decoration: _edsInputDecoration(
        context,
        label: label,
      ),
    );
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
              ? scheme.brandForeground
              : scheme.foregroundSecondary,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.brandSurface
              : EdsLayerResolver.fieldSurface(scheme, context.edsLayer),
        ),
        side: WidgetStatePropertyAll(
          BorderSide(color: scheme.borderDefault, width: tokens.stroke.hairline),
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

/// Token-driven text field for settings and forms.
class EdsTextField extends StatelessWidget {
  const EdsTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.obscureText = false,
    this.minLines,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;
  final bool obscureText;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  /// Explicit error text for non-Form usage.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final textStyle = tokens.typography
        .edsTextStyle(EdsFontRole.body)
        .copyWith(color: scheme.foregroundPrimary);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      autofocus: autofocus,
      obscureText: obscureText,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: textStyle,
      decoration: _edsInputDecoration(
        context,
        label: label,
        hint: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        errorText: errorText,
      ),
    );
  }
}

/// Form-integrated counterpart to [EdsTextField].
///
/// Use this inside a Flutter [Form] when validation, saving or automatic
/// validation is required. For simple input without Form lifecycle, prefer
/// [EdsTextField].
class EdsTextFormField extends StatelessWidget {
  const EdsTextFormField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.label,
    this.hint,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.onSaved,
    this.validator,
    this.errorBuilder,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.enabled = true,
    this.autofocus = false,
    this.obscureText = false,
    this.minLines,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
  }) : assert(
          controller == null || initialValue == null,
          'initialValue must be null when controller is provided.',
        );

  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;

  /// Forces an error state without running [validator].
  final String? errorText;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final FormFieldErrorBuilder? errorBuilder;
  final AutovalidateMode autovalidateMode;
  final bool enabled;
  final bool autofocus;
  final bool obscureText;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final textStyle = tokens.typography
        .edsTextStyle(EdsFontRole.body)
        .copyWith(color: scheme.foregroundPrimary);

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      enabled: enabled,
      autofocus: autofocus,
      obscureText: obscureText,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onSaved: onSaved,
      validator: validator,
      errorBuilder: errorBuilder,
      forceErrorText: errorText,
      autovalidateMode: autovalidateMode,
      style: textStyle,
      decoration: _edsInputDecoration(
        context,
        label: label,
        hint: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

/// Groups [EdsRadio] widgets with Flutter's modern RadioGroup behavior.
///
/// This provides APG-compatible keyboard navigation and semantics across all
/// radio choices in the subtree.
class EdsRadioGroup<T> extends StatelessWidget {
  const EdsRadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.child,
  });

  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<T>(
      groupValue: groupValue,
      onChanged: onChanged,
      child: child,
    );
  }
}

/// A single generic radio choice with optional label.
///
/// Place multiple radios under one [EdsRadioGroup] to get mutual exclusion,
/// arrow-key navigation, Space activation and group semantics.
class EdsRadio<T> extends StatelessWidget {
  const EdsRadio({
    super.key,
    required this.value,
    this.label,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
  });

  final T value;
  final String? label;
  final bool enabled;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final registry = RadioGroup.maybeOf<T>(context);
    final selected = registry?.groupValue == value;
    final isEnabled = enabled && registry != null;

    final radio = Radio<T>(
      value: value,
      focusNode: focusNode,
      autofocus: autofocus,
      activeColor: scheme.brandSurfaceStrong,
      enabled: isEnabled,
    );

    final text = label;
    if (text == null || text.isEmpty) {
      return radio;
    }

    return Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: true,
      enabled: isEnabled,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(tokens.radius.sm),
          onTap: isEnabled ? () => registry.onChanged(value) : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              radio,
              SizedBox(width: tokens.spacing.xs),
              Flexible(
                child: Text(
                  text,
                  style: tokens.typography
                      .edsTextStyle(EdsFontRole.body)
                      .copyWith(color: scheme.foregroundPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// EDS-styled slider preserving Flutter's keyboard and accessibility behavior.
class EdsSlider extends StatelessWidget {
  const EdsSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.label,
    this.semanticFormatterCallback,
    this.focusNode,
    this.autofocus = false,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final String Function(double value)? semanticFormatterCallback;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: scheme.brandSurfaceStrong,
        inactiveTrackColor: scheme.borderDefault,
        thumbColor: scheme.brandSurfaceStrong,
        overlayColor: scheme.brandSurface,
        valueIndicatorColor: scheme.brandSurfaceStrong,
        valueIndicatorTextStyle: tokens.typography
            .edsTextStyle(EdsFontRole.captionStrong)
            .copyWith(color: scheme.brandOnStrong),
      ),
      child: Slider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        semanticFormatterCallback: semanticFormatterCallback,
        focusNode: focusNode,
        autofocus: autofocus,
      ),
    );
  }
}

InputDecoration _edsInputDecoration(
  BuildContext context, {
  String? label,
  String? hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? errorText,
}) {
  final tokens = context.edsTokens;
  final scheme = context.edsScheme;
  final textStyle = tokens.typography
      .edsTextStyle(EdsFontRole.body)
      .copyWith(color: scheme.foregroundPrimary);

  return InputDecoration(
    labelText: label,
    hintText: hint,
    hintStyle: textStyle.copyWith(color: scheme.foregroundTertiary),
    labelStyle: tokens.typography
        .edsTextStyle(EdsFontRole.caption)
        .copyWith(color: scheme.foregroundSecondary),
    errorText: errorText,
    errorStyle: tokens.typography
        .edsTextStyle(EdsFontRole.caption)
        .copyWith(color: scheme.dangerForeground),
    filled: true,
    fillColor: EdsLayerResolver.fieldSurface(scheme, context.edsLayer),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    contentPadding: EdgeInsets.symmetric(
      horizontal: tokens.spacing.sm,
      vertical: tokens.spacing.xs,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.radius.md),
      borderSide: BorderSide(
        color: scheme.borderDefault,
        width: tokens.stroke.hairline,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.radius.md),
      borderSide: BorderSide(color: scheme.borderFocus, width: 1.5),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.radius.md),
      borderSide: BorderSide(
        color: scheme.borderDisabled,
        width: tokens.stroke.hairline,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.radius.md),
      borderSide: BorderSide(
        color: scheme.dangerBorder,
        width: tokens.stroke.hairline,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.radius.md),
      borderSide: BorderSide(color: scheme.dangerBorder, width: 1.5),
    ),
  );
}
