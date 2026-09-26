import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'catalog_support.dart';

class EdsDesignSystemPreview extends StatefulWidget {
  const EdsDesignSystemPreview({super.key});

  @override
  State<EdsDesignSystemPreview> createState() => _EdsDesignSystemPreviewState();
}

class _EdsDesignSystemPreviewState extends State<EdsDesignSystemPreview> {
  late EdsColorTokens _draftColors;
  late EdsSpacingTokens _draftSpacing;
  late EdsRadiusTokens _draftRadius;
  late EdsTypographyTokens _draftTypography;
  late EdsControlSizeTokens _draftControlSize;
  late EdsHeroGradient _draftHeroGradient;

  EdsPresetTheme? _selectedPreset;
  String _previewSelection = 'home';
  int _editorModeIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTokens(EdsTheme.instance.tokens);
  }

  void _loadTokens(EdsDesignTokens tokens) {
    _draftColors = tokens.colors;
    _draftSpacing = tokens.spacing;
    _draftRadius = tokens.radius;
    _draftTypography = tokens.typography;
    _draftControlSize = tokens.controlSize;
    _draftHeroGradient = tokens.heroGradient;
  }

  EdsDesignTokens _buildDraftTokens() {
    return const EdsDesignTokens().copyWith(
      colors: _draftColors,
      spacing: _draftSpacing,
      radius: _draftRadius,
      typography: _draftTypography,
      controlSize: _draftControlSize,
      heroGradient: _draftHeroGradient,
    );
  }

  void _resetToTheme() {
    setState(() {
      _selectedPreset = null;
      _loadTokens(EdsTheme.instance.tokens);
    });
  }

  void _applyToTheme() {
    setState(() {
      EdsTheme.instance.tokens = EdsTheme.instance.tokens.copyWith(
        colors: _draftColors,
        spacing: _draftSpacing,
        radius: _draftRadius,
        typography: _draftTypography,
        controlSize: _draftControlSize,
        heroGradient: _draftHeroGradient,
      );
    });
  }

  void _exportJson() {
    final json = encodeThemeJson(_buildDraftTokens());
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('导出主题 JSON'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: SelectableText(
              json,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: json));
              Navigator.of(dialogContext).pop();
            },
            child: const Text('复制'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.edsScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= catalogSplitBreakpoint;
        return Column(
          children: <Widget>[
            _actionBar(context),
            Divider(height: 1, thickness: 1, color: scheme.border),
            Expanded(
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(child: _previewPanel(context)),
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: scheme.border,
                        ),
                        SizedBox(width: 380, child: _editorPanel(context)),
                      ],
                    )
                  : _narrowBody(context),
            ),
          ],
        );
      },
    );
  }

  Widget _narrowBody(BuildContext context) {
    final tokens = context.edsTokens;
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(tokens.spacing.sm),
          child: SegmentedButton<int>(
            segments: const <ButtonSegment<int>>[
              ButtonSegment<int>(value: 0, label: Text('预览')),
              ButtonSegment<int>(value: 1, label: Text('主题')),
            ],
            selected: <int>{_editorModeIndex},
            onSelectionChanged: (selection) => setState(() {
              _editorModeIndex = selection.first;
            }),
          ),
        ),
        Expanded(
          child: _editorModeIndex == 0
              ? _previewPanel(context)
              : _editorPanel(context),
        ),
      ],
    );
  }

  Widget _actionBar(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Container(
      color: scheme.cardBackground,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.sm,
      ),
      child: Wrap(
        spacing: tokens.spacing.md,
        runSpacing: tokens.spacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          PopupMenuButton<EdsPresetTheme?>(
            key: const Key('catalog.preview.presetPicker'),
            initialValue: _selectedPreset,
            onSelected: (preset) {
              if (preset == null) {
                return;
              }
              setState(() {
                _selectedPreset = preset;
                _loadTokens(preset.tokens);
              });
            },
            itemBuilder: (context) => <PopupMenuEntry<EdsPresetTheme?>>[
              const PopupMenuItem<EdsPresetTheme?>(
                value: null,
                height: 44,
                child: Text('（当前）'),
              ),
              for (final preset in EdsPresetTheme.allPresets)
                PopupMenuItem<EdsPresetTheme?>(
                  value: preset,
                  height: 44,
                  child: Text(preset.name),
                ),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '预设',
                  style: tokens.typography.captionStrong.copyWith(
                    color: scheme.textSecondary,
                  ),
                ),
                SizedBox(width: tokens.spacing.xs),
                Text(
                  _selectedPreset?.name ?? '（当前）',
                  style: tokens.typography.bodyStrong.copyWith(
                    color: scheme.textPrimary,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: scheme.textSecondary,
                ),
              ],
            ),
          ),
          EdsButton(
            '重置',
            role: EdsButtonRole.soft,
            systemImage: Icons.refresh,
            action: _resetToTheme,
          ),
          EdsButton('应用到 Runtime', action: _applyToTheme),
          EdsButton(
            '导出 JSON',
            role: EdsButtonRole.secondary,
            systemImage: Icons.file_download_outlined,
            action: _exportJson,
          ),
        ],
      ),
    );
  }

  Widget _previewPanel(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return ColoredBox(
      color: scheme.pageBackground,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: tokens.spacing.xl,
          children: <Widget>[
            _previewSection(
              context,
              '颜色',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: <Widget>[
                  _colorSwatchRow(context, 'Primary', _draftColors.primary),
                  _colorSwatchRow(context, 'Accent（废弃）', _draftColors.accent),
                  _colorSwatchRow(context, 'Success', _draftColors.success),
                  _colorSwatchRow(context, 'Warning', _draftColors.warning),
                  _colorSwatchRow(context, 'Danger', _draftColors.danger),
                ],
              ),
            ),
            _previewSection(
              context,
              '按钮',
              Column(
                spacing: _draftSpacing.md,
                children: <Widget>[
                  Wrap(
                    spacing: _draftSpacing.md,
                    runSpacing: _draftSpacing.md,
                    children: <Widget>[
                      _previewButton(
                        context,
                        '主要',
                        background: _draftColors.primary,
                        foreground: Colors.white,
                      ),
                      _previewButton(
                        context,
                        '次要',
                        background: Colors.transparent,
                        foreground: _draftColors.primary,
                        border: _draftColors.primary,
                      ),
                      _previewButton(
                        context,
                        '柔和',
                        background: _draftColors.primary.withValues(
                          alpha: 0.12,
                        ),
                        foreground: _draftColors.primary,
                      ),
                      _previewButton(
                        context,
                        '危险',
                        background: _draftColors.danger,
                        foreground: Colors.white,
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: _draftSpacing.md,
                    runSpacing: _draftSpacing.md,
                    children: <Widget>[
                      _previewBadge('Pro', _draftColors.primary),
                      _previewBadge('成功', _draftColors.success),
                      _previewBadge('警告', _draftColors.warning),
                      _previewBadge('危险', _draftColors.danger),
                    ],
                  ),
                ],
              ),
            ),
            _previewSection(
              context,
              '文字层级',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: _draftSpacing.xs,
                children: <Widget>[
                  Text(
                    '页面大标题 Hero',
                    style: TextStyle(
                      fontSize: _draftTypography.heroSize,
                      fontWeight: _fontWeight(_draftTypography.heroWeight),
                      color: _draftColors.primary,
                    ),
                  ),
                  Text(
                    '章节标题 Section',
                    style: TextStyle(
                      fontSize: _draftTypography.sectionTitleSize,
                      fontWeight: _fontWeight(
                        _draftTypography.sectionTitleWeight,
                      ),
                      color: _draftColors.primary,
                    ),
                  ),
                  Text(
                    '正文内容 Body',
                    style: TextStyle(
                      fontSize: _draftTypography.bodySize,
                      fontWeight: _fontWeight(_draftTypography.bodyWeight),
                      color: scheme.textPrimary,
                    ),
                  ),
                  Text(
                    '说明文字 Caption',
                    style: TextStyle(
                      fontSize: _draftTypography.captionSize,
                      fontWeight: _fontWeight(_draftTypography.captionWeight),
                      color: scheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _previewSection(
              context,
              '侧边栏',
              Row(children: <Widget>[_sidebarPreview(context), const Spacer()]),
            ),
            _previewSection(
              context,
              '卡片 & 控件尺寸',
              Column(
                spacing: _draftSpacing.md,
                children: <Widget>[
                  _heroPanelPreview(context),
                  _cardPreview(context),
                  _settingRowPreview(context),
                ],
              ),
            ),
            _previewSection(
              context,
              '圆角',
              Wrap(
                spacing: _draftSpacing.md,
                runSpacing: _draftSpacing.md,
                children: <Widget>[
                  _roundedRectPreview(context, 'sm', _draftRadius.sm),
                  _roundedRectPreview(context, 'md', _draftRadius.md),
                  _roundedRectPreview(context, 'lg', _draftRadius.lg),
                  _roundedRectPreview(context, 'xl', _draftRadius.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewSection(BuildContext context, String title, Widget content) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: _draftSpacing.sm,
      children: <Widget>[
        Text(
          title,
          style: tokens.typography.caption.copyWith(
            color: scheme.textSecondary,
          ),
        ),
        content,
      ],
    );
  }

  Widget _colorSwatchRow(BuildContext context, String label, Color color) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Row(
      children: <Widget>[
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: tokens.typography.caption.copyWith(
            color: scheme.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          EdsColorHex.toHex(color),
          style: tokens.typography.monoCaption.copyWith(
            color: scheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _previewButton(
    BuildContext context,
    String label, {
    required Color background,
    required Color foreground,
    Color? border,
  }) {
    return Container(
      height: _draftControlSize.buttonHeight,
      padding: EdgeInsets.symmetric(horizontal: _draftSpacing.md),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(_draftRadius.md),
        border: border != null ? Border.all(color: border, width: 1.5) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: _draftTypography.bodyStrongSize,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }

  Widget _previewBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _draftSpacing.xs,
        vertical: _draftSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: _draftTypography.captionStrongSize,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _sidebarPreview(BuildContext context) {
    final scheme = context.edsScheme;
    return Container(
      width: 160,
      padding: EdgeInsets.all(_draftSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.pageBackground,
        borderRadius: BorderRadius.circular(_draftRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: _draftSpacing.xxs,
        children: <Widget>[
          _sidebarItem(context, Icons.home_outlined, '首页', 'home'),
          _sidebarItem(context, Icons.settings_outlined, '设置', 'settings'),
        ],
      ),
    );
  }

  Widget _sidebarItem(
    BuildContext context,
    IconData icon,
    String label,
    String id,
  ) {
    final scheme = context.edsScheme;
    final isSelected = _previewSelection == id;
    return GestureDetector(
      onTap: () => setState(() {
        _previewSelection = id;
      }),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _draftSpacing.sm,
          vertical: _draftSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? _draftColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(_draftRadius.sm),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 20,
              child: Icon(
                icon,
                size: 16,
                color: isSelected ? _draftColors.primary : scheme.textSecondary,
              ),
            ),
            SizedBox(width: _draftSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: _draftTypography.body15Size,
                color: isSelected ? _draftColors.primary : scheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroPanelPreview(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_draftSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            _draftHeroGradient.startColor,
            _draftHeroGradient.endColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_draftRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: <Widget>[
          Text(
            'Hero 面板',
            style: TextStyle(
              fontSize: _draftTypography.pageTitleSize,
              fontWeight: _fontWeight('bold'),
              color: Colors.white,
            ),
          ),
          Text(
            '使用 HeroGradient 的渐变背景',
            style: TextStyle(
              fontSize: _draftTypography.bodySize,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardPreview(BuildContext context) {
    final scheme = context.edsScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_draftSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.subtleFill,
        borderRadius: BorderRadius.circular(_draftRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: _draftSpacing.xs,
        children: <Widget>[
          Text(
            '卡片标题',
            style: TextStyle(
              fontSize: _draftTypography.sectionTitleSize,
              fontWeight: _fontWeight(_draftTypography.sectionTitleWeight),
              color: scheme.textPrimary,
            ),
          ),
          Text(
            '卡片内容，浅灰色背景，带圆角',
            style: TextStyle(
              fontSize: _draftTypography.bodySize,
              color: scheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingRowPreview(BuildContext context) {
    final scheme = context.edsScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: _draftSpacing.sm),
      constraints: BoxConstraints(minHeight: _draftControlSize.rowMinHeight),
      alignment: Alignment.center,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(
                  '设置项标题',
                  style: TextStyle(
                    fontSize: _draftTypography.bodyStrongSize,
                    fontWeight: _fontWeight(_draftTypography.bodyStrongWeight),
                    color: scheme.textPrimary,
                  ),
                ),
                Text(
                  '设置项说明文字',
                  style: TextStyle(
                    fontSize: _draftTypography.captionSize,
                    color: scheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '值',
            style: TextStyle(
              fontSize: _draftTypography.bodyStrongSize,
              fontWeight: _fontWeight(_draftTypography.bodyStrongWeight),
              color: _draftColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundedRectPreview(
    BuildContext context,
    String label,
    double radius,
  ) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Column(
      spacing: 4,
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _draftColors.primary,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        Text(
          '${radius.round()}',
          style: tokens.typography.monoCaption.copyWith(
            color: scheme.textSecondary,
            fontSize: 10,
          ),
        ),
        Text(
          label,
          style: tokens.typography.caption.copyWith(
            color: scheme.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _editorPanel(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return ColoredBox(
      color: scheme.cardBackground,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _editorSection(context, '颜色', <Widget>[
              _colorRow(
                context,
                'Primary',
                _draftColors.primary,
                (color) => setState(() {
                  _draftColors = _draftColors.copyWith(primary: color);
                }),
              ),
              _colorRow(
                context,
                'Accent（废弃）',
                _draftColors.accent,
                (color) => setState(() {
                  _draftColors = _draftColors.copyWith(accent: color);
                }),
              ),
              _colorRow(
                context,
                'Success',
                _draftColors.success,
                (color) => setState(() {
                  _draftColors = _draftColors.copyWith(success: color);
                }),
              ),
              _colorRow(
                context,
                'Warning',
                _draftColors.warning,
                (color) => setState(() {
                  _draftColors = _draftColors.copyWith(warning: color);
                }),
              ),
              _colorRow(
                context,
                'Danger',
                _draftColors.danger,
                (color) => setState(() {
                  _draftColors = _draftColors.copyWith(danger: color);
                }),
              ),
              _colorRow(
                context,
                'Hero Start',
                _draftHeroGradient.startColor,
                (color) => setState(() {
                  _draftHeroGradient = _draftHeroGradient.copyWith(
                    startColor: color,
                  );
                }),
              ),
              _colorRow(
                context,
                'Hero End',
                _draftHeroGradient.endColor,
                (color) => setState(() {
                  _draftHeroGradient = _draftHeroGradient.copyWith(
                    endColor: color,
                  );
                }),
              ),
            ]),
            _editorSection(context, '间距', <Widget>[
              _sliderRow(
                context,
                'xxs',
                _draftSpacing.xxs,
                0,
                80,
                (value) => setState(() {
                  _draftSpacing = _draftSpacing.copyWith(xxs: value);
                }),
              ),
              _sliderRow(
                context,
                'xs',
                _draftSpacing.xs,
                0,
                80,
                (value) => setState(() {
                  _draftSpacing = _draftSpacing.copyWith(xs: value);
                }),
              ),
              _sliderRow(
                context,
                'sm',
                _draftSpacing.sm,
                0,
                80,
                (value) => setState(() {
                  _draftSpacing = _draftSpacing.copyWith(sm: value);
                }),
              ),
              _sliderRow(
                context,
                'md',
                _draftSpacing.md,
                0,
                80,
                (value) => setState(() {
                  _draftSpacing = _draftSpacing.copyWith(md: value);
                }),
              ),
              _sliderRow(
                context,
                'lg',
                _draftSpacing.lg,
                0,
                80,
                (value) => setState(() {
                  _draftSpacing = _draftSpacing.copyWith(lg: value);
                }),
              ),
              _sliderRow(
                context,
                'xl',
                _draftSpacing.xl,
                0,
                80,
                (value) => setState(() {
                  _draftSpacing = _draftSpacing.copyWith(xl: value);
                }),
              ),
              _sliderRow(
                context,
                'xxl',
                _draftSpacing.xxl,
                0,
                80,
                (value) => setState(() {
                  _draftSpacing = _draftSpacing.copyWith(xxl: value);
                }),
              ),
              _sliderRow(
                context,
                'xxxl',
                _draftSpacing.xxxl,
                0,
                80,
                (value) => setState(() {
                  _draftSpacing = _draftSpacing.copyWith(xxxl: value);
                }),
              ),
            ]),
            _editorSection(context, '圆角', <Widget>[
              _sliderRow(
                context,
                'sm',
                _draftRadius.sm,
                0,
                40,
                (value) => setState(() {
                  _draftRadius = _draftRadius.copyWith(sm: value);
                }),
              ),
              _sliderRow(
                context,
                'md',
                _draftRadius.md,
                0,
                40,
                (value) => setState(() {
                  _draftRadius = _draftRadius.copyWith(md: value);
                }),
              ),
              _sliderRow(
                context,
                'lg',
                _draftRadius.lg,
                0,
                40,
                (value) => setState(() {
                  _draftRadius = _draftRadius.copyWith(lg: value);
                }),
              ),
              _sliderRow(
                context,
                'xl',
                _draftRadius.xl,
                0,
                40,
                (value) => setState(() {
                  _draftRadius = _draftRadius.copyWith(xl: value);
                }),
              ),
            ]),
            _editorSection(context, '字体大小', <Widget>[
              _stepperRow(
                context,
                'Hero',
                _draftTypography.heroSize,
                16,
                60,
                (value) => setState(() {
                  _draftTypography = _draftTypography.copyWith(heroSize: value);
                }),
              ),
              _stepperRow(
                context,
                'PageTitle',
                _draftTypography.pageTitleSize,
                10,
                40,
                (value) => setState(() {
                  _draftTypography = _draftTypography.copyWith(
                    pageTitleSize: value,
                  );
                }),
              ),
              _stepperRow(
                context,
                'SectionTitle',
                _draftTypography.sectionTitleSize,
                10,
                36,
                (value) => setState(() {
                  _draftTypography = _draftTypography.copyWith(
                    sectionTitleSize: value,
                  );
                }),
              ),
              _stepperRow(
                context,
                'Body15',
                _draftTypography.body15Size,
                10,
                32,
                (value) => setState(() {
                  _draftTypography = _draftTypography.copyWith(
                    body15Size: value,
                  );
                }),
              ),
              _stepperRow(
                context,
                'Body',
                _draftTypography.bodySize,
                10,
                28,
                (value) => setState(() {
                  _draftTypography = _draftTypography.copyWith(bodySize: value);
                }),
              ),
              _stepperRow(
                context,
                'Caption',
                _draftTypography.captionSize,
                8,
                24,
                (value) => setState(() {
                  _draftTypography = _draftTypography.copyWith(
                    captionSize: value,
                  );
                }),
              ),
            ]),
            _editorSection(context, '控件尺寸', <Widget>[
              _stepperRow(
                context,
                'Button Height',
                _draftControlSize.buttonHeight,
                24,
                60,
                (value) => setState(() {
                  _draftControlSize = _draftControlSize.copyWith(
                    buttonHeight: value,
                  );
                }),
              ),
              _stepperRow(
                context,
                'Field Height',
                _draftControlSize.fieldHeight,
                24,
                60,
                (value) => setState(() {
                  _draftControlSize = _draftControlSize.copyWith(
                    fieldHeight: value,
                  );
                }),
              ),
              _stepperRow(
                context,
                'Row MinHeight',
                _draftControlSize.rowMinHeight,
                36,
                80,
                (value) => setState(() {
                  _draftControlSize = _draftControlSize.copyWith(
                    rowMinHeight: value,
                  );
                }),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _editorSection(BuildContext context, String title, List<Widget> rows) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: tokens.typography.sectionTitle.copyWith(
            color: scheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Column(spacing: 8, children: rows),
        const SizedBox(height: 12),
        Divider(height: 1, thickness: 1, color: scheme.border),
      ],
    );
  }

  Widget _colorRow(
    BuildContext context,
    String label,
    Color color,
    ValueChanged<Color> onColorChanged,
  ) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Row(
      children: <Widget>[
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: tokens.typography.caption.copyWith(
              color: scheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _pickColor(context, color, onColorChanged),
          child: Container(
            width: 28,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: scheme.border, width: 1),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          EdsColorHex.toHex(color),
          style: tokens.typography.monoCaption.copyWith(
            color: scheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Future<void> _pickColor(
    BuildContext context,
    Color color,
    ValueChanged<Color> onColorChanged,
  ) async {
    final newColor = await showDialog<Color>(
      context: context,
      builder: (dialogContext) => CatalogColorPickerDialog(initialColor: color),
    );
    if (!mounted) {
      return;
    }
    if (newColor == null) {
      return;
    }
    onColorChanged(newColor);
  }

  Widget _sliderRow(
    BuildContext context,
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Row(
      children: <Widget>[
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: tokens.typography.caption.copyWith(
              color: scheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Slider(
            value: value.clamp(min, max).toDouble(),
            min: min,
            max: max,
            divisions: (max - min).round(),
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text(
            '${value.round()}',
            textAlign: TextAlign.end,
            style: tokens.typography.monoCaption.copyWith(
              color: scheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepperRow(
    BuildContext context,
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Row(
      children: <Widget>[
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: tokens.typography.caption.copyWith(
              color: scheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: value <= min
              ? null
              : () => onChanged((value - 1).clamp(min, max).toDouble()),
          icon: const Icon(Icons.remove),
          visualDensity: VisualDensity.compact,
        ),
        SizedBox(
          width: 36,
          child: Text(
            '${value.round()}',
            textAlign: TextAlign.center,
            style: tokens.typography.monoCaption.copyWith(
              color: scheme.textSecondary,
            ),
          ),
        ),
        IconButton(
          onPressed: value >= max
              ? null
              : () => onChanged((value + 1).clamp(min, max).toDouble()),
          icon: const Icon(Icons.add),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  FontWeight _fontWeight(String weight) {
    return switch (weight) {
      'bold' => FontWeight.w700,
      'semibold' => FontWeight.w600,
      'medium' => FontWeight.w500,
      'light' => FontWeight.w300,
      'thin' => FontWeight.w200,
      _ => FontWeight.w400,
    };
  }
}

class CatalogColorPickerDialog extends StatefulWidget {
  const CatalogColorPickerDialog({super.key, required this.initialColor});

  final Color initialColor;

  @override
  State<CatalogColorPickerDialog> createState() =>
      _CatalogColorPickerDialogState();
}

class _CatalogColorPickerDialogState extends State<CatalogColorPickerDialog> {
  late final TextEditingController _hexController;
  late int _r;
  late int _g;
  late int _b;

  @override
  void initState() {
    super.initState();
    _r = (widget.initialColor.r * 255).round();
    _g = (widget.initialColor.g * 255).round();
    _b = (widget.initialColor.b * 255).round();
    _hexController = TextEditingController(
      text: EdsColorHex.toHex(widget.initialColor),
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  Color get _currentColor => Color.fromARGB(255, _r, _g, _b);

  void _syncHexField() {
    _hexController.text = EdsColorHex.toHex(_currentColor);
  }

  void _onHexChanged(String text) {
    final stripped = text.startsWith('#') ? text.substring(1) : text;
    if (stripped.length != 3 && stripped.length != 6) {
      return;
    }
    final parsed = EdsColorHex.parseRgb('#$stripped');
    setState(() {
      _r = (parsed.r * 255).round();
      _g = (parsed.g * 255).round();
      _b = (parsed.b * 255).round();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return AlertDialog(
      title: const Text('选择颜色'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _currentColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: scheme.border, width: 1),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _hexController,
                    onChanged: _onHexChanged,
                    style: tokens.typography.monoCaption.copyWith(
                      color: scheme.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _channelSlider(
              'R',
              _r,
              (value) => setState(() {
                _r = value;
                _syncHexField();
              }),
            ),
            _channelSlider(
              'G',
              _g,
              (value) => setState(() {
                _g = value;
                _syncHexField();
              }),
            ),
            _channelSlider(
              'B',
              _b,
              (value) => setState(() {
                _b = value;
                _syncHexField();
              }),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_currentColor),
          child: const Text('确定'),
        ),
      ],
    );
  }

  Widget _channelSlider(String label, int value, ValueChanged<int> onChanged) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Row(
      children: <Widget>[
        SizedBox(
          width: 20,
          child: Text(
            label,
            style: tokens.typography.caption.copyWith(
              color: scheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 255,
            divisions: 255,
            label: value.toString(),
            onChanged: (newValue) => onChanged(newValue.round()),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$value',
            textAlign: TextAlign.end,
            style: tokens.typography.monoCaption.copyWith(
              color: scheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
