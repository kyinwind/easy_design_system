# EDS ColorScheme 2.0 设计规范 Draft 1

日期：2026-09-27  
状态：设计规范草案  
适用仓库：`easy_design_system`  
目标：重新定义 EDS 的颜色架构，使 Theme、语义色与组件色彩规则形成稳定、可扩展、可主题化的系统。

---

# 1. 文档定位

本文件不是“颜色调优建议”，而是 `easy_design_system` 下一代颜色系统的正式设计草案。

本设计希望解决的问题是：

- 组件数量增加后，各组件自行决定 Hover / Pressed / Disabled / Error / Selected 颜色
- 当前 `EdsColorScheme` 语义层级不足
- `Button` 已经拥有较成熟的 Tone × Emphasis 模型，但其他组件没有统一方法
- Theme Seed 与实际组件颜色之间缺少稳定中间层
- Card / Dialog / Field / Menu 等 Surface 层次没有系统表达
- Host App 想定制主题时，要么能力不足，要么容易下沉到组件级硬编码
- Light / Dark / Layer / State 缺乏统一推导规则

本版本采用一个核心原则：

> **组件决定自己需要什么语义角色，Theme 决定这些语义角色最终是什么颜色。**

---

# 2. 最终架构：三层模型

ColorScheme 2.0 采用三层结构：

```text
┌──────────────────────────────┐
│ 1. Theme Seed                │
│ brand / information /        │
│ success / warning / danger   │
└──────────────┬───────────────┘
               │ 自动推导
               ▼
┌──────────────────────────────┐
│ 2. Semantic Color Scheme     │
│ Surface / Foreground /       │
│ Border / Brand / Status /    │
│ Interaction / Layer          │
└──────────────┬───────────────┘
               │ 组件选择语义角色
               ▼
┌──────────────────────────────┐
│ 3. Component Color Recipe    │
│ Button / TextField /         │
│ Dropdown / Checkbox /        │
│ Dialog / Menu / ...          │
└──────────────────────────────┘
```

不再把“Expression / Field / Choice / Surface”做成额外运行时或代码层。

这些分类只保留为：

- 设计指导
- 新组件设计 Checklist
- Recipe 设计参考

而不是正式的数据模型。

---

# 2.1 ColorScheme 2.0 总体架构图

```text
┌──────────────────────────────────────────────┐
│ 1. Theme Seed                                │
│                                              │
│ brand                                        │
│ information                                  │
│ success                                      │
│ warning                                      │
│ danger                                       │
└───────────────────┬──────────────────────────┘
                    │
                    │ EDS 根据 Brightness / 默认规则自动推导
                    │ Host 可在结果层做 Semantic Override
                    ▼
┌──────────────────────────────────────────────┐
│ 2. Semantic Color Scheme                     │
│                                              │
│ Surface                                      │
│ ├─ surfacePage                               │
│ ├─ surfaceBase                               │
│ ├─ surfaceRaised                             │
│ ├─ surfaceSunken                             │
│ ├─ surfaceOverlay                            │
│ └─ surfaceDisabled                           │
│                                              │
│ Foreground                                   │
│ ├─ foregroundPrimary                         │
│ ├─ foregroundSecondary                       │
│ ├─ foregroundTertiary                        │
│ ├─ foregroundDisabled                        │
│ └─ foregroundInverse                         │
│                                              │
│ Border                                       │
│ ├─ borderSubtle                              │
│ ├─ borderDefault                             │
│ ├─ borderStrong                              │
│ ├─ borderSelected                            │
│ ├─ borderFocus                               │
│ ├─ borderDisabled                            │
│ └─ borderDanger                              │
│                                              │
│ Brand Family                                 │
│ ├─ brandForeground                           │
│ ├─ brandSurface                              │
│ ├─ brandSurfaceStrong                        │
│ ├─ brandBorder                               │
│ └─ brandOnStrong                             │
│                                              │
│ Status Families                              │
│ ├─ information*                              │
│ ├─ success*                                  │
│ ├─ warning*                                  │
│ └─ danger*                                   │
│    * Foreground / Surface / SurfaceStrong /  │
│      Border / OnStrong                       │
│                                              │
│ Interaction                                  │
│ ├─ rest                                      │
│ ├─ hover                                     │
│ ├─ pressed                                   │
│ ├─ selected                                  │
│ ├─ focused                                   │
│ └─ disabled                                  │
│                                              │
│ Layer / Context                              │
│ ├─ Layer 0                                   │
│ ├─ Layer 1                                   │
│ ├─ Layer 2                                   │
│ └─ Overlay                                   │
└───────────────────┬──────────────────────────┘
                    │
                    │ Component 只选择“自己需要哪些语义角色”
                    │ 不直接依赖具体 Hex / Seed
                    ▼
┌──────────────────────────────────────────────┐
│ 3. Component Color Recipe                    │
│                                              │
│ EdsButton                                    │
│ ├─ Tone × Emphasis                           │
│ ├─ background → Brand / Status Surface       │
│ ├─ foreground → Foreground / OnStrong        │
│ ├─ border → Border / Tone Border             │
│ └─ hover / pressed → Interaction Resolver    │
│                                              │
│ EdsTextField                                 │
│ ├─ surface → surfaceSunken                    │
│ ├─ text → foregroundPrimary                  │
│ ├─ placeholder → foregroundTertiary          │
│ ├─ border → borderDefault                    │
│ ├─ focus → borderFocus                       │
│ ├─ error → dangerBorder / dangerForeground   │
│ └─ disabled → Disabled Roles                 │
│                                              │
│ EdsCheckbox                                  │
│ ├─ unchecked → borderStrong                  │
│ ├─ checked → brandSurfaceStrong              │
│ ├─ check → brandOnStrong                     │
│ ├─ focus → borderFocus                       │
│ └─ disabled → Disabled Roles                 │
│                                              │
│ EdsDropdown                                  │
│ ├─ trigger → Field-like semantic roles       │
│ ├─ menu → surfaceOverlay                     │
│ └─ item → Interaction / Selected roles       │
│                                              │
│ EdsCard / Dialog / Menu / Sidebar / ...      │
│ └─ 各自记录自己的 Semantic Role Mapping      │
└──────────────────────────────────────────────┘

补充原则：

Component Category（Expression / Field / Choice / Surface）只作为设计指导和 Checklist，
不进入正式数据模型。新增组件时可以参考这些分类寻找共性，但最终仍直接定义该组件自己的
Component Color Recipe。
```

