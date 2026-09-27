import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('partial seed overrides preserve unspecified preset seeds', () {
    const base = EdsColorSeeds();
    final resolved = base.apply(
      const EdsColorSeedOverrides(
        brand: Color(0xFF8B5CF6),
      ),
    );

    expect(resolved.brand, const Color(0xFF8B5CF6));
    expect(resolved.information, base.information);
    expect(resolved.success, base.success);
    expect(resolved.warning, base.warning);
    expect(resolved.danger, base.danger);
  });

  test('theme data keeps non-color tokens while applying seed overrides', () {
    const theme = EdsThemeData(
      tokens: EdsDesignTokens(
        spacing: EdsSpacingTokens(lg: 22),
      ),
    );

    final changed = theme.withSeedOverrides(
      const EdsColorSeedOverrides(
        brand: Color(0xFFFF6B00),
      ),
    );

    expect(changed.seeds.brand, const Color(0xFFFF6B00));
    expect(changed.tokens.spacing.lg, 22);
  });
}
