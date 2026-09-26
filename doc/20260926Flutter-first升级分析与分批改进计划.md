# easy_design_system Flutter-first 升级分析与分批改进计划

> 日期：2026-09-26  
> 目标仓库：`kyinwind/easy_design_system`  
> 当前 Flutter 包版本：`0.2.0`  
> 参考来源：
> - `doc/20260926给easy_design_system作者的改进建议.md`
> - 当前 main 分支源码、README
> - RightClickMate 在 Windows 桌面端接入 easy_design_system 的实际反馈
>
> 说明：README / 源码中出现的 `0.4.0 / 0.4.1` 是 **Swift EasyDesignSystem 的版本语义与迁移注释**，不是 Flutter 包版本号。Flutter 包当前版本仍以 `pubspec.yaml` 为准。

---

## 一、这次升级的目标是什么

这次不把目标定义为“修 RightClickMate 提出的 22 条问题”，而定义为：

> **让 easy_design_system 从“Swift EasyDesignSystem 的 Flutter 移植版”，逐步成长为一个 Flutter-first、跨平台、可长期复用的应用级设计系统。**

Swift 版仍然是重要的设计来源，尤其是 Token 体系、视觉语言、组件语义、Easy API 思路，以及 Swift / Flutter 两端的一致性。

但 Flutter 版不能为了“逐项复刻 Swift”而忽略 Flutter 本身的运行模型。典型例子包括：

- SwiftUI 原生 Button 自动获得 Focus、键盘、Semantics，而 Flutter 自定义 `GestureDetector` 不会；
- SwiftUI Environment 与 Flutter `InheritedWidget / BuildContext` 的语义不同；
- Flutter 宿主通常同时存在 Material Theme / ThemeMode；
- Windows / macOS 桌面端更依赖 Hover、Focus、Tooltip、Keyboard；
- Flutter App 很常见的是多语言、不同平台字体、Material 控件混用。

所以今后的原则应该是：

> **视觉与语义尽量延续 Swift EasyDesignSystem；实现方式优先遵循 Flutter 的平台习惯。**

这就是本文所说的 **Flutter-first**。

---

# 二、包的长期定位

easy_design_system 的目标不应该只是 Token 包。

更适合的定位是：

> **一个提供 Design Token + Theme + Adaptive Layout + 常用 UI Components + Easy API 的 Flutter 应用 UI 基础设施。**

希望宿主 App 能做到：

```dart
EdsButton(
  '保存',
  icon: Icons.save,
  action: save,
)
```

或者：

```dart
Column(
  children: [
    ...
  ],
).easyDesign(style: EdsEasyStyle.page)
```

就能获得一致的颜色、字体、间距、控件尺寸、深浅色、Hover / Focus / Disabled、桌面 / 移动适配、无障碍语义和视觉层级。

因此，本包未来应坚持两层 API。

## 1. Easy API

服务 80% 常见场景。

特点：

- 参数少；
- 默认值优秀；
- 一行即可使用；
- 调用方无需理解全部 Token；
- 适合快速搭建简单、好看的页面。

## 2. Fine-grained API

服务复杂页面和特殊场景。

特点：

- Token 可直接读取；
- Appearance / Tone / Size 等可组合；
- 可局部覆盖 Theme；
- 高级组件可自定义；
- 不限制宿主业务设计。

不能为了增强 Fine-grained API，把最常用 API 变复杂。

---

# 三、对原改进建议的总体判断

原建议整体质量较高，且大量问题能够从源码中直接验证。

但建议的出发点偏向：

> “RightClickMate 能不能快速、大规模替换 Material 控件。”

而 easy_design_system 的目标应比单个宿主项目更高。

因此本文将建议分为四类：

- **直接采纳**：属于设计系统自身缺陷或基础能力缺失；
- **调整后采纳**：问题成立，但原建议的具体 API 不一定适合 EDS；
- **分阶段采纳**：方向成立，但不适合本轮一次做完；
- **暂缓**：收益低、没有真实性能证据，或当前没有必要制造 breaking change。

---

# 四、22 条建议的决策表