这张图体现的是完整依赖关系：

```text
组件决定“我要什么语义角色”
Theme / ColorScheme 决定“这个语义角色最终是什么颜色”
```

因此：

```text
具体颜色值 ≠ Semantic Role ≠ Component Style
```

三者必须保持分离。

---

# 3. 设计哲学

## 3.1 颜色值、颜色语义、组件样式必须分开

三者不能混为一谈。

例如：

```text
#3185FF
```

只是一个颜色值。

```text
brandSurfaceStrong
```

是一个语义角色。

```text
Primary Button background
```

是组件 Recipe 中的一个槽位。

它们之间应当是：

```text
Theme Seed
→ Semantic Role
→ Component Slot
```

而不是：

```text
Component
→ #3185FF
```

---

## 3.2 Host App 允许改 Theme，不允许破坏组件语义

Host App 可以：

- 修改 Seed
- 覆盖 Semantic Color Scheme
- 调整品牌视觉
- 调整 Surface 层次
- 调整 Focus / Border / Status 的最终颜色

Host App 不应直接定义：

- TextField Focus 要绑定哪个语义 Role
- Checkbox Selected 要绑定哪个语义 Role
- Button Danger 要绑定哪个语义 Role

也就是说：

> Theme 可覆盖，Component Recipe 由 EDS 管理。

---

## 3.3 ColorScheme 2.0 是 Breaking Change

本轮不保留旧 API 兼容层。

明确决定：

```text
primary → brand
```

直接升级。

旧宿主 App 编译失败是可接受的，目标是促使宿主尽快迁移到新 API。

原则：

> 不保护已被认定为不合理或过时的颜色 API。

---

# 4. Theme Seed

Theme Seed 是颜色系统最底层输入。

第一版正式 Seed：

```text
brand
information
success
warning
danger
```

Neutral 不要求宿主必须配置。

Neutral 更适合作为 EDS 默认提供的一组中性色基础，由 Light / Dark 模式自动推导。

---

# 5. 为什么从 primary 升级成 brand

`primary` 容易表达成：

> “第一个主要颜色”

而 EDS 真正想表达的是：

> “产品品牌强调色”

因此 `brand` 更准确。

例如：

```text
brand = #3185FF
```

之后可以自动推导：

```text
brandForeground
brandSurface
brandSurfaceStrong
brandBorder
brandOnStrong
```

`primary` 在 ColorScheme 2.0 实施时直接删除，不保留 Deprecated Alias。

---

# 6. Seed 的职责边界

Seed 只提供“颜色原料”。

Seed 不负责：

- Hover
- Pressed
- Focus
- Selected
- Field Background
- Card Background
- Text Color
- Border Color
- Disabled Color

这些都属于 Semantic Scheme。

Host App 配置一个 Theme 时，普通用法应该非常简单：

```text
brand
information
success
warning
danger
```

剩余颜色由 EDS 自动生成。

---

# 6.1 Neutral Foundation 与默认 Preset

ColorScheme 2.0 明确采用：

```text
Neutral Foundation
+
Chromatic Families
```

的整体视觉模型。

其中：

```text
Neutral Foundation
```

不是单纯指“灰色、黑色、白色”几个颜色，而是 EDS 默认的基础视觉底盘。

它负责：

- 页面与容器的基础 Surface 层次
- 普通文字与图标的 Foreground 层级
- 普通 Border 层级
- Disabled 状态
- 不承担 Brand / Status 语义的基础交互视觉

也就是说，Neutral Foundation 的核心含义是：

> **不承担品牌、状态或特殊语义的默认 UI 视觉基础。**

它最终通常会以中性色为主，但设计定义不应被简化为“灰色 Palette”。

---

# 6.2 运行时不存在“没有 Seed”的状态

EDS 默认必须提供完整 Preset。

例如默认 Blue Preset：

```text
Neutral Foundation
+
Blue Brand Seed
+
Blue Information Seed
+
Green Success Seed
+
Amber Warning Seed
+
Red Danger Seed
```

因此：

