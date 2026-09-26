import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'EdsCheckbox toggles and keeps EDS label styling',
    (tester) async {
    var value = false;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return EdsCheckbox(
              value: value,
              label: '开机启动',
              tooltip: '随系统启动',
              onChanged: (next) => setState(() => value = next ?? false),
            );
          },
        ),
      ),
    );

    expect(find.text('开机启动'), findsOneWidget);
    expect(find.byTooltip('随系统启动'), findsOneWidget);

    await tester.tap(find.text('开机启动'));
    await tester.pump();

      expect(value, isTrue);
    },
  );

  testWidgets('EdsDropdown is generic and reports selected value',
      (tester) async {
    String? selected = 'a';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EdsDropdown<String>(
            value: selected,
            items: const ['a', 'b'],
            labelBuilder: (value) => value.toUpperCase(),
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('B').last);
    await tester.pumpAndSettle();

    expect(selected, 'b');
  });

  testWidgets('EdsSegmented is generic and reports new selection',
      (tester) async {
    var selected = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EdsSegmented<int>(
            value: selected,
            values: const [1, 2, 3],
            labelBuilder: (value) => '选项$value',
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(find.text('选项1'), findsOneWidget);
    await tester.tap(find.text('选项2'));
    await tester.pump();
    expect(selected, 2);
  });

  testWidgets('form controls follow local EDS theme tokens', (tester) async {
    const local = EdsDesignTokens(
      colors: EdsColorTokens(primary: Color(0xFFFF5500)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: EdsThemeScope(
          tokens: local,
          child: const Scaffold(
            body: EdsSegmented<int>(
              value: 1,
              values: [1, 2],
              labelBuilder: _intLabel,
            ),
          ),
        ),
      ),
    );

    final segmented = tester.widget<SegmentedButton<int>>(
      find.byType(SegmentedButton<int>),
    );
    final color = segmented.style?.foregroundColor?.resolve(
      <WidgetState>{WidgetState.selected},
    );
    expect(color, const Color(0xFFFF5500));
  });
}

String _intLabel(int value) => '$value';
