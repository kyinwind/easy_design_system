# easy_design_system

A semantic design system for Flutter: design tokens, an Easy API, adaptive
layout, and fine-grained components — a faithful Flutter port of the Swift
[EasyDesignSystem](https://github.com) package.

- **Design tokens** — colors, spacing, radius, typography, control sizes,
  adaptive layout, gradients, strokes and shadows, all themeable.
- **Themes** — three built-in presets (`default`/`blue`, `orange`, `purple`),
  JSON configuration with Swift-compatible schema, import/export.
- **Adaptive layout** — interaction profiles (touch / hybrid / pointer), size
  classes, minimum hit targets, page padding that follows the spacing scale.
- **Easy API** — one-call semantic styling: `.easyDesign(...)`,
  `.easyDesignPreset(...)`, `.easyDesignTokens(...)`.
- **Components** — buttons, badges, toggles, rows, cards, groups, hero panels,
  pages, sections, collapsible sections, states, pills, comparison tables,
  sidebar widgets.

## Installation

```yaml
dependencies:
  easy_design_system: ^0.1.0
```

## Quick start

```dart
import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EdsThemeScope(
      // Subscribes to `EdsTheme.instance` and rebuilds on changes.
      child: MaterialApp(
        theme: ThemeData(fontFamily: 'PingFang SC'),
        home: const AccountPage(),
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return EdsPage(
      '账户',
      subtitle: '管理应用偏好',
      child: EdsPageSection(
        '通用',
        showsDivider: true,
        child: EdsGroup(
          '同步',
          child: EdsSettingRow(
            '自动同步',
            subtitle: '仅在 Wi-Fi 下传输',
            trailing: EdsToggle(
              isOn: true,
              label: '启用',
              onChanged: (value) {},
            ),
          ),
        ),
      ),
    );
  }
}
```

### Configuring tokens

```dart
// Copy-with style (tokens are immutable).
EdsTheme.instance.configure((tokens) {
  return tokens.copyWith(
    colors: tokens.colors.copyWith(primary: const Color(0xFFFF6B00)),
  );
});

// Or apply a preset.
EdsTheme.instance.applyPreset(EdsPresetTheme.orange);

// Or load from JSON (schema compatible with the Swift package).
await EdsTheme.instance.configureJsonAsset('assets/theme.json');

// Export the current theme as JSON.
final json = EdsTheme.instance.exportJsonString();
```

### Easy API

```dart
Text('Content').easyDesign(style: EdsEasyStyle.card);
Text('Section').easyDesign(
  style: EdsEasyStyle.section,
  options: const EdsEasyOptions(padding: EdsSpace.xl),
);
Text('Themed').easyDesignPreset(EdsPresetTheme.purple);
```

## Swift ↔ Dart API reference

| Swift | Dart | Notes |
| --- | --- | --- |
| `EDSTheme.shared` | `EdsTheme.instance` | Singleton + `ValueListenable` |
| `EDSDesignTokens` | `EdsDesignTokens` | Immutable, `copyWith` instead of `inout` |
| `EDSPresetTheme.allPresets` | `EdsPresetTheme.allPresets` | `default` → `defaultTheme` |
| `EDSColorScheme` | `EdsColorScheme` | `resolve(tokens, brightness)` |
| `EDSResolvedMetrics.resolve` | `EdsResolvedMetrics.resolve` | Same parameters |
| `EDSInteractionProfile` | `EdsInteractionProfile` | touch / hybrid / pointer / automatic |
| `EDSButton` | `EdsButton` | Role + `.label` + `.dimension` initializers |
| `EDSButton.Appearance` | `EdsButtonAppearance` | Top-level `EdsButtonEmphasis/Tone/Size` |
| `EDSBadge` | `EdsBadge` | |
| `EDSToggle` | `EdsToggle` | `Binding<Bool>` → `isOn` + `onChanged` |
| `EDSSettingRow` | `EdsSettingRow` | Trailing slot instead of trailing closure |
| `EDSPill` / `EDSPillFlow` | `EdsPill` / `EdsPillFlow` | 12-tone rotating palette |
| `EDSComparisonSection` | `EdsComparisonSection` | `(String, bool, bool)` records |
| `EDSEmptyState` … | `EdsEmptyState` … | Also `EdsErrorState`, `EdsLoadingState`, `EdsProgressPanel` |
| `.easyDesign(_:options:)` | `.easyDesign({style, options})` | |
| `.easyDesign(_:theme:options:)` | `.easyDesignPreset(theme, {style, options})` | Renamed (no overloads in Dart) |
| `.easyDesignTheme(_:)` | `.easyDesignTheme(tokens)` / `.easyDesignThemePreset(preset)` | Scope-only modifiers |
| `Color(hexRGB:)` | `EdsColorHex.parseRgb` | Also `parseArgb` / `parseRgba` |

## Intentional deviations from Swift

- **SF Symbols → Material icons.** `systemImage:` parameters take
  `IconData` (e.g. `Icons.check`), not symbol names.
- **Binding → callback.** `Binding<Bool>` becomes `isOn` + `onChanged`; a null
  `action` renders a disabled control (SwiftUI uses `.disabled()`).
- **Enums are top-level.** Swift's nested `EDSButton.Role` maps to top-level
  `EdsButtonRole` (Dart enums cannot nest inside classes).
- **Dynamic colors resolve explicitly.** SwiftUI's `Color.primary`/
  `Color.secondary` and light/dark system colors live in
  `EdsColorScheme.resolve(tokens, brightness)` via `context.edsScheme`.
- **Legacy SwiftUI `ButtonStyle`s are not ported** — Flutter has no
  `ButtonStyle` protocol; use `EdsButtonAppearance` and the `.dimension`
  constructor instead.
- **`EDSSidebarIconPresetTint` is an enum** with a `.color` getter (Dart enums
  cannot wrap values); dynamic tints read `EdsTheme.instance`.
- **Text truncation** uses `TextOverflow.ellipsis`; SwiftUI's
  `.truncationMode(.middle)` has no direct equivalent.
- **Preset locale** stays `zh-Hans` (labels like `功能对比` are intentionally
  kept in Chinese to match the Swift package); localization hooks may arrive
  in a later release.

## Development

```sh
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

The test suite is a line-by-line port of the Swift package's
`EasyDesignSystemTests`, pinning the same behavioral contracts (hex parsing
semantics, fixture fallbacks, recipe mapping, adaptive metrics, button role
appearances).

## License

MIT — see [LICENSE](LICENSE).
