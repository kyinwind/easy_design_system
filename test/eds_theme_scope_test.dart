import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    EdsTheme.instance.tokens = const EdsDesignTokens();
  });

  testWidgets('environment uses local tokens before global tokens',
      (tester) async {
    final global = const EdsDesignTokens()
        .copyWith(spacing: const EdsSpacingTokens().copyWith(md: 17));
    EdsTheme.instance.tokens = global;

    late EdsDesignTokens seenGlobal;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            seenGlobal = context.edsTokens;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(seenGlobal.spacing.md, 17);

    final local = global.copyWith(
      spacing: global.spacing.copyWith(md: 29),
    );
    late EdsDesignTokens seenLocal;
    await tester.pumpWidget(
      MaterialApp(
        home: EdsThemeScope(
          tokens: local,
          child: Builder(
            builder: (context) {
              seenLocal = context.edsTokens;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(seenLocal.spacing.md, 29);
    expect(EdsTheme.instance.tokens.spacing.md, 17);
  });

  testWidgets('preset scope installs preset tokens', (tester) async {
    late EdsDesignTokens seen;
    await tester.pumpWidget(
      MaterialApp(
        home: EdsThemeScope(
          preset: EdsPresetTheme.orange,
          child: Builder(
            builder: (context) {
              seen = context.edsTokens;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(seen.colors.primary, EdsPresetTheme.orange.tokens.colors.primary);
  });

  testWidgets('brightness override beats the platform brightness',
      (tester) async {
    late Brightness seenPlain;
    late Brightness seenOverride;
    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            Builder(
              builder: (context) {
                seenPlain = context.edsBrightness;
                return const SizedBox();
              },
            ),
            EdsThemeScope(
              brightness: Brightness.dark,
              child: Builder(
                builder: (context) {
                  seenOverride = context.edsBrightness;
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
    // The default test platform brightness is light.
    expect(seenPlain, Brightness.light);
    expect(seenOverride, Brightness.dark);
  });
}
