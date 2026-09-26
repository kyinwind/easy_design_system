
# EDS ColorScheme 2.0 API 设计规范 Draft 1

日期：2026-09-27  
状态：API 设计草案  
依赖设计：docs/20260927_EDS_ColorScheme_2.0_设计规范_Draft1.md

---

# 1. 文档目标

本文件只讨论 ColorScheme 2.0 对宿主 App 暴露的 API。

核心目标：

1. 普通开发者只需要很少参数就能获得完整 EDS 视觉。
2. 高级宿主可以修改 Theme Seed 与 Semantic Color。
3. 单个组件 API 只表达“语义意图”，不暴露任意颜色定制能力。
4. Easy API 保持简单。
5. EDS 不提供“把某个组件改成任意皮肤”的组件级覆盖 API。
6. 如果宿主需要一个脱离 EDS 设计语言的特殊组件，直接使用 Flutter 原生组件。

最终 API 分为三类：

    1. Theme 初始化 / Theme 配置 API
    2. Easy API
    3. Concrete Component API

明确不提供第四类：

    4. Component Visual Override API   ← 不提供

---

# 2. API 总体原则

ColorScheme 2.0 的 API 必须贯彻三层架构：

    Theme Seed
        ↓
    Semantic Color Scheme
        ↓
    Component Recipe

对应到宿主开发者能操作的边界：

宿主可以配置：

- Preset
- Seed
- Semantic Override

宿主可以选择：

- 组件的语义参数
- 组件状态与业务行为参数

宿主不能配置：

- 某个组件具体绑定哪个 Semantic Role
- 某个组件 Hover 时临时换成某个任意颜色
- 某个组件 Pressed / Focus / Selected 的任意视觉 Recipe

一句话：

> 宿主可以改 Theme，可以表达组件意图，但不能重写 EDS Component Recipe。

---

# 3. 第一类 API：Theme 初始化

Theme 初始化面向两类用户：

## 普通用户

只使用 EDS 默认 Preset，甚至零配置。

## 高级用户

覆盖：

- Brand / Status Seeds
- Semantic Color Roles
- 其他非颜色 Design Tokens

---


# 3.1 Theme API 不只有 Color

ColorScheme 2.0 只重构 Theme 中的颜色部分。

现有以下非颜色 Design Token API 继续保留：

- EdsSpacingTokens
- EdsRadiusTokens
- EdsTypographyTokens
- EdsControlSizeTokens
- EdsAdaptiveLayoutTokens
- EdsHeroGradient
- EdsStrokeTokens
- EdsShadowTokens

Host App 仍然可以像现在一样通过 Theme 配置这些值。

例如概念上仍应支持：

    theme.tokens.copyWith(
      spacing: theme.tokens.spacing.copyWith(
        lg: 22,
      ),
      adaptiveLayout: theme.tokens.adaptiveLayout.copyWith(
        readableContentMaxWidth: 960,
      ),
    )

ColorScheme 2.0 不应迫使宿主把 spacing / radius / typography 等迁移到另一套新 API。

它们与新的 Color API 一起组成完整 EDS Theme。

因此完整 Theme Configuration 应理解为：

    EdsThemeData
    ├─ seeds
    ├─ semanticOverrides
    └─ tokens
       ├─ spacing
       ├─ radius
       ├─ typography
       ├─ controlSize
       ├─ adaptiveLayout
       ├─ heroGradient
       ├─ stroke
       └─ shadow

---

# 4. 默认初始化：零配置

EDS 必须开箱即用。

即使宿主不配置任何颜色，也存在完整默认 Preset：

    Default Blue Preset

    Neutral Foundation
    +
    Blue Brand
    +
    Blue Information
    +
    Green Success
    +
    Amber Warning
    +
    Red Danger

因此最简单使用方式应该仍然成立：

    EdsThemeScope(
      child: MyApp(),
    )

此时自动使用 EDS 默认主题。

---

# 5. Preset 初始化

宿主可以明确选择 Preset：

    EdsThemeScope(
      preset: EdsPresetTheme.blue,
      child: MyApp(),
    )

未来可以存在：

- blue
- purple
- orange
- ...

