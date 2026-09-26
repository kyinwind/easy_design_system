# easy_design_system 0.3.0 → RightClickMate 组件替换交接说明

## 一、背景

`easy_design_system` 是 Swift `EasyDesignSystem` 的 Flutter/Dart 移植版。

它的目标不是单纯提供 Design Token，而是成为：

> Flutter 应用统一视觉、主题、交互和常用组件的基础设计系统，同时保持 Easy API，尽可能让宿主 App 用少量代码搭出统一、简洁、好看的页面。

这次升级的直接起因，就是 RightClickMate 在实际开发中对 `easy_design_system` 提出了一批改进建议。

这些建议已经被系统分析，并按照：

- 设计系统通用性
- Flutter 平台习惯
- Windows 桌面体验
- API 易用性
- 旧项目兼容性
- 长期可维护性

进行了筛选和实施。

目前已经完成一轮较大的 Flutter-first 改造，并正式发布：

```text
easy_design_system 0.3.0
```

Git tag：

```text
0.3.0
```

RightClickMate 现在应锁定这个版本进行组件替换。

---

# 二、RightClickMate 的依赖配置

`pubspec.yaml`：

```yaml
dependencies:
  easy_design_system:
    git:
      url: https://github.com/kyinwind/easy_design_system.git
      ref: 0.3.0
```

然后执行：

```bash
flutter pub get
```

不要直接跟随 `main`，本轮迁移应固定 `0.3.0`，避免设计系统后续继续开发影响宿主。

---

# 三、本轮 EDS 改造的整体原则

这次没有机械地把 RightClickMate 的建议全部照搬。

最终原则是：

> 视觉和语义继续继承 Swift EasyDesignSystem，但 Flutter 实现优先遵循 Flutter 自身的平台习惯。

特别是：

- Flutter Focus
- Keyboard
- Semantics
- ThemeMode
- Hover
- Tooltip
- Windows/macOS 桌面交互
- Material Theme integration

都按照 Flutter-first 方式补齐。

另一个非常重要的原则是：

> Easy API 不能因为“功能更强”而变难用。

所以普通场景仍然追求：

```dart
EdsButton(
  '保存',
  icon: Icons.save,
  action: save,
)
```

而不是强迫宿主写大量 Widget 拼装代码。

---

# 四、RightClickMate 原建议中已经解决的核心问题

## 1. EdsButton 桌面交互完整化

之前 Button 主要依赖：

```text
MouseRegion
GestureDetector
```

桌面能力不足。

现在 `EdsButton` 已支持：

- Tab Focus
- Shift+Tab
- Enter 激活
- Space 激活
- Focus ring
- Tooltip
- Semantics
- Disabled semantics
- `focusNode`
- `autofocus`
- `semanticLabel`

因此：

> RightClickMate 中普通 Material Button / 自定义 GestureDetector Button 可以开始优先替换成 EdsButton。

---

# 五、EdsButton 新 API

推荐主用法：

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

支持：

```text
icon
tooltip
isBusy
expands
focusNode
autofocus
semanticLabel
```

## 普通按钮

```dart
EdsButton(
  '保存',
  action: save,
)
```

## 带图标

```dart
EdsButton(
  '刷新',
  icon: Icons.refresh,
  action: refresh,
)
```

## 危险操作

```dart
EdsButton(
  '删除',
  role: EdsButtonRole.danger,
  action: delete,
)
```

## Busy

```dart
EdsButton(
  '保存',
  isBusy: saving,
  action: save,
)
```

Busy 状态：

- 自动防止重复点击
- 显示加载状态
- 不等同于 Disabled
- Semantics 仍表达“按钮可用，但当前正在处理”

## 撑满父宽度

```dart
EdsButton(
  '继续',
  expands: true,
  action: next,
)
```

## 高级样式

旧：

```dart
EdsButton.dimension(...)
```

已经 Deprecated。

新代码使用：

```dart
EdsButton.styled(
  '忽略并删除',
  emphasis: EdsButtonEmphasis.soft,
  tone: EdsButtonTone.danger,
  size: EdsButtonSize.regular,
  action: delete,
)
```

## 自定义内容

```dart
EdsButton.custom(
  label: Row(
    children: [
      Icon(Icons.download),
      SizedBox(width: 8),
      Text('下载全部'),
    ],
  ),
  action: downloadAll,
)
```

普通 `icon + text` 不要使用 custom，优先用 Easy API。

---

# 六、Button 兼容关系

以下旧 API 目前仍可编译：

```dart
systemImage:
EdsButton.dimension(...)
```

但已经 Deprecated。

