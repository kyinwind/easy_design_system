import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('done role resolves to filled success', () {
    final appearance = EdsButtonRole.done.appearance;
    expect(appearance.emphasis, EdsButtonEmphasis.filled);
    expect(appearance.tone, EdsButtonTone.success);
    expect(appearance.size, EdsButtonSize.regular);
  });

  test('legacy roles keep their appearance', () {
    expect(
      EdsButtonRole.primary.appearance,
      const EdsButtonAppearance(
        emphasis: EdsButtonEmphasis.filled,
        tone: EdsButtonTone.brand,
        size: EdsButtonSize.regular,
      ),
    );
    expect(
      EdsButtonRole.secondary.appearance,
      const EdsButtonAppearance(
        emphasis: EdsButtonEmphasis.medium,
        tone: EdsButtonTone.brand,
        size: EdsButtonSize.regular,
      ),
    );
    expect(
      EdsButtonRole.soft.appearance,
      const EdsButtonAppearance(
        emphasis: EdsButtonEmphasis.soft,
        tone: EdsButtonTone.brand,
        size: EdsButtonSize.regular,
      ),
    );
    expect(
      EdsButtonRole.danger.appearance,
      const EdsButtonAppearance(
        emphasis: EdsButtonEmphasis.filled,
        tone: EdsButtonTone.danger,
        size: EdsButtonSize.regular,
      ),
    );
    expect(
      EdsButtonRole.normal.appearance,
      const EdsButtonAppearance(
        emphasis: EdsButtonEmphasis.soft,
        tone: EdsButtonTone.neutral,
        size: EdsButtonSize.regular,
      ),
    );
  });

  test('default appearance matches the Swift defaults', () {
    expect(
      const EdsButtonAppearance(),
      const EdsButtonAppearance(
        emphasis: EdsButtonEmphasis.filled,
        tone: EdsButtonTone.brand,
        size: EdsButtonSize.regular,
      ),
    );
  });

  test('medium emphasis uses an intermediate brand surface', () {
    const tokens = EdsDesignTokens();
    final scheme = EdsColorScheme.resolve(
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
    );
    const appearance = EdsButtonAppearance(
      emphasis: EdsButtonEmphasis.medium,
      tone: EdsButtonTone.brand,
    );
    final visual = appearance.resolve(
      tokens: tokens,
      scheme: scheme,
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
    );

    expect(visual.background, isNotNull);
    expect(visual.background, isNot(scheme.brandSurfaceStrong));
    expect(visual.foreground, scheme.brandForeground);
    expect(visual.borderColor, isNull);
  });

  test('medium neutral uses primary neutral foreground', () {
    const tokens = EdsDesignTokens();
    final scheme = EdsColorScheme.resolve(
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
    );
    const appearance = EdsButtonAppearance(
      emphasis: EdsButtonEmphasis.medium,
      tone: EdsButtonTone.neutral,
    );
    final visual = appearance.resolve(
      tokens: tokens,
      scheme: scheme,
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
    );

    expect(visual.foreground, scheme.foregroundPrimary);
  });

  test('outline emphasis uses border color and transparent background', () {
    const tokens = EdsDesignTokens();
    final scheme = EdsColorScheme.resolve(
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
    );
    const appearance = EdsButtonAppearance(
      emphasis: EdsButtonEmphasis.outline,
      tone: EdsButtonTone.brand,
    );
    final visual = appearance.resolve(
      tokens: tokens,
      scheme: scheme,
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
    );

    expect(visual.background, isNull);
    expect(visual.borderColor, scheme.brandBorder);
    expect(visual.foreground, scheme.brandForeground);
  });

  test('filled success/warning use their semantic on-strong colors', () {
    const tokens = EdsDesignTokens();
    final scheme = EdsColorScheme.resolve(
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
    );

    final success = const EdsButtonAppearance(
      emphasis: EdsButtonEmphasis.filled,
      tone: EdsButtonTone.success,
    ).resolve(
      tokens: tokens,
      scheme: scheme,
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
    );
    final warning = const EdsButtonAppearance(
      emphasis: EdsButtonEmphasis.filled,
      tone: EdsButtonTone.warning,
    ).resolve(
      tokens: tokens,
      scheme: scheme,
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
    );

    expect(success.foreground, scheme.successOnStrong);
    expect(warning.foreground, scheme.warningOnStrong);
  });

  test('outline success uses success semantic foreground', () {
    const tokens = EdsDesignTokens();
    final scheme = EdsColorScheme.resolve(
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
    );
    const appearance = EdsButtonAppearance(
      emphasis: EdsButtonEmphasis.outline,
      tone: EdsButtonTone.success,
    );
    final visual = appearance.resolve(
      tokens: tokens,
      scheme: scheme,
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
    );

    expect(visual.foreground, scheme.textPrimary);
  });

  testWidgets('button renders title and icon and fires action on tap', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: EdsButton(
              '保存',
              role: EdsButtonRole.primary,
              systemImage: Icons.check,
              action: () => taps++,
            ),
          ),
        ),
      ),
    );

    expect(find.text('保存'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.tap(find.text('保存'));
    expect(taps, 1);
  });

  testWidgets('dimension factory renders three-dimensional primitives', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: EdsButton.dimension(
              '忽略并删除',
              emphasis: EdsButtonEmphasis.soft,
              tone: EdsButtonTone.danger,
              action: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('忽略并删除'), findsOneWidget);
  });

  testWidgets('null action renders disabled and ignores taps', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: _DisabledButton())),
      ),
    );

    await tester.tap(find.text('不可用'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('button exposes semantics and can be activated from keyboard', (
    tester,
  ) async {
    var activations = 0;
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EdsButton(
            '保存',
            semanticLabel: '保存项目',
            focusNode: focusNode,
            action: () => activations++,
          ),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(EdsButton));
    expect(semantics.label.trim(), '保存项目');
    expect(semantics.flagsCollection.isButton, isTrue);
    expect(semantics.flagsCollection.isEnabled.toBoolOrNull(), isTrue);

    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(activations, 2);
  });

  testWidgets('hover changes semantic button surface without opacity hacks', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: EdsButton('Hover', action: () {})),
      ),
    );

    BoxDecoration decoration() {
      final container =
          tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      return container.decoration! as BoxDecoration;
    }

    final restColor = decoration().color;

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer();
    await mouse.moveTo(tester.getCenter(find.text('Hover')));
    await tester.pumpAndSettle();

    final hoverColor = decoration().color;
    expect(hoverColor, isNot(restColor));
    expect(find.byType(AnimatedOpacity), findsNothing);
  });

  testWidgets('button supports optional tooltip', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EdsButton('删除', tooltip: '删除当前项目', action: () {}),
        ),
      ),
    );

    expect(find.byTooltip('删除当前项目'), findsOneWidget);
  });

  testWidgets('Button API 2 supports icon busy expanded custom and styled', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EdsButton(
                '保存',
                icon: Icons.save,
                expands: true,
                action: () => taps++,
              ),
              EdsButton('处理中', isBusy: true, action: () => taps++),
              EdsButton.custom(label: const Text('自定义'), action: () => taps++),
              EdsButton.styled(
                '删除',
                emphasis: EdsButtonEmphasis.soft,
                tone: EdsButtonTone.danger,
                action: () => taps++,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.save), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('自定义'), findsOneWidget);
    expect(find.text('删除'), findsOneWidget);

    final expandedSize = tester.getSize(find.widgetWithText(EdsButton, '保存'));
    expect(expandedSize.width, 800);

    await tester.tap(find.text('处理中'), warnIfMissed: false);
    expect(taps, 0);

    await tester.tap(find.text('自定义'));
    await tester.tap(find.text('删除'));
    expect(taps, 2);
  });

  testWidgets(
    'fullWidth convenience API expands while default stays content-sized',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: EdsButton('普通', action: () {}),
                ),
                EdsButton.fullWidth('整行', action: () {}),
              ],
            ),
          ),
        ),
      );

      final normalSize = tester.getSize(find.widgetWithText(EdsButton, '普通'));
      final fullSize = tester.getSize(find.widgetWithText(EdsButton, '整行'));

      expect(normalSize.width, lessThan(fullSize.width));
      expect(fullSize.width, 800);
    },
  );

  testWidgets('legacy systemImage and dimension APIs remain available', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              EdsButton('旧图标', systemImage: Icons.check, action: () {}),
              EdsButton.dimension(
                '旧样式',
                emphasis: EdsButtonEmphasis.soft,
                action: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('旧样式'), findsOneWidget);
  });

  testWidgets('busy button remains semantically enabled but cannot activate', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EdsButton(
            '保存',
            isBusy: true,
            semanticLabel: '保存',
            action: () => taps++,
          ),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(EdsButton));
    expect(semantics.flagsCollection.isEnabled.toBoolOrNull(), isTrue);

    await tester.tap(find.byType(EdsButton), warnIfMissed: false);
    await tester.pump();

    expect(taps, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('disabled button exposes disabled semantics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: EdsButton('不可用', semanticLabel: '不可用按钮')),
      ),
    );

    final semantics = tester.getSemantics(find.byType(EdsButton));
    expect(semantics.flagsCollection.isButton, isTrue);
    expect(semantics.flagsCollection.isEnabled.toBoolOrNull(), isFalse);
  });
}

class _DisabledButton extends StatelessWidget {
  const _DisabledButton();

  @override
  Widget build(BuildContext context) {
    return EdsButton('不可用');
  }
}
