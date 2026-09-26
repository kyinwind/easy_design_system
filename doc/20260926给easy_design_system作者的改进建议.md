# 给 easy_design_system 作者的改进建议

> 日期：2026-09-26
> 对象版本：`easy_design_system` **0.2.0**（pub cache 实际检出 tag `0.2.0`）
> 视角：把该包接入 `RightClickMate`（**Flutter Windows 桌面端**，中英双语、9 个视图、约 123 处按钮调用点）时的实战评估
> 依据：逐行读完 `lib/` 下 31 个源文件（约 4000 行）+ README + example + test

---

## 零、先说做得好的

提建议之前先给正面反馈，这些是真做得漂亮的地方，别在重构里弄丢了：

| 亮点 | 位置 | 说明 |
|---|---|---|
| `EdsButtonAppearance.resolve()` 刻意 public | `eds_button.dart:169` | 注释明说「Public so tests can verify visual rules without widget tests」——把视觉规则从 widget 里剥出来单测，非常正确的设计 |
| 无障碍动画一致的降级 | button / pill / collapsible | 全包一致使用 `MediaQuery.maybeDisableAnimationsOf`，不是想起来才加 |
| Badge 的「无颜色区分」强化 | `eds_badge.dart:57-65` | 用 `maybeAccessibleNavigationOf` 给 success/warning/danger 补图标，不依赖颜色单一通道——这是真懂无障碍的做法 |
| `EdsPill` 的 Semantics 完整度 | `eds_pills.dart:203,228` | 带 `label` + `hint` + `button: true`，是全包无障碍做最好的组件 |
| 工程完整度 | README 967 行 / example catalog / 9 个测试 / `doc/` 迁移文档 | 远超同类个人包的水位 |
| Swift 版的偏差全部写进注释 | 各文件头部 | 每个 widget 都标注「Deviation from Swift: …」，可追溯性极好 |

**下面的建议都建立在一个前提上：这个包是 Swift `EasyDesignSystem` 的 Flutter 移植，很多设计是为了「跟 Swift 对齐」。但 Flutter 的宿主生态（桌面端、Material、l10n）跟 SwiftUI 不一样，有些对齐在 Dart 里是负收益** —— 这正是我主要的吐槽方向。

---

## P0 — 阻断级：桌面端「不能用」，建议 0.3.0 修

### 1. `EdsButton` 既没有焦点、也没有 Semantics ⚠️ 最严重

**证据**

```
grep -rn "Focus|focusNode|autofocus|Shortcuts|Actions" lib/   → 全包 0 命中
grep -rn "Semantics" lib/                                      → 只有 eds_pills.dart:203/228、eds_badge.dart:87
```

`EdsButton` 的交互层是 `IgnorePointer → MouseRegion → GestureDetector`（`eds_button.dart:493-499`）。它：

- ❌ 不进 Focus 树 → **Tab 键永远走不到**
- ❌ 无焦点高亮 → 键盘用户看不到自己在哪
- ❌ **连 `Semantics(button: true)` 都没有** → 屏幕阅读器不认为是按钮

**矛盾点**：`EdsPill`（次要组件）有完整 Semantics，`EdsButton`（最该有的）没有。这是内部不一致，不像有意取舍。

**后果（实打实的）**：RightClickMate 是 Windows 桌面应用，用户会用 Tab 遍历。若按计划批量替换 105 处按钮，**等于把整个应用从「可键盘操作」降级为「只能鼠标点」**。我最终给出的接入方案是「按钮不急着换，或者自包一层 `RcmEdsButton` 补 Focus」—— 这本来不该是调用方操心的事。

**建议**

```dart
return Semantics(
  button: true,
  enabled: enabled,
  label: _title,                       // 纯图标按钮必填
  child: FocusableActionDetector(
    focusNode: widget.focusNode,
    autofocus: widget.autofocus,
    shortcuts: const <ShortcutActivator, Intent>{
      SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
      SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
    },
    actions: <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (_) => widget.action?.call(),
      ),
    },
    onShowFocusHighlight: (v) => setState(() => _isFocused = v),
    child: /* …现有 MouseRegion / GestureDetector 内容… */,
  ),
);
```

焦点视觉建议：`_isFocused` 时画一圈 `tokens.colors.primary` 的 1.5pt 外描边（`BorderRadius` 跟按钮一致），别用 Material 的 `focusColor` 那种大块变色。

---

### 2. 没有 `tooltip`

**证据**：`grep -rn "Tooltip" lib/` → **0 命中**。

**后果**：RightClickMate 有 **18 处 `IconButton`，其中至少 6 处依赖 `tooltip`**（如 `backup_settings.dart:349/354/359` 的打开/编辑/删除）。没有 tooltip 的图标按钮在桌面端是不合格的 —— 我因此把 IconButton 整类划进「不建议替换」。

