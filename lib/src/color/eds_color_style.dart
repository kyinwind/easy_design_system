import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../tokens/eds_color_hex.dart';

@immutable
class EdsToneSet {
  const EdsToneSet({
    required this.foreground,
    required this.surface,
    required this.strong,
    required this.border,
    required this.onStrong,
  });

  final int foreground;
  final int surface;
  final int strong;
  final int border;
  final int onStrong;

  factory EdsToneSet.fromJson(Map<String, Object?> json) => EdsToneSet(
        foreground: _tone(json, 'foreground'),
        surface: _tone(json, 'surface'),
        strong: _tone(json, 'strong'),
        border: _tone(json, 'border'),
        onStrong: _tone(json, 'onStrong'),
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'foreground': foreground,
        'surface': surface,
        'strong': strong,
        'border': border,
        'onStrong': onStrong,
      };

  @override
  bool operator ==(Object other) =>
      other is EdsToneSet &&
      other.foreground == foreground &&
      other.surface == surface &&
      other.strong == strong &&
      other.border == border &&
      other.onStrong == onStrong;

  @override
  int get hashCode =>
      Object.hash(foreground, surface, strong, border, onStrong);
}

@immutable
class EdsInteractionToneStyle {
  const EdsInteractionToneStyle({
    required this.lightBase,
    required this.darkBase,
    required this.lightHoveredDelta,
    required this.darkHoveredDelta,
    required this.lightPressedDelta,
    required this.darkPressedDelta,
  });

  final int lightBase;
  final int darkBase;
  final int lightHoveredDelta;
  final int darkHoveredDelta;
  final int lightPressedDelta;
  final int darkPressedDelta;

  factory EdsInteractionToneStyle.fromJson(Map<String, Object?> json) =>
      EdsInteractionToneStyle(
        lightBase: _tone(json, 'lightBase'),
        darkBase: _tone(json, 'darkBase'),
        lightHoveredDelta: _integer(json, 'lightHoveredDelta'),
        darkHoveredDelta: _integer(json, 'darkHoveredDelta'),
        lightPressedDelta: _integer(json, 'lightPressedDelta'),
        darkPressedDelta: _integer(json, 'darkPressedDelta'),
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'lightBase': lightBase,
        'darkBase': darkBase,
        'lightHoveredDelta': lightHoveredDelta,
        'darkHoveredDelta': darkHoveredDelta,
        'lightPressedDelta': lightPressedDelta,
        'darkPressedDelta': darkPressedDelta,
      };

  @override
  bool operator ==(Object other) =>
      other is EdsInteractionToneStyle &&
      other.lightBase == lightBase &&
      other.darkBase == darkBase &&
      other.lightHoveredDelta == lightHoveredDelta &&
      other.darkHoveredDelta == darkHoveredDelta &&
      other.lightPressedDelta == lightPressedDelta &&
      other.darkPressedDelta == darkPressedDelta;

  @override
  int get hashCode => Object.hash(
        lightBase,
        darkBase,
        lightHoveredDelta,
        darkHoveredDelta,
        lightPressedDelta,
        darkPressedDelta,
      );
}

enum EdsContentColorRole {
  foregroundPrimary,
  foregroundSecondary,
  foregroundTertiary,
  foregroundDisabled,
  foregroundInverse,
  brandOnStrong,
  informationOnStrong,
  successOnStrong,
  warningOnStrong,
  dangerOnStrong,
}

@immutable
class EdsContentColorOverrides {
  const EdsContentColorOverrides({
    this.light = const <EdsContentColorRole, Color>{},
    this.dark = const <EdsContentColorRole, Color>{},
  });

  final Map<EdsContentColorRole, Color> light;
  final Map<EdsContentColorRole, Color> dark;

  Color? colorFor(EdsContentColorRole role, Brightness brightness) =>
      (brightness == Brightness.dark ? dark : light)[role];

  factory EdsContentColorOverrides.fromJson(Map<String, Object?>? json) {
    if (json == null) return const EdsContentColorOverrides();
    return EdsContentColorOverrides(
      light: _contentColors(_group(json, 'light', required: false)),
      dark: _contentColors(_group(json, 'dark', required: false)),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        if (light.isNotEmpty) 'light': _encodeColors(light),
        if (dark.isNotEmpty) 'dark': _encodeColors(dark),
      };

  @override
  bool operator ==(Object other) =>
      other is EdsContentColorOverrides &&
      mapEquals(other.light, light) &&
      mapEquals(other.dark, dark);

  @override
  int get hashCode => Object.hash(
        Object.hashAllUnordered(light.entries),
        Object.hashAllUnordered(dark.entries),
      );
}

@immutable
class EdsColorStyle {
  const EdsColorStyle({
    required this.id,
    required this.name,
    required this.light,
    required this.dark,
    required this.strongInteraction,
    required this.softInteraction,
    required this.mediumInteraction,
    this.contentColors = const EdsContentColorOverrides(),
  });

