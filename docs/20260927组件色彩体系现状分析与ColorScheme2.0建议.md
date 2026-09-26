# easy_design_system 组件色彩体系现状分析与 ColorScheme 2.0 建议

日期：2026-09-27  
状态：设计研究 / 架构讨论稿  
目的：用于学习、讨论和后续设计决策，**本文件不代表已经确定要修改代码**。

---

# 一、为什么现在需要单独讨论“组件色彩系统”

`easy_design_system` 目前已经完成了一轮 Flutter-first 组件扩展。

从能力上看，已经具备：

- Theme / Token
- Light / Dark
- Button
- Checkbox
- Dropdown / DropdownFormField
- Segmented
- TextField / TextFormField
- Radio
- Slider
- Pill / ChoicePill
- Dialog
- Menu
- Sidebar
- Card / Group / Page
- 状态组件

但是随着组件越来越多，一个新的问题开始变得明显：

> **“这些组件应该使用什么颜色”目前还没有形成统一的方法论。**

Button 是一个例外。

Button 已经建立了比较完整的：

```text
Tone × Emphasis × State
```

思路。

而其他组件目前大多还是：

```text
组件
  ↓
直接选择 primary / border / cardBackground / textSecondary
```

这种方式在组件数量少时完全可用，但组件越来越多后，很容易出现：

- 每个组件各自决定 Hover
- 每个组件各自决定 Pressed
- 每个组件各自决定 Disabled
- Focus 的颜色和强度不一致
- Selected 状态不一致
- Error 状态不一致
- Card / Dialog / Field 的层级关系不清楚
- Dark Mode 只能做到“能看”，但不一定形成统一视觉层次

因此下一阶段如果继续逐个组件“补颜色”，很可能得到的是：

> 组件都用了 EDS Token，但整个 App 仍然没有真正统一的色彩语言。

真正需要补的是：

> **组件之下的“语义色彩系统”。**

---

# 二、EDS 当前颜色体系现状

## 2.1 第一层：EdsColorTokens

目前最底层的核心颜色主要是：

```text
primary
accent
success
warning
danger
```

其中：

```text
accent
```

目前主要是为了兼容 Swift JSON schema，Flutter EDS 内部实际上已经基本统一使用：

```text
primary
```

同时根据这些颜色派生：

```text
primarySoft
successSoft
warningSoft
dangerSoft
```

这些 Soft 色目前本质上是：

```text
base color × 12% alpha
```

这一层可以理解成：

> **品牌色 / 状态色种子。**

方向是合理的。

---

# 三、第二层：EdsColorScheme

当前 EDS 已经有一层亮暗模式语义颜色：

```text
label
textPrimary
textSecondary
textTertiary

pageBackground
cardBackground
cardGrayBackground
subtleFill

border
```

Light / Dark 会得到不同值。

当前默认大致关系为：

| Role | Light | Dark |
| --- | --- | --- |
| textPrimary | 黑 | 白 |
| textSecondary | 黑 60% | 白 60% |
| textTertiary | 黑 43.2% | 白 43.2% |
| pageBackground | #F7F7F7 | #1E1E20 |
| cardBackground | #FFFFFF | #2A2A2C |
| cardGrayBackground | 黑 4.5% | 白 4.5% |
| subtleFill | 黑 3% | 白 3% |
| border | 黑 10% | 白 10% |

这一层已经不是“具体颜色值”，而开始表达：

```text
这个颜色拿来干什么
```

例如：

```text
textPrimary
border
pageBackground
```

这是 EDS 当前最重要的基础，也是未来升级应该延续而不是推翻的部分。

---

# 四、第三层：当前组件如何取颜色

## 4.1 Button

Button 是目前最成熟的组件。

它不是简单写：

```text
primary button = 蓝色
danger button = 红色
```

而是建立了三个维度：

### Tone

```text
accent
neutral
danger
success
warning
```

### Emphasis

```text
filled
medium
outline
soft
plain
```

### Size

```text
small
regular
large
```

真正颜色由：

```text
EdsButtonAppearance.resolve()
```

统一解析成：

```text
foreground
background
borderColor
borderWidth
```

因此 Button 已经具备比较典型的 Design System Component Recipe。

例如：

```text
accent + filled
danger + soft
neutral + medium
success + filled
```

不是四个互不相关的样式，而是来自一套统一规则。