| # | 建议 | 决策 | 原因 |
|---|---|---|---|
| 1 | EdsButton Focus + Semantics | **直接采纳** | Flutter 桌面端基础能力，不属于业务特例 |
| 2 | Tooltip | **直接采纳** | 图标类/桌面控件必需能力，但 tooltip 保持可选 |
| 3 | ThemeMode 联动 | **调整后采纳** | 应建立明确 Brightness 解析优先级 |
| 4 | Sidebar Scope 泄漏 | **直接采纳** | 当前实现破坏局部 ThemeScope 语义 |
| 5 | 硬编码中文 | **调整后采纳** | 先允许调用方注入文案，不急着引入完整 l10n delegate |
| 6 | fontFamily token | **直接采纳** | 字体属于设计 Token 一等能力 |
| 7 | Button API 收敛 | **调整后采纳** | 保留 Easy String API，不接受“所有 label 都改 Widget” |
| 8 | Button expanded | **直接采纳** | 常见布局能力，应显式支持 |
| 9 | busy / selected | **分阶段采纳** | Button busy 本批做；selected 属于 Pill / Segmented 后续 |
| 10 | 表单控件族 | **分阶段采纳** | 方向正确，但需按组件批次建立 |
| 11 | systemImage → icon | **采纳并兼容** | Flutter 语义更准确；旧名 Deprecated |
| 12 | dimension 改名 | **采纳并兼容** | 名称不直观，建议新 API + Deprecated |
| 13 | 所有位置参数改命名参数 | **暂缓** | 大量 breaking change，实际收益有限 |
| 14 | EdsGroup.plain | **低优先级采纳** | 提升可读性，但不是核心 |
| 15 | EdsSection 改名/不导出 | **暂缓** | 需要先观察实际误用情况 |
| 16 | Collapsible 可控状态 | **采纳** | 属于通用组件应有能力 |
| 17 | PillFlow 泛型 | **采纳** | 字符串回查不够健壮 |
| 18 | Pill remove 隐藏时不占位 | **重新设计后采纳** | 要同时考虑视觉对齐、桌面 hover、touch |
| 19 | RGB darken | **采纳** | 色彩算法应更稳定 |
| 20 | hover 整体 opacity | **采纳** | 不应让文字随背景一起降低对比度 |
| 21 | metrics 每 build 重算 | **暂缓** | 没有性能数据，不提前复杂化 |
| 22 | Dialog / Toast | **拆分处理** | Dialog 属于 EDS；Toast service 更适合工具层 |

---

# 五、第一批：基础正确性与桌面可用性

这一批优先级最高。

目标：

> **先让现有组件“行为正确”，再扩充组件数量。**

## 5.1 EdsButton：补全 Focus / Keyboard / Semantics

当前 Button 的交互结构核心是：

```text
IgnorePointer
└─ MouseRegion
   └─ GestureDetector
```

这套结构可以处理鼠标，但不会自动进入 Flutter Focus Tree。

需要补充：

- `FocusNode?`
- `autofocus`
- Tab Focus
- Enter 激活
- Space 激活
- Focus visual
- `Semantics(button: true)`
- enabled / disabled semantics

建议内部基于：

```dart
FocusableActionDetector
```

而不是让每个宿主 App 自己包一层。

### Focus 视觉

不要简单使用 Material 大面积 `focusColor`。

建议使用 EDS 自己的 Focus Ring：

- 圆角继承按钮圆角；
- 颜色来自 `tokens.colors.primary`；
- 约 1.5pt；
- 尽量不改变按钮自身布局尺寸。

以后 Dropdown / Checkbox / Segmented 也应该共用相同 Focus 规范。

---

## 5.2 Tooltip

组件层提供：

```dart
String? tooltip
```

但不强制每个控件必须有 tooltip。

建议规范：

- icon-only control：强烈建议；
- 文字按钮：通常无需；
- Sidebar / Pill：视业务语义而定；
- tooltip 文案始终由宿主提供。

避免设计系统硬编码业务文案。

---

## 5.3 ThemeMode / Brightness 解析

当前：

```dart
MediaQuery.maybePlatformBrightnessOf(context)
```

只能表达操作系统亮暗状态，不能完整表达宿主主动覆盖的 `ThemeMode.dark / ThemeMode.light`。

建议明确 EDS Brightness 解析优先级：