> 用户没有显式提供 Seed，并不代表 Theme 没有 Seed，而是继续使用 EDS 默认 Preset 中对应的 Seed。

宿主 Theme 的行为更准确地说是：

```text
EDS Default Preset
        ↓
Host 可按 Family 替换 Seed
        ↓
重新生成对应 Palette
        ↓
重新映射 Semantic Roles
```

例如宿主只提供新的 Brand：

```text
Neutral Foundation  → 保持 EDS 默认
Brand               → 使用 Host Seed
Information         → 保持 EDS 默认
Success             → 保持 EDS 默认
Warning             → 保持 EDS 默认
Danger              → 保持 EDS 默认
```

这意味着多数 Theme 定制只需要改变 Brand，而 Status Families 不应被品牌色污染。

---

# 6.3 Neutral 与 Chromatic Roles 的来源关系

从视觉设计角度：

> Neutral Foundation 是整个界面的打底基础，Brand 与 Status Families 是只在需要表达意义时加入的语义着色层。

从实现角度：

> 每一个 Semantic Role 应明确知道自己从哪个 Palette / Foundation 获取颜色，而不是先全部 Neutral 再动态覆盖。

典型映射：

```text
surfacePage
surfaceBase
surfaceRaised
surfaceSunken
surfaceOverlay
foregroundPrimary
foregroundSecondary
foregroundTertiary
foregroundDisabled
borderSubtle
borderDefault
borderStrong
borderDisabled
    ↓
Neutral Foundation
```

而：

```text
brandForeground
brandSurface
brandSurfaceStrong
brandBorder
brandOnStrong
borderFocus
selected semantic roles
active semantic roles
    ↓
Brand Palette
```

Status：

```text
information*
    ↓
Information Palette

success*
    ↓
Success Palette

warning*
    ↓
Warning Palette

danger*
    ↓
Danger Palette
```

---

# 6.4 Focus 与 Selected 的默认语义归属

由于运行时始终存在默认 Brand Seed，因此不再需要设计“没有 Brand 时 Focus / Selected 回退到 Neutral”的分支。

ColorScheme 2.0 第一版明确：

```text
Focus
Selected
Primary Action
Active Navigation
```

默认都属于 Brand 语义。

因此：

```text
borderFocus
→ Brand Palette

Selected component recipe slots
→ 直接使用 brandSurface / brandForeground / brandBorder

第一版不创建独立的 selectedSurface / selectedForeground /
selectedBorder Semantic Tokens，避免与 Brand Roles 重复。

Primary Button
→ Brand Family

Active Navigation
→ Brand Family
```

Neutral 负责普通 Rest 状态与基础结构，Brand 负责品牌与关键交互强调。

---

# 6.5 EDS Theme 的核心视觉原则

ColorScheme 2.0 采用以下总体原则：

> **EDS 使用 Neutral Foundation 构建界面主体，再使用 Brand 与 Status Families 对需要表达交互、品牌和状态意义的位置进行语义化着色。**

这意味着默认 UI 应呈现：

```text
Neutral-dominant UI
+
Semantic Brand Accent
+
Semantic Status Accent
```

而不是：

```text
Brand-driven UI everywhere
```

这是 EDS 面向桌面工具类、生产力类 App 时的基础视觉策略。

---

# 6.6 Seed 到 Semantic Scheme 的初始化方向

ColorScheme 2.0 第一版采用：

```text
Chromatic Seed
    ↓
Perceptual Tonal Palette
    ↓
EDS Semantic Tone Mapping
    ↓
Semantic Color Scheme
```

Neutral Foundation 由 EDS 内置维护，不要求宿主提供 Neutral Seed。

Brand / Information / Success / Warning / Danger 则：

```text
Default Seed 或 Host Seed
    ↓
生成对应 Tonal Palette
    ↓
通过固定 Light / Dark Tone Mapping
    ↓
得到对应 Semantic Family
```

第一版不再使用：

```text
baseColor.withOpacity(...)
```

作为主要 Semantic Color 生成方法。

具体 Tone Mapping 表和 Palette Generator 属于技术方案阶段需要进一步确定的实现细节。

---

# 7. Semantic Color Scheme 总览

ColorScheme 2.0 第一版分为以下几组：

```text
Surface
Foreground
Border
Brand
Information
Success
Warning
Danger
Interaction
Layer / Context
```

其中 Status Family：

```text
information
success
warning
danger
```

采用一致的结构。

---

# 8. Surface Roles

Surface 回答：

> 这个区域在视觉空间中属于哪一层？

第一版定义：

```text
surfacePage
surfaceBase
surfaceRaised
surfaceSunken
surfaceOverlay
surfaceDisabled
```

---

## 8.1 surfacePage

页面最底层背景。

典型场景：

- App 主窗口背景
- 设置页页面背景
- 普通页面根 Surface

---

## 8.2 surfaceBase

普通内容 Surface。

典型场景：

- Page 内普通内容区域
- 不强调 elevation 的容器
- 基础 Section

---

## 8.3 surfaceRaised

视觉上高于 Base 的 Surface。

典型场景：

- Card
- Panel
- Group
- 某些强调区块

---

## 8.4 surfaceSunken

视觉上“嵌入”的 Surface。

典型场景：

