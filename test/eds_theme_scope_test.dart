import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    EdsTheme.instance.themeData = EdsPresetTheme.defaultTheme.theme;
  });

  testWidgets('environment uses local tokens before global tokens', (
    tester,
  ) async {
    final global = const EdsDesignTokens().copyWith(
      spacing: const EdsSpacingTokens().copyWith(md: 17),
    );
    EdsTheme.instance.themeData =
        EdsTheme.instance.themeData.copyWith(tokens: global);

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

    final local = global.copyWith(spacing: global.spacing.copyWith(md: 29));
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

  testWidgets('preset scope installs preset seeds and tokens', (tester) async {
    late EdsDesignTokens seen;
    late EdsColorSeeds seeds;
    await tester.pumpWidget(
      MaterialApp(
        home: EdsThemeScope(
          preset: EdsPresetTheme.orange,
          child: Builder(
            builder: (context) {
              seen = context.edsTokens;
              seeds = context.edsSeeds;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(seeds.brand, EdsPresetTheme.orange.theme.seeds.brand);
    expect(seen.heroGradient, EdsPresetTheme.orange.theme.tokens.heroGradient);
  });

  testWidgets('scope semantic override patches resolved scheme', (
    tester,
  ) async {
    late Color raised;
    await tester.pumpWidget(
      MaterialApp(
        home: EdsThemeScope(
          semanticOverrides: const EdsSemanticOverrides(
            light: EdsSemanticColorOverrides(
              surfaceRaised: Color(0xFFFDFDFD),
            ),
          ),
          child: Builder(
            builder: (context) {
              raised = context.edsScheme.surfaceRaised;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(raised, const Color(0xFFFDFDFD));
  });

  testWidgets('brightness override beats the platform brightness', (
    tester,
  ) async {
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

  testWidgets('platform brightness is used without a Material theme', (
    tester,
  ) async {
    late Brightness seen;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(platformBrightness: Brightness.dark),
        child: Builder(
          builder: (context) {
            seen = context.edsBrightness;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(seen, Brightness.dark);
  });

  testWidgets('ambient Material ThemeMode drives EDS brightness', (
    tester,
  ) async {
    late Brightness seen;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: Builder(
          builder: (context) {
            seen = context.edsBrightness;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(seen, Brightness.dark);
  });

  testWidgets('explicit EDS brightness still beats Material ThemeMode', (
    tester,
  ) async {
    late Brightness seen;
    await tester.pumpWidget(
      MaterialApp(
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: EdsThemeScope(
          brightness: Brightness.light,
          child: Builder(
            builder: (context) {
              seen = context.edsBrightness;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(seen, Brightness.light);
  });
}