```text
1. EdsThemeScope.brightness 显式覆盖
2. Flutter 宿主 Theme.of(context).brightness
3. MediaQuery platformBrightness
4. Brightness.light
```

意义：

- EDS 可以自然融入 Flutter App；
- 宿主已有 `ThemeMode.system/light/dark` 时不需要维护第二份设置；
- 局部 `EdsThemeScope(brightness: ...)` 仍拥有最高优先级。

实现时要注意：没有 Material ancestor 的纯 Widgets 环境仍应有安全 fallback，并补测试。

---

## 5.4 Sidebar ThemeScope 泄漏

当前类似：

```dart
EdsSidebarIconPresetTint.blue.color
```

内部读取：

```dart
EdsTheme.instance.colors.primary
```

因此局部：

```dart
EdsThemeScope(
  tokens: customTokens,
  child: ...
)
```

不能影响 Sidebar preset tint。

这是明确的 Theme Scope 语义错误。

### 新设计建议

增加：

```dart
Color resolve(BuildContext context)
```

由 `context.edsTokens` 解析。

更进一步，`EdsSidebarMenuItem` 最好能够持有 preset：

```dart
EdsSidebarIconPresetTint.blue
```

而不是在创建 model 时过早计算成 `Color`。

这样 runtime Theme 改变时也会跟随。

### 兼容

旧：

```dart
EdsSidebarIconPresetTint.blue.color
```

可以暂时保留并标 `@Deprecated`，说明它只读取 global theme。

---

## 5.5 去除不可覆盖的中文业务文案

本轮重点不是建立完整国际化系统，而是：

> **设计系统不阻止宿主 App 国际化。**

优先修改真正有阻断性的硬编码。

### EdsComparisonSection

从内部常量：

```dart
'功能对比'
'功能'
'Free'
'Pro'
```

改成可传：

```dart
EdsComparisonSection(
  title: ...,
  featureLabel: ...,
  freeLabel: ...,
  proLabel: ...,
)
```

可以保留当前中文作为兼容默认值。

### EdsPill remove Semantics

不能继续固定：

```dart
'删除 xxx'
'从列表中移除'
```

建议允许注入：

```dart
removeSemanticLabel
removeSemanticHint
```

或：

```dart
removeSemanticLabelBuilder
```

### EdsLoadingState

已有 `title` 可传，因此不是 API 阻断。

后续可以重新评估默认值是否应该改成中性英文、空值或字符串配置。

### 暂不做完整 EdsLocalizations

只有当未来内建文案明显增加、多个组件都需要系统生成语义文案、至少 zh/en 需要统一维护时，再引入：

```text
EdsLocalizations + ARB + delegate
```

否则当前成本偏高。

---

## 5.6 Typography 增加 FontFamily Token

建议加入：

```dart
String? fontFamily
List<String>? fontFamilyFallback
```

还应考虑 Mono 独立配置：

```dart
String? monoFontFamily
List<String>? monoFontFamilyFallback
```

理由：

- Windows App 常使用 Segoe UI / Microsoft YaHei；
- macOS 常使用系统字体 / PingFang；
- 宿主可能允许用户切换 UI 字体；
- Typography 如果不能定义字体家族，就不是完整 Typography Token。

`edsTextStyle()` 应统一从 token 构造，不依赖不稳定的 ambient inheritance。

同时：

- `copyWith`
- JSON schema
- 默认 theme JSON
- README
- tests

都要同步。

如果为了保持与 Swift JSON schema 兼容，需要明确：

> Flutter 专属字段可以是可选扩展字段；旧 Swift-compatible JSON 缺失时使用默认值。

不必为了字节级 schema 一致，放弃 Flutter 必需能力。

---

# 六、第二批：重构 EdsButton Easy API

Button 是整个设计系统最值得打磨的组件。

本轮原则：

> **增强表达能力，但绝不能牺牲最简单的调用方式。**

## 6.1 保留 Easy 用法

推荐继续支持：

```dart
EdsButton(
  '保存',
  action: save,
)
```

不建议改成：

```dart
EdsButton(
  label: Text('保存'),
)
```

作为默认入口。

Widget label 应该属于高级入口，而不是迫使所有调用者写更多模板代码。

---

## 6.2 推荐的新主 API

目标形态：