RightClickMate 这轮迁移应直接使用：

```text
systemImage → icon
dimension → styled
```

不要再产生新的旧 API 调用。

---

# 七、Theme / ThemeMode 已修复

之前 EDS brightness 可能只跟系统亮暗走，而忽略：

```dart
MaterialApp(
  themeMode: ThemeMode.dark,
)
```

现在解析顺序是：

```text
1. EdsThemeScope.brightness 显式覆盖
2. Material Theme / ThemeMode
3. MediaQuery platform brightness
4. Brightness.light
```

因此 RightClickMate 只要宿主已有正常：

```dart
MaterialApp(
  theme: ...,
  darkTheme: ...,
  themeMode: ...,
)
```

EDS 就能跟随。

不需要在业务里额外维护第二套 ThemeMode。

---

# 八、Sidebar Scope 问题已修复

之前：

```dart
EdsSidebarIconPresetTint.blue.color
```

读取全局：

```dart
EdsTheme.instance
```

可能绕过局部：

```dart
EdsThemeScope
```

现在应优先使用：

```text
presetTint
resolve(context)
```

让 Sidebar 跟随当前局部 ThemeScope。

如果 RightClickMate 中用了旧 `.color`：建议迁移。

---

# 九、Typography 已扩展

新增 Flutter 侧字体 Token：

```text
fontFamily
fontFamilyFallback
monoFontFamily
monoFontFamilyFallback
```

因此宿主不需要在每个 Text 单独指定字体。

例如：

```dart
EdsTheme.instance.configure((tokens) {
  return tokens.copyWith(
    typography: tokens.typography.copyWith(
      fontFamily: 'Microsoft YaHei UI',
      fontFamilyFallback: const [
        'Segoe UI',
        'sans-serif',
      ],
      monoFontFamily: 'Cascadia Mono',
    ),
  );
});
```

旧 Swift-compatible JSON 不需要增加这些字段。

字段缺失时继续使用平台默认字体。

---

# 十、硬编码文案问题

EDS 没有强行引入完整 `EdsLocalizations`。

策略是：

> 设计系统不阻止宿主国际化，但不抢宿主的业务文案职责。

例如 `EdsComparisonSection` 现在可以传：

```dart
EdsComparisonSection(
  title: l10n.featureComparison,
  featureLabel: l10n.feature,
  freeLabel: 'Free',
  proLabel: 'Pro',
)
```

Pill remove Semantics 也支持自定义文案。

RightClickMate 自己的国际化字符串继续由宿主 l10n 管理。

---

# 十一、本轮新增的设置页高频组件

RightClickMate 这轮迁移重点就是这些。

## 1. EdsCheckbox

```dart
EdsCheckbox(
  value: autoStart,
  label: '开机启动',
  onChanged: (value) {
    setState(() {
      autoStart = value ?? false;
    });
  },
)
```

适合替换：

```text
Checkbox
Checkbox + Text
CheckboxListTile
```

具体页面结构仍可保留 `EdsSettingRow`。

## 2. EdsDropdown<T>

```dart
EdsDropdown<String>(
  value: language,
  items: const ['zh', 'en'],
  labelBuilder: (value) {
    return value == 'zh' ? '中文' : 'English';
  },
  onChanged: (value) {
    ...
  },
)
```

优先替换：

```text
DropdownButton
DropdownButtonFormField
```

如果页面涉及复杂表单验证，再评估是否保留宿主 FormField。

## 3. EdsSegmented<T>

```dart
EdsSegmented<int>(
  value: mode,
  values: const [0, 1, 2],
  labelBuilder: (value) {
    return ['自动', '浅色', '深色'][value];
  },
  onChanged: (value) {
    ...
  },
)
```

适合替换：

```text
SegmentedButton
ToggleButtons
手写一排 Choice Button
```

---

# 十二、新增 EdsTextField

```dart
EdsTextField(
  controller: controller,
  label: '规则名称',
  hint: '请输入名称',
)
```

支持常见：

```text
controller
focusNode
label
hint
onChanged
onSubmitted
enabled
autofocus
obscureText
minLines
maxLines
keyboardType
textInputAction
prefixIcon
suffixIcon
```

RightClickMate 中普通设置输入框可以逐步替换。

---

# 十三、新版 Radio API

Flutter 新版已经废弃：

```dart
Radio(
  groupValue: ...,
  onChanged: ...,
)
```

所以 EDS 没有继续封装旧 API，而是采用 Flutter 新版 `RadioGroup`。

正确用法：

