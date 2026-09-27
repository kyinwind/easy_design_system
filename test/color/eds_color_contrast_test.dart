import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

double contrastRatio(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  for (final preset in EdsPresetTheme.allPresets) {
    for (final brightness in Brightness.values) {
      test('${preset.id} semantic text pairs meet contrast in $brightness', () {
        final scheme = EdsColorScheme.resolve(
          seeds: preset.theme.seeds,
          brightness: brightness,
        );

        final strongPairs = <(String, Color, Color)>[
          ('brand', scheme.brandOnStrong, scheme.brandSurfaceStrong),
          (
            'information',
            scheme.informationOnStrong,
            scheme.informationSurfaceStrong,
          ),
          ('success', scheme.successOnStrong, scheme.successSurfaceStrong),
          ('warning', scheme.warningOnStrong, scheme.warningSurfaceStrong),
          ('danger', scheme.dangerOnStrong, scheme.dangerSurfaceStrong),
        ];
        final neutralSurfaces = <(String, Color)>[
          ('page', scheme.surfacePage),
          ('base', scheme.surfaceBase),
          ('raised', scheme.surfaceRaised),
          ('sunken', scheme.surfaceSunken),
          ('overlay', scheme.surfaceOverlay),
        ];

        for (final pair in strongPairs) {
          expect(
            contrastRatio(pair.$2, pair.$3),
            greaterThanOrEqualTo(4.5),
            reason: '${pair.$1} on-strong text must meet WCAG AA',
          );
        }
        for (final surface in neutralSurfaces) {
          expect(
            contrastRatio(scheme.foregroundPrimary, surface.$2),
            greaterThanOrEqualTo(4.5),
            reason: 'primary text on ${surface.$1}',
          );
          expect(
            contrastRatio(scheme.foregroundSecondary, surface.$2),
            greaterThanOrEqualTo(4.5),
            reason: 'secondary text on ${surface.$1}',
          );
          expect(
            contrastRatio(scheme.foregroundTertiary, surface.$2),
            greaterThanOrEqualTo(4.5),
            reason: 'tertiary text on ${surface.$1} must meet WCAG AA',
          );
        }
      });

      test('${preset.id} key indicators meet non-text contrast in $brightness',
          () {
        final scheme = EdsColorScheme.resolve(
          seeds: preset.theme.seeds,
          brightness: brightness,
        );
        final backgrounds = <(String, Color)>[
          ('base', scheme.surfaceBase),
          ('raised', scheme.surfaceRaised),
          ('sunken', scheme.surfaceSunken),
        ];
        final indicators = <(String, Color)>[
          ('focus', scheme.borderFocus),
          ('selected', scheme.borderSelected),
          ('danger', scheme.borderDanger),
          ('strong neutral', scheme.borderStrong),
          ('brand', scheme.brandBorder),
          ('information', scheme.informationBorder),
          ('success', scheme.successBorder),
          ('warning', scheme.warningBorder),
        ];

        for (final background in backgrounds) {
          for (final indicator in indicators) {
            expect(
              contrastRatio(indicator.$2, background.$2),
              greaterThanOrEqualTo(3),
              reason: '${indicator.$1} indicator on ${background.$1}',
            );
          }
        }
      });
    }
  }

  for (final brightness in Brightness.values) {
    test('default interaction colors remain visually ordered in $brightness',
        () {
      final scheme = EdsColorScheme.resolve(
        seeds: const EdsColorSeeds(),
        brightness: brightness,
      );
      expect(scheme.surfaceBase, isNot(scheme.surfaceSunken));
      expect(scheme.borderSubtle, isNot(scheme.borderDefault));
      expect(scheme.borderDefault, isNot(scheme.borderStrong));
    });
  }
}
