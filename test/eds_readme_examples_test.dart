import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Compile-pins the code snippets published in `README.md`. When a snippet's
/// API changes, this file breaks first so the docs never drift from the code.
void main() {
  testWidgets('readme settings page example builds', (tester) async {
    await tester.pumpWidget(
      const EdsThemeScope(
        child: MaterialApp(home: _ReadmeSettingsPage()),
      ),
    );

    expect(find.text('设置'), findsOneWidget);
    expect(find.text('通用'), findsOneWidget);
    expect(find.text('自动更新'), findsOneWidget);
    expect(find.text('专业版'), findsOneWidget);
    expect(find.text('立即升级'), findsOneWidget);
  });

  testWidgets('readme account page with interaction profile override builds',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: _ReadmeAccountPage())),
    );

    expect(find.text('账户'), findsOneWidget);
    expect(find.text('自动同步'), findsOneWidget);
  });

  test('readme global configure and tokens listenable', () {
    EdsTheme.instance.configure((tokens) {
      return tokens.copyWith(
        colors: tokens.colors.copyWith(primary: const Color(0xFF0000FF)),
      );
    });

    expect(EdsTheme.instance.tokens.colors.primary, const Color(0xFF0000FF));

    addTearDown(() {
      EdsTheme.instance.applyPreset(EdsPresetTheme.defaultTheme);
      expect(
        EdsTheme.instance.tokens.colors.primary,
        const Color(0xFF3185FF),
      );
    });
  });

  testWidgets('readme runtime listener rebuilds on theme change',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListenableBuilder(
            listenable: EdsTheme.instance.tokensListenable,
            builder: (context, _) => const _ThemeIndicator(),
          ),
        ),
      ),
    );

    expect(find.text('主题色已配置'), findsOneWidget);

    EdsTheme.instance.configure((tokens) {
      return tokens.copyWith(
        colors: tokens.colors.copyWith(primary: const Color(0xFF0000FF)),
      );
    });
    await tester.pump();

    expect(find.text('主题色已配置'), findsOneWidget);

    addTearDown(
      () => EdsTheme.instance.applyPreset(EdsPresetTheme.defaultTheme),
    );
  });

  testWidgets('readme buttons: roles, dimensions and label factory',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              EdsButton('主要操作', role: EdsButtonRole.primary, action: () {}),
              EdsButton('次要操作', role: EdsButtonRole.secondary, action: () {}),
              EdsButton('轻量操作', role: EdsButtonRole.soft, action: () {}),
              EdsButton('危险操作', role: EdsButtonRole.danger, action: () {}),
              EdsButton('已完成', role: EdsButtonRole.done, action: () {}),
              EdsButton.dimension(
                '忽略并删除',
                emphasis: EdsButtonEmphasis.soft,
                tone: EdsButtonTone.danger,
                action: () {},
              ),
              EdsButton.dimension(
                '更多',
                emphasis: EdsButtonEmphasis.plain,
                systemImage: Icons.more_horiz,
                action: () {},
              ),
              EdsButton.dimension(
                '刷新',
                emphasis: EdsButtonEmphasis.outline,
                size: EdsButtonSize.small,
                action: () {},
              ),
              EdsButton.dimension(
                '开始处理',
                emphasis: EdsButtonEmphasis.filled,
                size: EdsButtonSize.large,
                action: () {},
              ),
              EdsButton.label(
                const Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('下载全部'),
                  ],
                ),
                role: EdsButtonRole.primary,
                action: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('主要操作'), findsOneWidget);
    expect(find.text('忽略并删除'), findsOneWidget);
    expect(find.text('下载全部'), findsOneWidget);
  });

  testWidgets('readme fine-grained panel and card background', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: const [
              _FineGrainedPanel(),
              _CardWithBackground(),
              EdsValueRow('缓存占用', value: '240 MB'),
              EdsValueRow('剩余空间', value: '仅剩 1 GB', tone: Color(0xFFE54444)),
              EdsMonoText('/Users/name/Documents/Exports'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('自定义面板'), findsOneWidget);
    expect(find.text('缓存占用'), findsOneWidget);
  });

  testWidgets('readme local theme scope with preset and brightness',
      (tester) async {
    await tester.pumpWidget(
      const EdsThemeScope(
        preset: EdsPresetTheme.orange,
        brightness: Brightness.dark,
        child: MaterialApp(
          home: Scaffold(body: EdsValueRow('套餐', value: '专业版')),
        ),
      ),
    );

    expect(find.text('套餐'), findsOneWidget);
  });

  testWidgets('readme adaptive layout override and metrics', (tester) async {
    EdsTheme.instance.configure((tokens) {
      return tokens.copyWith(
        adaptiveLayout: tokens.adaptiveLayout.copyWith(
          compactPagePadding: 20,
          regularPagePadding: 36,
          readableContentMaxWidth: 960,
          minimumTouchTarget: 44,
        ),
      );
    });

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: _MetricsReader())),
    );

    expect(find.text('pagePadding=36'), findsOneWidget);

    addTearDown(
      () => EdsTheme.instance.applyPreset(EdsPresetTheme.defaultTheme),
    );
  });
}

