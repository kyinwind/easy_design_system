
# EDS ColorScheme 2.0 技术改造方案与开发计划

日期：2026-09-27  
状态：技术方案 Draft 1  
目标版本：ColorScheme 2.0 Breaking Release  
依赖文档：
- docs/20260927_EDS_ColorScheme_2.0_设计规范_Draft1.md
- docs/20260927_EDS_ColorScheme_2.0_API设计规范_Draft1.md

---

# 1. 文档目标

本文件回答一个问题：

> 基于 easy_design_system 当前 0.3.1 代码，如何一次性改造成已经确定的 ColorScheme 2.0。

本轮不做兼容迁移。

允许：

- 旧 Host App 编译失败
- 旧 JSON Theme 失效
- primary / accent 等旧颜色 API 直接删除
- 旧组件内部颜色实现全部替换

目标是趁 1.0 之前彻底重构颜色基础设施，而不是长期背负两套 Theme API。

---

# 2. 已确认的设计前提

本技术方案不再重新讨论以下事项。

## 2.1 三层设计模型

    Theme Seed
        ↓
    Semantic Color Scheme
        ↓
    Component Color Recipe

Component Category 只作为设计 Checklist，不作为正式代码抽象层。

## 2.2 Neutral Foundation

Neutral Foundation 是 EDS 的基础视觉底盘，负责：

- Surface
- 普通 Foreground
- 普通 Border
- Disabled
- 普通 Neutral Interaction

它不要求 Host 提供 Neutral Seed。

## 2.3 Chromatic Families

第一版包含：

- Brand
- Information
- Success
- Warning
- Danger

运行时始终有完整默认 Preset。

Host 没有配置某个 Seed 时，继续使用 Preset Seed，而不是进入“无 Brand”状态。

## 2.4 Focus / Selected

默认属于 Brand 语义。

## 2.5 Host 权限

Host 可以：

- 选择 Preset
- 替换部分 Seeds
- 覆盖 Semantic Color
- 使用 JSON 配置

Host 不可以：

- 覆盖单个 EdsButton 的 hoverColor
- 覆盖单个 EdsTextField 的 focusColor
- 修改 Component Recipe
- 修改 Component → Semantic Role Mapping

如果单个组件需要完全脱离 EDS 视觉语言，直接使用 Flutter 原生组件。

---

# 3. 当前源码结构盘点