---

# 五、其他组件目前的典型颜色逻辑

## Checkbox

当前大致是：

```text
checked background = primary
check = white
border = scheme.border
text = scheme.textPrimary
```

## Dropdown

当前大致是：

```text
background = cardBackground
border = border
text = textPrimary
hint = textSecondary
icon = textSecondary
```

## Segmented

Selected：

```text
background = primarySoft
foreground = primary
```

Unselected：

```text
background = cardBackground
foreground = textSecondary
```

## TextField

```text
background = cardBackground
text = textPrimary
hint = textTertiary
label = textSecondary

rest border = border
focus border = primary
error border = danger
```

## ChoicePill

```text
rest surface = cardBackground
rest text = textSecondary
rest border = border

selected surface = primarySoft
selected text = primary
selected border = primary
```

## Dialog

```text
surface = cardBackground
border = border
title = textPrimary
content = textSecondary
```

这些选择单独来看基本合理。

问题不是：

> “这些颜色选错了。”

而是：

> **每个组件正在自己决定颜色规则。**

---

# 六、当前体系真正的结构性问题

如果继续按照现在的方式发展，很容易出现：

```text
Checkbox Hover
→ 自己设计

Dropdown Hover
→ 自己设计

Menu Hover
→ 自己设计

ChoicePill Hover
→ 自己设计

Sidebar Hover
→ 自己设计
```

同样，Disabled 也可能变成：

```text
Button
→ opacity 0.5

TextField
→ border alpha 0.5

Dropdown
→ textSecondary

Checkbox
→ Material 默认
```

即使所有组件都“引用了 EDS Token”，视觉语言仍然可能不统一。

所以 EDS 当前真正缺的不是更多 Hex Color，而是：

> **一套完整的 Color Role Language。**

---

# 七、现代设计系统共同采用什么方法

下面部分是对 Material 3、Fluent 2、Atlassian Design System、Carbon Design System 的公开设计资料整理。

重点不是复制其中任何一个，而是寻找它们共同采用的方法。

---

# 八、Material 3：Foreground / Background 成对设计

Material 3 非常重要的思路是：

> 不只定义一个颜色，而是定义它与“内容颜色”的配对关系。

典型角色包括：

```text
primary
onPrimary

primaryContainer
onPrimaryContainer

surface
onSurface

surfaceContainer
onSurfaceVariant

error
onError

errorContainer
onErrorContainer

outline
outlineVariant
```

例如：

```text
background = primary
foreground = onPrimary
```

而不是：

```text
background = primary
foreground = white
```

Selected Container 可以是：

```text
background = primaryContainer
foreground = onPrimaryContainer
```

这带来一个很重要的能力：

> Brand 色改变以后，前景色不需要假定永远是白色。

Material 3 同时提供多级 Surface Container，用于表达容器层级。

参考：

- Android Developers — Material 3 ColorScheme  
  https://developer.android.com/develop/ui/compose/designsystems/material3

---

# 九、Fluent 2：Background / Foreground / Stroke + State

对于 EDS 而言，Fluent 2 非常值得研究。

EDS 的核心宿主之一就是 Windows 桌面 App，而 Fluent 的颜色语言非常适合：

- 设置页
- 工具 App
- 生产力软件
- 桌面 UI

Fluent 2 的 Alias Color Token 主要按这些方向组织：

```text
Neutral
Brand
Status
Generic
```

同时又按 UI 属性区分：

```text
Background
Foreground
Stroke
```

例如：

```text
colorNeutralBackground1
colorNeutralBackground2

colorNeutralForeground1
colorNeutralForeground2
colorNeutralForeground3

colorNeutralStroke1
colorNeutralStroke2
```

更重要的是，同一个 Alias Token 本身就包含状态映射：

```text
Rest
Hover
Pressed
Selected
Disabled
```

因此组件不需要自己不断写：

```text
Color.lerp()
withOpacity()
```

去猜 Hover 应该是什么颜色。

Fluent 另一个非常值得 EDS 学习的原则是：

> **Neutral 才是 UI 的主体。Brand Color 应该承担强调，而不是铺满整个界面。**

Neutral 通常负责：

- Surface
- Text
- Stroke
- Layout hierarchy

Brand 主要用于：

- Primary action
- Active / Selected
- Focus
- 重要强调

参考：

