# EasyDesignSystem Flutter Color Style JSON 化技术方案与开发计划

> 日期：2026-10-02  
> 目标版本：在当前 `0.4.0` 开发线上新增能力，版本号本次不调整  
> 对齐来源：Swift EasyDesignSystem 的 Color Style 模型

## 1. 背景与问题

Flutter 版已经完成 ColorScheme 2.0，具备 Seed → HCT Tonal Palette → Semantic Color → Component Recipe 主链路，但当前视觉强弱仍由 Dart 常量决定：

- `EdsFamilyToneMap` 写死 foreground / surface / strong / border / onStrong Tone；
- `EdsInteractionResolver` 写死 strong / soft / medium 的基础 Tone 和 hover / pressed 偏移；
- `EdsThemeData` 无 Color Style；
- Theme JSON 无风格标识；
- Catalog 只能切换 Seed 主题，无法独立比较默认、浓烈、淡雅风格；
- 字体和图标前景色只能通过主题级 `semanticOverrides` 修改，不能作为一套可复用风格随包发布。

这使“色系”和“视觉性格”耦合在代码中。目标是让 Seed 继续表达颜色身份，让 Color Style 独立表达浓淡、交互态和可选前景色。

## 2. 设计目标

```text
Seed
  → Material Color Utilities / HCT Tonal Palette
  → Color Style JSON（Tone 映射、交互态、可选前景色）
  → Semantic Colors
  → Components
```

- 同一组 Seed 可以选择 `default`、`vivid`、`elegant`，也可以加载调用方自定义 JSON。
- `default` 是未配置时的默认值，保持现有调用方式可用。
- Color Style 不直接保存最终完整色板，只保存 Tone 规则和确实需要固定的内容色。
- 组件继续只消费语义角色，不直接感知 Style。
- Light / Dark 分别配置。
- Theme 级 `semanticOverrides` 保持最高优先级。

## 3. 数据模型与 JSON Schema

新增公开模型：

- `EdsToneSet`：`foreground`、`surface`、`strong`、`border`、`onStrong`。
- `EdsInteractionToneStyle`：light/dark base、hover delta、pressed delta。
- `EdsContentColorRole`：仅允许正文与 `onStrong` 前景角色。
- `EdsContentColorOverrides`：Light / Dark 前景色覆盖。
- `EdsColorStyle`：id、name、Light/Dark Tone、三类交互态 Tone、可选内容色。

随包新增：

- `lib/assets/eds_default_color_style.json`
- `lib/assets/eds_vivid_color_style.json`
- `lib/assets/eds_elegant_color_style.json`

Theme JSON 在 `colors` 下新增风格 ID：

```json
{
  "colors": {
    "style": "default",
    "seeds": { "brand": "#3185FF" },
    "semanticOverrides": {}
  }
}
```

自定义 Color Style JSON 示例：

```json
{
  "id": "custom-orange",
  "name": "Custom Orange",
  "light": { "foreground": 35, "surface": 95, "strong": 49, "border": 55, "onStrong": 100 },
  "dark": { "foreground": 85, "surface": 20, "strong": 70, "border": 60, "onStrong": 10 },
  "strongInteraction": { "lightBase": 49, "darkBase": 70, "lightHoveredDelta": -5, "darkHoveredDelta": 5, "lightPressedDelta": -10, "darkPressedDelta": 10 },
  "softInteraction": { "lightBase": 95, "darkBase": 20, "lightHoveredDelta": -3, "darkHoveredDelta": 4, "lightPressedDelta": -6, "darkPressedDelta": 8 },
  "mediumInteraction": { "lightBase": 85, "darkBase": 35, "lightHoveredDelta": -3, "darkHoveredDelta": 2, "lightPressedDelta": -5, "darkPressedDelta": 3 },
  "contentColors": {
    "light": { "foregroundPrimary": "#18120E", "brandOnStrong": "#FFFFFF" },
    "dark": { "foregroundPrimary": "#F7F1ED", "brandOnStrong": "#1A0D04" }
  }
}
```

允许的内容色角色：

- `foregroundPrimary`
- `foregroundSecondary`
- `foregroundTertiary`
- `foregroundDisabled`
- `foregroundInverse`
- `brandOnStrong`
- `informationOnStrong`
- `successOnStrong`
- `warningOnStrong`
- `dangerOnStrong`

解析优先级：Material 自动结果 → Color Style `contentColors` → Theme `semanticOverrides`。

## 4. API 与运行时改造

