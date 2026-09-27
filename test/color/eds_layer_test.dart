import 'package:easy_design_system/easy_design_system.dart';
import 'package:easy_design_system/src/color/eds_layer_resolver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('layer nesting clamps after nested', () {
    expect(EdsLayer.base.nestedChild, EdsLayer.raised);
    expect(EdsLayer.raised.nestedChild, EdsLayer.nested);
    expect(EdsLayer.nested.nestedChild, EdsLayer.nested);
    expect(EdsLayer.overlay.nestedChild, EdsLayer.overlay);
  });

  test('layer resolver maps structural surfaces to semantic roles', () {
    final scheme = EdsColorScheme.resolve(
      seeds: const EdsColorSeeds(),
      brightness: Brightness.light,
    );

    expect(EdsLayerResolver.surface(scheme, EdsLayer.base), scheme.surfacePage);
    expect(
      EdsLayerResolver.surface(scheme, EdsLayer.raised),
      scheme.surfaceRaised,
    );
    expect(
      EdsLayerResolver.surface(scheme, EdsLayer.overlay),
      scheme.surfaceOverlay,
    );
  });

  testWidgets('layer scope exposes local context', (tester) async {
    EdsLayer? captured;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: EdsLayerScope(
          layer: EdsLayer.raised,
          child: Builder(
            builder: (context) {
              captured = context.edsLayer;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(captured, EdsLayer.raised);
  });
}