```dart
EdsButton(
  '保存',
  icon: Icons.save,
  role: EdsButtonRole.primary,
  tooltip: '保存当前设置',
  isBusy: saving,
  expands: false,
  focusNode: focusNode,
  autofocus: false,
  action: save,
)
```

建议逐步支持：

- `icon`
- `tooltip`
- `isBusy`
- `expands`
- `focusNode`
- `autofocus`
- Semantics override（必要时）

---

## 6.3 isBusy

Busy 不等于 Disabled。

```text
disabled = 现在不能操作
busy     = 已经接受操作，正在处理
```

建议：

- Busy 时自动阻止重复点击；
- 显示 Spinner；
- 尽量保持原按钮宽度，避免 UI 抖动；
- Semantics 可以表达 processing/busy；
- title 是否隐藏或保留由视觉方案决定。

---

## 6.4 expands

支持：

```dart
EdsButton(
  '继续',
  expands: true,
)
```

默认仍保持当前内容宽度，避免 breaking layout。

这比模仿 Material 所有布局行为更清楚：

> EDS 的宽度是显式语义，而不是隐式猜父布局。

---

## 6.5 systemImage → icon

Flutter 中 `IconData` 不应长期叫 `systemImage`。

建议新增 `icon`，旧 `systemImage` 保留 Deprecated 迁移入口，不一次删除。

---

## 6.6 dimension → styled（暂定命名）

`dimension` 在 Swift 设计背景下可以理解，但 Flutter 使用者不直观。

建议候选：

```text
EdsButton.styled
EdsButton.custom
EdsButton.appearance
```

当前倾向：

```dart
EdsButton.styled(
  '忽略并删除',
  emphasis: EdsButtonEmphasis.soft,
  tone: EdsButtonTone.danger,
  size: EdsButtonSize.regular,
  action: remove,
)
```

旧 `.dimension` 保留 Deprecated。

最终命名在真正实现前再做一次 API review。

---

## 6.7 自定义 label

建议提供高级入口：

```dart
EdsButton.custom(
  label: Widget,
  ...
)
```

其目标是：

- loading 特殊展示；
- 富文本；
- 复杂组合；
- 未来特殊业务按钮。

但普通 icon + title 不需要调用方自己拼 Row，因为间距、IconTheme、字体颜色等应该由设计系统负责。

---

# 七、第三批：常用设置页控件

这一批开始扩充组件能力。

优先依据不是“Material 有什么就复制什么”，而是：

> **哪些组件在我们自己的 Flutter App 中重复出现最多，而且决定了页面能否完整采用 EDS。**

推荐第一组：

1. `EdsCheckbox`
2. `EdsDropdown<T>`
3. `EdsSegmented<T>`

理由：

- 设置页高频；
- RightClickMate 已经出现真实需求；
- VideoHero / ppt_to_video 等未来也会大量使用；
- 这三者能显著减少 EDS + Material 混搭。

## 7.1 EdsSegmented<T>

同时解决原建议中的 selected 状态问题。

目标 API：

```dart
EdsSegmented<MyType>(
  value: value,
  values: MyType.values,
  labelBuilder: (value) => ...,
  onChanged: ...,
)
```

需要天然支持：

- selected；
- Focus；
- Keyboard；
- Tooltip；
- disabled；
- Semantics；
- Pointer / Touch adaptive metrics。

不要只做一个视觉 Row。

## 7.2 EdsDropdown<T>

应以泛型 value 为核心，而不是字符串。

```dart
EdsDropdown<Locale>(
  value: locale,
  items: locales,
  labelBuilder: ...,
  onChanged: ...,
)
```

## 7.3 EdsCheckbox

同样建立一套共享交互语言：

- selected / checked；
- hover；
- pressed；
- focused；
- disabled；
- keyboard；
- semantics。

这将验证第一批建立的交互规范是否真正可复用。

---

# 八、第四批：已有组件的泛化与打磨

## 8.1 EdsCollapsibleSection

增加：

```dart
initiallyExpanded
onExpansionChanged
```

进一步可考虑受控：

```dart
isExpanded
```

但要明确 controlled / uncontrolled 模型，避免 API 模糊。

## 8.2 EdsPillFlow<T>

当前 `List<String>` 对真实数据模型限制明显。

建议泛型化：