- `EdsThemeData` 新增 `colorStyle`，默认 `EdsColorStyle.defaultStyle`。
- `copyWith`、相等判断、hashCode、Theme Scope、Theme Resolver 全部携带风格。
- `EdsColorResolver.resolve` 新增可选 `style` 参数，用 Style 的 Light/Dark Tone 生成各颜色族。
- `EdsInteractionResolver` 新增可选 `style` 参数，去除交互态魔法数字。
- `EdsTheme` 新增 `applyColorStyle`，保留现有 Seed 与非颜色 Token。
- `decodeThemeJson` 根据 `colors.style` 选择内置风格；缺失时使用默认风格。
- `encodeThemeJson` 写入 `colors.style`。
- 自定义风格通过 `EdsColorStyle.fromJsonString` / `fromJson` 加载后传给 Theme。

## 5. Catalog 界面变化

Catalog 顶部统一主题栏新增“色彩风格”选择器：

- 默认
- 浓烈
- 淡雅

Seed 主题与 Color Style 可以独立组合。任一选择变化时更新全局 `EdsThemeData`，所有 Catalog 页面实时重建并显示新效果；顶部语义色色块也按组合后的结果展示。

主题编辑器页面同步使用解析后的 Semantic Colors，避免直接使用 Seed 或 opacity 拼色。

## 6. 数据库与持久化

**无数据库变更。** 本包没有数据库模型，本功能不新增表、字段或迁移。

持久化变化仅涉及 JSON：

- Theme JSON 新增可选 `colors.style` 字符串；旧的 ColorScheme 2.0 JSON 缺少该字段时自动使用 `default`，无需迁移。
- Color Style 是独立 JSON 资源，不写入本地数据库。
- 未知内置 Style ID 应抛出带 ID 的 `FormatException`，避免静默回退造成视觉偏差。

## 7. 预计修改文件

现有文件：

- `pubspec.yaml`
- `lib/easy_design_system.dart`
- `lib/src/color/eds_color_resolver.dart`
- `lib/src/color/eds_interaction_resolver.dart`
- `lib/src/theme/eds_theme_data.dart`
- `lib/src/theme/eds_theme_resolver.dart`
- `lib/src/theme/eds_theme.dart`
- `lib/src/theme/eds_theme_json.dart`
- `lib/assets/eds_default_theme.json`
- `example/lib/catalog/eds_catalog_theme_playground.dart`
- 可能涉及直接调用 Interaction Resolver 的按钮等组件
- `README.md`
- `CHANGELOG.md`

新增文件：

- `lib/src/color/eds_color_style.dart`
- `lib/assets/eds_default_color_style.json`
- `lib/assets/eds_vivid_color_style.json`
- `lib/assets/eds_elegant_color_style.json`
- `test/color/eds_color_style_test.dart`

## 8. 兼容性与风险

- `EdsThemeData` 新增带默认值的命名参数，现有构造调用保持兼容。
- Resolver 新增带默认值的命名参数，现有调用保持兼容。
- 风格切换会有意改变同一 Seed 的最终颜色，这是新能力的预期行为。
- 固定 `contentColors` 可能破坏对比度；内置风格必须验证 Light/Dark 核心组合达到 WCAG AA 4.5:1。
- Catalog 若只更新 Theme 单例但未触发 Widget rebuild，会出现切换不刷新；应依赖现有 `ValueNotifier<EdsThemeData>` 链路验证。
- 自定义 JSON 需要严格验证 Tone 范围 0...100、颜色格式和允许角色，避免错误配置静默生效。

## 9. 验收与测试计划

- [x] 三套内置 Style JSON 均能解析，ID 唯一。
- [x] 缺少 Theme `colors.style` 时使用默认风格。
- [x] Theme JSON round-trip 保留 Style ID。
- [x] 同一橙色 Seed 在 default / vivid / elegant 下产生不同 strong surface。
- [x] 未配置的内容色继续使用自动结果。
- [x] 配置的内容色正确覆盖对应 Light / Dark 前景角色。
- [x] Theme `semanticOverrides` 优先于 Style `contentColors`。
- [x] 非法 Tone、颜色格式、未知内容色角色和未知 Style ID 明确报错。
- [x] 三套内置风格核心文字/背景组合达到 WCAG AA。
- [x] Catalog 可独立选择 Seed 与 Style，全部页面实时刷新。
- [x] `flutter analyze` 通过。
- [x] `flutter test` 通过。
- [x] Example 的 `flutter test` 通过。

## 10. 开发任务清单

- [x] 分析 Flutter ColorScheme 2.0 现状并确定与 Swift 版的对齐范围。
- [x] 完成本技术方案、数据库/持久化说明、风险和测试计划。
- [x] 新增 Color Style 模型及严格 JSON 校验。
- [x] 新增默认、浓烈、淡雅三套随包 JSON 资源。
- [x] 将 Color Resolver 与 Interaction Resolver 接入 Style。
- [x] 将 Style 接入 ThemeData、Theme、Scope、Resolver 和 Theme JSON。
- [x] 更新直接调用交互色解析器的组件。
- [x] Catalog 增加 Seed × Style 实时选择。
- [x] 更新 README 与 CHANGELOG。
- [x] 完成单元、Widget、静态分析与示例测试。
