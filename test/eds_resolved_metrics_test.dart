import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adaptive metrics resolve interaction profiles', () {
    final tokens = const EdsDesignTokens().copyWith(
      spacing: const EdsSpacingTokens().copyWith(md: 17, xxl: 33),
    );

    final touchCompact = EdsResolvedMetrics.resolve(
      tokens: tokens,
      profile: EdsInteractionProfile.touch,
      horizontalSizeClass: EdsSizeClass.compact,
    );
    expect(touchCompact.pagePadding, 17);
    expect(touchCompact.minimumInteractiveDimension, 44);
    expect(touchCompact.showsPersistentAuxiliaryActions, isTrue);
    expect(touchCompact.supportsHoverEnhancement, isFalse);

    final pointerRegular = EdsResolvedMetrics.resolve(
      tokens: tokens,
      profile: EdsInteractionProfile.pointer,
      horizontalSizeClass: EdsSizeClass.regular,
    );
    expect(pointerRegular.pagePadding, 33);
    expect(pointerRegular.minimumInteractiveDimension, 0);
    expect(pointerRegular.showsPersistentAuxiliaryActions, isFalse);
    expect(pointerRegular.supportsHoverEnhancement, isTrue);

    final hybrid = EdsResolvedMetrics.resolve(
      tokens: tokens,
      profile: EdsInteractionProfile.hybrid,
      horizontalSizeClass: EdsSizeClass.regular,
    );
    expect(hybrid.minimumInteractiveDimension, 44);
    expect(hybrid.showsPersistentAuxiliaryActions, isTrue);
    expect(hybrid.supportsHoverEnhancement, isTrue);
  });

  test('explicit adaptive padding overrides spacing compatibility fallback',
      () {
    final tokens = const EdsDesignTokens().copyWith(
      spacing: const EdsSpacingTokens().copyWith(md: 17, xxl: 33),
      adaptiveLayout: const EdsAdaptiveLayoutTokens().copyWith(
        compactPagePadding: 20,
        regularPagePadding: 36,
      ),
    );

    expect(
      EdsResolvedMetrics.resolve(
        tokens: tokens,
        profile: EdsInteractionProfile.touch,
        horizontalSizeClass: EdsSizeClass.compact,
      ).pagePadding,
      20,
    );
    expect(
      EdsResolvedMetrics.resolve(
        tokens: tokens,
        profile: EdsInteractionProfile.pointer,
        horizontalSizeClass: EdsSizeClass.regular,
      ).pagePadding,
      36,
    );
  });

  test('null size class is treated as regular', () {
    final metrics = EdsResolvedMetrics.resolve(
      tokens: const EdsDesignTokens(),
      profile: EdsInteractionProfile.touch,
    );

    // regularPagePadding default falls back to spacing.xxl (32).
    expect(metrics.pagePadding, 32);
  });

  test('interactiveHeight never shrinks below the hit target', () {
    final touch = EdsResolvedMetrics.resolve(
      tokens: const EdsDesignTokens(),
      profile: EdsInteractionProfile.touch,
    );
    final pointer = EdsResolvedMetrics.resolve(
      tokens: const EdsDesignTokens(),
      profile: EdsInteractionProfile.pointer,
    );

    expect(touch.interactiveHeight(28), 44);
    expect(touch.interactiveHeight(52), 52);
    expect(pointer.interactiveHeight(28), 28);
  });
}
