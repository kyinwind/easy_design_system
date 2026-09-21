# Changelog

## 0.1.0

Initial release — a Flutter port of the Swift EasyDesignSystem package.

- Design tokens: colors, spacing, radius, typography, control sizes, adaptive
  layout, hero gradient, stroke, shadow.
- `EdsTheme` singleton with copyWith-style configuration, JSON string/asset
  loading (Swift-compatible schema), preset application and JSON export.
- Presets: `defaultTheme` (alias `blue`), `orange`, `purple`.
- `EdsThemeScope` environment scoping with `context.edsTokens` /
  `context.edsScheme` / `context.edsBrightness`.
- Adaptive layout: interaction profiles, size classes, resolved metrics,
  minimum hit targets.
- Easy API: `EdsEasy` + `easyDesign` / `easyDesignPreset` / `easyDesignTokens`
  extensions over six semantic scenes.
- Components: button (roles + three-dimensional appearance), badge, toggle,
  text primitives, setting/value/inline/multiline rows, card, group, hero
  panel, page, page section, section, collapsible section, empty/error/
  loading/progress states, pill flow, comparison section, sidebar widgets.
- Swift-parity test suite ported from `EasyDesignSystemTests`.
