import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sidebar preset tint resolves from local theme scope', (
    tester,
  ) async {
    const localPrimary = Color(0xFFAA3366);
    const seeds = EdsColorSeedOverrides(brand: localPrimary);
    final item = EdsSidebarMenuItem(
      label: 'Inbox',
      icon: Icons.inbox,
      tone: EdsSidebarIconTone.blue,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: EdsThemeScope(
          seeds: seeds,
          child: Scaffold(
            body: EdsSidebarItemButton(
              item: item,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    final iconFinder = find.byType(EdsSidebarIcon);
    final icon = tester.widget<EdsSidebarIcon>(iconFinder);
    final expected = EdsColorScheme.resolve(
      seeds: const EdsColorSeeds(brand: localPrimary),
      brightness: Brightness.light,
    );
    final container = tester.widget<Container>(
      find.descendant(of: iconFinder, matching: find.byType(Container)).first,
    );
    final decoration = container.decoration! as BoxDecoration;

    expect(icon.tone, EdsSidebarIconTone.blue);
    expect(decoration.color, expected.brandSurfaceStrong);
  });

  testWidgets('pill remove semantics can be localized by host app', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EdsPill(
            'Design',
            tone: EdsPillTone.defaultPalette.first,
            showsRemoveButton: true,
            removeSemanticLabel: 'Remove Design',
            removeSemanticHint: 'Remove from tags',
            onRemove: () {},
          ),
        ),
      ),
    );

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer();
    await mouse.moveTo(tester.getCenter(find.text('Design')));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Remove Design'), findsOneWidget);
  });
}
