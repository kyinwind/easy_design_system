import 'dart:convert';

import '../tokens/eds_design_tokens.dart';

/// Decodes a theme JSON document (the `EDSDefaultTheme.json` schema) into
/// design tokens.
///
/// Mirrors Swift's `JSONDecoder().decode(EDSDesignTokens.self, from:)`:
/// missing keys (or whole groups) fall back to defaults; present-but-wrongly
/// typed values throw a [FormatException]; a non-object root throws a
/// [FormatException] too.
EdsDesignTokens decodeThemeJson(String json) {
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
  return EdsDesignTokens.fromJson(decoded);
}

/// Encodes tokens as a pretty-printed JSON document with sorted keys —
/// byte-for-byte compatible with Swift's
/// `JSONEncoder(outputFormatting: [.prettyPrinted, .sortedKeys])`
/// (two-space indent, integral numbers without a trailing `.0`).
String encodeThemeJson(EdsDesignTokens tokens) {
  final sorted = _sortKeys(tokens.toJson());
  return const JsonEncoder.withIndent('  ').convert(sorted);
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
