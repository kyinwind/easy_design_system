# 会话状态存档

> 最后更新：2026-09-21
> 仓库：`/Users/yangxuehui/Documents/dev_open_source/easy_design_system`
> 源包（Swift）：`/Users/yangxuehui/Documents/dev_open_source/EasyDesignSystem`
> 仓库地址：https://github.com/kyinwind/easy_design_system

## 用户偏好（新会话必须遵守）

- **开发计划/进度清单必须用可勾选格式（`- [ ]` / `- [x]`），完成一项立即打勾**，让用户随时可见进度。

## 总体进度：约 98%（v0.1.0 主体完成，README 完整版完成，待发布）

- [x] M0 工程脚手架（pubspec、analysis_options、LICENSE、CI workflow、fixtures、example）
- [x] M1 Token 系统 + 主题机制
  - [x] `eds_color_hex`（RGB/ARGB/RGBA 显式八位语义，对齐 Swift）
  - [x] `eds_design_tokens`（9 组子 token，JSON 编解码，缺失回退默认）
  - [x] `eds_color_scheme`（亮暗语义色解析）
  - [x] `eds_theme`（单例 + ValueNotifier + configure/JSON/preset/export）
  - [x] `eds_preset_theme`（default/blue 别名/orange/purple）
  - [x] `eds_theme_scope`（InheritedWidget，局部优先）
- [x] M2 Easy API + 自适应层
  - [x] `eds_easy_recipe`（六场景纯函数配方）
  - [x] `eds_easy` / `eds_easy_extension`（easyDesign / easyDesignPreset / easyDesignTokens）
  - [x] `eds_interaction_profile` / `eds_size_class` / `eds_resolved_metrics`
  - [x] `eds_font` / `eds_surface` 基础原语
- [x] M3 基础组件（button 三维+Role / badge / toggle / text 组 / rows 组 / card / group / hero_panel / page / page_section）
- [x] M4 扩展组件（states 组 / pills / collapsible_section / comparison_section / icon_mark / sidebar）
- [x] 测试：8 文件 53 用例全绿，逐条对齐 Swift `EasyDesignSystemTests`
- [x] README 完整版重写（对照 Mac 版 9 大节：设计理念/安装/使用向导/Easy API/主题/精细 API/示例/Catalog 规划/对照表/开发验证；全部 API 逐项核对源码）
- [x] README 示例固化测试 `test/eds_readme_examples_test.dart`（8 用例，防文档漂移；测试总数 61）
- [x] 修复：sidebar 选中态颜色 `colors.accent` → `colors.primary`（对齐"primary 唯一主题色"契约）
- [x] 修复：README 中 `EdsTheme.instance.colors` → `EdsTheme.instance.tokens.colors`（无便捷 getter）
- [x] 修复：磁盘 `docs/` 目录与 HEAD `doc/` 不一致（IDE 移回所致），已恢复
- [x] CHANGELOG 0.1.0、example 演示 App
- [x] git 仓库初始化、tag v0.1.0、`pubspec.lock` 不入库
- [x] pubspec 补 `repository` / `issue_tracker` 字段
- [x] `docs` 目录改名 `doc`（pub 布局规范）
- [ ] **发布 pub.dev**（`flutter pub publish`，dry-run 0 警告，需用户确认执行）
- [ ] **设置 git remote 并 push**（含 tag v0.1.0，需用户提供权限/确认）
- [ ] （可选）Catalog example 升级：组件 Gallery + Token 编辑器 + Easy API 演示页（README §7 已列为规划）
- [ ] （可选）本地化钩子：组件内中文文案参数化
- [ ] （可选）`EdsSettingRow.trailing` 通用无界宽度适配器、Sliver 版 Section

## 本轮修复的关键问题（易复发，备忘）

- **包资产 key 环境差异**：`lib/assets/...` 在真实 App 中 key 为 `packages/easy_design_system/assets/...`（剥 `lib/`），但包自身 `flutter test` 环境是 `packages/easy_design_system/lib/assets/...`。`applyDefaultThemeFromPackage` 用 4 个候选路径依次尝试。
- **`flutter test` 里 `rootBundle` 需 Binding**：纯 `test()`（非 `testWidgets`）文件必须 `TestWidgetsFlutterBinding.ensureInitialized()` 才能 `rootBundle.loadString`。
- **EdsToggle 无界宽度槽位崩溃**：Row 给非 flex 子项无界宽度，内含 `Spacer`（tight flex）的 widget 放进 `EdsSettingRow.trailing` 会炸。EdsToggle 已用 `LayoutBuilder` 按约束切展开/紧凑布局。其他含 flex 的 widget 若要进 trailing 槽位需同样处理。
- **扩展方法重名二义性**：`easyDesignTheme` 曾同时存在于 EdsEasyWidgetX（style+theme）与 EdsThemeWidgetX（scope-only），analyzer 报 ambiguous。已改名：`easyDesignPreset(preset, {style, options})` + `easyDesignTheme(tokens)` / `easyDesignThemePreset(preset)`。
- `ListView` 构造非 const；`const MaterialApp` 里包 ListView 会 `const_with_non_const`，改用 `children: const [...]`（`const Scaffold` 罩住 ListView 同样会炸）。
- `EdsTheme.instance` 只有 `.tokens` getter，无 `.colors`/`.spacing` 便捷转发；`metrics.pagePadding` 是 double，字符串插值会出 `36.0`。
- `Object.hash` 单值用 `runtimeType.hashCode`；私有命名参数不合法；三元分支类型提升 `!` 精确化；只经 `context.edsTokens` 使用 token 类型时不要 import token 文件（unused_import）。

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

- 先读本文件；需要背景再读 `doc/` 三份文档（分析报告 → 技术方案 → 开发计划）
- 复现验证：`flutter pub get && dart format --set-exit-if-changed . && flutter analyze && flutter test`（61 全绿）
- 本机 Flutter SDK：`/Users/yangxuehui/Documents/dev/ohos/flutter_flutter/bin/flutter`（3.41.10-ohos）；CI 用主线 stable
- 发布：`flutter pub publish`（dry-run 已验证通过）
