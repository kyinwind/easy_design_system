# EDS ColorScheme 2.0 Breaking Migration Guide

日期：2026-09-27  
目标版本：0.4.0（建议）  
适用来源版本：0.3.x → ColorScheme 2.0

---

## 1. 为什么这是 Breaking Change

ColorScheme 2.0 不只是重命名颜色，而是把 EDS 从“组件直接读取颜色 Token”升级为：

```text
Theme Seed
    ↓
Semantic Color Scheme
    ↓
Component Recipe
```

因此本轮明确不保留旧颜色 API 的兼容别名。

推荐迁移方式：

> 先让编译错误完整暴露，再逐项迁移，不新增临时 compatibility shim。

---

## 2. Theme 根模型

旧：

```dart
EdsDesignTokens(
  colors: ...,
  spacing: ...,
  radius: ...,
)
```

新：

```dart
EdsThemeData(
  seeds: ...,
  semanticOverrides: ...,
  tokens: EdsDesignTokens(
    spacing: ...,
    radius: ...,
  ),
)
```

其中 `EdsDesignTokens` 继续负责：

- spacing
- radius
- typography
- controlSize
- adaptiveLayout
- heroGradient
- stroke
- shadow

颜色不再属于 `EdsDesignTokens`。

---

## 3. primary / accent → brand

旧：

```dart
tokens.colors.primary
tokens.colors.accent
```

新：

```dart
EdsTheme.instance.seeds.brand
```

宿主最常见配置：

```dart
EdsTheme.instance.configureTheme(
  seeds: const EdsColorSeedOverrides(
    brand: Color(0xFF7C4DFF),
  ),
);
```

局部配置：

```dart
EdsThemeScope(
  seeds: const EdsColorSeedOverrides(
    brand: Color(0xFF7C4DFF),
  ),
  child: const FeatureArea(),
);
```

---

## 4. Status Seeds

第一版 Seed Families：

```dart
EdsColorSeeds(
  brand: ...,
  information: ...,
  success: ...,
  warning: ...,
  danger: ...,
)
```

Host 只需要传想覆盖的 Family：

```dart
EdsColorSeedOverrides(
  brand: myBrand,
)
```

没有覆盖的 Information / Success / Warning / Danger 继续使用当前 Preset 默认值。

---

## 5. Semantic Color Scheme 重命名

旧 Role → 新 Role：

| 0.3.x | ColorScheme 2.0 |
|---|---|
| `textPrimary` | `foregroundPrimary` |
| `textSecondary` | `foregroundSecondary` |
| `textTertiary` | `foregroundTertiary` |
| `pageBackground` | `surfacePage` |
| `cardBackground` | 根据语义改为 `surfaceBase / surfaceRaised / surfaceOverlay` |
| `cardGrayBackground` | 根据语义改为 `surfaceSunken` 等 |
| `subtleFill` | 不保留一一映射；按 Component Recipe 选择 Surface |
| `border` | `borderSubtle / borderDefault / borderStrong` |

旧 Soft 色：

```text
primarySoft
accentSoft
successSoft
warningSoft
dangerSoft
```

全部删除。

对应语义改用：

```text
brandSurface
successSurface
warningSurface
dangerSurface
...
```

---

## 6. Button

旧：

```dart
EdsButtonTone.accent
```

新：

```dart
EdsButtonTone.brand
```

并新增：

```dart
EdsButtonTone.information
```

推荐：

```dart
EdsButton.styled(
  '保存',
  emphasis: EdsButtonEmphasis.filled,
  tone: EdsButtonTone.brand,
  action: save,
)
```

Button 不提供：

- backgroundColor
- hoverColor
- pressedColor
- focusColor
- disabledColor

这些全部由 Theme + Recipe + Interaction Resolver 决定。

---

## 7. Badge

旧：

```dart
EdsBadgeStyle.accent
```

新：

```dart
EdsBadgeStyle.brand
```

Status Badge 继续使用：

```dart
EdsBadgeStyle.success
EdsBadgeStyle.warning
EdsBadgeStyle.danger
```

---

## 8. EdsValueRow

旧：

```dart
EdsValueRow(
  '剩余空间',
  value: '1 GB',
  tone: Color(0xFFE54444),
)
```

新：

```dart
EdsValueRow(
  '剩余空间',
  value: '1 GB',
  tone: EdsValueTone.danger,
)
```

支持：

```text
neutral
brand
information
success
warning
danger
```

---

## 9. EdsCard / EdsGroup

标准 EDS 高层组件不再提供 arbitrary raw background。

旧：

```dart
EdsCard(
  background: customColor,
  child: content,
)
```

新：

```dart
EdsCard(
  style: EdsCardStyle.raised,
  child: content,
)
```

如果确实需要完全自由的视觉：

> 使用 Flutter 原生 Container / DecoratedBox，而不是给 EdsCard 增加例外参数。

---

## 10. Sidebar

Sidebar 使用：

```dart
EdsSidebarIconTone.blue
EdsSidebarIconTone.green
EdsSidebarIconTone.orange
...
```

其中：

- blue → Brand
- green → Success
- orange → Warning
- red → Danger

不提供单实例 raw tint API。

---

## 11. Semantic Override

当 Seed 不够表达产品需求时：

```dart
EdsThemeScope(
  semanticOverrides: const EdsSemanticOverrides(
    light: EdsSemanticColorOverrides(
      surfaceRaised: Color(0xFFFDFDFD),
    ),
    dark: EdsSemanticColorOverrides(
      surfaceRaised: Color(0xFF29292D),
    ),
  ),
  child: const FeatureArea(),
)
```

注意：

- Light / Dark 独立
- 可以只覆盖部分 Role
- 未覆盖 Role 继续自动生成
- Light Override 不会自动复制到 Dark

---

## 12. JSON Theme 2.0

旧：

```json
{
  "colors": {
    "primary": "#3185FF",
    "success": "#27B15A"
  }
}
```

新：

```json
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
  }
}
```

旧 colors schema 会明确抛出 FormatException，不做静默迁移。

非颜色分组继续保留：

- spacing
- radius
- typography
- controlSize
- adaptiveLayout
- heroGradient
- stroke
- shadow

---

## 13. Theme Listenable

旧：

```dart
EdsTheme.instance.tokensListenable
```

新：

```dart
EdsTheme.instance.themeListenable
```

全局对象现在监听的是完整 `EdsThemeData`。

---

## 14. 建议迁移顺序

1. 更新 EDS 依赖到 ColorScheme 2.0 Breaking 版本。
2. 先改 App Theme 初始化。
3. 修 `primary / accent / colors` 编译错误。
4. 修旧 Scheme Role 名称。
5. 修 Button / Badge enum。
6. 修 EdsValueRow raw color。
7. 修 Card / Group raw background。
8. 更新 Theme JSON。
9. 运行：
   - flutter analyze
   - flutter test
10. 最后做 Light / Dark 视觉回归。

---

## 15. 不应为了迁移新增的代码

不要在 Host App 自己建立：

```dart
extension LegacyColorCompatibility ...
```

也不要重新包装：

```text
primary
accent
primarySoft
cardBackground
```

如果 Host 确实需要特殊视觉：

- 系统级需求 → Semantic Override
- 单个特殊组件 → Flutter 原生组件

这样迁移完成后 Host 才真正进入 ColorScheme 2.0，而不是套着旧模型继续运行。