```dart
EdsRadioGroup<int>(
  groupValue: selected,
  onChanged: (value) {
    setState(() {
      selected = value;
    });
  },
  child: const Column(
    children: [
      EdsRadio(
        value: 1,
        label: '选项一',
      ),
      EdsRadio(
        value: 2,
        label: '选项二',
      ),
    ],
  ),
)
```

这样自动获得：

- mutual exclusion
- Arrow keyboard navigation
- Space activation
- Radio group semantics

RightClickMate 如果有 Radio，直接按这个结构迁移。

---

# 十四、新增 EdsSlider

```dart
EdsSlider(
  value: opacity,
  min: 0,
  max: 1,
  onChanged: (value) {
    setState(() {
      opacity = value;
    });
  },
)
```

底层继续复用 Flutter Slider 的 Keyboard、Focus、Semantics，EDS 负责视觉 Token。

---

# 十五、Pill 系统调整

## 普通标签

继续使用：

```dart
EdsPill(...)
```

语义是：

```text
Tag / Label
```

## 可选择 Pill

新增：

```dart
EdsChoicePill(
  '仅图片',
  selected: selected,
  onChanged: (value) {
    ...
  },
)
```

语义是：

```text
Filter / Choice
```

不要再拿普通 EdsPill 自己手写 selected 状态。

---

# 十六、EdsPillFlow<T> 已泛型化

以前主要是 `List<String>`。

现在支持业务模型：

```dart
EdsPillFlow<Rule>(
  rules,
  labelBuilder: (rule) => rule.name,
  onTap: (rule) {
    ...
  },
  onRemove: (rule) {
    ...
  },
)
```

字符串调用仍然兼容：

```dart
EdsPillFlow(
  const ['设计', '开发', '测试'],
)
```

所以 RightClickMate 不需要为了显示 Pill 把业务 Model 转成 String 再反查。

---

# 十七、EdsCollapsibleSection 已增强

非受控：

```dart
EdsCollapsibleSection(
  '高级设置',
  initiallyExpanded: true,
  child: ...
)
```

受控：

```dart
EdsCollapsibleSection(
  '高级设置',
  isExpanded: expanded,
  onExpansionChanged: (value) {
    setState(() {
      expanded = value;
    });
  },
  child: ...
)
```

并补充了 Focus、Keyboard、Semantics。

所以 RightClickMate 如果有手写 Expansion / 折叠卡片，可以优先考虑替换。

---

# 十八、Dialog 已新增

## 普通 Dialog

```dart
EdsAlertDialog(
  title: '提示',
  content: Text('内容'),
  actions: [
    ...
  ],
)
```

## Confirm Dialog

```dart
EdsConfirmDialog(
  title: '删除规则',
  message: '确认删除吗？',
  confirmTitle: '删除',
  cancelTitle: '取消',
  isDestructive: true,
  onConfirm: delete,
  onCancel: cancel,
)
```

注意：EDS Dialog 本身不自动 `Navigator.pop()`，宿主仍然负责生命周期和业务。这是有意设计。

---

# 十九、新增 EdsMenuButton<T>

```dart
EdsMenuButton<int>(
  items: const [
    EdsMenuItem(
      value: 1,
      label: '编辑',
      icon: Icons.edit,
    ),
    EdsMenuItem(
      value: 2,
      label: '删除',
      icon: Icons.delete,
    ),
  ],
  onSelected: (value) {
    ...
  },
  child: const Icon(Icons.more_horiz),
)
```

适合替换：

```text
PopupMenuButton
普通“...”更多菜单
```

---

# 二十、暂时没有做的东西

## Popover

暂缓。

如果 RightClickMate 在迁移过程中遇到：

```text
anchored panel
context popup
非菜单型浮层
复杂 tooltip card
```

再把实际需求反馈回 EDS。

## Toast Service

故意没有放进 EDS。

设计边界：

```text
easy_design_system
→ Visual / Theme / Token / UI Component

my_flutter_app_tools
→ App Service / Overlay / Queue / Utility
```

未来可以有 `EdsToast visual widget`，但 `ToastService / Global Overlay / Queue` 不建议塞进设计系统。

---

# 二十一、RightClickMate 组件替换的推荐顺序

不要全项目无脑正则替换。

## 第一层：最安全

优先替换：

```text
ElevatedButton
FilledButton
OutlinedButton
TextButton
IconButton（能表达成普通操作时）

→ EdsButton
```

然后：

```text
Checkbox
Dropdown
SegmentedButton
Slider
TextField
Radio
```

分别换：

```text
EdsCheckbox
EdsDropdown<T>
EdsSegmented<T>
EdsSlider
EdsTextField
EdsRadioGroup<T> + EdsRadio<T>
```

