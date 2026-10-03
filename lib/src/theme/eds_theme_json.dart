import 'dart:convert';

import '../color/eds_color_seeds.dart';
import '../color/eds_color_style.dart';
import '../color/eds_semantic_overrides.dart';
import '../tokens/eds_design_tokens.dart';
import 'eds_theme_data.dart';

/// Decodes ColorScheme 2.0 theme configuration.
///
/// The top-level non-color token groups keep their existing schema. The
/// `colors` branch contains `seeds` plus optional brightness-specific
/// `semanticOverrides`.
EdsThemeData decodeThemeJson(String json) {
  final Object? decoded;
  try {
    decoded = jsonDecode(json);
  } on FormatException {
    rethrow;
  } catch (error) {
    throw FormatException('Invalid JSON document: $error');
  }

  if (decoded is! Map<String, Object?>) {
    throw FormatException(
      'Expected a JSON object at the root but found ${decoded.runtimeType}.',
    );
  }

  final colors = _readGroup(decoded, 'colors');
  if (colors != null &&
      !colors.containsKey('seeds') &&
      const <String>{'primary', 'accent', 'success', 'warning', 'danger'}
          .any(colors.containsKey)) {
    throw const FormatException(
      'Legacy colors schema is not supported. Use colors.seeds.*.',
    );
  }
  final seeds = EdsColorSeeds.fromJson(_readGroup(colors, 'seeds'));
  final semanticOverrides = EdsSemanticOverrides.fromJson(
    _readGroup(colors, 'semanticOverrides'),
  );
  final styleValue = colors?['style'];
  if (styleValue != null && styleValue is! String) {
    throw const FormatException('Expected a string for "colors.style".');
  }
  final colorStyle = styleValue == null
      ? EdsColorStyle.defaultStyle
      : EdsColorStyle.builtIn(styleValue as String);

  return EdsThemeData(
    seeds: seeds,
    semanticOverrides: semanticOverrides,
    colorStyle: colorStyle,
    tokens: EdsDesignTokens.fromJson(decoded),
  );
}

/// Encodes host theme configuration, not runtime-resolved semantic colors.
String encodeThemeJson(EdsThemeData theme) {
  final root = <String, Object?>{
    'colors': <String, Object?>{
      'seeds': theme.seeds.toJson(),
      'style': theme.colorStyle.id,
      if (theme.semanticOverrides.toJson().isNotEmpty)
        'semanticOverrides': theme.semanticOverrides.toJson(),
    },
    ...theme.tokens.toJson(),
  };
  final sorted = _sortKeys(root);
  return const JsonEncoder.withIndent('  ').convert(sorted);
}

Map<String, Object?>? _readGroup(
  Map<String, Object?>? json,
  String key,
) {
  if (json == null) return null;
  final value = json[key];
  if (value == null) return null;
  if (value is Map<String, Object?>) return value;
  throw FormatException(
    'Expected an object for "$key" but found ${value.runtimeType}.',
  );
}

Object? _sortKeys(Object? value) {
  if (value is Map<String, Object?>) {
    final keys = value.keys.toList()..sort();
    return <String, Object?>{
      for (final key in keys) key: _sortKeys(value[key]),
    };
  }
  return value;
}
