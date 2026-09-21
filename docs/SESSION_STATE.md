# 会话状态存档

> 最后更新：2026-09-21
> 仓库：`/Users/yangxuehui/Documents/dev_open_source/flutter_easy_design_system`
> 源包（Swift）：`/Users/yangxuehui/Documents/dev_open_source/EasyDesignSystem`

## 当前进度

**阶段：迁移文档已完成，等待用户评审；代码尚未开始编写。**

已完成：

1. 分析 Swift 包 EasyDesignSystem（0.3.x，17 个源文件约 4200 行）。
2. 写好三份文档（位于 `docs/`）：
   - `20260921Swift包分析报告.md` —— 源包架构、Token/EasyAPI/自适应/组件/测试全量分析，15 个迁移关注点
   - `20260921Flutter迁移技术方案.md` —— 包形态（纯 Dart package）、核心机制映射表、主题/颜色/图标/本地化决策、测试策略、API 差异报告
   - `20260921Flutter迁移开发计划.md` —— M0~M5 里程碑，约 10 个工作日，验收标准与风险

尚未开始：任何代码（目录下目前只有 `docs/`）。

## 下一步（新会话从这里继续）

1. 用户评审三份文档，确认或调整方案。
2. 开工前需拍板的问题（开发计划 §10，均有建议默认值）：
   - Q1 pub 包名 `easy_design_system`（目录名不变）
   - Q2 是否发布 pub.dev（建议暂不发布）
   - Q3 Golden 测试不纳入 CI
   - Q4 `EdsSection` Sliver 版 V1 不做
   - Q5 LICENSE 沿用 MIT
3. 用户确认后按开发计划执行：
   - **M0（0.5 天）**：`flutter create --template=package` 脚手架、analysis_options、CI（analyze+format+test）、复制 `EDSDefaultTheme.json` 与 3 份 Fixture JSON、example 骨架、README/CHANGELOG/LICENSE
   - **M1（1.5 天）**：Token 系统（9 组子 Token、hex 工具、EdsColorScheme 亮暗解析）+ 主题机制（EdsTheme 单例 + EdsThemeScope InheritedWidget + ValueNotifier 运行时刷新）+ 单测
   - **M2（1.5 天）**：Easy API（EdsEasyRecipe 纯函数六场景配方）+ 自适应层（InteractionProfile touch/pointer/hybrid、600 宽度断点、EdsResolvedMetrics）
   - **M3（2.5 天）**：基础组件（Button 三维/Role、Badge、Toggle、文本组、行组、Card/Group/HeroPanel、Page 骨架）→ tag v0.1.0
   - **M4（2 天）**：状态组件、Pill/PillFlow（用 Wrap）、折叠、对比表、侧边栏 → tag v0.2.0
   - **M5（2 天）**：Catalog example（组件 Gallery、Token 编辑器、Easy API Gallery）+ README 完整版 + 发布 dry-run

## 关键技术决策备忘（详见技术方案）

- 纯 Dart Flutter package，无 platform channel；无三方运行时依赖
- JSON 主题 schema 与 Swift 版逐字节兼容（key 用驼峰如 `heroSize`；缺失字段回退默认；导出 prettyPrinted + 排序 key）
- Swift `EDSTheme.shared` + Environment → Dart `EdsTheme.instance` + `EdsThemeScope`（InheritedWidget），局部优先全局回退；增强支持运行时全局切换
- `.easyDesign()` 修饰器 → `EdsEasy` Widget + `extension on Widget` 双入口
- SF Symbols → `IconData` 参数化（无默认图标，`.done` 默认 check 除外）
- `LocalizedStringKey` → `String`，本地化交给宿主 App
- 语义色亮暗：`EdsColorScheme.resolve(tokens, brightness)` 内置 light/dark 常量表（pageBackground light #F7F7F7 / dark #1E1E20，cardBackground light #FFFFFF / dark #2A2A2C 等）
- 尺寸断点 600 逻辑像素；textScaler ≥ 1.7 视为无障碍大字号（Row 切竖排）
- 13 个 Swift 单测一一对应移植；3 份 Fixture JSON 直接从 Swift 仓库复制
- 本机 Flutter SDK 为 OpenHarmony SIG fork 3.41.10-ohos；CI 用主线 stable，纯 Dart 天然覆盖 OHOS

## 新会话恢复指引

- 先读本文件，再读 `docs/` 下三份文档（按 分析报告 → 技术方案 → 开发计划 顺序）
- 若用户说"继续/开工"，直接从 M0 开始，按开发计划逐里程碑执行
- 每完成一个里程碑：更新本文件的"当前进度"，并在 CHANGELOG 记录
