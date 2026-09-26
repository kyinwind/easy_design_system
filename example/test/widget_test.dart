import 'package:easy_design_system/easy_design_system.dart';
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

    expect(EdsTheme.instance.tokens.colors.primary, const Color(0xFFFF6B00));
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
