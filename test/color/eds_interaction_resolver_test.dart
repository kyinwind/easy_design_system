import 'package:easy_design_system/src/color/eds_interaction_resolver.dart';
import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chromatic strong surface changes across interaction states', () {
    final rest = EdsInteractionResolver.strongSurface(
      family: EdsInteractionColorFamily.brand,
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
      state: EdsInteractionState.rest,
    );
    final hover = EdsInteractionResolver.strongSurface(
      family: EdsInteractionColorFamily.brand,
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
      state: EdsInteractionState.hovered,
    );
    final pressed = EdsInteractionResolver.strongSurface(
      family: EdsInteractionColorFamily.brand,
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
      state: EdsInteractionState.pressed,
    );

    expect(hover, isNot(rest));
    expect(pressed, isNot(hover));
  });

  test('neutral state resolver is brightness aware', () {
    final light = EdsInteractionResolver.neutralSurface(
      brightness: Brightness.light,
      state: EdsInteractionState.hovered,
    );
    final dark = EdsInteractionResolver.neutralSurface(
      brightness: Brightness.dark,
      state: EdsInteractionState.hovered,
    );

    expect(light, isNot(dark));
  });
}