- TextField
- Dropdown Field
- Search Field
- Well
- 输入区域

---

## 8.5 surfaceOverlay

浮在正常内容层之上的 Surface。

典型场景：

- Menu
- Popover
- Tooltip
- Floating Panel
- Dialog Surface

---

## 8.6 surfaceDisabled

禁用控件或禁用区域使用的 Surface。

它与 `surfaceSunken`、`surfaceBase` 不同，因为 Disabled 是交互语义，而不是层级语义。

---

# 9. Foreground Roles

Foreground 用于：

- Text
- Icon
- Symbol
- Control Content

第一版定义：

```text
foregroundPrimary
foregroundSecondary
foregroundTertiary
foregroundDisabled
foregroundInverse
```

---

## 9.1 foregroundPrimary

主要信息。

例如：

- 标题
- 正文
- 主要 Icon
- Setting Label

---

## 9.2 foregroundSecondary

次级信息。

例如：

- Subtitle
- Description
- 辅助图标

---

## 9.3 foregroundTertiary

弱信息。

例如：

- Placeholder
- Metadata
- Hint
- 非重要辅助信息

---

## 9.4 foregroundDisabled

禁用状态专用。

不能简单等同于 `foregroundTertiary`。

“弱信息”和“不可用”是两个不同语义。

---

## 9.5 foregroundInverse

用于强色 Surface 上的内容。

例如：

```text
brandSurfaceStrong
dangerSurfaceStrong
successSurfaceStrong
```

上的文字和图标。

组件内部应尽量避免直接使用：

```dart
Colors.white
```

而改为语义化的：

```text
foregroundInverse
```

或对应 Family 的 `onStrong`。

---

# 10. Border Roles

当前 EDS 的单一 `border` 不足以表达控件状态。

ColorScheme 2.0 第一版定义：

```text
borderSubtle
borderDefault
borderStrong
borderSelected
borderFocus
borderDisabled
borderDanger
```

---

## 10.1 borderSubtle

用于轻量分隔。

例如：

- Divider
- Card 内部轻分割线
- 不需要强调的边缘

---

## 10.2 borderDefault

普通控件边界。

例如：

- TextField Rest
- Dropdown Rest
- Pill Rest

---

## 10.3 borderStrong

需要更明确辨识度的边界。

例如：

- Checkbox Unchecked
- Radio Unselected
- 重要输入区域

---

## 10.4 borderSelected

选中状态。

用于：

- Choice Control
- Selected Item
- Selected Pill

---

## 10.5 borderFocus

键盘 Focus 和输入 Focus。

用于：

- TextField
- Dropdown
- Button Focus Ring
- Checkbox
- Radio
- Menu Item

---

## 10.6 borderDisabled

禁用组件边界。

---

## 10.7 borderDanger

Validation Error / Invalid State。

---

# 11. Brand Family

Brand 不是一个单独颜色，而是一组语义角色。

第一版：

```text
brandForeground
brandSurface
brandSurfaceStrong
brandBorder
brandOnStrong
```

---

## 11.1 brandForeground

用于：

- Brand Text
- Brand Icon
- Link
- Selected Text

---

## 11.2 brandSurface

浅 Brand Surface。

用于：

- Selected Pill
- Selected Segment
- Soft Brand Banner
- Selected Row

---

## 11.3 brandSurfaceStrong

强 Brand Surface。

用于：

- Primary Button
- 强选中控件
- 重要 Brand Action

---

## 11.4 brandBorder

Brand 语义边框。

---

## 11.5 brandOnStrong

强 Brand Surface 上的文字和 Icon。

---

# 12. Status Family 统一结构

Information / Success / Warning / Danger 采用统一结构：

```text
{tone}Foreground
{tone}Surface
{tone}SurfaceStrong
{tone}Border
{tone}OnStrong
```

---

# 13. Information

定义：

```text
informationForeground
informationSurface
informationSurfaceStrong
informationBorder
informationOnStrong
```

典型用途：

- 普通提示
- 信息 Banner
- 非错误类提示
- 系统说明
- 中性但需要强调的 Message

---

# 14. Success

定义：

```text
successForeground
successSurface
successSurfaceStrong
successBorder
successOnStrong
```

典型用途：

- 成功 Badge
- 完成状态
- 成功 Banner
- Done Button
- Success Result

---

# 15. Warning

定义：

```text
warningForeground
warningSurface
warningSurfaceStrong
warningBorder
warningOnStrong
```

典型用途：

- 警告提示
- 风险操作
- Warning Badge
- Warning Banner

---

# 16. Danger

定义：

```text
dangerForeground
dangerSurface
dangerSurfaceStrong
dangerBorder
dangerOnStrong
```

典型用途：

- Error Text
- Invalid Field
- Destructive Button
- Error Banner
- Danger Badge

---

# 17. Interaction State

第一版支持以下统一状态：

```text
rest
hover
pressed
selected
focused
disabled
```

但不建议把所有状态全部展开成公开字段，例如：

```text
brandSurfaceHover
brandSurfacePressed
dangerSurfaceHover
dangerSurfacePressed
surfaceRaisedHover
...
```

这会导致 Token 爆炸。

---

# 18. Interaction Resolver

ColorScheme 2.0 采用统一 Resolver 思路。

概念 API：