**建议**：给所有可点组件加 `final String? tooltip;`，统一包一层：

```dart
Widget result = /* … */;
if (widget.tooltip != null) result = Tooltip(message: widget.tooltip!, child: result);
```

---

### 3. `EdsThemeScope` 不跟随 Material 的 `ThemeMode` —— 这是潜在 bug

**证据**：`eds_theme_scope.dart:97-103`

```dart
Brightness get edsBrightness {
  final scope = dependOnInheritedWidgetOfExactType<_EdsTokensScope>();
  if (scope?.brightness != null) return scope!.brightness!;
  return MediaQuery.maybePlatformBrightnessOf(this) ?? Brightness.light;   // ← 只看系统
}
```

**问题**：App 若设 `themeMode: ThemeMode.dark`（强制深色，不跟系统），或者用户手动切换主题模式，**Material 侧变深了，EDS 侧仍是亮的**。

RightClickMate 目前是 `ThemeMode.system` 所以侥幸躲过，但只要加一个「外观：浅色/深色/跟随系统」的设置项就立刻穿帮 —— 而设置类 App 几乎必然会有这个选项。

**建议**：解析优先级改为

```dart
scope.brightness
  ?? Theme.of(context).brightness      // ← 新增：Material 已解析过 ThemeMode
  ?? MediaQuery.maybePlatformBrightnessOf(this)
  ?? Brightness.light;
```

`Theme.of(context).brightness` 是唯一能同时覆盖「跟随系统 / 强制深 / 强制浅」三种模式的信号源。

---

### 4. `EdsSidebarIconPresetTint` 绕过 Scope 直接读全局单例 —— 作用域泄漏

**证据**：`eds_sidebar.dart:110-132`

```dart
enum EdsSidebarIconPresetTint {
  Color get color => switch (this) {
    EdsSidebarIconPresetTint.blue => EdsTheme.instance.colors.primary,   // ← 全局单例
    …
  };
}
```

**问题**：`EdsThemeScope` 的核心价值是「局部覆盖 token」。但侧边栏图标颜色直接读 `EdsTheme.instance`，**局部 scope 覆盖主色后，侧边栏图标不跟随**，仍用全局色。

这是明确的作用域语义破坏——调用方用了 `EdsThemeScope` 却发现有一类组件不听话，非常难排查。

同样的问题在 `EdsTheme` 的注释里其实埋了伏笔（"matching the Swift singleton read"），**但 SwiftUI 的 `@Environment` 有隐式注入，Dart 这边的 Scope 是显式的，语义不等价**。

**建议**：改成需要 context 的解析：

```dart
extension EdsSidebarIconPresetTintX on EdsSidebarIconPresetTint {
  Color resolve(BuildContext context) => switch (this) {
    EdsSidebarIconPresetTint.blue => context.edsTokens.colors.primary,
    EdsSidebarIconPresetTint.green => context.edsTokens.colors.success,
    …
  };
}
```

若必须保留无 context 的 getter（兼容），请至少在文档里标注「不响应局部 Scope」。

---

## P1 — 强烈建议：影响采用率

### 5. 硬编码中文字符串，对多语言 App 是阻断性的

**证据**（全部是 `const`，**调用方无法覆盖**）

| 位置 | 内容 |
|---|---|
| `eds_comparison_section.dart:14-17` | `'功能对比'` / `'功能'` / `'Free'` / `'Pro'` |
| `eds_pills.dart:229-231` | Semantics `'删除 ${title}'` / `'从列表中移除'` |
| `eds_states.dart:88` | `EdsLoadingState` 默认 `'正在处理'` |
| `eds_preset_theme.dart` | name `'默认蓝色'` / `'橙色'` / `'紫色'` |

**后果**：RightClickMate 走 `AppLocalizations` 中英双语。`EdsComparisonSection` 是本包跟项目契合度最高的组件（结构一模一样），但因为表头写死中文，**英文界面下会显示中文，我只能放弃不用、保留自研版本**。

更糟的是 Semantics 里的中文 —— 这是无障碍文案，英文用户的读屏软件会念中文。

**建议（分两步）**

短期（0.3.0，改动最小）：

```dart
const EdsComparisonSection({
  super.key,
  required this.features,
  this.title = '功能对比',
  this.featureLabel = '功能',
  this.freeLabel = 'Free',
  this.proLabel = 'Pro',
});
```

中期（0.4.0）：提供 `EdsLocalizations` delegate + 内置 zh/en arb，或暴露可写的 `EdsStrings` 静态对象。这是让包走出中文圈的前提。

---

### 6. `EdsTypographyTokens` 缺 `fontFamily` 令牌

