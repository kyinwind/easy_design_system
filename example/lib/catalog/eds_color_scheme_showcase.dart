import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';

class EdsColorSchemeShowcase extends StatefulWidget {
  const EdsColorSchemeShowcase({super.key});

  @override
  State<EdsColorSchemeShowcase> createState() => _EdsColorSchemeShowcaseState();
}

class _EdsColorSchemeShowcaseState extends State<EdsColorSchemeShowcase> {
  EdsPresetTheme _preset = EdsPresetTheme.blue;
  Brightness _brightness = Brightness.light;
  bool _checked = true;
  bool _toggle = true;
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    return EdsThemeScope(
      preset: _preset,
      brightness: _brightness,
      child: Builder(
        builder: (context) {
          final tokens = context.edsTokens;
          final scheme = context.edsScheme;
          return ColoredBox(
            key: const Key('catalog.colorScheme.page'),
            color: scheme.surfacePage,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(tokens.spacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: tokens.spacing.xl,
                  children: <Widget>[
                    _toolbar(context),
                    _colorFoundation(context),
                    _layerShowcase(context),
                    _componentMatrix(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _toolbar(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceRaised,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: scheme.borderSubtle),
      ),
      child: Wrap(
        spacing: tokens.spacing.lg,
        runSpacing: tokens.spacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Text(
            'ColorScheme 2.0',
            style: tokens.typography.sectionTitle.copyWith(
              color: scheme.foregroundPrimary,
            ),
          ),
          PopupMenuButton<EdsPresetTheme>(
            initialValue: _preset,
            color: scheme.surfaceOverlay,
            onSelected: (value) => setState(() => _preset = value),
            itemBuilder: (context) => <PopupMenuEntry<EdsPresetTheme>>[
              for (final preset in <EdsPresetTheme>[
                EdsPresetTheme.blue,
                EdsPresetTheme.orange,
                EdsPresetTheme.purple,
              ])
                PopupMenuItem<EdsPresetTheme>(
                  value: preset,
                  child: Text(
                    preset.name,
                    style: tokens.typography.body.copyWith(
                      color: scheme.foregroundPrimary,
                    ),
                  ),
                ),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _preset.name,
                  style: tokens.typography.body.copyWith(
                    color: scheme.foregroundPrimary,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: scheme.foregroundSecondary,
                ),
              ],
            ),
          ),
          Wrap(
            spacing: tokens.spacing.xs,
            children: <Widget>[
              EdsChoicePill(
                'Light',
                selected: _brightness == Brightness.light,
                icon: const Icon(Icons.light_mode_outlined),
                onChanged: (_) {
                  setState(() => _brightness = Brightness.light);
                },
              ),
              EdsChoicePill(
                'Dark',
                selected: _brightness == Brightness.dark,
                icon: const Icon(Icons.dark_mode_outlined),
                onChanged: (_) {
                  setState(() => _brightness = Brightness.dark);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _colorFoundation(BuildContext context) {
    final scheme = context.edsScheme;
    return _section(
      context,
      'Color Foundation',
      'Neutral Foundation + Brand / Status semantic families',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          _roleGroup(
            context,
            'Surface',
            <(String, Color)>[
              ('Page', scheme.surfacePage),
              ('Base', scheme.surfaceBase),
              ('Raised', scheme.surfaceRaised),
              ('Sunken', scheme.surfaceSunken),
              ('Overlay', scheme.surfaceOverlay),
              ('Disabled', scheme.surfaceDisabled),
            ],
          ),
          _roleGroup(
            context,
            'Foreground',
            <(String, Color)>[
              ('Primary', scheme.foregroundPrimary),
              ('Secondary', scheme.foregroundSecondary),
              ('Tertiary', scheme.foregroundTertiary),
              ('Disabled', scheme.foregroundDisabled),
              ('Inverse', scheme.foregroundInverse),
            ],
          ),
          _roleGroup(
            context,
            'Border',
            <(String, Color)>[
              ('Subtle', scheme.borderSubtle),
              ('Default', scheme.borderDefault),
              ('Strong', scheme.borderStrong),
              ('Selected', scheme.borderSelected),
              ('Focus', scheme.borderFocus),
              ('Danger', scheme.borderDanger),
            ],
          ),
          _semanticFamily(
            context,
            'Brand',
            scheme.brandForeground,
            scheme.brandSurface,
            scheme.brandSurfaceStrong,
            scheme.brandBorder,
            scheme.brandOnStrong,
          ),
          _semanticFamily(
            context,
            'Information',
            scheme.informationForeground,
            scheme.informationSurface,
            scheme.informationSurfaceStrong,
            scheme.informationBorder,
            scheme.informationOnStrong,
          ),
          _semanticFamily(
            context,
            'Success',
            scheme.successForeground,
            scheme.successSurface,
            scheme.successSurfaceStrong,
            scheme.successBorder,
            scheme.successOnStrong,
          ),
          _semanticFamily(
            context,
            'Warning',
            scheme.warningForeground,
            scheme.warningSurface,
            scheme.warningSurfaceStrong,
            scheme.warningBorder,
            scheme.warningOnStrong,
          ),
          _semanticFamily(
            context,
            'Danger',
            scheme.dangerForeground,
            scheme.dangerSurface,
            scheme.dangerSurfaceStrong,
            scheme.dangerBorder,
            scheme.dangerOnStrong,
          ),
        ],
      ),
    );
  }

  Widget _layerShowcase(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return _section(
      context,
      'Layer / Context',
      'Page → Raised Card → Nested content → Field；Overlay 单独验证',
      Container(
        width: double.infinity,
        color: scheme.surfacePage,
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: tokens.spacing.md,
          children: <Widget>[
            Text(
              'Base / Page',
              style: tokens.typography.bodyStrong.copyWith(
                color: scheme.foregroundPrimary,
              ),
            ),
            EdsCard(
              style: EdsCardStyle.raised,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: tokens.spacing.md,
                children: <Widget>[
                  const EdsSectionTitle(
                    'Raised Card',
                    subtitle: 'Field 会读取当前 Layer Context',
                  ),
                  const EdsTextField(
                    label: 'Raised Field',
                    hint: '观察 surface 与 border',
                  ),
                  EdsCard(
                    style: EdsCardStyle.raised,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: tokens.spacing.sm,
                      children: const <Widget>[
                        EdsLabelText('Nested Card'),
                        EdsTextField(
                          label: 'Nested Field',
                          hint: '更深一层仍保持可辨识',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            EdsButton(
              '打开 Overlay Dialog',
              role: EdsButtonRole.secondary,
              action: () {
                showDialog<void>(
                  context: context,
                  builder: (dialogContext) => EdsAlertDialog(
                    title: 'Overlay',
                    content: const Text('Dialog 使用 surfaceOverlay 与强边框。'),
                    actions: <Widget>[
                      EdsButton(
                        '关闭',
                        action: () => Navigator.of(dialogContext).pop(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _componentMatrix(BuildContext context) {
    final tokens = context.edsTokens;
    return _section(
      context,
      'Component Matrix',
      '核心组件在同一 Preset / Brightness 下的语义一致性',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tokens.spacing.lg,
        children: <Widget>[
          Wrap(
            spacing: tokens.spacing.sm,
            runSpacing: tokens.spacing.sm,
            children: <Widget>[
              for (final tone in EdsButtonTone.values)
                EdsButton.styled(
                  tone.name,
                  emphasis: EdsButtonEmphasis.filled,
                  tone: tone,
                  action: () {},
                ),
            ],
          ),
          Wrap(
            spacing: tokens.spacing.sm,
            runSpacing: tokens.spacing.sm,
            children: const <Widget>[
              EdsBadge('Brand', style: EdsBadgeStyle.brand),
              EdsBadge('Success', style: EdsBadgeStyle.success),
              EdsBadge('Warning', style: EdsBadgeStyle.warning),
              EdsBadge('Danger', style: EdsBadgeStyle.danger),
            ],
          ),
          EdsCheckbox(
            value: _checked,
            label: 'Selected → Brand',
            onChanged: (value) => setState(() => _checked = value ?? false),
          ),
          EdsToggle(
            isOn: _toggle,
            label: 'Active → Brand',
            onChanged: (value) => setState(() => _toggle = value),
          ),
          EdsSegmented<int>(
            value: _segment,
            values: const <int>[0, 1, 2],
            labelBuilder: (value) => 'Option ${value + 1}',
            onChanged: (value) => setState(() => _segment = value),
          ),
          const EdsTextField(
            label: 'Field',
            hint: 'Focus → Brand / Error → Danger',
          ),
          const EdsTextField(
            label: 'Error Field',
            errorText: '示例错误信息',
          ),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    String subtitle,
    Widget child,
  ) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.spacing.sm,
      children: <Widget>[
        EdsSectionTitle(title, subtitle: subtitle),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(tokens.spacing.lg),
          decoration: BoxDecoration(
            color: scheme.surfaceBase,
            borderRadius: BorderRadius.circular(tokens.radius.lg),
            border: Border.all(color: scheme.borderSubtle),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _roleGroup(
    BuildContext context,
    String title,
    List<(String, Color)> colors,
  ) {
    final tokens = context.edsTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.spacing.xs,
      children: <Widget>[
        EdsLabelText(title),
        Wrap(
          spacing: tokens.spacing.sm,
          runSpacing: tokens.spacing.sm,
          children: <Widget>[
            for (final entry in colors) _swatch(context, entry.$1, entry.$2),
          ],
        ),
      ],
    );
  }

  Widget _semanticFamily(
    BuildContext context,
    String title,
    Color foreground,
    Color surface,
    Color strong,
    Color border,
    Color onStrong,
  ) {
    return _roleGroup(
      context,
      title,
      <(String, Color)>[
        ('Foreground', foreground),
        ('Surface', surface),
        ('Strong', strong),
        ('Border', border),
        ('OnStrong', onStrong),
      ],
    );
  }

  Widget _swatch(BuildContext context, String label, Color color) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return SizedBox(
      width: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tokens.spacing.xxs,
        children: <Widget>[
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(tokens.radius.sm),
              border: Border.all(color: scheme.borderSubtle),
            ),
          ),
          Text(
            label,
            style: tokens.typography.captionStrong.copyWith(
              color: scheme.foregroundPrimary,
            ),
          ),
          Text(
            EdsColorHex.toHex(color),
            style: tokens.typography.monoCaption.copyWith(
              color: scheme.foregroundSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