- Fluent 2 — Color  
  https://fluent2.microsoft.design/color
- Fluent 2 — Color Tokens  
  https://fluent2.microsoft.design/color-tokens

---

# 十、Atlassian：Property × Role × Emphasis × State

Atlassian 的 Color Token 命名很值得从工程架构角度研究。

典型例子：

```text
color.background.danger.bold.hovered
```

这个名字实际上表达了：

```text
color
    ↓
background       → 用于什么属性
    ↓
danger           → 什么语义
    ↓
bold             → 什么强调级别
    ↓
hovered          → 当前什么交互状态
```

Atlassian 把颜色设计中的几个问题明确拆开：

## Property

```text
background
text
icon
border
```

## Role

```text
neutral
brand
danger
success
warning
information
...
```

## Emphasis

```text
subtlest
subtler
subtle
bold
...
```

## Interaction State

```text
default
hovered
pressed
selected
focused
disabled
```

这和 EDS 当前 Button 的：

```text
Tone × Emphasis
```

非常接近。

区别是：

> Atlassian 把这种设计思想提升成了整个颜色系统的语言，而 EDS 目前主要只在 Button 中使用。

参考：

- Atlassian Design — Color  
  https://atlassian.design/foundations/color
- Atlassian Design — Design Tokens  
  https://atlassian.design/foundations/design-tokens

---

# 十一、Carbon：Layer Context

Carbon 对 EDS 最大的启发之一，是：

> **组件颜色不能只取决于组件本身，还会取决于它所在的 Surface Layer。**

Carbon 有类似：

```text
background

layer-01
layer-02
layer-03

field-01
field-02
field-03

border-strong-01
border-strong-02
border-strong-03
```

的 contextual tokens。

例如：

```text
TextField 放在 Page 上
→ field-01

TextField 放在 Layer 1 Card 上
→ field-02

TextField 放在 Layer 2 Surface 上
→ field-03
```

原因很直观。

如果：

```text
Page = white
Card = white
TextField = white
```

三个东西完全相同，就无法仅靠 Surface 色彩建立层级。

Carbon 会让 Field 根据父层级切换。

它的 Select / Field 规范也明确把：

```text
Field background
Field hover
Strong border
Focus
Text primary
Text secondary
Icon
```

分别作为语义 token。

参考：

- Carbon — Color Tokens  
  https://carbondesignsystem.com/elements/color/tokens/
- Carbon — Color Usage / Layering  
  https://carbondesignsystem.com/elements/color/usage/
- Carbon — Select style  
  https://carbondesignsystem.com/components/select/style/

---

# 十二、四套设计系统的共同规律

虽然 Material、Fluent、Atlassian、Carbon 名称不同，但底层共同逻辑非常接近：

```text
Primitive / Palette
        ↓
Semantic / Alias Tokens
        ↓
State / Context
        ↓
Component Recipe
```

也就是说：

> 成熟设计系统通常不会让组件直接从一个蓝色、一个灰色开始做设计。

组件最终使用的是：

```text
这个颜色是什么角色？
它被用在哪种属性？
它是什么强调程度？
它现在处于什么状态？
它处于什么 Surface Context？
```

---

# 十三、EDS 与现代设计系统的差异

| 能力 | EDS 当前 | 成熟现代体系 |
| --- | --- | --- |
| Brand 色 | 有 | 有 |
| Success / Warning / Danger | 有 | 有 |
| Light / Dark | 有 | 有 |
| Primary / Secondary / Tertiary text | 有 | 有 |
| Surface | 初步有 | 多层级、语义明确 |
| Foreground / Background 配对 | 部分 | 系统化 |
| Border | 基本一个 | 多级 |
| Hover | 组件自行处理 | 系统 token |
| Pressed | 组件自行处理 | 系统 token |
| Selected | 组件自行处理 | 系统 token |
| Disabled | 不完全统一 | 系统 token |
| Focus | Button / Field 各自处理 | 系统角色 |
| Status Surface / Foreground / Border | base + soft | 完整角色族 |
| Layer Context | 基本没有 | Carbon 等系统化 |
| Component Recipe | Button 最成熟 | 全组件均有规范 |
| Accessibility Color Pair | 经验处理较多 | 成对设计 / token 验证 |

因此 EDS 当前不是：

> 配色“不好”。

而更准确地说是：

> **颜色体系目前大约完成了 1～2 层，而 Button 已经独自走到了第 3 层。**