当前 0.3.1 的颜色体系主要分布在：

    lib/src/tokens/eds_design_tokens.dart
    lib/src/tokens/eds_color_scheme.dart

    lib/src/theme/eds_theme.dart
    lib/src/theme/eds_theme_scope.dart
    lib/src/theme/eds_preset_theme.dart
    lib/src/theme/eds_theme_json.dart

    lib/src/widgets/*
    lib/src/easy/*
    lib/src/primitives/eds_surface.dart

当前 pubspec 只有 Flutter 本身，没有直接声明颜色科学依赖。

---

# 4. 当前 EdsColorTokens 的问题

当前 EdsColorTokens 同时承担：

1. Theme Seed
2. 具体颜色 Token
3. Soft 派生色

目前包含：

    primary
    accent
    success
    warning
    danger

并直接派生：

    primarySoft
    accentSoft
    successSoft
    warningSoft
    dangerSoft

Soft 主要通过固定 12% alpha 生成。

问题：

- Seed 和 Semantic Color 混在一起
- accent / primary 概念重复
- Soft 色只是固定透明度，不具备稳定感知一致性
- Light / Dark 不能真正独立优化
- Button 等组件直接依赖这些实现细节

ColorScheme 2.0 中 EdsColorTokens 应被删除，不继续承担旧职责。

---

# 5. 当前 EdsColorScheme 的问题

当前 EdsColorScheme.resolve(tokens, brightness) 每次根据 brightness 直接得到：

    label
    textPrimary
    textSecondary
    textTertiary
    pageBackground
    cardBackground
    cardGrayBackground
    subtleFill
    border

其特点是：

- 语义角色数量很少
- 主要依赖 black / white alpha
- 没有 Brand Family
- 没有 Information Family
- Status Family 不完整
- 没有 Interaction Resolver
- 没有 Layer Context
- 没有 Semantic Override
- context.edsScheme 每次调用都会 resolve

ColorScheme 2.0 应把它升级成完整的运行时 Resolved Semantic Scheme。

---

# 6. 当前 Theme 架构的问题

当前 EdsTheme.instance 只持有：

    ValueNotifier<EdsDesignTokens>

EdsThemeScope 也主要注入：

    EdsDesignTokens
    Brightness

Preset 直接保存 EdsDesignTokens。

这意味着：

> “Theme 配置”和“Design Tokens”实际上是同一个对象。

ColorScheme 2.0 需要新增 Theme 聚合模型，避免继续把：

- Seed
- Semantic Override
- Non-color Tokens
- Resolved Runtime Color

塞进同一个 EdsDesignTokens。

---

# 7. 目标代码职责

ColorScheme 2.0 的内部实现建议拆成以下职责：

    Theme Configuration
        ↓
    Seed Resolution
        ↓
    Tonal Palette Generation
        ↓
    Semantic Mapping
        ↓
    Semantic Override Merge
        ↓
    Brightness Resolution
        ↓
    Layer Resolution
        ↓
    Interaction Resolution
        ↓
    Component Recipe

注意：

> 这是内部技术职责分层，不改变对用户暴露的三层心智模型。

---

# 8. 目标文件结构

建议新增：

    lib/src/color/
      eds_color_seeds.dart
      eds_tonal_palette.dart
      eds_neutral_foundation.dart
      eds_semantic_colors.dart
      eds_semantic_overrides.dart
      eds_color_resolver.dart
      eds_interaction_resolver.dart
      eds_layer.dart

调整：

    lib/src/tokens/eds_color_scheme.dart
    lib/src/tokens/eds_design_tokens.dart

    lib/src/theme/eds_theme_data.dart
    lib/src/theme/eds_theme.dart
    lib/src/theme/eds_theme_scope.dart
    lib/src/theme/eds_preset_theme.dart
    lib/src/theme/eds_theme_json.dart

组件继续位于：

    lib/src/widgets/

Component Recipe 第一版尽量保留在各组件内部，不创建大量公开的 XxxColorRecipe 类型。

---

# 9. 新增 EdsThemeData

建议新增真正的 Theme 聚合对象：

    EdsThemeData

概念字段：

    EdsThemeData(
      seeds,
      semanticOverrides,
      tokens,
    )

其中：

## seeds

类型：

    EdsColorSeeds

负责 Chromatic Seeds。

## semanticOverrides

类型：

    EdsSemanticOverrides

负责 Light / Dark 高级覆盖。

## tokens

类型：

    EdsDesignTokens

只负责非颜色设计 Tokens：

- spacing
- radius
- typography
- controlSize
- adaptiveLayout
- heroGradient
- stroke
- shadow

这样 EdsDesignTokens 不再包含 colors。

这是本轮最重要的结构性 Breaking Change 之一。

---

# 10. EdsDesignTokens 重构

旧：

    EdsDesignTokens(
      colors,
      spacing,
      radius,
      ...
    )

新：

    EdsDesignTokens(
      spacing,
      radius,
      typography,
      controlSize,
      adaptiveLayout,
      heroGradient,
      stroke,
      shadow,
    )

删除：

    EdsDesignTokens.colors

原因：

> Seed 和 Semantic Scheme 属于 Theme Color System，不再作为普通 Design Token 混在 EdsDesignTokens 中。

---


# 10.1 本轮只重构 Color 子系统，其他 Design Tokens 保留

本轮 ColorScheme 2.0 的 Breaking Change 范围必须严格限定在：

- colors / seeds
- semantic color scheme
- color resolver
- interaction color
- layer-aware color
- 与颜色直接相关的组件 Recipe

以下现有 Design Token 体系原则上继续保留原实现与公开 API：

    EdsSpacingTokens
    EdsRadiusTokens
    EdsTypographyTokens
    EdsControlSizeTokens
    EdsAdaptiveLayoutTokens
    EdsHeroGradient
    EdsStrokeTokens
    EdsShadowTokens

也就是说：

> ColorScheme 2.0 是“颜色子系统升级”，不是“重新设计全部 Design Tokens”。

现有这些类型已经具备：

- 默认值
- copyWith
- fromJson
- toJson
- equality / hashCode
- Host App 配置能力

本轮不应因为颜色重构而无意义地更名、删除或重做。

除非开发过程中发现明确 bug，否则保持现有行为。

---

# 10.2 EdsDesignTokens 的新职责

EdsDesignTokens 删除 colors 后，仍然继续作为“非颜色 Design Tokens”的聚合对象。

新结构：

    EdsDesignTokens(
      spacing,
      radius,
      typography,
      controlSize,
      adaptiveLayout,
      heroGradient,
      stroke,
      shadow,
    )

它仍然：

- 公开
- immutable
- 支持 copyWith
- 支持 JSON
- 支持局部 Theme
- 被 Easy API / Component Recipe / Adaptive Metrics 使用

Color 不再放在 EdsDesignTokens 中，是因为 ColorScheme 2.0 的颜色系统需要：

    Seed
    + Palette
    + Semantic Override
    + Brightness
    + Layer
    + Interaction

其生命周期和结构已经明显复杂于普通 Token。

所以拆分的是“职责”，不是废弃原 Token 系统。

---

# 10.3 现有非颜色 Token 默认值继续保留

当前默认实现继续作为 ColorScheme 2.0 默认值基线：

## Spacing

    xxs  4
    xs   8
    sm   12
    md   16
    lg   20
    xl   24
    xxl  32
    xxxl 40

## Radius

    sm 8
    md 12
    lg 16
    xl 24

## Control Size

    buttonHeight 34
    fieldHeight 34
    rowMinHeight 52

## Adaptive Layout

    compactPagePadding      16
    regularPagePadding      32
    readableContentMaxWidth 880
    minimumTouchTarget      44
    minimumHybridTarget     44

## Typography

继续使用现有：

- hero
- pageTitle
- sectionTitle
- body15
- body15Strong
- body
- bodyStrong
- caption
- captionStrong
- monoCaption

以及现有 fontFamily / fallback 扩展。

## Hero Gradient

继续保留现有显式 gradient token，不自动从 Brand Seed 推导。

## Stroke

继续保留 EdsStrokeTokens.hairline。

## Shadow

继续保留：

    EdsShadowTokens.card
    EdsShadowTokens.subtle
    EdsShadowTokens.prominent

以及现有 color / opacity / radius / x / y 配置结构。

---

# 11. EdsColorSeeds

新增公开不可变 Value Object：

    EdsColorSeeds

字段：

    brand
    information
    success
    warning
    danger

推荐所有字段最终 resolved 后都非空。

但为了方便 Host partial override，需要区分：

    EdsColorSeeds
    EdsColorSeedOverrides

建议：

## EdsColorSeeds

完整值，用于：

- Preset
- runtime resolved configuration

## EdsColorSeedOverrides

全部 nullable，用于：

- EdsThemeScope(seeds: ...)
- Host partial override
- JSON partial override

这样不会让一个类型同时承担“完整配置”和“patch”。

---

# 12. 默认 Seeds

默认 Blue Preset 第一版建议沿用当前品牌与状态方向：

    brand       #3185FF
    information #3185FF
    success     #27B15A
    warning     #F9B135
    danger      #E54444

后续 Catalog 可以校准 Seed，但结构不变。

Purple / Orange Preset 只应覆盖需要变化的 Family。

原则：

> Brand Theme 不自动改变 Success / Warning / Danger。

---

# 13. Tonal Palette 技术选型

第一版推荐直接依赖：

    material_color_utilities

当前 pub.dev 稳定版本为 0.13.1，最低 Dart SDK 3.5，与本包当前 Dart 3.6 约束兼容。

推荐在 pubspec.yaml 中显式声明直接依赖，而不是依赖 Flutter 的传递依赖。

使用范围仅限：

    Seed → HCT Tonal Palette

不直接采用 Material ColorScheme。

EDS 仍然自己负责：

- Semantic Role
- Tone Mapping
- Neutral Foundation
- Layer
- Interaction
- Component Recipe

因此：

> 使用 Material Color Utilities 的颜色科学，不等于把 EDS 变成 Material Design。

---

# 14. EdsTonalPalette

建议内部封装一层：

    EdsTonalPalette

而不是让整个包到处直接依赖 material_color_utilities.TonalPalette。

职责：

- 接收 Flutter Color Seed
- 转换为 ARGB
- 使用 HCT / TonalPalette 生成色阶
- 暴露 EDS 自己的 tone(int) 方法

概念：

    final palette = EdsTonalPalette.fromSeed(seed);

    palette.tone(40)
    palette.tone(80)
    palette.tone(95)

这样未来如需替换 Palette Engine，只改内部封装。

---

# 15. Neutral Foundation 实现

Neutral 第一版不从 Host Seed 推导。

建议新增：

    EdsNeutralFoundation

内部维护精心确定的 Neutral Palette / Neutral Roles。

第一版可以使用固定 Neutral tone 表，而不是通过一个 neutralSeed 动态生成。

原因：

- EDS 要稳定控制桌面工具类 App 的基础视觉
- 避免 Host Brand 影响 Neutral
- Light / Dark Surface 层次需要手工校准
- Neutral 是 EDS 视觉身份的一部分

Host 仍然可以通过 Semantic Override 精调最终 Neutral Roles。

---

# 16. Semantic Roles 第一版

Resolved EdsColorScheme 建议至少包含：

## Surface

    surfacePage
    surfaceBase
    surfaceRaised
    surfaceSunken
    surfaceOverlay
    surfaceDisabled

## Foreground

    foregroundPrimary
    foregroundSecondary
    foregroundTertiary
    foregroundDisabled
    foregroundInverse

## Border

    borderSubtle
    borderDefault
    borderStrong
    borderSelected
    borderFocus
    borderDisabled
    borderDanger

## Brand

    brandForeground
    brandSurface
    brandSurfaceStrong
    brandBorder
    brandOnStrong

## Information

    informationForeground
    informationSurface
    informationSurfaceStrong
    informationBorder
    informationOnStrong

## Success

    successForeground
    successSurface
    successSurfaceStrong
    successBorder
    successOnStrong

## Warning

    warningForeground
    warningSurface
    warningSurfaceStrong
    warningBorder
    warningOnStrong

## Danger

    dangerForeground
    dangerSurface
    dangerSurfaceStrong
    dangerBorder
    dangerOnStrong

---

# 17. Selected 不复制 Semantic Tokens

不建议额外增加：

    selectedSurface
    selectedForeground
    selectedBorder

因为我们已经确认：

    Selected → Brand

组件直接使用：

    brandSurface
    brandForeground
    brandBorder

避免同义 Token 膨胀。

---

# 18. Focus 不创建独立 Color Family

Focus 默认来自 Brand。

保留：

    borderFocus

它是一个跨组件通用 Semantic Role。

Button Focus Ring、TextField Focus Border 可以共享 Color Role。

Ring width / offset / shape 属于 style / metrics，而不是 Color Token。

如果以后出现不同颜色需求，再拆分，而不是第一版预先过度设计。

---

# 19. Semantic Tone Mapping

第一版实现需要一张固定 Mapping Table。

推荐以以下值作为起始实验，不视为不可修改的最终视觉值。

## Brand / Status Family Light

| Role | Tone |
|---|---:|
| Foreground | 40 |
| Surface | 95 |
| SurfaceStrong | 40 |
| Border | 70 |
| OnStrong | 100 |

## Brand / Status Family Dark

| Role | Tone |
|---|---:|
| Foreground | 80 |
| Surface | 20 |
| SurfaceStrong | 80 |
| Border | 60 |
| OnStrong | 10 |

Information / Success / Warning / Danger 先使用相同结构。

之后通过 Catalog 特别检查 Warning。

---

# 20. Warning 的特殊处理

黄色 / Amber 是最容易出问题的 Family。

第一版不能假设：

> Warning 完全照搬 Brand 的 Tone Mapping 就一定可用。

实现上应该允许每个 Family 有独立 Mapping：

    EdsToneMap.brand
    EdsToneMap.information
    EdsToneMap.success
    EdsToneMap.warning
    EdsToneMap.danger

第一轮可以先给相同默认值。

Catalog / Contrast Test 发现 Warning 问题后，只调整 Warning Mapping，不改 API。

---

# 21. Neutral Mapping 第一版

Neutral Foundation 不建议简单做 Light/Dark 镜像。

第一版先用固定角色值建立基准。

概念方向：

## Light

    surfacePage       轻灰
    surfaceBase       白
    surfaceRaised     白 / 极浅灰
    surfaceSunken     轻微内凹灰
    surfaceOverlay    白
    foregroundPrimary 深 Neutral
    foregroundSecondary 中深 Neutral
    foregroundTertiary 中 Neutral
    borderSubtle      极浅 Neutral
    borderDefault     浅 Neutral
    borderStrong      中 Neutral

## Dark

    surfacePage       深灰
    surfaceBase       稍亮深灰
    surfaceRaised     更亮一级
    surfaceSunken     更暗一级
    surfaceOverlay    更亮一级
    foregroundPrimary 接近白
    foregroundSecondary 中亮 Neutral
    foregroundTertiary 较弱 Neutral
    borderSubtle      很弱亮线
    borderDefault     弱亮线
    borderStrong      中亮线

具体 Hex / Tone 在 Catalog 阶段定稿。

---

# 22. Contrast Validation

新增内部工具：

    EdsContrastValidator

职责：

- 检查 foreground/background pair
- 关键文本目标 4.5:1
- 关键控件 / Focus Indicator 参考 3:1
- 对固定 Tone Mapping 做测试保护

第一版不要在每次 build 时动态“聪明调整”。

建议：

> 构建 Scheme 时使用确定性 Mapping，测试阶段验证 Mapping 是否合格。

原因：

- 运行时自动纠色可能造成不可预测视觉
- Debug 困难
- Host Semantic Override 本来就可能有意改变颜色

Host Override 可提供 debug assertion / diagnostics，但不强制修改用户值。

---

# 23. Semantic Override 类型

建议拆成：

    EdsSemanticColors
    EdsSemanticColorOverrides

## EdsSemanticColors

完整 resolved scheme，所有字段 required。

## EdsSemanticColorOverrides

所有字段 nullable，只表示 patch。

再用：

    EdsSemanticOverrides(
      light: ...,
      dark: ...,
    )

组织 brightness。

---

# 24. Light / Dark Override 规则

建议：

- light 和 dark 都允许独立缺省
- 没提供的一侧不自动复制另一侧
- 缺省侧继续使用自动生成值

例如：

    semanticOverrides.dark == null

意味着：

> Dark 完全使用默认生成方案。

不要把 Light Override 自动复制到 Dark。

这能避免宿主无意中破坏 Dark Theme。

---

# 25. Theme Resolve Pipeline

建议新增：

    EdsThemeResolver

概念输入：

    presetThemeData
    seedOverrides
    semanticOverrides
    brightness

输出：

    EdsResolvedTheme

EdsResolvedTheme 至少包含：

    designTokens
    seeds
    colorScheme
    brightness

后续加入 Layer Context 时，不必重新 resolve 整个 Theme。

---

# 26. EdsColorScheme 不应每次 getter 现场重算

当前：

    context.edsScheme
    → EdsColorScheme.resolve(context.edsTokens, brightness)

ColorScheme 2.0 建议：

> ThemeScope 在配置 / brightness 变化时 resolve 一次，并把 EdsResolvedTheme 注入树。

然后：

    context.edsScheme

只读取 Scope 已解析对象。

好处：

- 避免多个组件重复 Palette / Scheme 计算
- Semantic Override merge 只做一次
- 后续 Layer / Interaction resolver 更清晰
- Theme identity 更稳定

---

# 27. EdsThemeScope 重构

当前 _EdsTokensScope 注入：

    tokens
    brightness

建议改为内部：

    _EdsThemeScopeData

注入：

    EdsResolvedTheme theme

以及必要的 Theme configuration reference。

EdsThemeScope 公开参数建议最终支持：

    theme
    preset
    seeds
    semanticOverrides
    brightness
    child

但应避免允许多个互相冲突的入口。

技术实现建议优先规则：

    explicit theme
        >
    base preset + seeds + semanticOverrides
        >
    inherited/global theme

最终 constructor 可以通过 assert 保证冲突参数不可同时使用。

---

# 28. EdsTheme 全局对象重构

当前：

    ValueNotifier<EdsDesignTokens>

建议改为：

    ValueNotifier<EdsThemeData>

EdsTheme.instance 暴露：

    themeData
    configure(...)
    applyPreset(...)
    configureJsonString(...)
    configureJsonAsset(...)
    exportJsonString(...)

非颜色 token convenience accessor 仍可以保留：

    spacing
    radius
    typography
    ...

颜色访问改为：

    seeds
    semanticOverrides

不再暴露：

    colors.primary

---

# 29. JSON Schema 2.0

建议 JSON 顶层保持其他 token 结构稳定，但 colors 改成：

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
          },
          "dark": {
          }
        }
      },
      "spacing": {...},
      "radius": {...},
      ...
    }

旧 primary / accent schema 直接废弃。

---


# 29.1 JSON Schema 的兼容边界

ColorScheme 2.0 的 JSON 不是重新设计整份 Theme JSON。

只重构：

    colors

这一分支。

当前已有的以下顶层分组继续保留原命名与原语义：

    spacing
    radius
    typography
    controlSize
    adaptiveLayout
    heroGradient
    stroke
    shadow

因此新 JSON 应保持类似：

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
          "light": {},
          "dark": {}
        }
      },

      "spacing": {
        "xxs": 4,
        "xs": 8,
        "sm": 12,
        "md": 16,
        "lg": 20,
        "xl": 24,
        "xxl": 32,
        "xxxl": 40
      },

      "radius": {
        "sm": 8,
        "md": 12,
        "lg": 16,
        "xl": 24
      },

      "typography": {
        "...": "继续沿用现有 schema"
      },

      "controlSize": {
        "buttonHeight": 34,
        "fieldHeight": 34,
        "rowMinHeight": 52
      },

      "adaptiveLayout": {
        "compactPagePadding": 16,
        "regularPagePadding": 32,
        "readableContentMaxWidth": 880,
        "minimumTouchTarget": 44,
        "minimumHybridTarget": 44
      },

      "heroGradient": {
        "startColor": "#3185FF",
        "endColor": "#0A6BFF"
      },

      "stroke": {
        "hairline": 1
      },

      "shadow": {
        "color": "#000000",
        "opacity": 0.06,
        "radius": 18,
        "x": 0,
        "y": 10
      }
    }

注意：

当前 bundled default JSON 没有显式写 stroke / shadow，但源码已经支持这两个分组，缺失时会回退到 EdsStrokeTokens() / EdsShadowTokens() 默认值。

ColorScheme 2.0 可以选择：

1. 继续允许默认 JSON 省略 stroke / shadow；或
2. 为了让默认 JSON 成为“完整示例”，把它们显式写出来。

本技术方案推荐第 2 种：

> bundled default JSON 应尽量完整展示所有可配置 Theme 分组。

但 decoder 必须继续支持分组缺失时使用默认值。

---

# 30. JSON Export 策略

本轮建议明确：

> exportJsonString 导出“Theme Configuration”，而不是完整 Resolved Scheme。

即导出：

- Seeds
- Semantic Overrides
- Non-color Design Tokens

不导出：

- 自动生成的 Tonal Palette
- 每个自动生成的 Semantic Role 最终 Hex
- Brightness runtime result
- Layer runtime result
- Interaction runtime result

原因：

1. 自动值属于实现细节
2. Palette 算法以后可以升级
3. 导出完整 resolved scheme 会把自动系统重新写死
4. JSON 应表达用户配置意图，而不是运行时快照

---

# 31. Interaction Resolver

新增内部公开程度较低的：

    EdsInteractionResolver

统一状态：

    rest
    hover
    pressed
    selected
    focused
    disabled

第一版关键原则：

> Component 不再自己 Color.lerp / withOpacity 计算 Hover 和 Pressed。

---

# 32. Interaction Resolver 输入

不要只接一个裸 Color。

否则 Resolver 不知道它属于哪个 Palette。

建议内部使用：

    EdsSemanticColorRef

概念上携带：

- family
- base tone / role
- resolved color

例如：

    brandSurfaceStrong
    neutralSurfaceBase
    dangerSurface

Resolver 能基于 Family + Brightness 做 Tone Movement。

---

# 33. Interaction 第一版策略

建议：

## Strong Chromatic Surface

Light：

    rest    T40
    hover   T35
    pressed T30

Dark：

    rest    T80
    hover   T85
    pressed T90

## Soft Chromatic Surface

围绕 soft surface tone 小步移动。

## Neutral Surface

使用 Neutral Foundation 的相邻状态值，不强制套 Chromatic 算法。

这是一版默认策略，不是 API 契约。

后续只需调整 Resolver Mapping。

---

# 34. Selected 的处理

Selected 不是 Interaction Resolver 自动把任意 Neutral Surface 变成 Brand。

Component Recipe 决定：

    unselected
    → Neutral roles

    selected
    → Brand roles

然后：

    selected + hovered

再交给 Interaction Resolver。

也就是说：

> Selection 是 Component semantic state，Hover/Pressed 是 Interaction state。

这两个维度不要混在一起。

---

# 35. Disabled 的处理

Disabled 可以同时影响：

- Surface
- Foreground
- Border
- Interaction

第一版建议 Component Recipe 明确换到：

    surfaceDisabled
    foregroundDisabled
    borderDisabled

而不是整组件统一 opacity 0.5。

这样文本、边框和 Surface 可以独立控制可读性。

---

# 36. Layer / Context 技术方案

新增：

    enum EdsLayer {
      base,
      raised,
      nested,
      overlay,
    }

或等价命名。

公开命名在实现前可校准。

核心是：

> Layer 表示当前视觉上下文，不直接等同于某一个 Widget 类型。

---

# 37. Layer 在 Widget Tree 中传播

建议新增：

    EdsLayerScope

内部用 InheritedWidget / InheritedModel 传播当前 layer depth / context。

提供：

    context.edsLayer

组件通过 Layer Resolver 获取当前上下文。

不建议把 Layer 塞进全局 EdsThemeScope，因为：

- Theme 是全局 / subtree 配置
- Layer 是局部嵌套上下文
- 两者生命周期不同

---

# 38. 哪些组件创建 Layer

第一版建议：

## Page

进入 Base / Layer 0。

## Card / Group

根据 Recipe 进入 Raised / Layer 1。

## Nested Card

允许进入 Nested / Layer 2。

## Dialog / Menu / Popover

进入 Overlay。

## TextField / Dropdown

不创建 Layer。

它们读取当前 Layer，并根据 Context 解析 Field Surface。

---

# 39. Layer 深度不要无限增加颜色

不设计：

    Layer 0
    Layer 1
    Layer 2
    Layer 3
    Layer 4
    Layer 5
    ...

第一版最多：

    base
    raised
    nested
    overlay

更深嵌套 clamp 到 nested。

这样视觉系统可控。

---

# 40. Layer Resolver

新增：

    EdsLayerResolver

输入：

    Semantic Role
    Current Layer
    Brightness

输出最终适合 Context 的 Surface / Border role variation。

第一版主要影响：

- surfaceBase
- surfaceRaised
- surfaceSunken
- borderSubtle / Default
- Field Surface

不要让 Layer 随意修改 Brand / Status。

---

# 41. Component Recipe 实现方式

第一版不创建公开：

    EdsButtonColorRecipe
    EdsTextFieldColorRecipe
    ...

建议组件内部建立 private resolver：

    _resolveButtonVisual(...)
    _resolveTextFieldColors(...)
    _resolveCheckboxColors(...)

输入只来自：

    scheme
    layer
    state
    semantic component params

这样先保持实现简单。

如果未来出现三个以上组件共享完全一致的 Recipe，再抽内部公共 resolver。

---

# 42. Button 迁移

当前 Button 是本次改造最大的颜色 Breaking 点。

需要：

## Enum

    EdsButtonTone.accent
    → EdsButtonTone.brand

新增：

    information

保留：

    neutral
    success
    warning
    danger

## Appearance

删除对：

    tokens.colors.primary
    primarySoft
    successSoft
    warningSoft
    dangerSoft

的访问。

改为使用：

    scheme.brand*
    scheme.information*
    scheme.success*
    scheme.warning*
    scheme.danger*

## Hover

删除组件内部 Color.lerp 状态算法。

统一走 Interaction Resolver。

## Disabled

逐步从整组件 opacity 迁移为 Disabled Roles。

---

# 43. Button Emphasis Mapping

第一版：

## filled

    background = toneSurfaceStrong
    foreground = toneOnStrong

## soft

    background = toneSurface
    foreground = toneForeground

## outline

    background = transparent
    foreground = toneForeground
    border = toneBorder / borderDefault

## plain

    foreground = toneForeground

## medium

需要单独在 Catalog 验证。

当前 25% alpha 不保留为技术定义。

建议将 medium 映射为：

    比 soft 更强、比 filled 更弱的 Palette Tone

如果单一 Surface / SurfaceStrong 两档不足，则优先通过内部 Emphasis Mapping 使用中间 Tone，不急着新增公开 Semantic Role。

---

# 44. Form Controls 迁移

需要一次迁移：

    EdsTextField
    EdsTextFormField
    EdsDropdown
    EdsDropdownFormField
    EdsCheckbox
    EdsRadio
    EdsRadioGroup
    EdsSegmented
    EdsSlider

重点：

- TextField / Dropdown 共享 Field 设计规则
- Focus → Brand / borderFocus
- Error → Danger
- Selected → Brand
- Disabled → Disabled Roles
- Hover → Interaction Resolver
- Field Surface 读取 Layer Context

---

# 45. Pill / Badge 迁移

EdsChoicePill：

    Rest → Neutral
    Selected → Brand

普通 Pill / Badge：

- 根据现有语义决定是否增加 Tone
- 不机械开放 Raw Color

如果 Badge 已有独立 raw color API，应在本轮评估并删除或改成 Tone。

---

# 46. Surface 组件迁移

包括：

    EdsPage
    EdsCard
    EdsGroup
    EdsDialog
    EdsMenu
    EdsSidebar
    EdsSurface
    Easy API surface

重点：

- pageBackground → surfacePage
- cardBackground → surfaceRaised / context role
- subtleFill → 不直接保留旧同义词
- border → borderSubtle / Default
- Dialog / Menu → surfaceOverlay
- Card / Group 正确创建 Layer Scope

---

# 47. EdsSurface 的定位

当前 EdsSurfaceConfiguration 允许直接传 raw Color：

    background
    borderColor

这属于低层 primitive，需要单独判断。

建议：

> EdsSurface 继续作为低层 primitive，不把它当成 EDS 高层 semantic component。

原因：

- 内部 Recipe 需要最终 Color 来绘制
- 它类似 rendering primitive
- Host 虽然能公开 import，但不代表它是推荐的 Theme API

技术上可以保留 raw Color。

但文档要明确：

> EdsSurface 是底层构建工具，不属于高层“组件级任意视觉覆盖 API”。

如果希望更严格，也可以在后续版本把它 internal；本轮不必扩大改动范围。

---

# 48. Easy API 迁移

当前 EdsEasyBackgroundPolicy：

    inherited
    page
    subtle
    card

建议重命名 / 映射到新 Surface 语言。

例如：

    inherited
    page
    base
    raised

是否保留 group 的 subtle 视觉，应通过 Recipe 决定，不再依赖 scheme.subtleFill。

EdsEasy 本身：

- 不再手动 EdsColorScheme.resolve
- 直接读取 resolved theme
- foregroundPrimary 替代 textPrimary
- borderSubtle / Default 替代 border

---

# 49. Preset 重构

当前 EdsPresetTheme 保存：

    id
    name
    EdsDesignTokens tokens

建议升级成：

    id
    name
    EdsThemeData theme

Preset 中 Seeds 成为显式一等数据。

Blue：

    brand #3185FF

Orange：

    brand #FF6B00

Purple：

    brand #8B5CF6

Status Seeds 默认尽量保持稳定，除非某 Preset 确实需要改变。

---

# 50. Hero Gradient 与 Brand

当前 Hero Gradient 作为独立 Token。

第一版不强迫它自动从 Brand Seed 推导。

原因：

- Gradient 是品牌视觉资产，不等同于 Semantic Color
- 自动生成 gradient 可能产生不可控视觉
- Preset 已经可以提供 Hero Gradient

因此继续保留在 EdsDesignTokens。

未来再讨论 Hero Gradient 是否可自动 derive。

---

# 51. Public Export 调整

lib/easy_design_system.dart 新增导出：

    eds_color_seeds.dart
    eds_semantic_colors.dart
    eds_semantic_overrides.dart
    eds_layer.dart
    eds_theme_data.dart

不建议公开：

    eds_tonal_palette.dart
    eds_neutral_foundation.dart
    eds_color_resolver.dart
    eds_interaction_resolver.dart

除非测试 / 高级扩展确实需要。

原则：

> 公开语义模型，不公开颜色算法细节。

---

# 52. 旧 API 删除清单

预计直接删除：

    EdsColorTokens
    EdsDesignTokens.colors
    primary
    accent
    primarySoft
    accentSoft
    successSoft
    warningSoft
    dangerSoft

旧 EdsColorScheme：

    label
    textPrimary
    textSecondary
    textTertiary
    pageBackground
    cardBackground
    cardGrayBackground
    subtleFill
    border

全部迁移到新命名，不保留 Deprecated Alias。

Button：

    EdsButtonTone.accent
    → brand

其他组件中的 accent / primary 命名同步清理。

---

# 53. 旧 JSON Breaking Change

旧：

    colors.primary
    colors.accent
    colors.success
    colors.warning
    colors.danger

新：

    colors.seeds.brand
    colors.seeds.information
    colors.seeds.success
    colors.seeds.warning
    colors.seeds.danger
    colors.semanticOverrides.light
    colors.semanticOverrides.dark

不写兼容 parser。

旧 JSON 应明确报 FormatException / migration error。

---

# 54. 测试架构

至少新增以下测试组。

## Seed / Palette

    test/color/eds_tonal_palette_test.dart
    test/color/eds_color_seeds_test.dart

验证：

- Seed → deterministic tones
- Preset default seeds
- partial seed merge

## Semantic Scheme

    test/color/eds_color_scheme_test.dart

验证：

- Light / Dark mapping
- Brand / Status roles
- Neutral roles
- Semantic Override merge

## Interaction

    test/color/eds_interaction_resolver_test.dart

验证：

- Hover
- Pressed
- family-specific movement
- Light / Dark

## Layer

    test/color/eds_layer_test.dart

验证：

- Base
- Raised
- Nested
- Overlay
- Field context

## JSON

    test/theme/eds_theme_json_v2_test.dart

验证：

- import
- export
- partial override
- old schema rejected

---

# 55. Contrast Test

新增专门测试：

    test/color/eds_color_contrast_test.dart

至少验证默认 Presets：

    Blue
    Orange
    Purple

在：

    Light
    Dark

下关键组合：

- foregroundPrimary / main surfaces
- brandOnStrong / brandSurfaceStrong
- informationOnStrong / informationSurfaceStrong
- successOnStrong / successSurfaceStrong
- warningOnStrong / warningSurfaceStrong
- dangerOnStrong / dangerSurfaceStrong
- borderFocus 与相邻背景

---

# 56. Component Widget Test

每个迁移组件至少验证：

- 正常状态
- Hover
- Pressed（适用时）
- Focus
- Selected（适用时）
- Disabled
- Error（适用时）
- Light / Dark 关键差异

重点不是截取 Hex，而是验证组件读取正确 Semantic Role / resolver path。

---

# 57. Golden Test 策略

如果当前仓库尚未建立稳定 Golden Test 基础，本轮不要一次引入大量脆弱截图测试阻塞重构。

建议：

第一阶段：

- Unit
- Widget
- Catalog 人工检查

ColorScheme 稳定后再建立少量核心 Golden：

- Buttons
- Form Controls
- Surface / Layer
- Status

---

# 58. Catalog 新增 Color Foundation 页面

必须有一页：

    Color Foundation

展示：

## Neutral

- Surface
- Foreground
- Border

## Brand / Status

- Foreground
- Surface
- SurfaceStrong
- Border
- OnStrong

## Interaction

每个主要 Surface 的：

- Rest
- Hover
- Pressed

## Brightness

- Light
- Dark

---

# 59. Catalog Layer 页面

展示：

    Page
      Card
        Field

以及：

    Page Field
    Card Field
    Nested Card Field

再展示：

    Dialog
    Menu
    Overlay

用视觉方式验证 Layer 是否真的有价值。

---

# 60. Catalog Component Matrix

至少展示：

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
    States

并可以切换：

    Blue / Orange / Purple
    Light / Dark

---

# 61. 开发阶段总览

虽然架构与代码最终一次性切换，但开发过程仍应拆成可验证批次。

原则：

> 分批开发，不分裂最终 API。

---

# 61.1 开发里程碑 Checklist

后续以本清单作为 ColorScheme 2.0 的阶段性进度记录。

每完成一个 Batch：

1. 完成代码与测试
2. 通过该 Batch 的验收条件
3. 提交 Git Commit
4. 将对应项从 `[ ]` 改为 `[x]`

总进度：

- [ ] Batch 0 — 建立重构分支与基线
- [ ] Batch 1 — Theme Data / Seed 基础模型
- [ ] Batch 2 — Palette / Semantic Scheme
- [ ] Batch 3 — Theme Resolver / Scope
- [ ] Batch 4 — Interaction Resolver
- [ ] Batch 5 — Layer / Context
- [ ] Batch 6 — Button 全量迁移
- [ ] Batch 7 — Form / Choice Controls
- [ ] Batch 8 — Pills / Badge / Navigation
- [ ] Batch 9 — Surface / Dialog / Menu / States / Easy
- [ ] Batch 10 — JSON Theme 2.0
- [ ] Batch 11 — Catalog
- [ ] Batch 12 — 清理旧颜色体系
- [ ] Batch 13 — 文档 / README / CHANGELOG
- [ ] Batch 14 — 最终 CI
- [ ] Host Migration — RightClickMate
- [ ] Host Migration — VideoHero
- [ ] Release — ColorScheme 2.0 Breaking Version

---

# 62. Batch 0 — 建立重构分支与基线

阶段任务：

- [ ] 创建 / 确认 `feature/colorscheme-2` 分支
- [ ] 确认 main CI 为 green
- [ ] 记录当前 0.3.1 test baseline
- [ ] 确认本阶段不修改 Host App
- [ ] 在开发分支保留设计规范 / API 规范 / 技术方案链接
- [ ] `flutter pub get` 通过
- [ ] `dart format --set-exit-if-changed .` 通过
- [ ] `flutter analyze` 通过
- [ ] `flutter test` 通过



建议分支：

    feature/colorscheme-2

执行：

- 确认 main CI green
- 记录当前 0.3.1 test baseline
- 不修改 Host App
- 建立设计文档链接

完成标准：

    flutter pub get
    dart format --set-exit-if-changed .
    flutter analyze
    flutter test

全部通过。

---

# 63. Batch 1 — Theme Data / Seed 基础模型

阶段任务：

- [ ] 新增 `EdsThemeData`
- [ ] 新增 `EdsColorSeeds`
- [ ] 新增 `EdsColorSeedOverrides`
- [ ] 从 `EdsDesignTokens` 删除 `colors`
- [ ] 保留并验证所有非颜色 Design Tokens
- [ ] `EdsPresetTheme` 改为基于 `EdsThemeData`
- [ ] `EdsTheme` 全局存储改为 `EdsThemeData`
- [ ] 更新相关 equality / copyWith / tests
- [ ] 本 Batch commit 完成



实现：

- EdsThemeData
- EdsColorSeeds
- EdsColorSeedOverrides
- EdsDesignTokens 删除 colors
- Preset 改用 EdsThemeData
- Theme global storage 改为 EdsThemeData

此批允许组件暂时编译失败，只在分支持续推进。

建议 commit：

    refactor: introduce ColorScheme 2.0 theme data and seeds

---

# 64. Batch 2 — Palette / Semantic Scheme

阶段任务：

- [ ] 添加 `material_color_utilities` 直接依赖
- [ ] 实现 `EdsTonalPalette`
- [ ] 实现 `EdsNeutralFoundation`
- [ ] 实现新的 `EdsColorScheme`
- [ ] 实现 Brand / Information / Success / Warning / Danger Tone Mapping
- [ ] 实现 `EdsSemanticColorOverrides`
- [ ] 实现 Semantic Override merge
- [ ] 增加基础 contrast tests
- [ ] 本 Batch commit 完成



实现：

- material_color_utilities direct dependency
- EdsTonalPalette wrapper
- EdsNeutralFoundation
- New EdsColorScheme
- Tone Mapping
- EdsSemanticColorOverrides
- Semantic merge
- basic contrast tests

建议 commit：

    feat: add tonal palettes and semantic color scheme

---

# 65. Batch 3 — Theme Resolver / Scope

阶段任务：

- [ ] 实现 `EdsThemeResolver`
- [ ] 实现 `EdsResolvedTheme`
- [ ] 重构 `EdsThemeScope`
- [ ] Theme / brightness 变化时只 resolve 必要内容
- [ ] `context.edsScheme` 改为读取 resolved scheme
- [ ] 增加必要的 theme / seeds context accessor
- [ ] 验证 global / subtree / brightness override
- [ ] 本 Batch commit 完成



实现：

- EdsThemeResolver
- EdsResolvedTheme
- EdsThemeScope resolve-on-change
- context.edsScheme 改为直接读取 resolved object
- context.edsSeeds / edsThemeData 等必要 accessor
- brightness 正确触发 re-resolve

建议 commit：

    refactor: resolve semantic theme in EdsThemeScope

---

# 66. Batch 4 — Interaction Resolver

阶段任务：

- [ ] 定义内部 Interaction State 模型
- [ ] 实现 Neutral interaction mapping
- [ ] 实现 Chromatic tone movement
- [ ] 接入 Hover
- [ ] 接入 Pressed
- [ ] 用 Button 作为第一验证组件
- [ ] 增加 Light / Dark interaction tests
- [ ] 本 Batch commit 完成



实现：

- State enum / internal state model
- Neutral state mapping
- Chromatic tone movement
- Button hover / pressed 先接入用于验证

建议 commit：

    feat: add semantic interaction color resolver

---

# 67. Batch 5 — Layer / Context

阶段任务：

- [ ] 实现 `EdsLayer`
- [ ] 实现 `EdsLayerScope`
- [ ] 实现 `EdsLayerResolver`
- [ ] Page 建立 Base Context
- [ ] Card / Group 建立 Raised / Nested Context
- [ ] Dialog / Menu 建立 Overlay Context
- [ ] Field 读取当前 Context
- [ ] 超过最大层级时正确 clamp
- [ ] 增加 Layer tests
- [ ] 本 Batch commit 完成



实现：

- EdsLayer
- EdsLayerScope
- EdsLayerResolver
- Page / Card / Group / Overlay 建立 Context
- Field 读取 Context

建议 commit：

    feat: add layered surface color context

---

# 68. Batch 6 — Button 全量迁移

阶段任务：

- [ ] `EdsButtonTone.accent → brand`
- [ ] 新增 `information` tone
- [ ] filled 映射到 Semantic Roles
- [ ] medium 映射到新 Palette / Recipe
- [ ] outline 映射到 Semantic Roles
- [ ] soft 映射到 Semantic Roles
- [ ] plain 映射到 Semantic Roles
- [ ] Hover / Pressed 改用 Interaction Resolver
- [ ] Focus 使用 Focus Recipe
- [ ] Disabled 改用 Disabled Roles
- [ ] 删除旧 soft / raw color derivation
- [ ] 更新 Button tests
- [ ] 本 Batch commit 完成



实现：

- accent → brand
- information tone
- Emphasis semantic mapping
- Hover / Pressed resolver
- Disabled roles
- 删除旧 soft / raw derivation

更新 tests。

建议 commit：

    refactor: migrate EdsButton to ColorScheme 2.0

---

# 69. Batch 7 — Form / Choice Controls

阶段任务：

- [ ] 迁移 `EdsTextField`
- [ ] 迁移 `EdsTextFormField`
- [ ] 迁移 `EdsDropdown`
- [ ] 迁移 `EdsDropdownFormField`
- [ ] 迁移 `EdsCheckbox`
- [ ] 迁移 `EdsRadio`
- [ ] 迁移 `EdsRadioGroup`
- [ ] 迁移 `EdsSegmented`
- [ ] 迁移 `EdsSlider`
- [ ] Field 正确接入 Layer Context
- [ ] Focus / Error / Selected / Disabled / Hover 语义统一
- [ ] 更新相关 tests
- [ ] 本 Batch commit 完成



迁移：

- TextField
- TextFormField
- Dropdown
- DropdownFormField
- Checkbox
- Radio
- Segmented
- Slider

建议优先统一 Field 内部 helper。

建议 commit：

    refactor: migrate form controls to semantic colors

---

# 70. Batch 8 — Pills / Badge / Navigation

阶段任务：

- [ ] 迁移普通 Pill
- [ ] 迁移 `EdsChoicePill`
- [ ] 迁移 `EdsBadge`
- [ ] 迁移 `EdsSidebar`
- [ ] 迁移 selectable rows / navigation state
- [ ] Selected 使用 Brand Roles
- [ ] 清理相关 raw color API
- [ ] 更新相关 tests
- [ ] 本 Batch commit 完成



迁移：

- Pill
- ChoicePill
- Badge
- Sidebar
- selectable rows / navigation state

建议 commit：

    refactor: migrate choice and navigation components to semantic colors

---

# 71. Batch 9 — Surface / Dialog / Menu / States / Easy

阶段任务：

- [ ] 迁移 `EdsPage`
- [ ] 迁移 `EdsCard`
- [ ] 迁移 `EdsGroup`
- [ ] 迁移 Dialog
- [ ] 迁移 Menu
- [ ] 迁移 States
- [ ] 迁移 `EdsEasy`
- [ ] 迁移 `EdsEasyRecipe`
- [ ] page / raised / overlay surface 语义统一
- [ ] 更新相关 tests
- [ ] 本 Batch commit 完成



迁移：

- Page
- Card
- Group
- Dialog
- Menu
- States
- EdsEasy
- Easy Recipe
- remaining semantic surfaces

建议 commit：

    refactor: migrate surfaces and Easy API to ColorScheme 2.0

---

# 72. Batch 10 — JSON Theme 2.0

阶段任务：

- [ ] 实现新 colors.seeds schema
- [ ] 实现 semanticOverrides.light
- [ ] 实现 semanticOverrides.dark
- [ ] 保留 spacing / radius / typography / controlSize / adaptiveLayout / heroGradient / stroke / shadow 原 schema
- [ ] 更新 bundled default theme JSON
- [ ] 默认 JSON 显式包含 stroke / shadow
- [ ] 实现 decode
- [ ] 实现 encode
- [ ] 实现 round-trip tests
- [ ] 实现旧 colors schema rejection tests
- [ ] 本 Batch commit 完成



实现：

- New JSON Schema
- decode
- encode
- bundled default theme JSON
- preset consistency tests
- old schema rejection tests

建议 commit：

    feat: replace theme JSON schema with ColorScheme 2.0

---

# 73. Batch 11 — Catalog

阶段任务：

- [ ] 新增 Color Foundation 页面
- [ ] 新增 Layer 页面
- [ ] 新增 Component Matrix
- [ ] 支持 Blue / Orange / Purple 切换
- [ ] 支持 Light / Dark 切换
- [ ] 校准 Brand Tone Mapping
- [ ] 校准 Warning Tone Mapping
- [ ] 校准 Surface hierarchy
- [ ] 校准 Border strength
- [ ] 校准 Hover / Pressed
- [ ] 校准 Focus visibility
- [ ] 本 Batch commit 完成



实现：

- Color Foundation page
- Layer page
- Component Matrix
- Theme switch
- Light / Dark switch

视觉校准：

- Tone Mapping
- Warning
- Surface hierarchy
- Border strength
- Hover / Pressed
- Focus visibility

允许在此阶段修改内部 Mapping 数字，但不随意修改已经确定的公开 API。

建议 commit：

    feat: add ColorScheme 2.0 catalog coverage

---

# 74. Batch 12 — 清理旧颜色体系

阶段任务：

- [ ] 清理 `primary`
- [ ] 清理 `accent`
- [ ] 清理 `primarySoft`
- [ ] 清理 `accentSoft`
- [ ] 清理 `successSoft`
- [ ] 清理 `warningSoft`
- [ ] 清理 `dangerSoft`
- [ ] 清理 `textPrimary` 旧语义
- [ ] 清理 `pageBackground`
- [ ] 清理 `cardBackground`
- [ ] 清理 `subtleFill`
- [ ] 删除 dead helpers
- [ ] 更新旧注释 / Swift compatibility wording
- [ ] 本 Batch commit 完成



全仓搜索并确认不存在：

    primary
    accent
    primarySoft
    accentSoft
    successSoft
    warningSoft
    dangerSoft
    textPrimary
    pageBackground
    cardBackground
    subtleFill

注意：

某些非 ColorScheme 语境中的 primary 字样可能合理，需要人工判断。

删除：

- dead helpers
- old docs
- old JSON comments
- Swift compatibility wording that no longer适用

建议 commit：

    refactor: remove legacy color system

---

# 75. Batch 13 — 文档 / README / CHANGELOG

阶段任务：

- [ ] 更新 README Theme 初始化
- [ ] 更新 Seed 示例
- [ ] 更新 Semantic Override 示例
- [ ] 更新 JSON 示例
- [ ] 更新 Button Tone 示例
- [ ] 编写 Breaking Migration Guide
- [ ] 更新 CHANGELOG
- [ ] 核对设计规范 / API 规范 / 技术方案一致性
- [ ] 本 Batch commit 完成



更新：

- README
- Theme initialization
- JSON sample
- Button tone example
- Host semantic override
- Breaking migration guide
- Catalog screenshots if repository惯例需要
- CHANGELOG

建议 commit：

    docs: document ColorScheme 2.0 migration

---

# 76. Batch 14 — 最终 CI

阶段任务：

- [ ] `flutter pub get`
- [ ] `dart format --set-exit-if-changed .`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] 检查 public API
- [ ] 检查 JSON round-trip
- [ ] 检查 bundled assets
- [ ] 检查 Blue / Orange / Purple
- [ ] 检查 Light / Dark
- [ ] 检查所有 presets
- [ ] CI 全绿
- [ ] 本 Batch commit 完成



严格运行：

    flutter pub get
    dart format --set-exit-if-changed .
    flutter analyze
    flutter test

另外检查：

- package public API
- JSON round-trip
- bundled assets
- Light / Dark catalog
- all presets

通过后才能发布。

---

# 77. Host App 迁移顺序

EDS 发布 Breaking Version 后：

## RightClickMate

先处理：

- Theme setup
- primary → brand
- compile errors
- deprecated / deleted API
- component visuals

然后进行 Windows 实机回归。

## VideoHero

再迁：

- Theme / brand
- ColorScheme APIs
- actual component use

宿主反馈回流 EDS。

---

# 78. Host Migration 原则

因为本次明确不保留 compatibility aliases：

> 编译错误就是迁移清单。

不增加 temporary deprecated shims。

迁移完成后 Host 应只使用：

- Preset
- Seeds
- Semantic Overrides
- Semantic Component APIs

---

# 79. 版本建议

这是明显 Breaking Change。

当前包仍处于 0.x。

从 SemVer 角度，0.x 的 minor version 可以承载 breaking change。

建议下一版本至少升级为：

    0.4.0

不建议继续 0.3.2。

原因：

- Theme model 重构
- JSON schema 重构
- primary → brand
- EdsDesignTokens public API breaking
- ColorScheme public API breaking

最终版本号可在开发完成时确认。

---

# 80. 风险清单

## 风险 1：Palette 颜色“技术合理但不好看”

解决：

- Catalog
- Tone Mapping 可配置在内部
- 不把 tone number 暴露成 public API

## 风险 2：Warning 对比度

解决：

- family-specific Tone Map
- contrast test

## 风险 3：Layer 太复杂

解决：

- 只支持 base / raised / nested / overlay
- nested 后 clamp

## 风险 4：Theme API 入口过多

解决：

- EdsThemeData 为单一完整模型
- ThemeScope 参数冲突 assert
- README 分三档使用方式

## 风险 5：Semantic Override 破坏视觉

这是高级 API 的合理风险。

解决：

- 文档
- debug diagnostics
- 不自动篡改 Host 颜色

## 风险 6：组件迁移遗漏旧颜色逻辑

解决：

- 全仓关键词清理
- test
- catalog
- Host compile migration

---

# 81. 本轮不做的事情

为了控制范围，本轮不同时解决：

- 完整 Windows High Contrast Theme
- Dynamic OS accent 自动跟随
- 用户自定义 Component Recipe
- 每组件 raw color override
- Material ColorScheme 自动桥接
- 无限 Layer 深度
- Hero Gradient 自动从 Brand Seed 推导
- 完整 Golden Test 基础设施重建

这些以后按真实需求决定。

---

# 82. Definition of Done

ColorScheme 2.0 开发完成必须满足：

1. EdsColorTokens 已删除
2. primary / accent 旧颜色 API 已删除
3. EdsDesignTokens 不再保存 colors
4. EdsThemeData 成为完整 Theme Configuration
5. Default Preset 零配置工作
6. Host 可以部分替换 Seeds
7. Host 可以分别覆盖 Light / Dark Semantic Roles
8. Seed → Tonal Palette → Semantic Mapping 工作
9. Neutral Foundation 工作
10. Interaction Resolver 工作
11. Layer Context 工作
12. 所有 Eds 高层组件迁移到 Semantic Scheme
13. 不存在单组件 Raw Color Override API
14. JSON Theme 2.0 工作
15. exportJsonString 导出配置，不导出 runtime resolved snapshot
16. Blue / Orange / Purple Light/Dark Catalog 检查通过
17. Contrast tests 通过
18. flutter analyze 通过
19. flutter test 通过
20. README / CHANGELOG / Migration Guide 完成

---

# 83. 实施时的决策优先级

如果开发过程中出现设计冲突，按以下顺序决策：

    设计规范
        ↓
    API 设计规范
        ↓
    本技术方案
        ↓
    现有 0.3.1 实现

也就是说：

> 不能为了少改旧代码而破坏已经确定的 ColorScheme 2.0 架构。

---

# 84. 最终建议

本轮不再继续纯设计迭代。

建议直接按照本计划进入开发分支。

开发过程中重点用：

- Compile errors
- Unit tests
- Catalog
- RightClickMate real host

反向检查设计。

如果发现真正的设计矛盾，再同步修订 Design Spec / API Spec。

这比继续在实现前增加 Draft 2、Draft 3 更有效。

---

# 85. 一句话总结

> 本轮改造的核心不是“换一批颜色”，而是把 easy_design_system 从直接引用颜色值的组件库，升级成 Seed 驱动、Semantic Role 稳定、Layer 与 State 可解析、Host 可主题化但不能破坏 Component Recipe 的完整设计系统。
