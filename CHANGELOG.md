# Changelog

## Unreleased

### Theme / Color Style

- 新增 JSON 驱动的 `EdsColorStyle`，同一组 Seed 可选择默认、浓烈、淡雅或调用方自定义风格。
- Color Style 分别配置 Light / Dark Tone、strong / soft / medium 交互态以及可选 `contentColors` 前景色。
- `EdsThemeData`、Theme Scope、Color Resolver、Interaction Resolver、Button 和 Theme JSON 全链路接入 Color Style；`semanticOverrides` 保持最高优先级。
- 随包新增 `eds_default_color_style.json`、`eds_vivid_color_style.json`、`eds_elegant_color_style.json`，并校验同步常量与 JSON 不漂移。
- Catalog 顶部增加 Seed × Color Style 独立选择，全部页面实时刷新；主题编辑器改用解析后的语义色。
- 新增 Style JSON 严格校验、Theme JSON round-trip、风格差异、前景色优先级和 WCAG AA 对比度测试。

## 0.4.0 — 2026-09-27

ColorScheme 2.0 breaking release。

### Theme / Color System

- 新增 Seed → Tonal Palette → Semantic Color Scheme → Component Recipe 架构。
- 新增 `EdsThemeData`、`EdsColorSeeds`、`EdsColorSeedOverrides`、
  `EdsSemanticOverrides` 与 `EdsResolvedTheme`。
- `EdsDesignTokens` 继续管理 spacing / radius / typography / controlSize /
  adaptiveLayout / heroGradient / stroke / shadow，但不再保存 colors。
- 新增 EDS-owned Neutral Foundation、Brand / Information / Success /
  Warning / Danger Semantic Families。
- 新增 Interaction Resolver 与 Layer / Context。
- Seed Palette 使用 perceptual tonal palette，当前基于
  `material_color_utilities`。

### Breaking API

- 删除 `EdsColorTokens` 与旧 `primary / accent / *Soft` 颜色体系。
- `EdsButtonTone.accent` 改为 `EdsButtonTone.brand`，新增
  `information`。
- `EdsBadgeStyle.accent` 改为 `EdsBadgeStyle.brand`。
- `EdsValueRow.tone` 从 Raw Color 改为 `EdsValueTone`。
- `EdsCard` / `EdsGroup` 不再提供标准组件级 Raw Background Override。
- `EdsTheme.instance.tokensListenable` 改为 `themeListenable`。
- JSON `colors.primary` 等旧 schema 被替换为
  `colors.seeds + colors.semanticOverrides`，不保留兼容解析。

### Components

- Button / Form Controls / Choice / Badge / Sidebar / Surface / Dialog /
  Menu / States / Easy API 全部迁移到 Semantic Color Scheme。
- Focus / Selected / Primary Action / Active Navigation 默认使用 Brand。
- Disabled 使用独立 Semantic Roles，不再统一整组件 opacity。
- Field Surface 支持 Layer Context。

### Catalog / Tests

- 新增 ColorScheme 2.0 Catalog Showcase：Color Foundation、Layer、
  Component Matrix、Blue / Orange / Purple、Light / Dark。
- 新增当前 EDS / Material 对齐 / Fluent 风格三方案语义色彩校准视图。
- `foregroundTertiary` 调整为浅色 `#6C6C72`、暗色 `#97979F`，
  确保在全部中性 Surface 上达到 WCAG AA `4.5:1` 文字对比度。
- 新增 Seed / Semantic Scheme / Contrast / Interaction / Layer /
  Theme JSON 测试。
- 迁移现有 Widget / README compile / example tests。

### Migration

- 详见
  `docs/20260927_EDS_ColorScheme_2.0_Breaking_Migration_Guide.md`。

---

## 0.3.1 — 2026-09-27

Host-app form integration improvements discovered during the RightClickMate migration.

### Added

- `EdsTextField.errorText` for explicit validation/error display outside a `Form`.
- `EdsTextFormField` with `validator`, `onSaved`, `autovalidateMode`, `errorBuilder`, `initialValue` and forced `errorText` support.
- `EdsDropdownFormField<T>` with Flutter `FormField` validation/saving APIs and typed values.
- `EdsButton.fullWidth` as an Easy API for common full-row actions.

### Changed

- Form-capable text and dropdown controls use EDS typography, colors, radius and error styling while preserving Flutter's native `Form` lifecycle.
- `EdsButton.expands` intentionally remains `false` by default. Content-sized buttons stay safe in rows, dialogs and toolbars; use `EdsButton.fullWidth` or `expands: true` when full width is intended.
- `EdsDropdownFormField<T>` uses Flutter's current `initialValue` API rather than the deprecated `value` parameter.

### Compatibility

- Existing `EdsTextField`, `EdsDropdown<T>` and `EdsButton` calls remain source-compatible.
- The new FormField widgets are additive APIs intended for host screens that previously relied on `TextFormField` / `DropdownButtonFormField`.

## 0.3.0 — 2026-09-27

Flutter-first component rollout. This release completes the desktop correctness work from Batch A, introduces Button API 2, adds the high-frequency settings/form controls needed by host apps, and generalizes several existing components.

### Added

