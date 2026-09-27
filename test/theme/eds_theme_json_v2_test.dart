import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ColorScheme 2.0 theme JSON round-trips seeds and non-color tokens', () {
    const theme = EdsThemeData(
      seeds: EdsColorSeeds(
        brand: Color(0xFF8B5CF6),
      ),
      semanticOverrides: EdsSemanticOverrides(
        dark: EdsSemanticColorOverrides(
          surfaceRaised: Color(0xFF222226),
        ),
      ),
      tokens: EdsDesignTokens(
        spacing: EdsSpacingTokens(lg: 22),
        radius: EdsRadiusTokens(md: 14),
      ),
    );

    final encoded = encodeThemeJson(theme);
    final decoded = decodeThemeJson(encoded);

    expect(decoded.seeds.brand, theme.seeds.brand);
    expect(decoded.semanticOverrides.dark?.surfaceRaised,
        const Color(0xFF222226));
    expect(decoded.tokens.spacing.lg, 22);
    expect(decoded.tokens.radius.md, 14);
  });
}
