import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
        tone: EdsButtonTone.accent,
        size: EdsButtonSize.regular,
      ),
    );
    expect(
      EdsButtonRole.secondary.appearance,
      const EdsButtonAppearance(
        emphasis: EdsButtonEmphasis.medium,
        tone: EdsButtonTone.accent,
        size: EdsButtonSize.regular,
      ),
    );
    expect(
      EdsButtonRole.soft.appearance,
      const EdsButtonAppearance(
        emphasis: EdsButtonEmphasis.soft,
        tone: EdsButtonTone.accent,
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
        tone: EdsButtonTone.accent,
        size: EdsButtonSize.regular,
      ),
    );
  });

  test('medium emphasis has 25% tinted background', () {
    const tokens = EdsDesignTokens();
    final scheme = EdsColorScheme.resolve(tokens, Brightness.light);
    const appearance = EdsButtonAppearance(
      emphasis: EdsButtonEmphasis.medium,
      tone: EdsButtonTone.accent,
    );
    final visual = appearance.resolve(tokens: tokens, scheme: scheme);

    expect(visual.background, tokens.colors.primary.withValues(alpha: 0.25));
    expect(visual.borderColor, isNull);
  });

  test('medium neutral uses textPrimary foreground', () {
    const tokens = EdsDesignTokens();
    final scheme = EdsColorScheme.resolve(tokens, Brightness.light);
    const appearance = EdsButtonAppearance(
      emphasis: EdsButtonEmphasis.medium,
      tone: EdsButtonTone.neutral,
    );
    final visual = appearance.resolve(tokens: tokens, scheme: scheme);

    expect(visual.foreground, scheme.textPrimary);
  });

  test('outline emphasis uses border color and transparent background', () {
    const tokens = EdsDesignTokens();
    final scheme = EdsColorScheme.resolve(tokens, Brightness.light);
    const appearance = EdsButtonAppearance(
      emphasis: EdsButtonEmphasis.outline,
      tone: EdsButtonTone.accent,
    );
    final visual = appearance.resolve(tokens: tokens, scheme: scheme);

    expect(visual.background, isNull);
    expect(visual.borderColor, scheme.border);
    expect(visual.foreground, tokens.colors.primary);
  });

  test('filled success/warning use white foreground', () {
    const tokens = EdsDesignTokens();
    final scheme = EdsColorScheme.resolve(tokens, Brightness.light);

    for (final tone in [EdsButtonTone.success, EdsButtonTone.warning]) {
      final appearance = EdsButtonAppearance(
        emphasis: EdsButtonEmphasis.filled,
        tone: tone,
      );
      final visual = appearance.resolve(tokens: tokens, scheme: scheme);
      expect(visual.foreground, Colors.white, reason: '$tone filled');
    }
  });

  test('outline success uses textPrimary foreground', () {
    const tokens = EdsDesignTokens();
    final scheme = EdsColorScheme.resolve(tokens, Brightness.light);
    const appearance = EdsButtonAppearance(
      emphasis: EdsButtonEmphasis.outline,
      tone: EdsButtonTone.success,
    );
    final visual = appearance.resolve(tokens: tokens, scheme: scheme);

    expect(visual.foreground, scheme.textPrimary);
  });

  testWidgets('button renders title and icon and fires action on tap',
      (tester) async {
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

  testWidgets('dimension factory renders three-dimensional primitives',
      (tester) async {
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
        home: Scaffold(
          body: Center(
            child: _DisabledButton(),
          ),
        ),
      ),
    );

    await tester.tap(find.text('不可用'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('button exposes semantics and can be activated from keyboard',
      (tester) async {
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
    expect(semantics.label, '保存项目');
    expect(semantics.flagsCollection.contains(SemanticsFlag.isButton), isTrue);
    expect(semantics.flagsCollection.contains(SemanticsFlag.isEnabled), isTrue);

    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(activations, 1);
  });

  testWidgets('button supports optional tooltip', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EdsButton(
            '删除',
            tooltip: '删除当前项目',
            action: () {},
          ),
        ),
      ),
    );

    expect(find.byTooltip('删除当前项目'), findsOneWidget);
  });

  testWidgets('disabled button exposes disabled semantics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EdsButton('不可用', semanticLabel: '不可用按钮'),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(EdsButton));
    expect(semantics.flagsCollection.contains(SemanticsFlag.isButton), isTrue);
    expect(semantics.flagsCollection.contains(SemanticsFlag.isEnabled), isFalse);
  });
}

class _DisabledButton extends StatelessWidget {
  const _DisabledButton();

  @override
  Widget build(BuildContext context) {
    return EdsButton('不可用');
  }
}