---

# 十四、EDS 下一代色彩体系不应该怎么做

## 不建议：直接增加几十个颜色字段

例如简单增加：

```text
checkboxHoverColor
dropdownHoverColor
menuHoverColor
pillSelectedColor
textFieldFocusColor
...
```

这会得到一个巨大的 Component-specific Token 集合。

问题是：

- 很难统一
- Theme 很难维护
- 新组件仍然需要发明新颜色
- 多个平台难以保持视觉一致
- 用户自定义主题的成本会急剧上升

---

# 十五、建议的总体架构

建议 EDS 逐步走向：

```text
Theme Seed / Palette
        ↓
Semantic Color Scheme
        ↓
Component Color Recipe
```

其中状态与 Context 贯穿 Semantic Scheme 和 Component Recipe。

---

# 十六、第一层：Theme Seed / Palette

这一层应该保持非常少。

宿主通常只需要配置：

```text
brand
success
warning
danger
```

当前 EDS 的：

```text
primary
success
warning
danger
```

其实已经很接近。

这里不应该变成几十个字段。

主题预设：

```text
blue
orange
purple
```

主要改变 Seed。

---

# 十七、第二层：Semantic Color Scheme

这是我认为未来 EDS 最需要加强的部分。

建议从五大类语义开始研究：

```text
Surface
Foreground
Border
Status
Interaction
```

不是说这些名字现在必须立即确定，而是建议把“设计问题”先按这五类拆开。

---

# 十八、Surface

EDS 当前有：

```text
pageBackground
cardBackground
cardGrayBackground
subtleFill
```

未来可以考虑重新整理成更明确的层级语言，例如：

```text
surfacePage
surfaceBase
surfaceRaised
surfaceSunken
surfaceOverlay
```

含义可以类似：

### surfacePage

页面最底层背景。

### surfaceBase

默认内容 Surface。

### surfaceRaised

Card、Dialog 等视觉上高一层的 Surface。

### surfaceSunken

Field、Well、Inset 区域等视觉上凹进去的 Surface。

### surfaceOverlay

Menu、Popover、Floating Panel 等浮层。

这里最重要的不是名称，而是：

> **EDS 应该先明确“一个 App 到底有几层 Surface”。**

Card、Dialog、Menu、TextField 的颜色才能自然确定。

---

# 十九、Foreground

EDS 当前已有：

```text
textPrimary
textSecondary
textTertiary
```

这是非常好的基础。

建议进一步研究：

```text
foregroundPrimary
foregroundSecondary
foregroundTertiary

foregroundDisabled
foregroundInverse

foregroundBrand
foregroundDanger
foregroundSuccess
foregroundWarning
```

其中 `inverse` 非常重要。

未来应该尽量避免组件内部写：

```dart
Colors.white
```

而是表达：

```text
foregroundInverse
```

这样 Brand 色变化以后，可以保证前景色仍然正确。

---

# 二十、Border

当前 EDS 几乎只有：

```text
border
```

这个粒度明显不够。

至少从设计语言上需要区分：

```text
borderSubtle
borderDefault
borderStrong
borderSelected
borderFocus
borderDanger
```

例如：

### borderSubtle

装饰性分割。

### borderDefault

普通控件边界。

### borderStrong

Field、Checkbox 等需要更明确辨识的边界。

### borderSelected

选中控件。

### borderFocus

键盘 Focus。

### borderDanger

Validation Error。

这样 TextField、Dropdown、Checkbox、Pill、Card 就不必自己决定：

> “这里到底是 10% black 还是 primary？”

---

# 二十一、Status Color Family

当前：

```text
danger
dangerSoft
```

实际上只解决：

```text
一个强色
一个浅色
```

未来可以把每一个 Status 看成一个 Color Family。

例如：

```text
Danger

foreground
surface
surfaceStrong
border
onStrong
```

Success / Warning 同理。

概念上类似：

```text
dangerForeground
dangerSurface
dangerSurfaceStrong
dangerBorder
dangerOnStrong
```

具体最终 API 可以再讨论。

这样：

- Error Text
- Error Field
- Danger Badge
- Danger Button
- Error Banner
- Error Pill

都从同一个 Danger Family 来。

---

# 二十二、Interaction State

建议 EDS 明确一套统一状态：