```dart
EdsPillFlow<T>(
  items,
  labelBuilder: ...,
  onTap: ...,
  onRemove: ...,
)
```

字符串场景仍应保持 Easy。

## 8.3 EdsPill selected

不要单纯给现有 Tag 组件加一个 bool 然后结束。

需要先区分：

```text
Tag / Label
Filter Chip
Choice / Segment
Action Pill
```

如果不同交互语义开始明显分化，应考虑 `EdsPill` 与 `EdsChoicePill` 分开，而不是一个组件塞所有状态。

## 8.4 Remove 按钮布局

原建议希望隐藏时完全不占空间，这不能直接照改。

需要分别考虑：

- Windows Pointer：hover 后 remove 出现会不会导致内容宽度跳动；
- Touch：没有 hover，remove 是否常驻；
- Pill flow：每个 item 宽度变化是否造成重排；
- 无障碍：remove control 是否可 Focus。

因此这条应通过组件交互设计解决，而不是简单删掉占位。

## 8.5 Button 色彩算法

### darken

当前 RGB channel 乘法应替换。

候选：

```dart
Color.lerp(color, Colors.black, amount)
```

或者 HSL lightness。

优先选择可预测、简洁、测试方便、且不破坏已有视觉过多的方案。

### Hover

不建议继续对整个 Button：

```dart
AnimatedOpacity(opacity: 0.85)
```

因为会一起降低 Text、Icon、Background。

建议只变化 surface：背景 overlay、tonal adjustment 或 border adjustment；文字和图标保持正常对比度。

---

# 九、第五批：后续组件扩展

在前三批稳定之后，再考虑：

```text
EdsTextField
EdsRadio
EdsSlider
EdsDialog
EdsMenu
Popover
```

## Dialog

属于设计系统合理职责。

可以建立：

```text
EdsAlertDialog
EdsConfirmDialog
EdsDangerConfirmDialog
```

重点统一：

- padding；
- typography；
- button ordering；
- danger 语义；
- desktop keyboard Escape / Enter；
- mobile adaptation。

## Toast

建议区分两层。

### EDS 可以负责

```text
Toast visual widget
颜色
字体
图标
间距
动画规范
```

### 不一定属于 EDS

```text
ToastService
全局 Overlay 管理
队列
历史
生命周期
调用 API
```

后者更适合 `my_flutter_app_tools`。

长期建议两个包职责：

```text
easy_design_system
    └─ 视觉 / Theme / Token / UI Component / Adaptive Interaction

my_flutter_app_tools
    └─ License / Toast service / App utilities / 通用功能能力
```

二者可以组合，但避免把所有 App service 都放进设计系统。

---

# 十、暂缓的建议

## 10.1 全量改命名参数

例如：

```dart
EdsBadge('Pro')
```

改：

```dart
EdsBadge(text: 'Pro')
```

从纯 API 风格看，命名参数更统一。

但目前：

- 会制造大量宿主迁移；
- 不改善实际能力；
- Flutter 本身大量组件也允许位置参数；
- EDS 的 Easy 特性反而可能受损。

因此暂缓。

只有未来重新设计某个组件 API 时，顺带判断是否值得改。

## 10.2 EdsSection 重命名

当前“它是否产生视觉 chrome”并不是判断 Section 名称是否合理的唯一依据。

Section 也可以表达语义分区、spacing、hierarchy、accessibility grouping。

除非真实宿主项目持续误用，否则暂时保留。

## 10.3 ResolvedMetrics 缓存

`EdsResolvedMetrics.resolve()` 当前只是一些简单 token/profile 计算。

没有 profile 数据证明它是性能热点之前，不为了“可能优化”增加新 InheritedWidget、新缓存生命周期和更复杂的 Scope。

原则：

> 先测量，再优化。

---

# 十一、兼容策略

当前包仍处于早期阶段，且主要宿主项目由同一开发者维护。

因此兼容策略应该偏向：

> **保护合理的调用方式，不保护明显不合理的 API 设计。**

## A. 低成本兼容：应兼容

例如：

```text
systemImage → icon
dimension → styled
preset.color → preset.resolve(context)
```

通过 `@Deprecated` 保留一个迁移周期，README 给迁移示例。

## B. 新参数增强：天然兼容

