import 'package:flutter/material.dart';

import '../theme/eds_theme_scope.dart';

/// A hero panel with a gradient background, mirroring Swift's
/// `EDSHeroPanel`.
///
/// The gradient comes from the theme's `heroGradient` tokens; the card
/// shadow tokens drive the drop shadow. The gradient itself is painted
/// directly instead of going through `edsSurface`.
class EdsHeroPanel extends StatelessWidget {
  const EdsHeroPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final shadow = tokens.shadow;
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(tokens.spacing.xxl),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: tokens.heroGradient.gradient,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: shadow.shadowColor,
            blurRadius: shadow.radius,
            offset: Offset(shadow.x, shadow.y),
          ),
        ],
      ),
      child: child,
    );
  }
}
