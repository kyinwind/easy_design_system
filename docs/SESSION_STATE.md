# 会话状态存档

> 最后更新：2026-09-21
> 仓库：`/Users/yangxuehui/Documents/dev_open_source/easy_design_system`
> 源包（Swift）：`/Users/yangxuehui/Documents/dev_open_source/EasyDesignSystem`

## 当前进度

**阶段：v0.1.0 已完成并提交（commit `3a17590`，tag `v0.1.0`）。analyze 零告警，53/53 测试全绿，example 可编译。**

已完成（M0~M4 全部 + M5 大部分）：

1. M0：脚手架、LICENSE(MIT)、CI（analyze+format+test）、fixtures 字节级复制、example、README（含 Swift↔Dart 对照表与偏差说明）、CHANGELOG。
2. M1：Token 系统（`eds_color_hex`/`eds_design_tokens`/`eds_color_scheme`）+ 主题机制（`eds_theme`/`eds_preset_theme`/`eds_theme_json`/`eds_theme_scope`）。
3. M2：Easy API（`eds_easy`/`eds_easy_recipe`/`eds_easy_style`/`eds_easy_extension`）+ 自适应层（`eds_interaction_profile`/`eds_size_class`/`eds_resolved_metrics`）+ 基础原语（`eds_font`/`eds_surface`）。
4. M3+M4：17 个 widget 文件（button/badge/toggle/text/rows/card/group/hero_panel/page/page_section/section/collapsible_section/states/pills/comparison_section/icon_mark/sidebar）。
5. 测试 8 文件 53 用例，逐条对齐 Swift `EasyDesignSystemTests`（含 `testDoneRoleResolvesToFilledSuccess`、`testLegacyRolesKeepTheirAppearance`）。
6. git 仓库初始化、首次提交、tag v0.1.0；`pubspec.lock` 不入库（库包惯例）。

### 本轮修复的关键问题（易复发，备忘）

- **包资产 key 环境差异**：`lib/assets/...` 在真实 App 中 key 为 `packages/easy_design_system/assets/...`（剥 `lib/`），但包自身 `flutter test` 环境是 `packages/easy_design_system/lib/assets/...`。`applyDefaultThemeFromPackage` 用 4 个候选路径依次尝试。
- **`flutter test` 里 `rootBundle` 需 Binding**：纯 `test()`（非 `testWidgets`）文件必须 `TestWidgetsFlutterBinding.ensureInitialized()` 才能 `rootBundle.loadString`。
- **EdsToggle 无界宽度槽位崩溃**：Row 给非 flex 子项无界宽度，内含 `Spacer`（tight flex）的 widget 放进 `EdsSettingRow.trailing` 会炸。EdsToggle 已用 `LayoutBuilder` 按约束切展开/紧凑布局。其他含 flex 的 widget 若要进 trailing 槽位需同样处理。
- **扩展方法重名二义性**：`easyDesignTheme` 曾同时存在于 EdsEasyWidgetX（style+theme）与 EdsThemeWidgetX（scope-only），analyzer 报 ambiguous。已改名：`easyDesignPreset(preset, {style, options})` + `easyDesignTheme(tokens)` / `easyDesignThemePreset(preset)`。
- `ListView` 构造非 const；`const MaterialApp` 里包 ListView 会 `const_with_non_const`，改用 `children: const [...]`。
- `Object.hash` 单值用 `runtimeType.hashCode`；私有命名参数不合法；`EdsSectionTitle` 三元分支 `!` 精确化；未用 import（`context.edsTokens` 不点名类型时不 import token 文件）。

## 下一步（新会话从这里继续）

1. **发布前必办**：`pubspec.yaml` 补 `repository`/`homepage` 字段（当前无，发布 pub.dev 必填校验会失败）；随后 `flutter pub publish --dry-run` 验证，再正式发布。
2. M5 剩余（可选）：Catalog example 升级为组件 Gallery + Token 编辑器 + Easy API 演示页。
3. 可选增强：本地化钩子（组件内中文文案参数化）、`EdsSettingRow.trailing` 槽位的通用无界宽度适配器、Sliver 版 Section。

## 关键技术决策备忘（详见技术方案）

- 纯 Dart Flutter package，无 platform channel；无三方运行时依赖；lib/ 禁 dart:io
- JSON 主题 schema 与 Swift 版兼容（key 驼峰；缺失字段回退默认；错误抛异常不静默回退；导出排序 key + 2 空格缩进）
- `EDSTheme.shared` → `EdsTheme.instance`（单例 + `ValueNotifier`，`tokensListenable` 可监听）
- `EdsThemeScope`（InheritedWidget）局部优先；`context.edsTokens`/`context.edsScheme`/`context.edsBrightness`
- SF Symbols → `IconData`；`Binding<Bool>` → `isOn`+`onChanged`；null `action` = disabled
- Swift 嵌套枚举 → Dart 顶层枚举（`EdsButtonRole/Emphasis/Tone/Size`、`EdsSidebarIconSize`）
- 语义色亮暗：`EdsColorScheme.resolve(tokens, brightness)`（pageBackground #F7F7F7/#1E1E20，cardBackground #FFFFFF/#2A2A2C，textPrimary=label 全透明度等）
- 尺寸断点 600 逻辑像素；textScaler ≥ 1.7 / `edsIsAccessibilityTextSize` 时 Row 切竖排
- `EdsButton` Role 5 档（primary/secondary/soft/danger/done），`.done`=filled+success+checkmark 默认图标（Swift 2026-09-20 目视验收后固化，测试钉死）
- `EdsPillTone.defaultPalette` 12 色、border 非可选（`border ?? fg 0.16`）；`EdsPillFlow` tone 按排序后 index 轮转
- `minHeight` 居中技巧：`ConstrainedBox(minHeight) > Align(center, widthFactor: 1.0)`（Container+alignment 会双向撑满）
- Row/Column `spacing:` 参数（Flutter ≥3.27）；divider 统一 `Divider(height: 1, thickness: 1, color: scheme.border)`

## 新会话恢复指引

- 先读本文件；需要背景再读 `docs/` 三份文档（分析报告 → 技术方案 → 开发计划）
- 复现验证：`flutter pub get && dart format --set-exit-if-changed . && flutter analyze && flutter test`（53 全绿）
- 本机 Flutter SDK：`/Users/yangxuehui/Documents/dev/ohos/flutter_flutter/bin/flutter`（3.41.10-ohos）；CI 用主线 stable