  final String id;
  final String name;
  final EdsToneSet light;
  final EdsToneSet dark;
  final EdsInteractionToneStyle strongInteraction;
  final EdsInteractionToneStyle softInteraction;
  final EdsInteractionToneStyle mediumInteraction;
  final EdsContentColorOverrides contentColors;

  static const defaultStyle = EdsColorStyle(
    id: 'default',
    name: 'EDS Default',
    light: EdsToneSet(
        foreground: 35, surface: 95, strong: 49, border: 55, onStrong: 100),
    dark: EdsToneSet(
        foreground: 85, surface: 20, strong: 70, border: 60, onStrong: 10),
    strongInteraction: EdsInteractionToneStyle(
        lightBase: 49,
        darkBase: 70,
        lightHoveredDelta: -5,
        darkHoveredDelta: 5,
        lightPressedDelta: -10,
        darkPressedDelta: 10),
    softInteraction: EdsInteractionToneStyle(
        lightBase: 95,
        darkBase: 20,
        lightHoveredDelta: -3,
        darkHoveredDelta: 4,
        lightPressedDelta: -6,
        darkPressedDelta: 8),
    mediumInteraction: EdsInteractionToneStyle(
        lightBase: 85,
        darkBase: 35,
        lightHoveredDelta: -3,
        darkHoveredDelta: 2,
        lightPressedDelta: -5,
        darkPressedDelta: 3),
  );

  static const vivid = EdsColorStyle(
    id: 'vivid',
    name: 'EDS Vivid',
    light: EdsToneSet(
        foreground: 30, surface: 92, strong: 45, border: 50, onStrong: 100),
    dark: EdsToneSet(
        foreground: 90, surface: 16, strong: 60, border: 65, onStrong: 5),
    strongInteraction: EdsInteractionToneStyle(
        lightBase: 45,
        darkBase: 60,
        lightHoveredDelta: -6,
        darkHoveredDelta: 6,
        lightPressedDelta: -12,
        darkPressedDelta: 12),
    softInteraction: EdsInteractionToneStyle(
        lightBase: 92,
        darkBase: 16,
        lightHoveredDelta: -4,
        darkHoveredDelta: 5,
        lightPressedDelta: -8,
        darkPressedDelta: 10),
    mediumInteraction: EdsInteractionToneStyle(
        lightBase: 80,
        darkBase: 30,
        lightHoveredDelta: -4,
        darkHoveredDelta: 3,
        lightPressedDelta: -7,
        darkPressedDelta: 5),
    contentColors: EdsContentColorOverrides(
      light: <EdsContentColorRole, Color>{
        EdsContentColorRole.foregroundPrimary: Color(0xFF0B0B0D),
        EdsContentColorRole.foregroundSecondary: Color(0xFF515158)
      },
      dark: <EdsContentColorRole, Color>{
        EdsContentColorRole.foregroundPrimary: Color(0xFFFAFAFB),
        EdsContentColorRole.foregroundSecondary: Color(0xFFC4C4CA)
      },
    ),
  );

  static const elegant = EdsColorStyle(
    id: 'elegant',
    name: 'EDS Elegant',
    light: EdsToneSet(
        foreground: 42, surface: 97, strong: 60, border: 65, onStrong: 5),
    dark: EdsToneSet(
        foreground: 78, surface: 24, strong: 80, border: 55, onStrong: 10),
    strongInteraction: EdsInteractionToneStyle(
        lightBase: 60,
        darkBase: 80,
        lightHoveredDelta: -4,
        darkHoveredDelta: 4,
        lightPressedDelta: -8,
        darkPressedDelta: 8),
    softInteraction: EdsInteractionToneStyle(
        lightBase: 97,
        darkBase: 24,
        lightHoveredDelta: -2,
        darkHoveredDelta: 3,
        lightPressedDelta: -5,
        darkPressedDelta: 6),
    mediumInteraction: EdsInteractionToneStyle(
        lightBase: 90,
        darkBase: 40,
        lightHoveredDelta: -2,
        darkHoveredDelta: 2,
        lightPressedDelta: -4,
        darkPressedDelta: 3),
    contentColors: EdsContentColorOverrides(
      light: <EdsContentColorRole, Color>{
        EdsContentColorRole.foregroundPrimary: Color(0xFF242124),
        EdsContentColorRole.foregroundSecondary: Color(0xFF6E676C)
      },
      dark: <EdsContentColorRole, Color>{
        EdsContentColorRole.foregroundPrimary: Color(0xFFEEEAE7),
        EdsContentColorRole.foregroundSecondary: Color(0xFFB8B0AB)
      },
    ),
  );

