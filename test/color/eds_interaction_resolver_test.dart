import 'package:easy_design_system/src/color/eds_interaction_resolver.dart';
import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrastRatio(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

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

  for (final preset in EdsPresetTheme.allPresets) {
    for (final brightness in Brightness.values) {
      test(
          '${preset.id} button interactions remain distinct and readable in $brightness',
          () {
        final scheme = EdsColorScheme.resolve(
          seeds: preset.theme.seeds,
          brightness: brightness,
        );

        for (final tone in EdsButtonTone.values) {
          for (final emphasis in EdsButtonEmphasis.values) {
            final appearance = EdsButtonAppearance(
              tone: tone,
              emphasis: emphasis,
            );
            final visuals = <EdsResolvedButtonVisual>[
              for (final state in EdsInteractionState.values)
                appearance.resolve(
                  tokens: preset.theme.tokens,
                  scheme: scheme,
                  seeds: preset.theme.seeds,
                  brightness: brightness,
                  state: state,
                ),
            ];

            for (var index = 0; index < visuals.length; index += 1) {
              final visual = visuals[index];
              if (visual.background case final background?) {
                expect(
                  _contrastRatio(visual.foreground, background),
                  greaterThanOrEqualTo(4.5),
                  reason:
                      '${tone.name}/${emphasis.name}/${EdsInteractionState.values[index].name} label contrast in $brightness',
                );
              }
            }

            if (emphasis != EdsButtonEmphasis.outline &&
                emphasis != EdsButtonEmphasis.plain) {
              expect(
                visuals.map((visual) => visual.background).toSet(),
                hasLength(3),
                reason:
                    '${tone.name}/${emphasis.name} needs visible rest/hover/pressed states',
              );
            }
          }
        }
      });
    }
  }
}