- `EdsButton`: `icon`, `isBusy`, `expands`, `focusNode`, `autofocus`, `EdsButton.custom`, and `EdsButton.styled`.
- Desktop button interaction baseline: Tab focus, Enter / Space activation, focus ring, Tooltip and Semantics.
- `EdsCheckbox`, `EdsDropdown<T>`, `EdsSegmented<T>`.
- `EdsTextField`, `EdsRadioGroup<T>` / `EdsRadio<T>`, `EdsSlider`.
- `EdsChoicePill`, separating choice/filter semantics from tag-style `EdsPill`.
- `EdsAlertDialog`, `EdsConfirmDialog`.
- `EdsMenuButton<T>` / `EdsMenuItem<T>`.
- `EdsCollapsibleSection` initial and controlled expansion APIs plus keyboard/focus support.
- `EdsPillFlow<T>` with `labelBuilder` and typed callbacks.
- `EdsTypographyTokens`: `fontFamily`, `fontFamilyFallback`, `monoFontFamily`, `monoFontFamilyFallback`.
- Host-overridable Comparison labels and Pill remove Semantics labels/hints.
- Scope-aware Sidebar preset tint resolution.

### Changed

- `context.edsBrightness` now resolves in this order: explicit `EdsThemeScope.brightness` → ambient Material Theme / ThemeMode → platform brightness → light.
- `EdsButton.dimension` is deprecated; new code should use `EdsButton.styled`.
- Button `systemImage` is deprecated; new code should use `icon`.
- Busy buttons remain semantically enabled but cannot be activated repeatedly while busy.
- Button hover adjusts the surface instead of fading the whole control.
- Button darkening uses stable `Color.lerp` interpolation instead of raw RGB channel multiplication.
- `EdsRadio` uses Flutter's modern `RadioGroup` model.
- Catalog and examples migrated to Button API 2.
- Pill remove Semantics are emitted as a distinct action node.
- Sidebar theme presets now resolve from the local `EdsThemeScope`.

### Compatibility

- Existing `EdsButton('title', ...)` calls remain valid.
- `systemImage` and `EdsButton.dimension` remain available as deprecated compatibility APIs.
- Existing `EdsPillFlow(List<String>)` usage continues to work through generic type inference.
- Old Swift-compatible theme JSON remains valid; Flutter-only typography fields are optional.
- `EdsSidebarIconPresetTint.color` remains temporarily available as a deprecated global-theme compatibility path.
- Toast service is intentionally outside EDS; Popover remains deferred until a real host interaction requires a stable abstraction.

## 0.2.0 — 2026-09-22

Sync button visual system with Swift EasyDesignSystem 0.3.1–0.4.2.

### Added

- **`EdsButtonEmphasis.medium`**：25% 色底 + 深一档同色系文字（neutral 用
  `textPrimary`）。档位强度序：`filled` → `medium` → `outline` → `soft` → `plain`。
- **`EdsButtonRole.normal`**：灰底次级操作快捷方式，等价于 `soft + neutral + regular`。
- **`EdsColorTokens.primarySoft`**：`primary` 的 12% 透明版本。`accentSoft` 改为
  `primarySoft` 的别名（包内不再跟随 `accent`，与 Swift 0.3.1 收敛一致）。
- `EdsButtonAppearance.resolve()` 公开方法 + `EdsResolvedButtonVisual` 公开类型，
  供测试验证按钮视觉规则。

### Changed

- **`EdsButtonEmphasis.outline` 重做为 MD3 风格**：透明底 + 1pt 中性浅边框
  （`scheme.border`）+ tone 色文字。边框不再染主题色，强调全靠文字色。
  `success` tone 与 `soft` 档同规则改用 `textPrimary` 保证可读。
- **`EdsButtonRole.secondary` 视觉跟随**：别名从 `outline + accent` 改指
  `medium + accent`，调用方源码零改动。
- **`filled` 彩色档文字统一白色**：`success` / `warning` 实心档从 `textPrimary`
  改为白色，与 `accent` / `danger` 实心档观感一致。
- **`outline` 边框宽度从 1.5pt 改为 `stroke.hairline`（1pt）**，非 outline 档仍用 1.5pt。
- **按钮标签防压缩变形**：`maxLines: 1` + `TextOverflow.ellipsis`，容器过窄时
  按钮保持胶囊形状，宁可溢出不折行。

### Compatibility

- 既有 `EdsButton(role: .secondary)` 调用点源码零改动，视觉自动从"白底描边"变为
  "主题色 25% 中底"。
- `accentSoft` 仍可读取，值为 `primarySoft` 的别名，不构成破坏性变更。

## 0.1.0

Initial release — a Flutter port of the Swift EasyDesignSystem package.

- Design tokens: colors, spacing, radius, typography, control sizes, adaptive
  layout, hero gradient, stroke, shadow.
- `EdsTheme` singleton with copyWith-style configuration, JSON string/asset
  loading (Swift-compatible schema), preset application and JSON export.
- Presets: `defaultTheme` (alias `blue`), `orange`, `purple`.
- `EdsThemeScope` environment scoping with `context.edsTokens` /
  `context.edsScheme` / `context.edsBrightness`.
- Adaptive layout: interaction profiles, size classes, resolved metrics,
  minimum hit targets.
- Easy API: `EdsEasy` + `easyDesign` / `easyDesignPreset` / `easyDesignTokens`
  extensions over six semantic scenes.
- Components: button (roles + three-dimensional appearance), badge, toggle,
  text primitives, setting/value/inline/multiline rows, card, group, hero
  panel, page, page section, section, collapsible section, empty/error/
  loading/progress states, pill flow, comparison section, sidebar widgets.
- Swift-parity test suite ported from `EasyDesignSystemTests`.