**证据**：`eds_design_tokens.dart:258-301`，26 个字段全是 `xxxSize` + `xxxWeight`，**无 fontFamily**；`edsTextStyle()`（`eds_font.dart:51`）只写 `fontSize` + `fontWeight`。

**问题**：中文 App 普遍要指定字体（微软雅黑 / 苹方 / 思源黑体），这是刚需不是偏好。现在靠 ambient `DefaultTextStyle` 继承，而包内部 `DefaultTextStyle.merge` 与直接 `Text(style:)` **混用**，行为不保证一致。

RightClickMate 恰好有「界面字体」设置项（系统默认 / 微软雅黑 / 微软雅黑 UI / Segoe UI），这是我这次评估里唯一标注「**待实测**」的项 —— 换句话说，包没给出确定答案，只能靠试。

**建议**

```dart
const EdsTypographyTokens({
  this.fontFamily,                    // 新增
  this.fontFamilyFallback,            // 新增
  this.heroSize = 30,
  …
});

TextStyle edsTextStyle(EdsFontRole role) => TextStyle(
  fontFamily: fontFamily,
  fontFamilyFallback: fontFamilyFallback,
  fontSize: …,
  fontWeight: …,
);
```

`copyWith` 一并支持。

---

### 7. `EdsButton` 的三个入口互斥，「自定义 label + 图标」无法表达

**证据**

| 入口 | label | 图标 |
|---|---|---|
| `EdsButton(String title, {systemImage, role, action})` | String | ✅ |
| `EdsButton.label(Widget label, {role, action})` | Widget | ❌ **签名里没有** |
| `EdsButton.dimension(String title, {emphasis, tone, size, systemImage, action})` | String | ✅ |

**缺失的组合**：`Widget label` + `icon`。

**后果**：RightClickMate 有 6+ 处「按钮内塞小 `CircularProgressIndicator` 表示 busy」（`general_settings.dart:437`、`image_annotation_window.dart:754`、`batch_rename_window.dart:817`）。这个需求只能走 `.label` 自己拼 Row，**且拼出来的图标颜色/间距跟内建的不一致**（内建用 `tokens.spacing.xxs` + `IconTheme.merge`，外部不知道）。

**建议**：收敛为单一构造函数 + 便捷工厂

```dart
EdsButton({
  super.key,
  required Widget label,          // 统一为 Widget
  IconData? icon,                 // 统一命名
  EdsButtonAppearance? appearance,
  EdsButtonRole? role,
  VoidCallback? action,
  String? tooltip,
  FocusNode? focusNode,
  bool isBusy = false,
});

EdsButton.text(String title, {IconData? icon, …});   // 便捷
```

`systemImage` / `.dimension` 保留为 `@Deprecated` 别名，给一个版本的迁移期。

---

### 8. 宽度行为与 Material 不一致（迁移时布局全变）

**证据**：`eds_button.dart:465-474`

```dart
ConstrainedBox(
  constraints: BoxConstraints(minHeight: …),
  child: Align(alignment: Alignment.center, widthFactor: 1.0, child: current),
)
```

`widthFactor: 1.0` 让按钮**收缩到内容宽度**，不响应父级拉伸。而 Material 的 Button 在 `Column(crossAxisAlignment: stretch)` / `Expanded` / `SizedBox.expand` 下会撑满。

**后果**：RightClickMate 的 `batch_rename_window.dart:1055-1095` 是一列 `CrossAxisAlignment.stretch` 的按钮，直接换会让按钮缩成文字宽度，视觉突变。这是最容易踩、也最容易被误判为「bug」的坑。

**建议**：

- 加 `final bool expands;` 参数（或 `double? width`），true 时内部用 `SizedBox(width: double.infinity)`；
- 至少提供 `EdsButton.expanded(...)` 工厂；
- **务必**在 README 的「与 Material 对照」章节（第 8 节）显式写出这个差异 —— 现在这一节只对照了 Swift 版，没有对照 Material，而 Material 才是 Flutter 调用方的实际迁移来源。

---

### 9. 缺桌面端高频状态：`isBusy` 与 `isSelected`

- **loading**：6+ 处需要「按钮内转圈」，EDS 只有 `action == null` 的禁用态，语义不够（禁用态视觉上看起来是「不可点」，而 busy 是「正在处理」）。
- **selected**：`resize_image_window.dart:455` 用 `ChoiceChip` 做尺寸预设选择、`image_annotation_window` 工具栏需要「当前工具」高亮态；EDS 的 `EdsPill` 无 selected 态，也没有 Segmented 控件。

**建议**：`EdsButton(isBusy:)`（自动把 label 换成 spinner 并保持宽度）+ `EdsPill(isSelected:)` + `EdsSegmented<T>`。