```text
resolveState(
  role,
  state,
)
```

例如：

```text
resolveState(
  brandSurfaceStrong,
  hovered,
)
```

得到 Brand Strong Surface 的 Hover 颜色。

---

# 19. Resolver 的设计原则

对外：

- 一个统一 State Resolver
- Component 不自己写 `Color.lerp`
- Component 不自己写固定 alpha

内部：

- Neutral 可以有自己的 State Mapping
- Brand 可以有自己的 State Mapping
- Danger 可以有自己的 State Mapping
- Warning 可以有自己的 State Mapping
- Success 可以有自己的 State Mapping
- Information 可以有自己的 State Mapping

也就是说：

> API 统一，但算法不强迫统一。

---

# 20. 为什么不直接使用统一 opacity

不同颜色、不同 Brightness 下，单纯：

```text
+ 8% black
+ 8% white
```

并不一定都能产生好的视觉结果。

因此 Resolver 可以默认提供算法推导，但应允许 Semantic Scheme 或 Theme 内部做更精确映射。

---

# 21. Semantic Scheme 必须允许 Host Override

默认路径：

```text
Theme Seed
→ EDS 自动生成 Semantic Scheme
```

高级路径：

```text
Theme Seed
→ 默认 Scheme
→ Host Override
```

例如宿主应该可以覆盖：

```text
surfaceRaised
surfaceOverlay
borderFocus
brandSurface
dangerForeground
foregroundSecondary
```

这是正式要求。

---

# 22. Host Override 的边界

允许：

```text
修改某个 Semantic Role 最终是什么颜色
```

不允许：

```text
重新定义某个 EDS 组件该消费哪个 Semantic Role
```

例如 Host 可以说：

```text
borderFocus = 某个紫色
```

但不允许说：

```text
EdsTextField.focusBorder = successBorder
```

这保证：

> Theme 自由，组件语义稳定。

---

# 23. Layer / Context 正式进入 2.0

ColorScheme 2.0 第一版正式考虑 Context。

目标：

> 同一个组件放在不同 Surface Layer 中，仍然能保持清晰层次。

---

# 24. Layer 模型

第一版建议至少表达：

```text
Layer 0
Layer 1
Layer 2
Overlay
```

概念上：

```text
Layer 0
→ Page

Layer 1
→ Card / Group / Raised Panel

Layer 2
→ Nested Surface

Overlay
→ Dialog / Menu / Popover
```

最终 API 命名可在实现阶段调整，但 Context 能力必须进入本轮设计。

---

# 25. Layer 的核心目的

解决：

```text
Page
  └─ Card
      └─ TextField
```

如果：

```text
Page = white
Card = white
TextField = white
```

即使都有 Border，也容易失去空间层次。

Layer Context 应允许：

```text
TextField on Page
≠
TextField inside Raised Card
```

最终可能表现为：

- Field Surface 变化
- Border 强弱变化
- Raised Surface 变化

而不是组件硬编码一套颜色。

---

# 26. Layer 推导原则

Layer 不是新的 Theme Seed。

Layer 是上下文。

概念流程：

```text
Semantic Role
+
Current Layer
+
Brightness
+
Interaction State
=
Resolved Color
```

例如：

```text
surfaceSunken
+
Layer 1
+
Dark
+
Rest
```

最终得到一个具体颜色。

---

# 27. Component Recipe

Component Recipe 是第三层。

每一个 EDS 组件都应明确记录：

- 有哪些颜色槽位
- 每个槽位绑定哪个 Semantic Role
- 不同 State 下如何切换
- 是否受 Layer 影响

Recipe 由 EDS 管理。

第一版不把 Component Recipe 暴露为宿主可配置对象。

---

# 28. Component Recipe 不公开的原因

如果公开：

```text
EdsTextFieldColorRecipe
EdsCheckboxColorRecipe
EdsButtonColorRecipe
```

宿主就很容易重新定义：

- TextField Focus 的语义
- Checkbox Selected 的语义
- Button Danger 的语义

最终 EDS 会退化成：

> 一套默认组件皮肤。

而不是：

> 一套有稳定视觉语言的 Design System。

---

# 29. 组件分类只作为设计指导

虽然不进入正式三层模型，但设计新组件时可以参考这些常见类型。

---

## 29.1 Expression 型组件

典型：

- Button
- Badge
- Pill
- Banner
- Callout

通常关注：

- Tone
- Emphasis
- Surface
- Foreground
- Border
- Hover
- Pressed
- Disabled
- Focus

---

## 29.2 Field 型组件

典型：

- TextField
- Dropdown
- Search

通常关注：

- Surface
- Text
- Placeholder
- Border
- Hover
- Focus
- Error
- Disabled
- Layer

---

## 29.3 Choice 型组件

典型：

- Checkbox
- Radio
- Segmented
- ChoicePill
- Selectable Row
- Slider

通常关注：

- Rest
- Selected
- Hover
- Pressed
- Focus
- Disabled

---

## 29.4 Surface 型组件

典型：

- Page
- Card
- Group
- Dialog
- Menu
- Popover
- Tooltip

通常关注：

- Surface Layer
- Overlay
- Border
- Foreground Hierarchy
- Context

这些分类是 Checklist，不是继承体系。

---

# 30. Button Recipe