Preset 的职责是：

- 提供完整默认 Seeds
- 提供必要的非颜色 Tokens
- 提供稳定的开箱即用视觉

---

# 6. Seed 初始化 API

宿主最常见的 Theme 定制是：

> 只改变 Brand。

因此 Seed API 必须很轻。

概念 API：

    EdsThemeScope(
      seeds: EdsColorSeeds(
        brand: Color(0xFF7C4DFF),
      ),
      child: MyApp(),
    )

没有提供的 Seed Family 继续继承当前 Preset。

例如只传：

    EdsColorSeeds(
      brand: myPurple,
    )

实际效果：

    brand       = Host Purple
    information = Preset Information
    success     = Preset Success
    warning     = Preset Warning
    danger      = Preset Danger

---

# 7. EdsColorSeeds

第一版公开 Seed：

    EdsColorSeeds(
      brand: ...,
      information: ...,
      success: ...,
      warning: ...,
      danger: ...,
    )

这些参数应允许部分传入。

原因：

> Host 不应该为了只修改 Brand，被迫重复配置全部 Status Seeds。

Neutral 不作为 Seed 参数。

Neutral Foundation 由 EDS 内置维护。

---

# 8. Seed 的解析流程

概念流程：

    Preset Seeds
        ↓
    Host Seed Overrides
        ↓
    Resolved Seeds
        ↓
    Tonal Palette Generator
        ↓
    Semantic Tone Mapping
        ↓
    Semantic Color Scheme

宿主 API 不接触：

- Tone 40
- Tone 80
- Palette Step
- HCT / OKLCH
- Palette Generator

这些属于 EDS 内部实现。

---

# 9. Semantic Override API

仅有 Seed 不足以覆盖所有宿主视觉需求。

例如某个产品可能希望：

- Card 更亮
- Overlay 更深
- Focus 更强
- Secondary Text 更弱
- Border 更明显

这些并不是新的 Brand Seed，而是：

> 对具体 Semantic Role 的高级 Theme 调整。

因此 ColorScheme 2.0 正式允许 Semantic Override。

---

# 10. Semantic Override 不等于 Component Override

允许：

    surfaceRaised = ...
    borderFocus = ...
    foregroundSecondary = ...
    brandSurface = ...
    dangerForeground = ...

不允许：

    EdsButton.hoverColor = ...
    EdsTextField.focusColor = ...
    EdsCheckbox.checkedColor = ...

区别：

    Semantic Override
    → 调整整套 Theme 中一个“词”的视觉值

    Component Override
    → 单独改某个组件说什么“词”

前者允许，后者不提供。

---

# 11. Semantic Override 必须支持 Light / Dark

一个 Semantic Role 在 Light 与 Dark 中通常不应共享同一个固定 Color。

因此不建议只设计成：

    EdsSemanticOverrides(
      surfaceRaised: Color(...),
    )

更合理的是显式区分 Brightness。

概念 API：

    EdsSemanticOverrides(
      light: EdsSemanticColorsOverride(
        surfaceRaised: ...,
        borderFocus: ...,
      ),
      dark: EdsSemanticColorsOverride(
        surfaceRaised: ...,
        borderFocus: ...,
      ),
    )

没有覆盖的 Role：

> 继续使用 Seed + Palette + Semantic Mapping 自动生成值。

---

# 12. Semantic Override 应允许部分覆盖

宿主不应该被要求传一整套 Scheme。

例如只覆盖两个角色：

    EdsSemanticOverrides(
      light: EdsSemanticColorsOverride(
        surfaceRaised: Color(...),
        borderStrong: Color(...),
      ),
      dark: EdsSemanticColorsOverride(
        surfaceRaised: Color(...),
        borderStrong: Color(...),
      ),
    )

其他全部继续使用 EDS 默认解析结果。

因此实现层应明确区分：

- Resolved Semantic Colors：字段完整
- Semantic Color Overrides：字段可空

---

# 13. Theme 初始化组合