例如：

```text
tooltip
isBusy
expands
focusNode
autofocus
fontFamily
```

默认行为保持现状即可。

这类最优先。

## C. 为兼容会破坏新 API：不强求

如果旧设计导致：

- Scope 语义错误；
- 无法正确国际化；
- 无障碍错误；
- 新 API 被迫长期扭曲；

可以直接 breaking。

因为当前使用者基本是自有项目，可以统一升级。

## D. 1.0 之前是整理 API 的窗口

在 `1.0.0` 前：

- 可以 Deprecated；
- 可以收敛构造器；
- 可以调整命名；
- 可以清理 Swift 移植遗留。

到 1.0 后，再提高兼容标准。

---

# 十二、建议的开发批次

## Batch A — 基础正确性

目标：现有组件可放心用于 Flutter 桌面 App。

实现状态（2026-09-26）：

- [x] EdsButton Focus / Enter / Space / Semantics / Tooltip / Focus ring
- [x] ThemeMode brightness 与无 Material Theme 的平台亮暗回退
- [x] Sidebar Scope fix
- [x] Comparison 文案可覆盖
- [x] Pill remove semantics 可覆盖
- [x] Typography fontFamily / fallback
- [x] Button hover 对比度修复
- [x] 自动化测试覆盖

## Batch B — Button API 2

目标：让 EdsButton 成为真正的主力通用按钮。

实现状态：

- [x] `icon`
- [x] `isBusy`
- [x] `expands`
- [x] `focusNode`
- [x] `autofocus`
- [x] `EdsButton.custom`
- [x] `EdsButton.styled`
- [x] `systemImage` Deprecated compatibility
- [x] `dimension` Deprecated compatibility
- [x] busy / expanded / keyboard / legacy compatibility tests
- [x] Catalog / 示例迁移到新 API
- [x] busy 与 disabled 语义分离

## Batch C — Settings Controls

目标：设置类 App 的常见页面尽可能不再混用裸 Material visual controls。

实现状态：

- [x] `EdsCheckbox`
- [x] `EdsDropdown<T>`
- [x] `EdsSegmented<T>`
- [x] 泛型 value API
- [x] ThemeScope / Typography / Token styling
- [x] 复用 Flutter 原生 Focus / Keyboard / Semantics 行为
- [x] 对应 widget tests

## Batch D — Existing Components 2

实现状态：

- [x] EdsCollapsibleSection controlled / uncontrolled API
- [x] EdsPillFlow<T>
- [x] EdsChoicePill（与 Tag 型 EdsPill 分离）
- [x] Button darken 改为稳定的颜色插值
- [x] EdsGroup.plain 已存在，无需新增
- [x] 泛型 Pill / Collapsible tests
- [x] remove action 继续保留占位，避免 pointer hover 时 Pill 宽度跳变

## Batch E — Application UI Completeness

实现状态：

- [x] EdsTextField
- [x] EdsRadioGroup<T> / EdsRadio<T>（采用 Flutter 新 RadioGroup API）
- [x] EdsSlider
- [x] EdsAlertDialog
- [x] EdsConfirmDialog
- [x] EdsMenuButton<T>
- [ ] Popover：暂缓，等待真实宿主交互场景后再确定抽象

Toast service 不进入 EDS；如以后需要，可由 EDS 提供视觉 Widget，
全局 Overlay / 队列 / Service 更适合 `my_flutter_app_tools`。

### 发布状态（0.3.0）

截至 2026-09-27：

- [x] Batch A-E 计划内主体能力已实现
- [x] Catalog / README / CHANGELOG 已同步
- [x] `pubspec.yaml` 版本提升到 `0.3.0`
- [x] CI 恢复严格 format / analyze / test
- [ ] Git tag `0.3.0`（需在 Git 客户端执行）
- [ ] RightClickMate 集中批量迁移与 Windows 实机回归
- [ ] Popover：继续暂缓，等待真实宿主场景

### 0.3.1 宿主迁移补丁

RightClickMate 在正式批量迁移前进一步暴露了两个通用 Form 缺口，已作为 0.3.1 补齐：