## 第二层：结构组件

再检查：

```text
ExpansionTile
手写折叠区域
Chip / FilterChip
Wrap + Chip
PopupMenuButton
AlertDialog
```

映射：

```text
EdsCollapsibleSection
EdsPill
EdsChoicePill
EdsPillFlow<T>
EdsMenuButton<T>
EdsAlertDialog
EdsConfirmDialog
```

## 第三层：页面结构

最后再统一：

```text
页面 padding
Card
Section
Group
SettingRow
Typography
```

优先使用：

```text
.easyDesign()
EdsEasyStyle.section
EdsEasyStyle.group
EdsEasyStyle.card

EdsSettingRow
EdsPageTitle
EdsSectionTitle
EdsLabelText
EdsCaptionText
```

这一步不要为了“全部 EDS 化”破坏现有合理布局。

目标是统一视觉语义，而不是机械消灭所有 Flutter Widget。

---

# 二十二、哪些 Flutter 原生 Widget 不需要替换

不要试图替换：

```text
Row
Column
Stack
Expanded
Flexible
SizedBox
Padding
Align
LayoutBuilder
ListView
GridView
ScrollView
Navigator
Scaffold
MaterialApp
Focus
Shortcuts
Actions
Semantics
```

这些是 Flutter 布局 / 框架基础设施。

EDS 不应该复制它们。

---

# 二十三、替换判断原则

如果一个 Flutter Widget 主要负责：

```text
视觉风格
状态视觉
Theme
控件尺寸
交互外观
```

优先考虑 EDS。

如果主要负责：

```text
布局
生命周期
导航
业务状态
数据
平台能力
```

一般保留 Flutter 原生或宿主实现。

---

# 二十四、迁移过程中遇到缺口怎么处理

RightClickMate 智能体遇到某个 Material 组件无法合理换成 EDS 时：不要为了“全替换”强行拼。

### A. EDS 已有能力

直接使用。

### B. EDS 有能力，但 API 不够顺

记录具体代码和场景，反馈 EDS。

### C. EDS 根本没有这个组件

先判断：这是 RightClickMate 特殊需求，还是多个 App 都会需要的通用能力？

如果是通用能力，再回流 `easy_design_system`。

### D. 本来就不属于设计系统

保留宿主/Flutter 原生。

---

# 二十五、迁移时特别注意 Deprecated API

新代码不要继续使用：

```text
EdsButton.dimension
systemImage
EdsSidebarIconPresetTint.color
```

优先：

```text
EdsButton.styled
icon
presetTint / resolve(context)
```

---

# 二十六、当前发布状态

`easy_design_system`：

```text
version: 0.3.0
tag: 0.3.0
```

最终发布前已经完整通过：

```text
flutter pub get                      ✅
dart format --set-exit-if-changed . ✅
flutter analyze                      ✅
flutter test                         ✅
```

并且 release workflow 在正式打 tag 前再次执行了一遍上述检查。

最终 tag：

```text
0.3.0
```

指向正式发布提交。

---

# 二十七、给 RightClickMate 智能体的任务

请开始 RightClickMate 的 EDS 迁移。

第一步不是直接修改所有文件。

先做一次组件盘点：

```text
1. 找出所有 Material / Flutter 视觉控件
2. 按页面和组件类型分类
3. 标记：
   - 可以直接换 EDS
   - 需要轻微重构
   - 暂时保留原生
   - EDS 仍缺能力
4. 生成迁移计划
```

然后分批改：

```text
Batch 1
Button / Checkbox / Dropdown / Segmented

Batch 2
TextField / Radio / Slider

Batch 3
Pill / Collapsible / Menu / Dialog

Batch 4
Page / Section / Group / Card / Typography
```

每批：

```text
修改
↓
flutter analyze
↓
flutter test
↓
Windows 编译
↓
再继续下一批
```

不要一次性改完整个项目后才编译。

---

# 二十八、迁移最终目标

RightClickMate 最终应该达到：

> 业务代码主要表达“这是什么控件、这是什么页面结构”，而不是到处维护颜色、padding、圆角、Hover、Focus、字体和深浅色。

EDS 负责：

```text
视觉
Theme
Token
桌面交互
常见组件
无障碍
跨平台一致性
```

RightClickMate 负责：

```text
业务
数据
状态
导航
生命周期
平台功能
```

如果迁移过程中发现 `easy_design_system 0.3.0` 仍有不合理 API 或缺少真正通用能力，请把**具体使用场景 + 当前写法 + 希望的 Easy API**整理出来，再回流到 EDS，而不是在宿主内部长期打补丁。