Button 已经有：

```text
Tone × Emphasis
```

ColorScheme 2.0 保留这个思想，但底层颜色不再自行推导。

Tone 第一版：

```text
brand
neutral
information
success
warning
danger
```

其中旧的：

```text
accent
```

应升级为：

```text
brand
```

同样不保留旧命名。

---

# 31. Button Emphasis

可继续保留现有：

```text
filled
medium
outline
soft
plain
```

但重新解释为 Semantic Recipe。

例如：

## filled

```text
background = toneSurfaceStrong
foreground = toneOnStrong
```

## soft

```text
background = toneSurface
foreground = toneForeground
```

## outline

```text
background = transparent
foreground = toneForeground
border = toneBorder / borderDefault
```

## plain

```text
background = transparent
foreground = toneForeground
```

Hover / Pressed 统一走 Interaction Resolver。

---

# 32. TextField Recipe

建议：

```text
Rest
surface       = surfaceSunken
text          = foregroundPrimary
label         = foregroundSecondary
placeholder   = foregroundTertiary
border        = borderDefault

Hover
border        = borderStrong
surface       = resolveState(surfaceSunken, hover)

Focus
border        = borderFocus

Error
border        = dangerBorder
message       = dangerForeground

Disabled
surface       = surfaceDisabled
text          = foregroundDisabled
border        = borderDisabled
```

并受 Layer Context 影响。

---

# 33. Dropdown Recipe

Dropdown Trigger：

```text
按 Field Recipe
```

Dropdown Menu：

```text
surface = surfaceOverlay
border = borderSubtle
```

Menu Item：

```text
text = foregroundPrimary
hover = Interaction Resolver
selected surface = brandSurface
selected foreground = brandForeground
disabled = foregroundDisabled
```

这说明：

> 一个 Concrete Component 可以同时消费多个语义角色，不需要强行只属于某个分类。

---

# 34. Checkbox Recipe

```text
Unchecked
surface    = transparent
border     = borderStrong

Checked
surface    = brandSurfaceStrong
foreground = brandOnStrong
border     = brandBorder

Hover
state      = Interaction Hover

Pressed
state      = Interaction Pressed

Focus
border     = borderFocus

Disabled
surface    = surfaceDisabled / transparent
foreground = foregroundDisabled
border     = borderDisabled
```

---

# 35. Radio Recipe

Radio 与 Checkbox 使用一致的选择语义：

```text
Unselected
border = borderStrong

Selected
foreground / indicator = brandForeground or brandSurfaceStrong

Focus
border / ring = borderFocus

Disabled
foreground = foregroundDisabled
border = borderDisabled
```

---

# 36. Segmented Recipe

```text
Unselected
surface = surfaceBase
foreground = foregroundSecondary
border = borderDefault

Selected
surface = brandSurface
foreground = brandForeground
border = borderSelected

Hover
Interaction Resolver

Disabled
foreground = foregroundDisabled
```

---

# 37. Slider Recipe

```text
inactiveTrack = borderDefault / subtle semantic track
activeTrack = brandSurfaceStrong / brandForeground
thumb = brandSurfaceStrong
focus = borderFocus / focus ring
disabled = Disabled Roles
```

Slider 最终是否需要独立的 Track Semantic Role，可在 Catalog 验证后决定。

如果只有 Slider 需要，不应轻易扩大 Semantic Scheme。

---

# 38. Pill Recipe

普通 Tag/Pill：

```text
surface = surfaceRaised / subtle neutral surface
foreground = foregroundSecondary
border = borderSubtle
```

ChoicePill：

```text
Rest
surface = surfaceBase
foreground = foregroundSecondary
border = borderDefault

Selected
surface = brandSurface
foreground = brandForeground
border = brandBorder
```

---

# 39. Badge Recipe

Badge 属于表达型组件。

建议支持：

```text
neutral
brand
information
success
warning
danger
```

Soft Badge：

```text
surface = toneSurface
foreground = toneForeground
```

Strong Badge：

```text
surface = toneSurfaceStrong
foreground = toneOnStrong
```

---

# 40. Card / Group Recipe

Card：

```text
surface = surfaceRaised
foreground = foregroundPrimary
border = borderSubtle
```

Group 是否与 Card 使用相同 Surface，要在 Catalog 中比较。

如果 Group 是“同层内容组织”，可能使用：

```text
surfaceBase
```

如果 Group 是视觉容器，则可以使用：

```text
surfaceRaised
```

最终应明确，不由业务页面自行决定。

---

# 41. Dialog Recipe

```text
surface = surfaceOverlay
title = foregroundPrimary
content = foregroundSecondary
border = borderSubtle
```

Actions 继续走 Button Recipe。

Dialog 本身不直接硬编码 Brand。

---

# 42. Menu Recipe

```text
surface = surfaceOverlay
foreground = foregroundPrimary
secondaryForeground = foregroundSecondary
border = borderSubtle

itemHover
= Interaction Resolver

itemSelected
= brandSurface + brandForeground

itemDisabled
= foregroundDisabled
```

---

# 43. Sidebar Recipe

Sidebar Container：

```text
surface = surfaceBase / Raised
```

Item Rest：

```text
foreground = foregroundSecondary
```

Item Hover：

```text
Interaction Resolver
```