  static const allBuiltIn = <EdsColorStyle>[defaultStyle, vivid, elegant];

  static EdsColorStyle builtIn(String id) {
    for (final style in allBuiltIn) {
      if (style.id == id) return style;
    }
    throw FormatException('Unknown EDS color style: $id');
  }

  factory EdsColorStyle.fromJson(Map<String, Object?> json) {
    final id = _string(json, 'id');
    final name = _string(json, 'name');
    return EdsColorStyle(
      id: id,
      name: name,
      light: EdsToneSet.fromJson(_group(json, 'light')),
      dark: EdsToneSet.fromJson(_group(json, 'dark')),
      strongInteraction:
          EdsInteractionToneStyle.fromJson(_group(json, 'strongInteraction')),
      softInteraction:
          EdsInteractionToneStyle.fromJson(_group(json, 'softInteraction')),
      mediumInteraction:
          EdsInteractionToneStyle.fromJson(_group(json, 'mediumInteraction')),
      contentColors: EdsContentColorOverrides.fromJson(
          _group(json, 'contentColors', required: false)),
    );
  }

  factory EdsColorStyle.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException(
          'Expected a JSON object for EDS color style.');
    }
    return EdsColorStyle.fromJson(decoded);
  }

  static Future<EdsColorStyle> loadAsset(String assetPath,
      {AssetBundle? bundle}) async {
    final source = await (bundle ?? rootBundle).loadString(assetPath);
    return EdsColorStyle.fromJsonString(source);
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
        'light': light.toJson(),
        'dark': dark.toJson(),
        'strongInteraction': strongInteraction.toJson(),
        'softInteraction': softInteraction.toJson(),
        'mediumInteraction': mediumInteraction.toJson(),
        if (contentColors.toJson().isNotEmpty)
          'contentColors': contentColors.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      other is EdsColorStyle &&
      other.id == id &&
      other.name == name &&
      other.light == light &&
      other.dark == dark &&
      other.strongInteraction == strongInteraction &&
      other.softInteraction == softInteraction &&
      other.mediumInteraction == mediumInteraction &&
      other.contentColors == contentColors;

  @override
  int get hashCode => Object.hash(id, name, light, dark, strongInteraction,
      softInteraction, mediumInteraction, contentColors);
}

int _integer(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) return value;
  throw FormatException('Expected integer for "$key".');
}

int _tone(Map<String, Object?> json, String key) {
  final value = _integer(json, key);
  if (value < 0 || value > 100) {
    throw FormatException('Tone "$key" must be in 0...100.');
  }
  return value;
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('Expected non-empty string for "$key".');
}

Map<String, Object?> _group(Map<String, Object?>? json, String key,
    {bool required = true}) {
  final value = json?[key];
  if (value == null && !required) return <String, Object?>{};
  if (value is Map<String, Object?>) return value;
  throw FormatException('Expected object for "$key".');
}

Map<EdsContentColorRole, Color> _contentColors(Map<String, Object?> json) {
  final result = <EdsContentColorRole, Color>{};
  for (final entry in json.entries) {
    final role = EdsContentColorRole.values
        .where((value) => value.name == entry.key)
        .firstOrNull;
    if (role == null) {
      throw FormatException('Unsupported content color role: ${entry.key}');
    }
    if (entry.value is! String ||
        !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(entry.value! as String)) {
      throw FormatException('Expected #RRGGBB for "${entry.key}".');
    }
    result[role] = EdsColorHex.parseRgb(entry.value! as String);
  }
  return result;
}

Map<String, Object?> _encodeColors(Map<EdsContentColorRole, Color> colors) =>
    <String, Object?>{
      for (final entry in colors.entries)
        entry.key.name: EdsColorHex.toHex(entry.value),
    };
