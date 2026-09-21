import 'package:flutter/material.dart';

import '../theme/eds_theme_scope.dart';
import '../tokens/eds_color_scheme.dart';

/// An on/off mark used by comparison tables, mirroring Swift's
/// `EDSIconMark`.
class EdsIconMark extends StatelessWidget {
  const EdsIconMark({super.key, required this.isOn});

  final bool isOn;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Icon(
      isOn ? Icons.check_circle : Icons.remove_circle_outline,
      size: 18,
      color: isOn ? tokens.colors.success : scheme.textTertiary,
    );
  }
}