Item Selected：

```text
surface = brandSurface
foreground = brandForeground
```

Focus：

```text
border / ring = borderFocus
```

---

# 44. Error State / Banner Recipe

Error State：

```text
icon = dangerForeground
title = foregroundPrimary
message = foregroundSecondary
action = Button Recipe
```

Warning Banner：

```text
surface = warningSurface
foreground = warningForeground
border = warningBorder
```

Information Banner：

```text
surface = informationSurface
foreground = informationForeground
border = informationBorder
```

---

# 45. Neutral 是否需要独立 Family

第一版暂不要求公开：

```text
neutralForeground
neutralSurface
neutralBorder
```

Neutral 主要由：

- Surface
- Foreground
- Border

三套基础角色承担。

如果未来 Expression Component 明确需要：

```text
Tone.neutral
```

则 Neutral Tone Recipe 可以映射到现有基础 Role：

```text
neutral soft
→ surfaceRaised / foregroundPrimary / borderDefault

neutral strong
→ foregroundPrimary-based strong surface / foregroundInverse
```

无需立即创建一整套 Neutral Family。

---

# 46. Light / Dark 推导原则

ColorScheme 2.0 不应只是：

```text
Light = 白底黑字
Dark = 黑底白字
```

而应保证：

- Surface 层级在两种模式下都可辨识
- Foreground 对比度稳定
- Brand / Status 在 Dark Mode 下不刺眼
- Border 在 Dark Mode 下不消失
- Overlay 与 Raised Surface 有明确层次
- Disabled 明显但仍可识别
- Focus 足够清楚

---

# 47. 对比度原则

所有核心前景/背景配对应以 WCAG AA 为最低设计目标。

重点验证：

```text
foregroundPrimary / Surface
foregroundSecondary / Surface
brandOnStrong / brandSurfaceStrong
dangerOnStrong / dangerSurfaceStrong
successOnStrong / successSurfaceStrong
warningOnStrong / warningSurfaceStrong
informationOnStrong / informationSurfaceStrong
```

小文字通常以 4.5:1 为目标。

关键非文字控件边界、Focus Indicator 等通常以 3:1 为参考目标。

---

# 48. Semantic Scheme Override API 原则

高级宿主必须可以：

```text
Seed
+
Semantic Overrides
```

而不是只能二选一。

概念上：

```dart
EdsTheme(
  brand: ...,
  semanticOverrides: ...
)
```

具体 API 实现以后再定。

重点是：

> 默认自动生成，高级用户只覆盖需要覆盖的 Role。

---

# 49. JSON Theme Schema

ColorScheme 2.0 会成为 Breaking Change，因此 JSON Schema 也可以同步升级。

不要求继续兼容旧：

```text
primary
accent
```

旧主题文件应在宿主升级时显式迁移。

新 Schema 应至少能表达：

```text
seed
semanticOverrides
```

以及未来可能需要的：

```text
interactionOverrides
layerOverrides
```

但应避免 Schema 变成“每个组件一个颜色字段”。

---

# 50. Component Recipe 设计规则

新增组件时必须先完成 Color Recipe 设计。

每个组件至少回答：

1. 它有哪些颜色槽位？
2. Rest 状态使用哪些 Semantic Roles？
3. Hover 怎么处理？
4. Pressed 怎么处理？
5. Focus 怎么处理？
6. Selected 是否存在？
7. Disabled 怎么处理？
8. Error / Warning 是否存在？
9. 是否受 Layer Context 影响？
10. 是否真的需要新的 Semantic Role？

---

# 51. 新增 Semantic Role 的门槛

不能因为一个组件“想要一个特殊灰色”就增加 Token。

只有当新颜色角色满足：

> **多个组件、多个场景都能明确理解并复用**

时，才应该进入 Semantic Scheme。

否则应优先：

- 使用现有 Role
- 使用 Component 内部 Recipe
- 使用 Interaction Resolver
- 使用 Layer Context

---

# 52. Breaking Change 策略

本次明确采取：

> 一次升级，不做过渡兼容。

预计会导致：

- `primary` 编译失败
- `accent` 相关旧概念移除
- `textPrimary` 等旧 Semantic Role 可能更名
- `pageBackground` / `cardBackground` 等旧 Surface API 重构
- 旧组件内部颜色实现全部迁移
- 旧 JSON Theme Schema 需要迁移
- Host App 必须跟进

这是预期行为。

---

# 53. 实施策略：代码一步到位

本设计不采用“先部分兼容、再逐步删除”的策略。

目标实施流程：

```text
设计文档确认
      ↓
重构 Theme Seed
      ↓
实现 Semantic Color Scheme 2.0
      ↓
实现 Interaction Resolver
      ↓
实现 Layer / Context
      ↓
一次迁移所有 EDS 组件
      ↓
重做 Color Catalog
      ↓
Light / Dark / Theme 验证
      ↓
flutter analyze / test
      ↓
发布 Breaking Version
      ↓
RightClickMate / VideoHero 跟进新 API
```

---

# 54. 为什么代码也选择一步到位

当前 EDS 的实际宿主主要由同一开发者控制。

因此相比长期维护：

- 旧 API
- 新 API
- Deprecated Alias
- 两套 Theme Schema
- 两套 Component Recipe