完整 Theme 初始化概念上应该支持：

    EdsThemeScope(
      preset: EdsPresetTheme.blue,
      seeds: EdsColorSeeds(
        brand: myBrand,
      ),
      semanticOverrides: EdsSemanticOverrides(
        light: EdsSemanticColorsOverride(
          surfaceRaised: myLightCard,
        ),
        dark: EdsSemanticColorsOverride(
          surfaceRaised: myDarkCard,
        ),
      ),
      child: MyApp(),
    )

解析优先级：

    EDS Default Preset
        ↓
    Selected Preset
        ↓
    Host Seed Overrides
        ↓
    Automatic Semantic Generation
        ↓
    Host Semantic Overrides
        ↓
    Final Resolved Theme

---

# 14. Global Theme API

当前 EDS 已经存在 EdsTheme.instance.configure(...)。

ColorScheme 2.0 应继续保留“App 启动时全局配置”能力。

但 Color API 应从旧的：

    tokens.colors.copyWith(primary: ...)

升级成更清楚的配置结构。

概念方向：

    EdsTheme.instance.configure(
      preset: EdsPresetTheme.blue,
      seeds: EdsColorSeeds(
        brand: myBrand,
      ),
      semanticOverrides: ...,
    )

最终 Dart 签名在技术方案阶段结合现有 EdsDesignTokens 决定。

已确定原则：

> Seed 与 Semantic Override 必须是 Theme 的一等配置入口。

---

# 15. Subtree Theme API

EdsThemeScope 继续承担局部 Theme 的职责。

例如某个独立页面需要另一套 Brand：

    EdsThemeScope(
      seeds: EdsColorSeeds(
        brand: anotherBrand,
      ),
      child: FeatureArea(),
    )

它仍然遵守完整的：

    Seed
    → Palette
    → Semantic Scheme
    → Component Recipe

而不是对子组件逐个传颜色。

---

# 16. JSON Theme API

现有 EDS 已经支持：

- configureJsonString
- configureJsonAsset
- exportJsonString

ColorScheme 2.0 应继续保留这套能力。

但 JSON Schema 允许 Breaking Change。

旧 colors.primary / colors.accent 等字段不要求兼容。

---

# 17. 推荐 JSON 结构

ColorScheme 2.0 推荐概念结构：

    {
      "colors": {
        "seeds": {
          "brand": "#3185FF",
          "information": "#3185FF",
          "success": "#27B15A",
          "warning": "#F9B135",
          "danger": "#E54444"
        },
        "semanticOverrides": {
          "light": {
            "surfaceRaised": "#FFFFFF",
            "borderFocus": "#3185FF"
          },
          "dark": {
            "surfaceRaised": "#2A2A2C",
            "borderFocus": "#78AFFF"
          }
        }
      }
    }

没有出现的 Semantic Role：

> 继续由 EDS 自动生成。

---

# 18. JSON 与 Dart API 应保持同构

理想关系：

    EdsColorSeeds
    ↔ JSON colors.seeds

    EdsSemanticOverrides.light
    ↔ JSON colors.semanticOverrides.light

    EdsSemanticOverrides.dark
    ↔ JSON colors.semanticOverrides.dark

这样：

- 导入简单
- 导出简单
- 文档简单
- Host 更容易理解

---


# 18.1 JSON Theme 仍然是完整 Design Token 配置

JSON API 不应被理解成单纯的 ColorScheme 配置。

colors 分支升级到 2.0 后，其他已有顶层分组继续保留：

    spacing
    radius
    typography
    controlSize
    adaptiveLayout
    heroGradient
    stroke
    shadow

这些分组继续沿用现有：

- 字段名
- 默认值
- 缺失回退规则
- fromJson / toJson 语义

因此 ColorScheme 2.0 的 JSON Breaking Change 主要集中在：

    colors

而不是整份 Theme Schema。

---

# 19. Theme API 的使用层级

## Level 0：零配置

什么都不配置：

    Default Preset

## Level 1：品牌定制

只换 Brand：

    EdsColorSeeds(brand: ...)

## Level 2：完整 Seed 定制

替换 Brand + Status Seeds。

## Level 3：Semantic Override

精调 Surface / Foreground / Border / Brand / Status 语义色。

Theme API 到此为止。

---

# 20. 第二类 API：Easy API

Easy API 保留现有设计方向。

