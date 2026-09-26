# Changelog

## Unreleased — Flutter-first component rollout

在 Batch A 桌面正确性补全之后，继续完成 Button API 2、设置页控件、已有组件泛化和常用应用组件扩展。当前仍不提升 Flutter 包版本号，待 CI 全绿后统一确定发布版本。

### Added

- `EdsButton` 新增 `icon`、`isBusy`、`expands`、`EdsButton.custom` 和 `EdsButton.styled`。
- `EdsCheckbox`、`EdsDropdown<T>`、`EdsSegmented<T>`。
- `EdsTextField`、`EdsRadioGroup<T>` / `EdsRadio<T>`、`EdsSlider`。
- `EdsChoicePill`，明确区分 Tag 型 Pill 与可选择 Pill。
- `EdsAlertDialog`、`EdsConfirmDialog`。
- `EdsMenuButton<T>` / `EdsMenuItem<T>`。
- `EdsCollapsibleSection` 增加 initial / controlled expansion API。
- `EdsPillFlow<T>` 泛型化，可通过 `labelBuilder` 绑定业务模型。

### Changed

- `EdsButton.dimension` 标记 Deprecated，新代码使用 `EdsButton.styled`。
- Button 的 `systemImage` 标记 Deprecated，新代码使用 `icon`。
- Button busy 状态不再被 Semantics 当成 disabled；它仍表达业务可用，但暂时不可重复激活。
- Button 色彩 darken 从 RGB 通道乘法改为稳定的 `Color.lerp` 插值。
- `EdsRadio` 使用 Flutter 新版 `RadioGroup` 模型，不依赖已废弃的 `groupValue/onChanged` Radio 参数。
- Catalog 与示例迁移到 Button API 2。

### Compatibility

- 原有 `EdsButton('标题', ...)` 继续有效。
- `systemImage` 和 `EdsButton.dimension` 暂时保留 Deprecated compatibility。
- 原有 `EdsPillFlow(List<String>)` 通过泛型推断继续工作。
- Toast service 仍不进入设计系统；Popover 暂缓，等待真实宿主场景后再确定抽象。

## Unreleased — Batch A

本轮从“Swift 行为移植”继续向 Flutter-first 桌面可用性补全，不改变 Flutter 包版本号。

### Added

- `EdsButton` 增加桌面键盘焦点、Tab 遍历、Enter / Space 激活、Semantics、
  可选 `tooltip`、`focusNode`、`autofocus` 与 `semanticLabel`。
- `EdsTypographyTokens` 增加 Flutter 专用 `fontFamily` /
  `fontFamilyFallback` / `monoFontFamily` / `monoFontFamilyFallback`。
- `EdsComparisonSection` 的标题与 Free/Pro 列标签允许宿主覆盖。
- `EdsPill` 删除操作的 Semantics label / hint 允许宿主覆盖。
- `EdsSidebarMenuItem.presetTint`：在 build 时从局部 `EdsThemeScope` 解析主题色。

### Changed

- `context.edsBrightness` 在没有显式 `EdsThemeScope.brightness` 时优先读取
  Material Theme / `ThemeMode`；没有 Material Theme 时回退到 `MediaQuery`
  平台亮暗，最后回退 `Brightness.light`。
- `EdsButton` hover 不再整体降低 opacity；改为只调整 surface，避免文字和图标
  对比度随 hover 一起降低。
- Sidebar 的主题型 preset tint 推荐使用 `presetTint` / `resolve(context)`。

### Compatibility

- 原有 `EdsButton('标题', ...)`、`EdsButton.label(...)` 与
  `EdsButton.dimension(...)` 调用方式继续有效。
- `EdsSidebarIconPresetTint.color` 暂时保留并标记 Deprecated；它仍读取全局
  `EdsTheme.instance`，新代码应使用局部 Scope 感知 API。
- 旧 Swift-compatible JSON 不需要新增字体字段；Flutter 专用字体字段缺失时保持
  原平台默认字体行为。

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