```text
rest
hover
pressed
selected
focused
disabled
```

目前 Button 已经有 Hover / Focus / Pressed 逻辑。

未来不应该每个组件都自己：

```dart
withOpacity(...)
Color.lerp(...)
```

去创造状态颜色。

可以研究两种实现路线。

## 路线 A：直接定义 state token

例如：

```text
surfaceHover
surfacePressed
surfaceSelected

borderHover
borderPressed
...
```

## 路线 B：定义 state layer / state transformation

例如：

```text
hoverOverlay
pressedOverlay
selectedOverlay
```

再由 Recipe 应用。

哪种适合 EDS，需要经过 Catalog 验证。

现在先确定一个原则：

> **Hover / Pressed / Selected / Disabled 应该属于 Design System，而不是属于某一个组件的临时算法。**

---

# 二十三、Context / Layer

这是 EDS 目前最容易被忽视、但长期非常重要的部分。

可以先研究一种非常简单的模型：

```text
Layer 0 = Page
Layer 1 = Card / Group
Layer 2 = Nested Surface
Layer Overlay = Dialog / Menu
```

Field 的 Surface 可以根据 Layer 变化：

```text
Page
 └─ TextField
     → fieldSurface1

Card
 └─ TextField
     → fieldSurface2
```

不一定需要完全复制 Carbon 的：

```text
field-01
field-02
field-03
```

但 EDS 至少需要意识到：

> **同一个组件放在不同 Surface 上，可能需要不同颜色才能保持层级。**

---

# 二十四、第三层：Component Color Recipe

Semantic Scheme 建立之后，组件才去消费它。

组件自己不应该再“发明颜色”。

---

# 二十五、Checkbox Recipe 示例

未来可以表达成：

```text
unchecked
  surface     = transparent
  border      = borderStrong
  foreground  = foregroundPrimary

checked
  surface     = brandSurfaceStrong
  foreground  = brandOnStrong
  border      = brandBorder

hover
  state       = hover

focus
  border      = borderFocus

disabled
  foreground  = foregroundDisabled
  border      = borderSubtle
```

---

# 二十六、Field Recipe 示例

TextField 和 Dropdown 应该共享同一套 Field Color Recipe，而不是分别设计。

```text
rest
  surface      = fieldSurface
  text         = foregroundPrimary
  placeholder  = foregroundTertiary
  border       = borderDefault

hover
  surface      = fieldSurfaceHover
  border       = borderStrong

focus
  border       = borderFocus

error
  border       = dangerBorder
  message      = dangerForeground

disabled
  surface      = disabledSurface
  text         = foregroundDisabled
```

这样：

```text
EdsTextField
EdsTextFormField
EdsDropdown
EdsDropdownFormField
```

可以共享颜色系统。

---

# 二十七、Choice Control Recipe

可以服务：

```text
ChoicePill
Segmented
Selectable Row
Filter
```

例如：

```text
rest
  surface = transparent / neutralSurface
  text = foregroundSecondary
  border = borderDefault

selected
  surface = brandSurface
  text = brandForeground
  border = brandBorder

hover
  state = hover

disabled
  text = foregroundDisabled
```

---

# 二十八、Expression Components 和 Control Components 应分开

这是未来设计时需要特别注意的边界。

## 表达型组件

例如：

```text
Button
Badge
Pill
Banner
Status
Callout
```

它们非常适合使用：

```text
Tone × Emphasis
```

例如：

```text
danger + bold
success + soft
brand + medium
neutral + subtle
```

Button 目前已经验证了这个模型。

---

## 控件型组件

例如：

```text
TextField
Dropdown
Checkbox
Radio
Slider
```

它们的核心不是：

```text
success TextField
warning Checkbox
```

而是：

```text
rest
hover
focus
selected
invalid
disabled
```

因此更适合：

```text
Control Role × State
```

两者最终都从同一 Semantic Color Scheme 获取颜色。

---

# 二十九、Button 当前模型值得保留并向上提炼

目前 Button 的：

```text
Tone
+
Emphasis
```

其实是 EDS 当前最成熟的设计成果之一。

未来可以考虑把其中部分概念提升为通用 Foundation，例如：

```text
EdsTone

brand
neutral
danger
success
warning
```

以及概念上的：

```text
strong
medium
soft
subtle
```

但不建议为了“代码复用”立即强行让所有组件继承同一个 Enum。

