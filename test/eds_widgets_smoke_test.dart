import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The Dart counterpart of Swift's `testPublicEntrypointsCompile`: pumps every
/// public entry point once inside a Material app so constructor signature
/// drift and build-time crashes surface here.
void main() {
  testWidgets('badge, toggle, text primitives', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              const EdsBadge('Pro', style: EdsBadgeStyle.accent),
              EdsToggle(isOn: true, label: '自动更新', onChanged: (value) {}),
              const EdsPageTitle('账户'),
              const EdsSectionTitle('通用'),
              const EdsSectionTitle.text(Text('订阅')),
              const EdsLabelText('标签'),
              const EdsCaptionText('说明文字'),
              const EdsMonoText('monospace'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Pro'), findsOneWidget);
    expect(find.text('自动更新'), findsOneWidget);
  });

  testWidgets('cards, groups, sections', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              const EdsCard(child: Text('Card')),
              const EdsGroup('分组', subtitle: '副标题', child: Text('Content')),
              const EdsHeroPanel(child: Text('Hero')),
              const EdsSection(
                header: Text('Header'),
                footer: Text('Footer'),
                child: Text('Section child'),
              ),
              EdsSection.labeled('标题', '副标题', child: const Text('Labeled')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Card'), findsOneWidget);
    expect(find.text('Hero'), findsOneWidget);
  });

  testWidgets('page and page section', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EdsPage(
          '设置',
          subtitle: '管理应用偏好',
          child: EdsPageSection(
            '通用',
            subtitle: '基础设置',
            showsDivider: true,
            child: EdsGroup(null, child: Text('Content')),
          ),
        ),
      ),
    );

    expect(find.text('设置'), findsOneWidget);
    expect(find.text('通用'), findsOneWidget);
  });

  testWidgets('page stack', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EdsPageStack(
          title: '账户',
          child: Text('Stack body'),
        ),
      ),
    );

    expect(find.text('账户'), findsOneWidget);
    expect(find.text('Stack body'), findsOneWidget);
  });

  testWidgets('rows', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: const [
              EdsSettingRow('标题', subtitle: '说明', trailing: Text('Value')),
              EdsValueRow('标签', value: '已开启'),
              EdsInlineField('说明', child: Text('Field')),
              EdsMultilineSubtitleRow(
                title: 'Title',
                subtitle: 'Subtitle',
                child: Text('Row child'),
              ),
              EdsMultilineSubtitleRow(
                systemIcon: Icons.book,
                title: 'Image',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Title'), findsOneWidget);
  });

  testWidgets('pills', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              EdsPill(
                '标签',
                tone: EdsPillTone.defaultPalette[0],
                action: () {},
              ),
              EdsPillFlow(
                const ['香蕉', '苹果', '樱桃'],
                onRemove: (item) {},
              ),
              const EdsFlowLayout(
                children: [Text('Flow 1'), Text('Flow 2')],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('香蕉'), findsOneWidget);
    expect(find.text('Flow 1'), findsOneWidget);
  });

  testWidgets('state views', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              const EdsEmptyState(title: '暂无内容', message: '稍后再来看看'),
              EdsErrorState(title: '出错了', action: () {}),
              const EdsLoadingState(),
              EdsProgressPanel(
                '正在下载更新',
                fractionCompleted: 0.5,
                statusText: '2.5 MB / 5 MB',
                actionTitle: '取消',
                action: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('暂无内容'), findsOneWidget);
    expect(find.text('正在处理'), findsOneWidget);
    expect(find.text('正在下载更新'), findsOneWidget);
  });

  testWidgets('collapsible section expands on header tap', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EdsCollapsibleSection('Details', child: Text('Hidden content')),
        ),
      ),
    );

    expect(find.text('Hidden content'), findsNothing);

    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();

    expect(find.text('Hidden content'), findsOneWidget);
  });

  testWidgets('comparison section renders feature table', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EdsComparisonSection(
            title: 'Feature comparison',
            featureLabel: 'Feature',
            freeLabel: 'Basic',
            proLabel: 'Plus',
            features: [
              ('无限画布', true, true),
              ('团队协作', false, true),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Feature comparison'), findsOneWidget);
    expect(find.text('Basic'), findsOneWidget);
    expect(find.text('Plus'), findsOneWidget);
    expect(find.text('无限画布'), findsOneWidget);
  });

  testWidgets('sidebar widgets', (tester) async {
    final items = [
      EdsSidebarMenuItem(
        label: '收件箱',
        icon: Icons.inbox,
        presetTint: EdsSidebarIconPresetTint.blue,
      ),
      EdsSidebarMenuItem(
        label: '云盘',
        icon: Icons.cloud,
        presetTint: EdsSidebarIconPresetTint.green,
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EdsSidebarGroupView(
            title: '工作区',
            items: items,
            selection: items.first.id,
            onSelectionChange: (id) {},
          ),
        ),
      ),
    );

    expect(find.text('收件箱'), findsOneWidget);
    expect(find.byIcon(Icons.inbox), findsOneWidget);
  });

  testWidgets('sidebar icon and standalone icon mark', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              EdsSidebarIcon(
                icon: Icons.inbox,
                tint: Color(0xFFF9B135),
              ),
              EdsIconMark(isOn: true),
              EdsIconMark(isOn: false),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.inbox), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
  });

  testWidgets('easy API extension entry points', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ListView(
          children: [
            const Text('Page').easyDesign(),
            const Text('Content').easyDesign(style: EdsEasyStyle.content),
            const Text('Section').easyDesign(
              style: EdsEasyStyle.section,
              options: const EdsEasyOptions(
                padding: EdsSpace.xl,
                maxContentWidth: EdsEasyWidth.fixed(960),
                background: EdsEasyVisibility.visible,
              ),
            ),
            const Text('Preset').easyDesignPreset(EdsPresetTheme.orange),
            const Text('Tokens').easyDesignTokens(const EdsDesignTokens()),
            const Text('Theme only')
                .easyDesignThemePreset(EdsPresetTheme.purple),
          ],
        ),
      ),
    );

    expect(find.text('Page'), findsOneWidget);
    expect(find.text('Theme only'), findsOneWidget);
  });

  testWidgets('readme account page example builds', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: _ReadmeAccountPage())),
    );

    expect(find.text('账户'), findsOneWidget);
    expect(find.text('自动同步'), findsOneWidget);
  });
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
      ).easyDesign(style: EdsEasyStyle.page),
    );
  }
}
