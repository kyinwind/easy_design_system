import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

enum _CalibrationProfile { current, material, fluent }

class EdsColorCalibrationShowcase extends StatelessWidget {
  const EdsColorCalibrationShowcase({
    super.key,
    required this.preset,
    required this.brightness,
  });

  final EdsPresetTheme preset;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.spacing.sm,
      children: <Widget>[
        const EdsSectionTitle(
          '语义色彩校准',
          subtitle: '同一 Seed、同一亮度、同一组真实控件；这里只比较候选映射，不改变运行时默认值。',
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(tokens.spacing.lg),
          decoration: BoxDecoration(
            color: scheme.surfaceBase,
            borderRadius: BorderRadius.circular(tokens.radius.lg),
            border: Border.all(color: scheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: tokens.spacing.md,
            children: <Widget>[
              _methodNote(context),
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 16.0;
                  final columns = constraints.maxWidth >= 840
                      ? 3
                      : constraints.maxWidth >= 620
                          ? 2
                          : 1;
                  final width =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: <Widget>[
                      for (final profile in _CalibrationProfile.values)
                        SizedBox(
                          width: width,
                          child: _profileScope(profile),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _methodNote(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacing.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceSunken,
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      child: Text(
        'Material 列用于验证标准 Tone 层级；Fluent 风格列是基于 EDS Seed 的桌面角色近似，'
        '不是复制 Microsoft 的固定品牌色。点击输入框可直接比较 Focus。',
        style: tokens.typography.caption.copyWith(
          color: scheme.foregroundSecondary,
        ),
      ),
    );
  }

  Widget _profileScope(_CalibrationProfile profile) {
    return EdsThemeScope(
      theme: preset.theme,
      semanticOverrides: _overrides(profile),
      brightness: brightness,
      child: Builder(
        builder: (context) => _CalibrationCard(profile: profile),
      ),
    );
  }

  EdsSemanticOverrides? _overrides(_CalibrationProfile profile) {
    if (profile == _CalibrationProfile.current) return null;
    return EdsSemanticOverrides(
      light: _patch(profile, Brightness.light),
      dark: _patch(profile, Brightness.dark),
    );
  }

  EdsSemanticColorOverrides _patch(
    _CalibrationProfile profile,
    Brightness brightness,
  ) {
    final brand = _Tones(preset.theme.seeds.brand);
    final warning = _Tones(preset.theme.seeds.warning);
    final isLight = brightness == Brightness.light;

    return switch (profile) {
      _CalibrationProfile.current => const EdsSemanticColorOverrides(),
      _CalibrationProfile.material => EdsSemanticColorOverrides(
          brandForeground: brand(isLight ? 40 : 80),
          brandSurface: brand(isLight ? 90 : 30),
          brandSurfaceStrong: brand(isLight ? 40 : 80),
          brandBorder: brand(isLight ? 50 : 60),
          brandOnStrong: brand(isLight ? 100 : 20),
          borderSelected: brand(isLight ? 40 : 80),
          borderFocus: brand(isLight ? 40 : 80),
        ),
      _CalibrationProfile.fluent => EdsSemanticColorOverrides(
          foregroundTertiary:
              isLight ? const Color(0xFF6C6C72) : const Color(0xFFADADB3),
          brandForeground: brand(isLight ? 40 : 75),
          brandSurface: brand(isLight ? 95 : 20),
          brandSurfaceStrong: brand(isLight ? 45 : 40),
          brandBorder: brand(isLight ? 55 : 60),
          brandOnStrong: brand(100),
          borderSelected: brand(isLight ? 45 : 70),
          borderFocus: brand(isLight ? 50 : 70),
          warningSurfaceStrong: warning(isLight ? 80 : 40),
          warningOnStrong: warning(isLight ? 10 : 100),
        ),
    };
  }
}

class _CalibrationCard extends StatelessWidget {
  const _CalibrationCard({required this.profile});

  final _CalibrationProfile profile;

  String get _title => switch (profile) {
        _CalibrationProfile.current => '当前 EDS',
        _CalibrationProfile.material => 'Material 对齐',
        _CalibrationProfile.fluent => 'Fluent 风格',
      };

  String get _description => switch (profile) {
        _CalibrationProfile.current => '现行基线 · 高对比品牌文字',
        _CalibrationProfile.material => '经典 Tone 角色 · 容器层次更明显',
        _CalibrationProfile.fluent => '桌面层级 · 独立 Focus 与亮色 Warning',
      };

  String get _toneSummary => switch (profile) {
        _CalibrationProfile.current =>
          'FG 35/85 · Surface 95/20 · Strong 40/80',
        _CalibrationProfile.material =>
          'FG 40/80 · Surface 90/30 · Strong 40/80',
        _CalibrationProfile.fluent => 'FG 40/75 · Surface 95/20 · Strong 45/40',
      };

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Container(
      key: Key('catalog.colorCalibration.${profile.name}'),
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: scheme.surfacePage,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: scheme.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tokens.spacing.md,
        children: <Widget>[
          _heading(context),
          _miniPage(context),
          _contrastSummary(context),
        ],
      ),
    );
  }

  Widget _heading(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.spacing.xxs,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                _title,
                style: tokens.typography.sectionTitle.copyWith(
                  color: scheme.foregroundPrimary,
                ),
              ),
            ),
            if (profile == _CalibrationProfile.current)
              const EdsBadge('基线', style: EdsBadgeStyle.neutral),
          ],
        ),
        Text(
          _description,
          style: tokens.typography.caption.copyWith(
            color: scheme.foregroundSecondary,
          ),
        ),
        Text(
          _toneSummary,
          style: tokens.typography.monoCaption.copyWith(
            color: scheme.foregroundTertiary,
          ),
        ),
      ],
    );
  }

  Widget _miniPage(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceBase,
        borderRadius: BorderRadius.circular(tokens.radius.sm),
        border: Border.all(color: scheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.spacing.sm,
              tokens.spacing.sm,
              tokens.spacing.sm,
              0,
            ),
            child: Row(
              children: <Widget>[
                _tab(context, '概览', selected: true),
                SizedBox(width: tokens.spacing.xxs),
                _tab(context, '设置', selected: false),
              ],
            ),
          ),
          Divider(height: 1, color: scheme.borderSubtle),
          Padding(
            padding: EdgeInsets.all(tokens.spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: tokens.spacing.sm,
              children: <Widget>[
                Text(
                  '页面标题',
                  style: tokens.typography.sectionTitle.copyWith(
                    color: scheme.brandForeground,
                  ),
                ),
                Text(
                  '三级辅助信息与输入提示文字',
                  style: tokens.typography.caption.copyWith(
                    color: scheme.foregroundTertiary,
                  ),
                ),
                const EdsTextField(
                  label: '导出位置',
                  hint: '点击这里比较 Focus 颜色',
                  prefixIcon: Icon(Icons.folder_outlined),
                ),
                Wrap(
                  spacing: tokens.spacing.xs,
                  runSpacing: tokens.spacing.xs,
                  children: <Widget>[
                    EdsButton('保存', icon: Icons.check, action: () {}),
                    EdsButton(
                      '稍后',
                      role: EdsButtonRole.soft,
                      action: () {},
                    ),
                  ],
                ),
                _warning(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String label, {required bool selected}) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: selected ? scheme.brandSurface : Colors.transparent,
        borderRadius: BorderRadius.circular(tokens.radius.sm),
        border: selected ? Border.all(color: scheme.brandBorder) : null,
      ),
      child: Text(
        label,
        style: tokens.typography.bodyStrong.copyWith(
          color: selected ? scheme.brandForeground : scheme.foregroundSecondary,
        ),
      ),
    );
  }

  Widget _warning(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacing.sm),
      decoration: BoxDecoration(
        color: scheme.warningSurfaceStrong,
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: scheme.warningOnStrong,
          ),
          SizedBox(width: tokens.spacing.xs),
          Expanded(
            child: Text(
              '文件将覆盖，请确认后继续',
              style: tokens.typography.captionStrong.copyWith(
                color: scheme.warningOnStrong,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contrastSummary(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final entries = <(String, Color, Color, double)>[
      (
        '品牌文字',
        scheme.brandForeground,
        scheme.surfaceBase,
        4.5,
      ),
      (
        '主要按钮',
        scheme.brandOnStrong,
        scheme.brandSurfaceStrong,
        4.5,
      ),
      (
        '三级文字',
        scheme.foregroundTertiary,
        scheme.surfaceBase,
        4.5,
      ),
      (
        'Warning',
        scheme.warningOnStrong,
        scheme.warningSurfaceStrong,
        4.5,
      ),
    ];

    return Wrap(
      spacing: tokens.spacing.xs,
      runSpacing: tokens.spacing.xs,
      children: <Widget>[
        for (final entry in entries)
          _ContrastBadge(
            label: entry.$1,
            ratio: _contrastRatio(entry.$2, entry.$3),
            target: entry.$4,
          ),
      ],
    );
  }
}

class _ContrastBadge extends StatelessWidget {
  const _ContrastBadge({
    required this.label,
    required this.ratio,
    required this.target,
  });

  final String label;
  final double ratio;
  final double target;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final passes = ratio >= target;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.xs,
        vertical: tokens.spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: passes ? scheme.successSurface : scheme.dangerSurface,
        borderRadius: BorderRadius.circular(tokens.radius.sm),
        border: Border.all(
          color: passes ? scheme.successBorder : scheme.dangerBorder,
        ),
      ),
      child: Text(
        '$label ${ratio.toStringAsFixed(1)}:1 ${passes ? 'AA' : '未达 AA'}',
        style: tokens.typography.monoCaption.copyWith(
          color: passes ? scheme.successForeground : scheme.dangerForeground,
        ),
      ),
    );
  }
}

class _Tones {
  _Tones(Color seed)
      : _palette = TonalPalette.fromHct(Hct.fromInt(seed.toARGB32()));

  final TonalPalette _palette;

  Color call(int tone) => Color(_palette.get(tone));
}

double _contrastRatio(Color foreground, Color background) {
  final lighter = foreground.computeLuminance() > background.computeLuminance()
      ? foreground
      : background;
  final darker = identical(lighter, foreground) ? background : foreground;
  return (lighter.computeLuminance() + 0.05) /
      (darker.computeLuminance() + 0.05);
}
