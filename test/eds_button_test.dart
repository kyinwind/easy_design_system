import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';
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
        emphasis: EdsButtonEmphasis.outline,
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
}

class _DisabledButton extends StatelessWidget {
  const _DisabledButton();

  @override
  Widget build(BuildContext context) {
    return EdsButton('不可用');
  }
}