class _ReadmeSettingsPage extends StatefulWidget {
  const _ReadmeSettingsPage();

  @override
  State<_ReadmeSettingsPage> createState() => _ReadmeSettingsPageState();
}

class _ReadmeSettingsPageState extends State<_ReadmeSettingsPage> {
  bool _automaticUpdates = true;

  void _purchase() {
    // 执行业务操作
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EdsPageTitle('设置', subtitle: '管理应用偏好'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EdsSectionTitle('通用'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EdsSettingRow(
                      '自动更新',
                      subtitle: '定期检查是否有新版本。',
                      trailing: EdsToggle(
                        isOn: _automaticUpdates,
                        label: '启用',
                        onChanged: (value) =>
                            setState(() => _automaticUpdates = value),
                      ),
                    ),
                  ],
                ).easyDesign(style: EdsEasyStyle.group),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EdsSectionTitle(
                      '专业版',
                      subtitle: '解锁更多高级功能。',
                    ),
                    Row(
                      children: [
                        const EdsBadge('推荐', style: EdsBadgeStyle.accent),
                        const Spacer(),
                        EdsButton(
                          '立即升级',
                          role: EdsButtonRole.primary,
                          action: _purchase,
                        ),
                      ],
                    ),
                  ],
                ).easyDesign(style: EdsEasyStyle.card),
              ],
            ).easyDesign(style: EdsEasyStyle.section),
          ],
        ).easyDesign(),
      ),
    );
  }
}

class _ReadmeAccountPage extends StatelessWidget {
  const _ReadmeAccountPage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EdsPageTitle('账户'),
          EdsSettingRow(
            '自动同步',
            trailing: EdsToggle(
              isOn: true,
              label: '启用',
              onChanged: (value) {},
            ),
          ).easyDesign(style: EdsEasyStyle.group),
        ],
      ).easyDesignInteractionProfile(EdsInteractionProfile.touch),
    );
  }
}

class _ThemeIndicator extends StatelessWidget {
  const _ThemeIndicator();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.edsTokens.colors.primary,
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Text('主题色已配置'),
      ),
    );
  }
}

class _FineGrainedPanel extends StatelessWidget {
  const _FineGrainedPanel();

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius.lg),
      child: ColoredBox(
        color: scheme.cardBackground,
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('自定义面板', style: tokens.typography.sectionTitle),
              Text(
                '这里使用完整 Token 进行精细控制。',
                style: tokens.typography.body
                    .copyWith(color: scheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardWithBackground extends StatelessWidget {
  const _CardWithBackground();

  @override
  Widget build(BuildContext context) {
    return EdsCard(
      background: context.edsScheme.cardBackground,
      child: const Text('卡片内容'),
    );
  }
}

class _MetricsReader extends StatelessWidget {
  const _MetricsReader();

  @override
  Widget build(BuildContext context) {
    final metrics = EdsResolvedMetrics.resolve(
      tokens: context.edsTokens,
      profile: context.edsInteractionProfile,
      horizontalSizeClass: context.edsSizeClass,
    );

    return Text('pagePadding=${metrics.pagePadding.round()}');
  }
}