- [x] EdsTextField 支持显式 errorText
- [x] 新增 EdsTextFormField，支持 validator / onSaved / autovalidateMode
- [x] 新增 EdsDropdownFormField<T>，覆盖 DropdownButtonFormField 场景
- [x] 新增 EdsButton.fullWidth Easy API
- [x] 保持 EdsButton.expands 默认 false，避免 Row / Dialog / Toolbar 布局破坏
- [x] pubspec.yaml 提升至 0.3.1
- [ ] 0.3.1 最终严格 CI
- [ ] Git tag 0.3.1

### 当前验证策略

开发流程已根据实际迁移计划调整为：

```text
Batch A-E 包内能力完善
        ↓
Catalog / README / tests
        ↓
format + analyze + flutter test 全绿
        ↓
确定 Flutter 包版本并打 tag
        ↓
RightClickMate 批量替换原生组件
        ↓
Windows 宿主集中回归
        ↓
真实问题再回流 EDS
```

RightClickMate 不再作为每个 Batch 的阻塞验收点。这样可以避免宿主项目反复迁移，
等 EDS 的常用组件体系稳定后一次性替换，效率更高。

---

# 十三、每一批的验收原则

每增加一个交互组件，不只验“看起来好不好看”。

至少检查以下维度。

## Visual

- Light
- Dark
- custom primary color
- local ThemeScope
- text scaling

## Pointer

- hover
- press
- cursor
- tooltip

## Keyboard

- Tab
- Shift+Tab
- Enter
- Space
- Escape（适用时）
- Arrow navigation（适用时）

## Semantics

- role
- enabled
- selected / checked
- button / toggle
- label / hint

## Layout

- compact width
- regular width
- parent stretch
- long localized text
- loading state

## Platform

至少：

- Windows
- macOS
- Android / iOS 基础行为

鸿蒙后续按 Flutter/平台能力单独验证。

---

# 十四、对 Swift 移植关系的原则

easy_design_system 的来源仍然是 Swift EasyDesignSystem，这点不应该被抹掉。

未来建议把“对齐”分成三种。

## 1. 必须保持一致

- Token 名称和基本语义；
- Color role；
- Spacing scale；
- Typography role；
- Component semantic role；
- Easy API 的设计哲学；
- 视觉层级。

## 2. 可以平台化实现

- Focus；
- Keyboard；
- Hover；
- Tooltip；
- Semantics；
- ThemeMode；
- Adaptive interaction；
- Windows / macOS specific behavior。

## 3. Flutter 可以合理扩展

例如：

- fontFamily；
- Flutter-specific Focus controls；
- Material Theme integration；
- Widget label；
- platform adaptive form controls。

原则：

> **不是追求 Dart 源码像 Swift，而是追求两个平台给用户的设计体验一致。**

---

# 十五、最终路线

这次 RightClickMate 的反馈非常有价值，因为它证明：

> 设计系统是否合理，不能只看 Catalog，必须放进真正的宿主 App 才能暴露问题。

所以以后 easy_design_system 的开发流程可以固定为：

```text
Swift / Design idea
        ↓
Flutter EDS implementation
        ↓
Catalog
        ↓
真实宿主 App 接入
        ↓
发现 friction / missing capability
        ↓
判断是业务特殊需求还是设计系统共性需求
        ↓
合理能力回流 EDS
```

RightClickMate 是第一轮比较系统的“真实 App 反向验证”。

后续 VideoHero / ppt_to_video 等项目也可以继续承担这个作用。

最终希望形成：

```text
                 EasyDesignSystem Swift
                         │
                  Design Language
                         │
                         ▼
               easy_design_system Flutter
                 │                 │
              Easy API        Fine API / Token
                 │                 │
                 └────────┬────────┘
                          ▼
                多个 Flutter 宿主 App
                          │
                          ▼
                 实际使用反馈回流
```

---

# 十六、下一步

本文确认后，不直接同时做所有条目。

当前开发顺序调整为：

```text
EDS Batch A-E 集中完善
  ↓
包内自动化验证 + Catalog 验证
  ↓
版本发布 / tag
  ↓
RightClickMate 集中批量迁移
  ↓
Windows 实机回归
  ↓
宿主反馈回流下一轮 EDS
```

真实宿主验证仍然重要，但放到设计系统常用能力基本完整之后集中进行，
避免宿主在 API 尚未稳定时反复替换和返工。