更合理的是：

> 趁 1.0 之前彻底修正基础架构。

本轮允许宿主编译失败，以换取更干净的长期 API。

---

# 55. Catalog 是 ColorScheme 2.0 的核心验证工具

本轮不能只依赖 Unit Test。

必须新增专门的 Color Catalog。

至少展示：

## Theme Seed

- Blue Brand
- Orange Brand
- Purple Brand

## Brightness

- Light
- Dark

## Semantic Roles

- Surface
- Foreground
- Border
- Brand
- Information
- Success
- Warning
- Danger

## Interaction

- Rest
- Hover
- Pressed
- Selected
- Focus
- Disabled

## Context

- Field on Page
- Field on Card
- Field in Nested Surface
- Menu / Dialog Overlay

---

# 56. Catalog 必须验证的组件

至少：

```text
Button
Badge
Pill
ChoicePill

TextField
Dropdown
Checkbox
Radio
Segmented
Slider

Card
Group
Sidebar

Dialog
Menu

Empty / Error / Loading / Progress
```

---

# 57. ColorScheme 2.0 的成功标准

实现完成后应满足：

### Theme

只改 `brand`，整个 App 的品牌相关视觉自然变化。

### Dark Mode

不需要组件自己单独写 Dark Color。

### Interaction

组件不自己临时计算 Hover / Pressed Color。

### Layer

Field 放在 Page 与 Raised Surface 中仍然保持清晰层级。

### Status

Information / Success / Warning / Danger 具有统一视觉语言。

### Override

Host 可以调整 Theme，但不需要修改组件源码。

### Component

每个组件有明确 Recipe，而不是边开发边挑颜色。

---

# 58. 最终原则

ColorScheme 2.0 最核心的原则可以浓缩为以下几句。

> **Seed 是颜色原料。**

> **Semantic Scheme 是 EDS 的颜色语言。**

> **Component Recipe 是组件如何说这门语言。**

> **Host 可以修改这门语言中每个词最终呈现的颜色，但不能随意改变组件说的是什么词。**

> **状态变化属于 Design System，不属于组件临时算法。**

> **Layer 是颜色语义的一部分，而不是纯布局概念。**

> **新增组件时，优先复用 Semantic Roles，而不是新增颜色。**

---

# 59. 当前已拍板事项

- [x] Neutral Foundation 是 EDS 基础视觉底盘，不等同于“简单灰色”
- [x] 运行时始终存在完整默认 Preset，不存在“没有 Seed”的 Theme
- [x] Host 未覆盖的 Seed Family 继续使用 EDS 默认 Preset
- [x] Focus / Selected / Primary Action / Active Navigation 默认属于 Brand 语义
- [x] Surface / 普通 Foreground / 普通 Border 主要来自 Neutral Foundation
- [x] Brand / Information / Success / Warning / Danger 各自从独立 Palette 获取颜色
- [x] Theme 采用 Neutral-dominant + Semantic Accent 的整体视觉策略
- [x] Seed → Tonal Palette → Semantic Tone Mapping 作为初始化主方向
- [x] Neutral Foundation 不要求宿主提供 Neutral Seed
- [x] 不再以 alpha / opacity 派生作为核心语义色生成方案


截至 2026-09-27，以下事项已经明确：

- [x] 采用三层模型：Seed → Semantic Scheme → Component Recipe
- [x] Component Category 仅作为设计指导，不进入核心模型
- [x] `primary` 正式升级为 `brand`
- [x] 不保留旧 `primary` 兼容 API
- [x] Semantic Scheme 允许 Host Override
- [x] Interaction 采用统一 Resolver 思路
- [x] Resolver 内部允许不同 Color Family 使用不同算法
- [x] Layer / Context 进入 ColorScheme 2.0 第一版
- [x] 实施时一次完成，不延期到后续版本
- [x] `information` 正式进入 Status Family
- [x] Component Recipe 由 EDS 管理，不作为宿主公开配置层
- [x] ColorScheme 2.0 允许 Breaking Change
- [x] 旧 JSON Theme Schema 不要求兼容
- [x] 所有组件最终统一迁移到新颜色体系

---

# 60. 下一轮讨论重点

虽然总体架构已经确定，但真正开始编码前仍建议逐项审查：

1. Semantic Role 最终命名是否需要调整
2. Surface 六级是否过多或过少
3. Layer 0 / 1 / 2 / Overlay 的具体解析规则
4. Interaction Resolver 的输入输出 API
5. Brand / Status Family 的具体生成算法
6. Light / Dark 默认色阶
7. Warning OnStrong 是否需要特殊前景策略
8. Focus Ring 与 Focus Border 是否需要拆分
9. Slider Track 是否需要独立 Semantic Role
10. Sidebar 是否应有独立 Navigation Recipe
11. Dialog 与 Menu 是否共享同一个 Overlay Surface
12. Semantic Override 的 Dart API 与 JSON Schema

这些属于 Draft 1 之后的“参数与实现设计”，不影响当前三层架构。

---

# 61. 一句话总结

> **EDS ColorScheme 2.0 的目标不是给每个组件挑一套更好看的颜色，而是建立一门稳定的色彩语言，让所有组件都能通过同一套语义体系正确表达自己的状态、层级和用途。**