目标仍然是：

> 高频页面样式一行调用。

现有 easyDesign / easy style / easy recipe 的总体思路不因 ColorScheme 2.0 改变。

ColorScheme 2.0 改的是 Easy Recipe 底层颜色来源，而不是把 Easy API 变成颜色配置入口。

---

# 21. Easy API 不暴露 Raw Color

Easy API 应继续主要表达：

- Style
- Emphasis
- Semantic Intent
- Layout Intent

而不是：

- backgroundColor
- hoverColor
- pressedColor
- focusColor

ColorScheme 2.0 应让 Easy API 更简单，而不是更复杂。

---

# 22. Easy API 与 ColorScheme 的关系

    用户表达意图
        ↓
    Easy Recipe
        ↓
    Semantic Role
        ↓
    ColorScheme 2.0

Easy API 自己不保存一套组件颜色。

---

# 23. 第三类 API：Concrete Component API

这是 ColorScheme 2.0 对组件 API 最大的影响。

原则：

> 组件公开参数应该表达“组件语义”，而不是表达“组件颜色实现”。

---

# 24. Component Recipe 与 API 的关系

某个组件关注哪些 Semantic Roles，已经由 EDS Component Recipe 决定。

例如 Button 内部 Recipe 关注：

- Tone
- Emphasis
- Foreground
- Surface
- Border
- Interaction
- Focus
- Disabled

宿主不需要知道：

- background 实际绑定 brandSurfaceStrong
- hover 实际由 Resolver 生成
- focus 实际绑定 borderFocus

宿主只需要通过 API 说明：

> 这个 Button 想表达什么。

---

# 25. EdsButton API

推荐继续使用语义参数：

    EdsButton(
      '保存',
      tone: EdsButtonTone.brand,
      emphasis: EdsButtonEmphasis.filled,
      onPressed: save,
    )

tone 决定 Color Family：

- brand
- neutral
- information
- success
- warning
- danger

emphasis 决定该 Family 的视觉强度与 Recipe：

- filled
- medium
- outline
- soft
- plain

---

# 26. EdsButton 不应提供的参数

ColorScheme 2.0 后不提供：

- backgroundColor
- foregroundColor
- hoverColor
- pressedColor
- focusColor
- disabledColor
- borderColor

因为这些都已经由：

    Tone
    +
    Emphasis
    +
    State
    +
    Theme

完整决定。

---

# 27. Button 示例

    EdsButton(
      '删除',
      tone: EdsButtonTone.danger,
      emphasis: EdsButtonEmphasis.filled,
      onPressed: delete,
    )

EDS 内部已经知道：

    rest
    → dangerSurfaceStrong + dangerOnStrong

    hover
    → Interaction Resolver

    pressed
    → Interaction Resolver

    focus
    → Focus Recipe

    disabled
    → Disabled Roles

宿主不参与颜色计算。

---

# 28. TextField API

TextField 的公开参数应该表达：

- 内容
- 输入行为
- Validation
- 状态

例如：

    EdsTextField(
      controller: controller,
      label: '名称',
      hint: '请输入名称',
      errorText: error,
    )

而不提供：

- fillColor
- hoverFillColor
- focusedBorderColor
- errorBorderColor
- hintColor
- labelColor

这些由 TextField Recipe 决定。

---

# 29. Checkbox / Radio API

宿主表达：

- value
- onChanged
- enabled
- label
- semantic information

而不是：

- checkedColor
- uncheckedColor
- hoverColor
- focusColor

选中状态已经具有确定的 Brand Recipe。

---

# 30. Choice / Segmented / Pill API

同样遵循：

宿主表达：

- 是否选中
- Tone（仅当组件本身有 Tone 语义）
- Emphasis（仅当组件本身需要）
- 行为

EDS 决定：

- Surface
- Foreground
- Border
- Hover
- Pressed
- Focus
- Disabled

---

# 31. 并非所有组件都需要 Tone

不能为了 API 统一而给所有组件增加 tone。

例如：

- TextField
- Dropdown
- Checkbox
- Radio

通常不应该支持：

- success TextField
- danger Checkbox
- warning Dropdown

除非该语义本身有明确产品需求。

