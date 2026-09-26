import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EdsCheckbox toggles and keeps EDS label styling', (
    tester,
  ) async {
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
  });

  testWidgets('EdsDropdown is generic and reports selected value', (
    tester,
  ) async {
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

  testWidgets('EdsSegmented is generic and reports new selection', (
    tester,
  ) async {
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
      const MaterialApp(
        home: EdsThemeScope(
          tokens: local,
          child: Scaffold(
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
    final color = segmented.style?.foregroundColor?.resolve(<WidgetState>{
      WidgetState.selected,
    });
    expect(color, const Color(0xFFFF5500));
  });

  testWidgets('EdsTextField shows explicit errorText', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EdsTextField(
            label: '名称',
            errorText: '名称不能为空',
          ),
        ),
      ),
    );

    expect(find.text('名称不能为空'), findsOneWidget);
  });

  testWidgets('EdsTextFormField participates in Form validation', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: EdsTextFormField(
              label: '名称',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入名称';
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('请输入名称'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '规则 A');
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('EdsDropdownFormField validates and saves typed values', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    String? saved;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: EdsDropdownFormField<String>(
              items: const ['a', 'b'],
              labelBuilder: (value) => value.toUpperCase(),
              validator: (value) => value == null ? '请选择' : null,
              onSaved: (value) => saved = value,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('请选择'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('B').last);
    await tester.pumpAndSettle();

    expect(formKey.currentState!.validate(), isTrue);
    formKey.currentState!.save();
    expect(saved, 'b');
  });
}

String _intLabel(int value) => '$value';
