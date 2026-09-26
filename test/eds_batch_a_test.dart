import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sidebar preset tint resolves from local theme scope',
      (tester) async {
    const localPrimary = Color(0xFFAA3366);
    final tokens = const EdsDesignTokens().copyWith(
      colors: const EdsColorTokens().copyWith(primary: localPrimary),
    );
    final item = EdsSidebarMenuItem(
      label: 'Inbox',
      icon: Icons.inbox,
      presetTint: EdsSidebarIconPresetTint.blue,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: EdsThemeScope(
          tokens: tokens,
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

    final icon = tester.widget<EdsSidebarIcon>(find.byType(EdsSidebarIcon));
    expect(icon.tint, localPrimary);
  });

  testWidgets('pill remove semantics can be localized by host app',
      (tester) async {
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

    expect(find.bySemanticsLabel('Remove Design'), findsOneWidget);
  });
}
