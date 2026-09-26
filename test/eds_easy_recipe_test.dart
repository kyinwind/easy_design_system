import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('easy recipe maps all semantic scenes', () {
    final tokens = const EdsDesignTokens().copyWith(
      spacing: const EdsSpacingTokens().copyWith(
        xs: 7,
        md: 15,
        lg: 21,
        xxl: 35,
      ),
      radius: const EdsRadiusTokens().copyWith(md: 13),
    );

    final page = EdsEasyRecipe.resolve(
      style: EdsEasyStyle.page,
      tokens: tokens,
    );
    expect(page.padding, 35);
    expect(page.width, const EdsEasyResolvedWidth.fixed(880));
    expect(page.background, EdsEasyBackgroundPolicy.inherited);

    final content = EdsEasyRecipe.resolve(
      style: EdsEasyStyle.content,
      tokens: tokens,
    );
    expect(content.padding, 15);
    expect(content.width, EdsEasyResolvedWidth.fill);

    final section = EdsEasyRecipe.resolve(
      style: EdsEasyStyle.section,
      tokens: tokens,
    );
    expect(section.padding, 7);
    expect(section.paddingAxis, EdsEasyPaddingAxis.vertical);

    final group = EdsEasyRecipe.resolve(
      style: EdsEasyStyle.group,
      tokens: tokens,
    );
    expect(group.padding, 21);
    expect(group.background, EdsEasyBackgroundPolicy.subtle);
    expect(group.cornerRadius, 13);
    expect(group.showsShadow, isFalse);

    final card = EdsEasyRecipe.resolve(
      style: EdsEasyStyle.card,
      tokens: tokens,
    );
    expect(card.background, EdsEasyBackgroundPolicy.card);
    expect(card.showsBorder, isTrue);
    expect(card.showsShadow, isTrue);

    final plain = EdsEasyRecipe.resolve(
      style: EdsEasyStyle.plain,
      tokens: tokens,
    );
    expect(plain.padding, 0);
    expect(plain.width, EdsEasyResolvedWidth.unchanged);
    expect(plain.background, EdsEasyBackgroundPolicy.inherited);
  });

  test('easy options override recipe without ambiguous null', () {
    final recipe = EdsEasyRecipe.resolve(
      style: EdsEasyStyle.card,
      options: const EdsEasyOptions(
        padding: EdsSpace.none,
        maxContentWidth: EdsEasyWidth.fixed(-10),
        background: EdsEasyVisibility.hidden,
      ),
      tokens: const EdsDesignTokens(),
    );

    expect(recipe.padding, 0);
    expect(recipe.paddingAxis, EdsEasyPaddingAxis.all);
    expect(recipe.width, const EdsEasyResolvedWidth.fixed(0));
    expect(recipe.background, EdsEasyBackgroundPolicy.inherited);
  });

  test('explicit padding override keeps the recipe axis semantics', () {
    final recipe = EdsEasyRecipe.resolve(
      style: EdsEasyStyle.section,
      options: const EdsEasyOptions(padding: EdsSpace.xl),
      tokens: const EdsDesignTokens(),
    );

    expect(recipe.padding, 24);
    expect(recipe.paddingAxis, EdsEasyPaddingAxis.all);
  });

  test('visible background upgrades inherited to page', () {
    final recipe = EdsEasyRecipe.resolve(
      style: EdsEasyStyle.page,
      options: const EdsEasyOptions(background: EdsEasyVisibility.visible),
      tokens: const EdsDesignTokens(),
    );

    expect(recipe.background, EdsEasyBackgroundPolicy.page);
  });
}