---

### 10. 缺表单控件族，设置类 App 卡在这里

EDS 目前**没有** Dropdown / Segmented / TextField / Slider / Checkbox / Radio。

RightClickMate 的 `general_settings.dart` 恰好有两个：语言选择用 `SegmentedButton`、字体选择用 `DropdownButton` —— 这两个无法迁移，只能继续用 Material，导致**同一页里 EDS 和 Material 混着来**。而「设置页」正是这个包的主战场。

**建议**：优先补 `EdsDropdown<T>` + `EdsSegmented<T>` + `EdsCheckbox`，这是设置场景的最小可用集。

---

## P2 — 打磨项（不影响采用，但影响手感）

| # | 问题 | 证据 | 建议 |
|---|---|---|---|
| 11 | `systemImage` 命名是 Swift 遗留 | button / states / progress_panel | Flutter 里 `systemImage` 指 SF Symbol，这里却传 Material `IconData`，误导。改 `icon`，旧名留 `@Deprecated` |
| 12 | `EdsButton.dimension` 名字难懂 | `eds_button.dart:340` | Swift 里指「三维度」，Dart 开发者猜不到。改 `.custom` / `.styled` |
| 13 | 位置参数 / 命名参数混用 | `EdsGroup(this.title,…)`、`EdsBadge(this.text,…)` 用位置；`EdsCard({…})`、`EdsToggle({…})` 用命名 | 统一命名参数（Flutter 惯例），可读性更好 |
| 14 | `EdsGroup(null, child: …)` 写法怪 | `eds_states.dart:196`（EdsProgressPanel 内） | 提供 `EdsGroup.plain(child:)` |
| 15 | `EdsSection` 在 Dart 里是噪音 | `eds_section.dart:3-9` 自己注释承认「没有 chrome」 | 名为 Section 却不产生视觉分组，开发者会误用。建议改名 `EdsLabeledBlock` 或不导出 |
| 16 | `EdsCollapsibleSection` 状态不可控 | `eds_collapsible_section.dart:25` `_isExpanded` 纯内部，默认 false | 加 `initiallyExpanded` + `onExpansionChanged` |
| 17 | `EdsPillFlow` 只吃 `List<String>` | `eds_pills.dart:294-305` 回调是 `ValueChanged<String>` | 泛型化 `EdsPillFlow<T>(items:, label: (T)=>String, onTap: (T))`，避免靠字符串回查 |
| 18 | `EdsPill` 的 remove 按钮恒占位 | `eds_pills.dart:243-247` | 即使隐藏也占最小交互尺寸（注释说为对齐 Swift）；touch profile 下每个 pill 都变宽。建议 false 时完全不占位 |
| 19 | `_darkened` 用 RGB 通道相乘 | `eds_button.dart:259` `color.r * 0.7` | 不同色相表现不一致（黄乘 0.7 仍亮，深蓝乘 0.7 近黑）。改用 `HSLColor` 降 lightness 或 `Color.lerp(c, black, 0.3)` |
| 20 | hover 用整体 opacity 0.85 | `eds_button.dart:448` | filled 按钮的白字一起变淡，**文字对比度下降**（无障碍问题）。改成背景叠 overlay，文字不动 |
| 21 | `EdsResolvedMetrics.resolve` 每次 build 重算 | button / setting_row / value_row / pill / sidebar_item 均如此 | 单次不贵，但列表滚动时成百上千次。用 InheritedWidget 在 scope 层算一次（跟 `_EdsTokensScope` 同一手法） |
| 22 | 缺 Dialog / Toast 族 | — | 设计系统标配。RightClickMate 有自建 `AppDialogService`（6 处按钮）和 `AppToast`，EDS 无对应，只能继续自研。建议补 `EdsAlertDialog` / `EdsConfirmDialog`（含 danger 确认） |

---

## 优先级汇总

| 优先级 | 条目 | 一句话 |
|---|---|---|
| **P0** | 1 焦点+Semantics、2 tooltip、3 ThemeMode 跟随、4 Scope 泄漏 | 这 4 条决定「桌面端能不能用」 |
| **P1** | 5 硬编码中文、6 fontFamily、7 按钮 API 收敛、8 宽度行为、9 busy/selected、10 表单控件 | 这 6 条决定「有多少项目愿意用」 |
| **P2** | 11-22 | 手感与一致性 |

---

## 一句话总结

**这个包的工程质量远超同类个人包，主要短板不在「写得不好」，而在「太忠于 Swift 原版」—— 焦点/tooltip/ThemeMode 联动这些 SwiftUI 由系统免费提供、Flutter 必须自己实现的能力被一并移植成了空白。补上 P0 那 4 条，它就能真正撑起桌面端生产项目。**