应该先统一：

> **设计语言。**

再判断：

> **代码抽象是否也应该统一。**

---

# 三十、建议的 Color Architecture

可以先把未来目标画成：

```text
                     Theme Seed
          ┌─────────────┼─────────────┐
        Brand         Status        Neutral
                    success...
                         │
                         ▼
               Semantic Color Scheme
 ┌──────────────┬──────────────┬──────────────┬─────────────┐
 Surface     Foreground       Border       Status       Interaction
 page         primary         subtle       danger       hover
 base         secondary       default      success      pressed
 raised       tertiary        strong       warning      selected
 sunken       disabled        focus                     disabled
 overlay      inverse         danger                    focus
      │
      └──────────────────────┬──────────────────────────┘
                             ▼
                    Component Color Recipes
           ┌─────────────────┼──────────────────┐
       Expression           Field            Choice Control
       Button               TextField        Checkbox
       Badge                Dropdown         Radio
       Pill                 Search           Segmented
       Banner                                Slider
```

---

# 三十一、EDS 未来应该先做什么，而不是马上改组件

建议下一阶段不要直接：

```text
修改 Checkbox Color
修改 Dropdown Color
修改 TextField Color
修改 Pill Color
```

而是先完成一份：

> **EDS Color Foundation 2.0 设计稿**

先回答：

### 1. EDS 到底有几级 Surface？

例如：

```text
Page
Base
Raised
Sunken
Overlay
```

### 2. Foreground 需要几级？

例如：

```text
Primary
Secondary
Tertiary
Disabled
Inverse
```

### 3. Border 有哪些语义？

例如：

```text
Subtle
Default
Strong
Selected
Focus
Danger
```

### 4. Status Family 怎么定义？

```text
Foreground
Surface
Strong Surface
Border
On Strong
```

### 5. Interaction State 怎么统一？

```text
Hover
Pressed
Selected
Focus
Disabled
```

这些答案确定以后，组件颜色会自然得多。

---

# 三十二、建议的迁移顺序

如果未来决定正式做 ColorScheme 2.0，我建议按照下面顺序。

## Phase 1 — 只设计 Foundation

不改组件。

建立：

```text
Surface
Foreground
Border
Status
Interaction
```

同时设计 Light / Dark Mapping。

---

## Phase 2 — Catalog 做色彩实验

建立专门的：

```text
Color Foundation Gallery
```

展示：

```text
所有 Surface
所有 Foreground
所有 Border
Status Family
所有 State
Light / Dark
Blue / Orange / Purple Theme
```

不要先拿真实 App 调颜色。

---

## Phase 3 — 迁移一类组件

建议第一批：

```text
TextField
Dropdown
Checkbox
Radio
Segmented
Slider
```

因为它们目前最缺统一状态语言。

建立统一：

```text
Control / Field Recipe
```

---

## Phase 4 — 迁移表达型组件

```text
Button
Badge
Pill
ChoicePill
Banner
Status
```

把 Button 已有经验提炼出来。

---

## Phase 5 — Surface / Container

最后统一：

```text
Page
Card
Group
Dialog
Menu
Sidebar
Popover
```

解决 Layer 和 Overlay。

---

## Phase 6 — RightClickMate / VideoHero 实机验证

观察：

- Windows Light
- Windows Dark
- 高对比显示
- Hover
- Focus
- Selected
- Disabled
- Error
- Nested Card / Field
- Dialog / Menu Overlay

真实 App 发现的问题再回流 Color Foundation。

---

# 三十三、无障碍应该成为 Color System 的约束

未来 ColorScheme 2.0 不应该只验证：

> 好不好看。

还要验证：

> 这些 Role Pair 是否具有足够的 Contrast。

Atlassian 的公开颜色规范明确以 WCAG AA 为基础，并强调：

- 小文字通常需要 4.5:1
- 关键非文本 UI 通常需要 3:1

Material 的 `onPrimary`、`onSurface` 等设计，本质上也有利于建立可验证的前景/背景配对。

因此 EDS 未来可以把：

```text
surface + foreground
strong status surface + onStrong
brand surface + brand foreground
```

作为“配对”来测试，而不是单独测试一个 Color。

参考：

https://atlassian.design/foundations/color

---

# 三十四、关于 Brand Color 的使用建议

EDS 未来应该避免：