因此：

> Component Recipe 决定组件公开哪些“语义选择参数”。

---

# 32. Component API 的设计检查表

新增组件时 API 设计需要先回答：

1. 哪些视觉语义是组件固定的？
2. 哪些视觉语义应该允许宿主选择？
3. 是否需要 Tone？
4. 是否需要 Emphasis？
5. 是否存在 Selected？
6. 是否存在 Error / Invalid？
7. 哪些状态来自业务参数？
8. 哪些状态完全由 Interaction 自动管理？
9. 哪些参数属于视觉语义，哪些属于业务行为？
10. 有没有参数实际上是在泄露 Component Recipe？

---

# 33. Component Recipe 体现在哪里

Component Recipe 不需要成为宿主可配置对象。

它可以体现在：

- 组件内部 resolver
- 组件默认实现
- 设计规范
- Catalog
- Test

例如 EdsTextField Recipe 知道：

    Rest Border = borderDefault
    Focus Border = borderFocus
    Error Border = dangerBorder

但宿主 API 里不出现：

    restBorderRole:
    focusBorderRole:
    errorBorderRole:

否则就是把设计系统内部规则泄露给业务层。

---

# 34. 明确不提供第四类 API：Component Visual Override

ColorScheme 2.0 第一版明确不提供类似：

- EdsButtonStyleOverride
- EdsTextFieldColorOverride
- EdsCheckboxTheme
- EdsComponentColorRecipe

也不提供：

- 单个 EDS 组件的 arbitrary background override
- 单个 EDS 组件的 foreground override
- 单个 EDS 组件的 hover override
- 单个 EDS 组件的 pressed override
- 单个 EDS 组件的 focus override

---

# 35. 为什么不提供 Component Visual Override

如果宿主大量需要：

    这个 Button 特殊一点
    那个 TextField 特殊一点
    这个 Checkbox 再换一个颜色

最终 EDS 会退化成：

> Flutter 原生组件外面包了一层名字。

这违背设计系统目标。

---

# 36. 特殊组件的推荐做法

如果宿主确实需要：

- 完全不同的视觉语言
- 特殊营销组件
- 高度品牌化控件
- 一次性的特殊动画按钮
- 与 EDS Recipe 明显冲突的控件

推荐：

> 直接使用 Flutter 原生组件自行实现。

边界：

    希望遵循 EDS 设计语言
    → 使用 Eds*

    希望自由定制到脱离 EDS
    → 使用 Flutter 原生组件

---

# 37. API 权限矩阵

| 能力 | 宿主是否可以配置 |
|---|---|
| 选择 Preset | 是 |
| 替换 Brand Seed | 是 |
| 替换 Status Seed | 是 |
| 覆盖 Semantic Color | 是 |
| 分别覆盖 Light / Dark Semantic Color | 是 |
| 使用 JSON Theme | 是 |
| 导出 JSON Theme | 是 |
| Button 选择 Tone | 是 |
| Button 选择 Emphasis | 是 |
| 组件设置业务状态 | 是 |
| 单组件 backgroundColor | 否 |
| 单组件 hoverColor | 否 |
| 单组件 pressedColor | 否 |
| 单组件 focusColor | 否 |
| 单组件重写 Semantic Role Mapping | 否 |
| 自定义 Component Recipe | 否 |
| 使用 Flutter 原生组件 | 是 |

---

# 38. API 的三档实际使用复杂度

## 1. 零配置

    EdsThemeScope(
      child: MyApp(),
    )

适合：

> 我就想要一套完整、好看的默认 UI。

## 2. 品牌定制

    EdsThemeScope(
      seeds: EdsColorSeeds(
        brand: myBrand,
      ),
      child: MyApp(),
    )

适合：

> 我的 App 有自己的品牌色。

## 3. 完整 Theme 定制

    EdsThemeScope(
      seeds: ...,
      semanticOverrides: ...,
      child: MyApp(),
    )

或通过 JSON：

    Preset
    +
    Seeds
    +
    Semantic Overrides

适合：

> 我要建立自己产品完整的 EDS Theme。

---

# 39. API 不应出现第四档

不设计：

