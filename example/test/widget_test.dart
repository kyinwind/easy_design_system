import 'package:easy_design_system/easy_design_system.dart';
import 'package:easy_design_system_example/catalog/eds_design_system_preview.dart';
import 'package:easy_design_system_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    EdsTheme.instance.applyPreset(EdsPresetTheme.defaultTheme);
  });

  tearDown(() {
    EdsTheme.instance.applyPreset(EdsPresetTheme.defaultTheme);
  });

  test('Catalog Preview 保留未编辑的 Theme 字段并可完整导出', () {
    const semanticOverrides = EdsSemanticOverrides(
      light: EdsSemanticColorOverrides(
        surfaceRaised: Color(0xFFF1F2F3),
      ),
      dark: EdsSemanticColorOverrides(
        borderStrong: Color(0xFF778899),
      ),
    );
    const adaptiveLayout = EdsAdaptiveLayoutTokens(
      compactPagePadding: 19,
      regularPagePadding: 37,
      readableContentMaxWidth: 913,
      minimumTouchTarget: 47,
      minimumHybridTarget: 43,
    );
    const stroke = EdsStrokeTokens(hairline: 1.5);
    const shadow = EdsShadowTokens(
      color: '#123456',
      opacity: 0.17,
      radius: 23,
      x: 2,
      y: 11,
    );
    const baseTheme = EdsThemeData(
      semanticOverrides: semanticOverrides,
      tokens: EdsDesignTokens(
        adaptiveLayout: adaptiveLayout,
        stroke: stroke,
        shadow: shadow,
      ),
    );
    final editedSeeds = baseTheme.seeds.copyWith(
      brand: const Color(0xFF3344EE),
    );
    final editedSpacing = baseTheme.tokens.spacing.copyWith(md: 21);
    final editedRadius = baseTheme.tokens.radius.copyWith(lg: 17);

    final draft = buildCatalogPreviewTheme(
      baseTheme: baseTheme,
      seeds: editedSeeds,
      spacing: editedSpacing,
      radius: editedRadius,
      typography: baseTheme.tokens.typography,
      controlSize: baseTheme.tokens.controlSize,
      heroGradient: baseTheme.tokens.heroGradient,
    );

    expect(draft.seeds, editedSeeds);
    expect(draft.tokens.spacing, editedSpacing);
    expect(draft.tokens.radius, editedRadius);
    expect(draft.semanticOverrides, same(semanticOverrides));
    expect(draft.tokens.adaptiveLayout, same(adaptiveLayout));
    expect(draft.tokens.stroke, same(stroke));
    expect(draft.tokens.shadow, same(shadow));

    final exported = decodeThemeJson(encodeThemeJson(draft));
    expect(exported.semanticOverrides, semanticOverrides);
    expect(exported.tokens.adaptiveLayout, adaptiveLayout);
    expect(exported.tokens.stroke, stroke);
    expect(exported.tokens.shadow, shadow);
  });

  testWidgets('启动后展示主题条与 Gallery 默认节', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('预览主题'), findsOneWidget);
    expect(find.text('默认蓝'), findsOneWidget);
    expect(find.byType(EdsSidebarGroupView), findsOneWidget);
    expect(find.text('标准页面'), findsOneWidget);
    expect(
      find.text('EDSPageSection + EDSGroup + EDSSettingRow'),
      findsOneWidget,
    );
    expect(find.text('EDSProgressPanel'), findsOneWidget);
    expect(find.text('模型下载'), findsOneWidget);
    expect(find.text('状态反馈'), findsOneWidget);
  });

  testWidgets('四个 Tab 可切换', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(Tab, 'Easy API'));
    await tester.pumpAndSettle();
    expect(find.text('一行启用页面最佳实践'), findsOneWidget);
    expect(find.text('层次是语义化的'), findsOneWidget);

    await tester.tap(find.widgetWithText(Tab, '主题'));
    await tester.pumpAndSettle();
    expect(find.text('应用到 Runtime'), findsOneWidget);
    expect(find.text('导出 JSON'), findsOneWidget);
    expect(find.text('未在编辑器中展示的 Theme Token 会原样保留。'), findsOneWidget);
    expect(find.text('颜色'), findsWidgets);

    await tester.tap(find.widgetWithText(Tab, '设置'));
    await tester.pumpAndSettle();
    expect(find.text('管理应用偏好'), findsOneWidget);

    await tester.tap(find.widgetWithText(Tab, '组件'));
    await tester.pumpAndSettle();
    expect(find.text('EDSProgressPanel'), findsOneWidget);
  });

  testWidgets('主题条切换全局主题', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('catalog.theme.picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('橙').last);
    await tester.pumpAndSettle();

    expect(EdsTheme.instance.seeds.brand, const Color(0xFFFF6B00));
    expect(find.text('橙'), findsOneWidget);
  });

  testWidgets('Gallery 分节切换', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('状态模式'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('EDSErrorState'), findsOneWidget);
    expect(find.text('EDSLoadingState'), findsOneWidget);
    expect(find.text('暂无文件'), findsOneWidget);

    await tester.tap(find.text('按钮'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('预设入口 · Role'), findsOneWidget);
    expect(find.text('组合矩阵 · Emphasis × Tone'), findsOneWidget);
    expect(find.text('别名等价性 · Role ↔ 三维'), findsOneWidget);
  });

  testWidgets('ColorScheme 校准页可访问', (tester) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ColorScheme'));
    await tester.pumpAndSettle();

    expect(find.text('Color Foundation'), findsOneWidget);
    expect(find.text('Layer / Context'), findsOneWidget);
    expect(find.text('Component Matrix'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('窄屏使用 ChoiceChip 导航', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.byType(ChoiceChip), findsWidgets);
    expect(find.byType(EdsSidebarGroupView), findsNothing);
    expect(find.text('标准页面'), findsOneWidget);

    await tester.tap(find.text('状态模式'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('EDSErrorState'), findsOneWidget);
    expect(find.text('EDSLoadingState'), findsOneWidget);
  });
}