> “换成紫色主题以后，整个 App 到处都是紫色。”

比较成熟的桌面生产力 App 通常：

```text
Neutral = UI 主体
Brand = 关键强调
Status = 状态信息
```

Brand 更适合：

- Primary Button
- Selected
- Active
- Focus
- Progress
- Link / Highlight
- 少量视觉强调

而：

- Page
- Card
- Field
- Dialog
- 普通 Menu
- 普通 Row

主要应该由 Neutral Surface 构成。

Fluent 2 对这点尤其值得参考。

参考：

https://fluent2.microsoft.design/color

---

# 三十五、当前暂时不要决定的问题

本文件的目的不是直接决定最终 API。

下面这些问题还需要以后逐个讨论：

1. `surfaceBase / surfaceRaised` 是否是最适合的命名？
2. 是否真的需要 5 层 Surface？
3. Interaction State 应该是具体颜色，还是统一 State Overlay？
4. Status Family 最终暴露几个 token？
5. 是否需要 `EdsTone` 通用枚举？
6. Layer 是否通过 InheritedWidget 自动传递？
7. Field 是否跟随 Layer 自动变化？
8. 是否允许宿主覆盖 Semantic Scheme，而不仅是 Seed？
9. Material Theme ColorScheme 和 EdsColorScheme 应该建立多深的桥接？
10. Windows High Contrast 将来是否进入 EDS Theme Model？

这些都应该先通过：

```text
设计语言
→ Catalog
→ 真实宿主
```

验证后再决定。

---

# 三十六、阶段性结论

对 EDS 当前状态最准确的描述不是：

> “其他组件的颜色没设计好。”

而是：

> **EDS 已经有 Palette、初步 Semantic Scheme，以及一个很成熟的 Button Recipe，但还没有把三者扩展成完整的组件色彩架构。**

这其实是一个非常适合继续演进的位置。

不需要推倒重来。

可以沿着现有结构继续：

```text
EdsColorTokens
        ↓
EdsColorScheme 2.0
        ↓
Component Color Recipe
```

其中最值得优先研究的五个 Foundation 是：

```text
1. Surface
2. Foreground
3. Border
4. Status
5. Interaction State
```

再补一个长期重要维度：

```text
6. Context / Layer
```

如果这一层设计成熟，未来 Checkbox、TextField、Dropdown、Menu、Dialog、Pill 等组件的颜色就不再是：

> “设计师觉得这里应该浅一点。”

而可以明确表达为：

> “这是 Raised Surface 上的 Field，在 Rest 状态使用 Field Surface；Focus 使用 Focus Border；Invalid 使用 Danger Border + Danger Foreground。”

到这个阶段，easy_design_system 才会从：

> **一组风格相近的 Flutter 组件**

进一步成长为：

> **一套具有统一视觉语言、可以稳定扩展和换主题的通用设计系统。**

---

# 三十七、建议后续学习顺序

如果要继续深入研究，可以按这个顺序看：

### 第一优先：Fluent 2 Color / Color Tokens

适合 EDS 的桌面工具 App 定位。

- https://fluent2.microsoft.design/color
- https://fluent2.microsoft.design/color-tokens

重点看：

```text
Neutral / Brand / Status
Background / Foreground / Stroke
Rest / Hover / Pressed / Selected / Disabled
```

### 第二优先：Atlassian Color

特别适合学习“语义 Token 如何命名”。

- https://atlassian.design/foundations/color
- https://atlassian.design/foundations/design-tokens

重点看：

```text
Property
Role
Emphasis
Interaction State
```

### 第三优先：Carbon Color / Layer

特别适合研究：

```text
Surface Context
Field Layer
Nested Surface
```

- https://carbondesignsystem.com/elements/color/tokens/
- https://carbondesignsystem.com/elements/color/usage/
- https://carbondesignsystem.com/components/select/style/

### 第四优先：Material 3 ColorScheme

适合研究：

```text
foreground / background pair
primary / onPrimary
container / onContainer
surface hierarchy
```

- https://developer.android.com/develop/ui/compose/designsystems/material3

---

# 三十八、一句话记忆

如果明天继续讨论，只需要先记住这一句话：

> **不要先问“Checkbox 应该是什么颜色”，先问“Checkbox 在这个状态下需要什么语义角色”。**

这是从“组件配色”走向“设计系统色彩架构”的关键一步。
