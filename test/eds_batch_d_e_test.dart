import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('collapsible supports uncontrolled initial state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EdsCollapsibleSection(
            'Details',
            initiallyExpanded: true,
            child: Text('Body'),
          ),
        ),
      ),
    );

    expect(find.text('Body'), findsOneWidget);
  });

  testWidgets('collapsible controlled mode reports requested changes',
      (tester) async {
    bool? requested;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EdsCollapsibleSection(
            'Details',
            isExpanded: false,
            onExpansionChanged: (value) => requested = value,
            child: const Text('Body'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Details'));
    await tester.pump();

    expect(requested, isTrue);
    expect(find.text('Body'), findsNothing);
  });

  testWidgets('generic pill flow preserves model values', (tester) async {
    const items = [
      _Tag(2, 'Beta'),
      _Tag(1, 'Alpha'),
    ];
    _Tag? tapped;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EdsPillFlow<_Tag>(
            items,
            sortOrder: EdsPillFlowSortOrder.ascending,
            labelBuilder: (item) => item.label,
            onTap: (item) => tapped = item,
          ),
        ),
      ),
    );

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);

    await tester.tap(find.text('Alpha'));
    expect(tapped?.id, 1);
  });

  testWidgets('text field radio slider and dialogs build', (tester) async {
    final controller = TextEditingController(text: 'hello');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              EdsTextField(
                controller: controller,
                label: 'Name',
                hint: 'Input',
              ),
              EdsRadio<int>(
                value: 1,
                groupValue: 1,
                label: 'One',
                onChanged: (_) {},
              ),
              EdsSlider(
                value: 0.5,
                onChanged: (_) {},
                label: '50%',
              ),
              EdsConfirmDialog(
                title: 'Delete',
                message: 'Confirm',
                confirmTitle: 'OK',
                onConfirm: () {},
                onCancel: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Name'), findsOneWidget);
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });
}

class _Tag {
  const _Tag(this.id, this.label);

  final int id;
  final String label;
}
