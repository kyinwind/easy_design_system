import 'package:flutter/painting.dart';

import '../tokens/eds_design_tokens.dart';

/// A built-in theme preset, mirroring Swift's `EDSPresetTheme`.
///
/// Two presets are equal when their [id]s are equal, matching the Swift
/// implementation.
class EdsPresetTheme {
  const EdsPresetTheme({
    required this.id,
    required this.name,
    required this.tokens,
  });

  final String id;
  final String name;
  final EdsDesignTokens tokens;

  @override
  bool operator ==(Object other) => other is EdsPresetTheme && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'EdsPresetTheme($id)';

  /// The default blue theme.
  ///
  /// Swift names this `.default`; `default` is a reserved word in Dart, so the
  /// Dart spelling is [defaultTheme].
  static const EdsPresetTheme defaultTheme = EdsPresetTheme(
    id: 'default',
    name: '默认蓝色',
    tokens: EdsDesignTokens(
      heroGradient: EdsDesignTokens.heroGradientBlue,
    ),
  );

  /// The generic blue theme; an alias of [defaultTheme], like Swift's
  /// `EDSPresetTheme.blue`.
  static const EdsPresetTheme blue = defaultTheme;

  /// The orange theme.
  static const EdsPresetTheme orange = EdsPresetTheme(
    id: 'orange',
    name: '橙色',
    tokens: EdsDesignTokens(
      colors: EdsColorTokens(
        primary: Color(0xFFFF6B00),
        accent: Color(0xFFFF6B00),
      ),
      heroGradient: EdsDesignTokens.heroGradientOrange,
    ),
  );

  /// The purple theme.
  static const EdsPresetTheme purple = EdsPresetTheme(
    id: 'purple',
    name: '紫色',
    tokens: EdsDesignTokens(
      colors: EdsColorTokens(
        primary: Color(0xFF8B5CF6),
        accent: Color(0xFF8B5CF6),
        success: Color(0xFF10B981),
        warning: Color(0xFFF59E0B),
        danger: Color(0xFFEF4444),
      ),
      heroGradient: EdsDesignTokens.heroGradientPurple,
    ),
  );

  /// All built-in presets.
  static const List<EdsPresetTheme> allPresets = <EdsPresetTheme>[
    defaultTheme,
    orange,
    purple,
  ];
}