> 每个组件单独改颜色 / Recipe。

如果需求走到这里：

> 离开 EDS Component，使用 Flutter 原生组件。

---

# 40. 与当前 API 的 Breaking Change 方向

ColorScheme 2.0 实施时：

    primary
    → brand

直接修改。

旧：

- accent
- primarySoft
- accentSoft
- successSoft
- warningSoft
- dangerSoft

应由新 Palette / Semantic Family 替代。

具体删除清单由技术方案结合源码给出。

---

# 41. 现有 JSON API 的保留原则

保留能力：

- configureJsonString
- configureJsonAsset
- exportJsonString

但 Schema 重做。

不保留旧 JSON Color Keys 兼容逻辑。

---

# 42. 现有 Easy API 的保留原则

现有：

- eds_easy
- eds_easy_extension
- eds_easy_recipe
- eds_easy_style

整体方向保持。

ColorScheme 2.0 改的是 Easy Recipe 底层颜色来源，不把 Easy API 重做成颜色 API。

---

# 43. 现有 Component API 的处理原则

组件已有的合理业务 API，例如：

- title
- icon
- action
- value
- onChanged
- enabled
- errorText
- validator
- isBusy
- isSelected
- size
- tone
- emphasis

原则上保留。

如果已有 API 暴露了：

- Raw Color
- 组件级颜色覆盖
- 过时的 accent / primary 语义

则在本轮 Breaking Change 中直接重构。

---

# 44. API 成功标准

## 场景 A：什么都不配置

得到完整默认蓝色 EDS。

## 场景 B：只改 Brand

全局以下视觉自动跟随：

- Primary Button
- Focus
- Selected
- Active Navigation

普通：

- Page
- Card
- Text
- Border

仍然保持稳定 Neutral Foundation。

## 场景 C：只改 surfaceRaised

所有使用 Raised Surface 的组件统一变化。

## 场景 D：使用 danger Button

宿主只写：

    tone: EdsButtonTone.danger

不需要知道 Danger 的具体颜色。

## 场景 E：想做一个完全特殊的彩虹 Button

不增加 EDS override 参数。

直接使用 Flutter 原生组件。

---

# 45. 当前已拍板事项

- [x] API 分成 Theme 初始化、Easy API、Concrete Component API 三类
- [x] 不提供 Component Visual Override API
- [x] 默认 Preset 零配置可用
- [x] Seed 支持部分覆盖
- [x] Neutral 不作为 Host Seed
- [x] Semantic Scheme 允许 Host Override
- [x] Semantic Override 支持 Light / Dark
- [x] Semantic Override 支持部分字段覆盖
- [x] JSON 与 Dart Theme API 保持概念同构
- [x] Easy API 保留现有总体设计方向
- [x] Component API 表达语义意图而不是 Raw Color
- [x] Component Recipe 由 EDS 内部维护
- [x] Tone / Emphasis 只在真正适合的组件中暴露
- [x] 不给所有组件机械增加 Tone
- [x] 特殊视觉组件直接使用 Flutter 原生组件
- [x] ColorScheme 2.0 允许 Breaking API Change

---

# 46. 技术方案阶段仍需落地的 API 细节

以下不再属于产品/设计边界问题，而属于具体 Dart 技术设计：

1. EdsColorSeeds 最终类型定义
2. Resolved Semantic Colors 与 Semantic Color Overrides 是否拆成两个类型
3. EdsTheme.instance.configure 的最终签名
4. EdsThemeScope 如何同时接收 Preset / Seeds / Override / Tokens
5. Semantic Overrides 的 Merge 顺序
6. JSON Schema 的精确字段结构
7. Light / Dark Override 缺一侧时是否允许自动 fallback
8. Theme Export 输出“用户输入”还是“完整 resolved scheme”
9. Component Recipe resolver 放在哪些内部文件
10. 旧 Component API 中是否存在需要删除的 Raw Color 参数

这些应结合当前 easy_design_system 源码，在《技术改造方案与开发计划》中一次确定。

---

# 47. 一句话总结

> EDS API 只让宿主决定 Theme 和组件意图；组件最终怎么画、状态怎么变，由 EDS 自己负责。
