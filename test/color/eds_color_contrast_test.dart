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
  for (final brightness in Brightness.values) {
    test('strong semantic pairs meet text contrast in $brightness', () {
      final scheme = EdsColorScheme.resolve(
        seeds: const EdsColorSeeds(),
        brightness: brightness,
      );

      final pairs = <(Color, Color)>[
        (scheme.brandOnStrong, scheme.brandSurfaceStrong),
        (scheme.informationOnStrong, scheme.informationSurfaceStrong),
        (scheme.successOnStrong, scheme.successSurfaceStrong),
        (scheme.warningOnStrong, scheme.warningSurfaceStrong),
        (scheme.dangerOnStrong, scheme.dangerSurfaceStrong),
      ];

      for (final pair in pairs) {
        expect(
          contrastRatio(pair.$1, pair.$2),
          greaterThanOrEqualTo(4.5),
        );
      }
    });
  }
}
