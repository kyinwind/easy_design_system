import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';

class CatalogThemeEntry {
  const CatalogThemeEntry({
    required this.id,
    required this.name,
    required this.detail,
    required this.isBuiltIn,
    required this.preset,
  });

  final String id;
  final String name;
  final String detail;
  final bool isBuiltIn;
  final EdsPresetTheme preset;

  List<Color> swatchColors(EdsColorStyle style, Brightness brightness) {
    final scheme = EdsColorScheme.resolve(
      seeds: preset.theme.seeds,
      brightness: brightness,
      style: style,
    );
    return <Color>[
      scheme.brandSurfaceStrong,
      scheme.successSurfaceStrong,
      scheme.warningSurfaceStrong,
      scheme.dangerSurfaceStrong,
    ];
  }
}

abstract final class CatalogThemeCatalog {
  static const String defaultThemeId = 'builtin.default';

  static const List<CatalogThemeEntry> builtIn = <CatalogThemeEntry>[
    CatalogThemeEntry(
      id: defaultThemeId,
      name: '默认蓝',
      detail: '包内预设 · #3185FF',
      isBuiltIn: true,
      preset: EdsPresetTheme.defaultTheme,
    ),
    CatalogThemeEntry(
      id: 'builtin.orange',
      name: '橙',
      detail: '包内预设 · #FF6B00',
      isBuiltIn: true,
      preset: EdsPresetTheme.orange,
    ),
    CatalogThemeEntry(
      id: 'builtin.purple',
      name: '紫',
      detail: '包内预设 · #8B5CF6',
      isBuiltIn: true,
      preset: EdsPresetTheme.purple,
    ),
  ];

  static final List<CatalogThemeEntry> custom = <CatalogThemeEntry>[
    _makeCustom(
      id: 'custom.businessBlue',
      name: '商务深蓝',
      primaryHex: '#1D4ED8',
      endHex: '#123A9E',
    ),
    _makeCustom(
      id: 'custom.teal',
      name: '青',
      primaryHex: '#0E9E9E',
      endHex: '#0A7373',
    ),
    _makeCustom(
      id: 'custom.green',
      name: '绿',
      primaryHex: '#27B15A',
      endHex: '#1B8342',
    ),
    _makeCustom(
      id: 'custom.rose',
      name: '玫红',
      primaryHex: '#E0457B',
      endHex: '#B32B5C',
    ),
  ];

  static List<CatalogThemeEntry> get all => <CatalogThemeEntry>[
        ...builtIn,
        ...custom,
      ];

  static CatalogThemeEntry? entryById(String id) {
    for (final entry in all) {
      if (entry.id == id) {
        return entry;
      }
    }
    return null;
  }

  static EdsPresetTheme? presetById(String id) => entryById(id)?.preset;

  static CatalogThemeEntry _makeCustom({
    required String id,
    required String name,
    required String primaryHex,
    required String endHex,
  }) {
    final brand = EdsColorHex.parseRgb(primaryHex);
    final theme = EdsThemeData(
      seeds: EdsColorSeeds(brand: brand),
      tokens: const EdsDesignTokens().copyWith(
        heroGradient: EdsHeroGradient(
          startColor: brand,
          endColor: EdsColorHex.parseRgb(endHex),
        ),
      ),
    );
    return CatalogThemeEntry(
      id: id,
      name: name,
      detail: '包外自定义 · $primaryHex',
      isBuiltIn: false,
      preset: EdsPresetTheme(id: id, name: name, theme: theme),
    );
  }
}

class CatalogThemeBar extends StatefulWidget {
  const CatalogThemeBar({
    super.key,
    this.initialThemeId = CatalogThemeCatalog.defaultThemeId,
  });

  final String initialThemeId;

  @override
  State<CatalogThemeBar> createState() => _CatalogThemeBarState();
}

class _CatalogThemeBarState extends State<CatalogThemeBar> {
  late String _selectedId = widget.initialThemeId;
  String _selectedStyleId = EdsColorStyle.defaultStyle.id;

  void _select(String id) {
    final preset = CatalogThemeCatalog.presetById(id);
    if (preset == null) {
      return;
    }
    final style = EdsColorStyle.builtIn(_selectedStyleId);
    EdsTheme.instance.themeData = preset.theme.copyWith(colorStyle: style);
    setState(() {
      _selectedId = id;
    });
  }

  void _selectStyle(String id) {
    final style = EdsColorStyle.builtIn(id);
    final preset = CatalogThemeCatalog.presetById(_selectedId);
    if (preset == null) return;
    EdsTheme.instance.themeData = preset.theme.copyWith(colorStyle: style);
    setState(() => _selectedStyleId = id);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final entry = CatalogThemeCatalog.entryById(_selectedId);
    final style = EdsColorStyle.builtIn(_selectedStyleId);
    return Container(
      color: scheme.surfaceRaised,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.sm,
      ),
      child: Wrap(
        spacing: tokens.spacing.sm,
        runSpacing: tokens.spacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Text(
            '预览主题',
            style: tokens.typography.captionStrong.copyWith(
              color: scheme.foregroundSecondary,
            ),
          ),
          PopupMenuButton<String>(
            key: const Key('catalog.theme.picker'),
            initialValue: _selectedId,
            onSelected: _select,
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              _menuHeader(context, '包内预设'),
              for (final entry in CatalogThemeCatalog.builtIn)
                _menuItem(context, entry),
              _menuHeader(context, '包外自定义示例'),
              for (final entry in CatalogThemeCatalog.custom)
                _menuItem(context, entry),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  entry?.name ?? '未知主题',
                  style: tokens.typography.bodyStrong.copyWith(
                    color: scheme.foregroundPrimary,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: scheme.foregroundSecondary,
                ),
              ],
            ),
          ),
          Text(
            '色彩风格',
            style: tokens.typography.captionStrong.copyWith(
              color: scheme.foregroundSecondary,
            ),
          ),
          PopupMenuButton<String>(
            key: const Key('catalog.color-style.picker'),
            initialValue: _selectedStyleId,
            onSelected: _selectStyle,
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              for (final item in EdsColorStyle.allBuiltIn)
                PopupMenuItem<String>(
                  value: item.id,
                  child: Text(_styleName(item)),
                ),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _styleName(style),
                  style: tokens.typography.bodyStrong.copyWith(
                    color: scheme.foregroundPrimary,
                  ),
                ),
                Icon(Icons.arrow_drop_down,
                    size: 18, color: scheme.foregroundSecondary),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final color
                  in entry?.swatchColors(style, context.edsBrightness) ??
                      const <Color>[])
                Padding(
                  padding: EdgeInsets.only(right: tokens.spacing.xxs),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border:
                          Border.all(color: scheme.borderDefault, width: 0.5),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _styleName(EdsColorStyle style) => switch (style.id) {
        'vivid' => '浓烈',
        'elegant' => '淡雅',
        _ => '默认',
      };

  PopupMenuItem<String> _menuItem(
    BuildContext context,
    CatalogThemeEntry entry,
  ) {
    final scheme = context.edsScheme;
    return PopupMenuItem<String>(
      value: entry.id,
      height: 44,
      child: Text(
        entry.name,
        style: TextStyle(fontSize: 14, color: scheme.foregroundPrimary),
      ),
    );
  }

  PopupMenuItem<String> _menuHeader(BuildContext context, String label) {
    final scheme = context.edsScheme;
    return PopupMenuItem<String>(
      enabled: false,
      height: 36,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: scheme.foregroundTertiary,
        ),
      ),
    );
  }
}
