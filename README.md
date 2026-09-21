# easy_design_system

[![CI](https://github.com/kyinwind/easy_design_system/actions/workflows/ci.yml/badge.svg)](https://github.com/kyinwind/easy_design_system/actions/workflows/ci.yml)

easy_design_system 是一套面向 Flutter 多平台应用的设计系统，是 Swift 版 [EasyDesignSystem](https://github.com/kyinwind/EasyDesignSystem) 的忠实移植。它使用统一的语义 API，让 Android、iOS、macOS、Windows、Linux 与 Web 应用快速获得一致的界面，同时为特殊页面保留完整的精细控制能力。两边的 JSON 主题 schema 完全兼容，同一份主题文件可以在 SwiftUI 与 Flutter 应用之间复用。

- Flutter ≥ 3.27 / Dart ≥ 3.6
- 纯 Dart，无 platform channel，无三方运行时依赖
- API 前缀：`Eds`
- 亮暗双外观、交互形态自适应、无障碍大字号自适应

## 1. 设计理念

### 调用方描述"这是什么"

业务代码更适合表达页面结构和业务语义，而不是重复声明颜色、padding、圆角和阴影。

```dart
Column(
  children: [
    // 业务内容
  ],
).easyDesign(style: EdsEasyStyle.card);
```

调用方只说明这是一张 Card，easy_design_system 负责将它映射为卡片的内边距、语义背景、圆角、边框和阴影。

### 易用 API 与精细 API 并行

easy_design_system 提供两层 API：

| API | 适合场景 | 调用方负责 | easy_design_system 负责 |
| --- | --- | --- | --- |
| Easy API | 大多数普通页面 | 声明 Page、Section、Group、Card 等语义 | 整体色彩、宽度、padding 和表面层级 |
| 精细 API | 特殊布局、定制页面、底层组件 | 选择组件、Token 和具体参数 | 提供一致的 Token、组件和渲染原语 |

两层 API 不互相排斥。一个页面可以用 Easy API 管理整体层级，内部继续使用 `EdsButton`、`EdsBadge`、`EdsSettingRow` 等业务语义组件。

### 最佳实践不等于"所有地方都填色"

Page、Content、Section 和 Plain 默认继承宿主背景，让 `Scaffold`/`Material` 的外观和原有容器层级自然生效。Group 和 Card 只在需要表达内容分组或独立层级时绘制自适应语义表面。

### Easy API 只作用于组合容器

Easy API 不定义 `.button` 或 `.text` 这类叶子样式。按钮的确定、次要、危险等含义仍由调用方显式提供：

```dart
EdsButton('确定', role: EdsButtonRole.primary, action: confirm);

EdsButton('删除', role: EdsButtonRole.danger, action: delete);
```

## 2. 安装

> 本包不发布到 pub.dev。注意：pub.dev 上的 `easy_design_system` 是另一个无关的包，**不要**对它执行 `flutter pub add easy_design_system`。

方式一：本地路径依赖（推荐，自己的项目与本仓库在同一台机器上时，改动即时生效）：

```yaml
dependencies:
  easy_design_system:
    path: ../easy_design_system
```

方式二：Git 依赖（其他机器或 CI 构建时，用标签锁定版本）：

```yaml
dependencies:
  easy_design_system:
    git:
      url: https://github.com/kyinwind/easy_design_system.git
      ref: 0.1.0
```

然后在 Dart 文件中导入：

```dart
import 'package:easy_design_system/easy_design_system.dart';
```

## 3. 使用向导

如果你只想快速开始，完成下面两个步骤就可以使用 easy_design_system。后续章节都是更详细的规则、定制能力和组件参考，可以需要时再阅读。

### 步骤一：在 App 初始化时配置主题

在 `main()` 中完成一次全局配置，并用 `EdsThemeScope` 包裹 `MaterialApp`：

```dart
import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';

void main() {
  // Dart Token 不可变，configure 通过 copyWith 返回新值（对应 Swift 的 inout 闭包）。
  EdsTheme.instance.configure((tokens) {
    return tokens.copyWith(
      colors: tokens.colors.copyWith(primary: const Color(0xFF0000FF)),
    );
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EdsThemeScope(
      // 不显式传 tokens 时，Scope 订阅全局主题；
      // 之后修改 EdsTheme.instance 会让整棵子树自动重建。
      child: MaterialApp(
        theme: ThemeData(fontFamily: 'PingFang SC'),
        home: const SettingsPage(),
      ),
    );
  }
}
```

如果不想手动配置 Token，也可以直接选择预设主题：

```dart
void main() {
  EdsTheme.instance.applyPreset(EdsPresetTheme.orange);
  runApp(const MyApp());
}
```

当前提供 `defaultTheme`、`blue`、`orange` 和 `purple`，其中 `blue` 是 `defaultTheme` 的别名。不配置时使用内置默认主题，零配置即可启动。

### 步骤二：用 Easy API 编写页面

编写页面时，只需要记住这个常用层级：

```text
Page
└── Section
    ├── Group
    │   └── Row / Toggle / Button
    └── Card
        └── 业务内容
```

- Page 是页面根内容，使用 `.easyDesign()`。
- Section 是页面中的一个信息区块，使用 `.easyDesign(style: EdsEasyStyle.section)`。
- Group 把同一功能的内容组织在一起，使用 `.easyDesign(style: EdsEasyStyle.group)`。
- Card 用于需要独立视觉层级的内容，使用 `.easyDesign(style: EdsEasyStyle.card)`。

下面是一个可直接参考的完整设置页：

```dart
import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _automaticUpdates = true;

  void _purchase() {
    // 执行业务操作
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EdsPageTitle('设置', subtitle: '管理应用偏好'),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EdsSectionTitle('通用'),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EdsSettingRow(
                      '自动更新',
                      subtitle: '定期检查是否有新版本。',
                      trailing: EdsToggle(
                        isOn: _automaticUpdates,
                        label: '启用',
                        onChanged: (value) =>
                            setState(() => _automaticUpdates = value),
                      ),
                    ),
                  ],
                ).easyDesign(style: EdsEasyStyle.group),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EdsSectionTitle(
                      '专业版',
                      subtitle: '解锁更多高级功能。',
                    ),

                    Row(
                      children: [
                        const EdsBadge('推荐', style: EdsBadgeStyle.accent),
                        const Spacer(),
                        EdsButton(
                          '立即升级',
                          role: EdsButtonRole.primary,
                          action: _purchase,
                        ),
                      ],
                    ),
                  ],
                ).easyDesign(style: EdsEasyStyle.card),
              ],
            ).easyDesign(style: EdsEasyStyle.section),
          ],
        ).easyDesign(),
      ),
    );
  }
}
```

这个页面中：

- `.easyDesign()` 自动应用页面 padding、居中的最大宽度和主题前景色。
- `.section` 建立页面区块的垂直节奏。
- `.group` 自动应用轻量语义背景、padding 和圆角。
- `.card` 自动应用卡片背景、padding、圆角、边框和阴影。
- `EdsButton(role:)` 和 `EdsBadge(style:)` 仍由业务代码指定"主要操作"或"强调状态"等语义。

> Easy API 不会自动添加滚动、导航和页面标题，因为这些属于页面结构，应由调用方决定。

到这里就已经完成了 easy_design_system 的基本接入。需要更多场景、局部覆盖、主题或精细组件时，再继续阅读后面的章节。

## 4. Easy API

### 最小用法

`.easyDesign()` 默认等价于 `.easyDesign(style: EdsEasyStyle.page)`：

```dart
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EdsPageTitle('设置'),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EdsLabelText('自动更新'),
            EdsToggle(
              isOn: true,
              label: '启用',
              onChanged: (value) {},
            ),
          ],
        ).easyDesign(style: EdsEasyStyle.group),
      ],
    ).easyDesign();
  }
}
```

Page 会应用主题环境、默认文本样式、页面 padding 和居中的最大内容宽度。

> `.easyDesign(style: EdsEasyStyle.page)` 是样式修饰器，不会隐式添加滚动、导航或页面标题。需要完整页面骨架时可以使用后文的 `EdsPage`。

### 六种语义场景

| 场景 | 用途 | 默认行为 |
| --- | --- | --- |
| `EdsEasyStyle.page` | 普通页面根内容 | 页面 padding、最大宽度 880、居中、继承背景 |
| `EdsEasyStyle.content` | 已位于导航或滚动容器内的内容 | 轻量 padding、填满可用宽度、继承背景 |
| `EdsEasyStyle.section` | 页面中的信息区块 | 垂直节奏、填满可用宽度、继承背景 |
| `EdsEasyStyle.group` | 同一功能的内容集合 | 分组 padding、subtle 语义表面、圆角、无阴影 |
| `EdsEasyStyle.card` | 需要独立视觉层级的内容 | 卡片 padding、语义表面、圆角、边框和阴影 |
| `EdsEasyStyle.plain` | 只希望子树跟随主题 | 仅应用主题和文本样式，不改变几何尺寸 |

一个常规页面的层级通常是：

```text
Page
└── Section
    ├── Group
    │   └── Row / Toggle / Button
    └── Card
        └── 业务内容
```

### Page、Section、Group 和 Card

```dart
SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const EdsPageTitle('设置', subtitle: '管理应用偏好'),

      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EdsSectionTitle('通用'),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EdsSettingRow(
                '自动更新',
                trailing: EdsToggle(
                  isOn: isEnabled,
                  label: '启用',
                  onChanged: (value) {},
                ),
              ),
            ],
          ).easyDesign(style: EdsEasyStyle.group),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EdsLabelText('专业版功能'),
              EdsButton('升级', role: EdsButtonRole.primary, action: purchase),
            ],
          ).easyDesign(style: EdsEasyStyle.card),
        ],
      ).easyDesign(style: EdsEasyStyle.section),
    ],
  ).easyDesign(),
)
```

### 局部覆盖

Easy API 只开放少量高频覆盖，避免将易用入口重新扩张成另一套 Token API：

```dart
ContentView().easyDesign(
  style: EdsEasyStyle.page,
  options: const EdsEasyOptions(
    padding: EdsSpace.xl,
    maxContentWidth: EdsEasyWidth.fixed(960),
    background: EdsEasyVisibility.visible,
  ),
);
```

#### Padding

```dart
padding: EdsSpace.automatic // 使用场景的默认配方
padding: EdsSpace.none      // 明确取消 padding
padding: EdsSpace.xl        // 使用当前主题 spacing.xl
```

可用语义间距为 `EdsSpace.xxs`、`xs`、`sm`、`md`、`lg`、`xl`、`xxl` 和 `xxxl`。

#### 内容宽度

```dart
maxContentWidth: EdsEasyWidth.automatic
maxContentWidth: EdsEasyWidth.fixed(960)
maxContentWidth: EdsEasyWidth.unlimited
```

#### 背景策略

```dart
background: EdsEasyVisibility.automatic
background: EdsEasyVisibility.visible
background: EdsEasyVisibility.hidden
```

`automatic` 使用场景配方。`visible` 要求绘制对应的语义表面，`hidden` 要求继承父容器背景。

### 嵌套 Easy API

每次显式调用都会生效：

```dart
Column(
  children: [
    const DetailView().easyDesign(style: EdsEasyStyle.card),
  ],
).easyDesign();
```

系统不会猜测或去重调用方的语义。常规页面保持 Page → Section → Group/Card 两到四层即可。

### 平台自动适配

同一份页面代码可以直接用于移动端和桌面端，无需在业务层判断平台：

```dart
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EdsPageTitle('账户'),
          EdsSettingRow(
            '自动同步',
            trailing: EdsToggle(
              isOn: true,
              label: '启用',
              onChanged: (value) {},
            ),
          ).easyDesign(style: EdsEasyStyle.group),
        ],
      ).easyDesign(style: EdsEasyStyle.page),
    );
  }
}
```

easy_design_system 会按运行平台自动选择交互档案：

| 运行环境 | 默认档案 | 主要行为 |
| --- | --- | --- |
| Android / iOS / 移动端 Web | Touch | 44pt 最小触控目标、紧凑或常规页面边距 |
| macOS / Windows / Linux 桌面 | Pointer | 保留桌面端紧凑控件、启用 Hover 增强 |
| 触屏 + 键盘混合设备 | 不自动判定 | 需要时显式指定 `hybrid`（见下） |

页面在紧凑宽度下默认使用 16pt 边距，在常规宽度下默认使用 32pt 边距，内容最大宽度默认是 880pt。显式传入 Easy API 的 `padding` 或 `maxContentWidth` 时，显式值始终优先。

通常不需要覆盖自动判断；预览特殊环境或构建自定义容器时，可以在局部指定档案：

```dart
ContentView().easyDesignInteractionProfile(EdsInteractionProfile.touch);
```

也可以通过主题统一调整自适应值：

```dart
EdsTheme.instance.configure((tokens) {
  return tokens.copyWith(
    adaptiveLayout: tokens.adaptiveLayout.copyWith(
      compactPagePadding: 20,
      regularPagePadding: 36,
      readableContentMaxWidth: 960,
      minimumTouchTarget: 44,
    ),
  );
});
```

## 5. 主题

### 全局主题

建议在 `main()` 阶段完成全局配置：

```dart
void main() {
  EdsTheme.instance.configure((tokens) {
    return tokens.copyWith(
      colors: tokens.colors.copyWith(primary: const Color(0xFF0000FF)),
      spacing: tokens.spacing.copyWith(lg: 22),
    );
  });

  runApp(const MyApp());
}
```

也可以使用内置预设：

```dart
EdsTheme.instance.applyPreset(EdsPresetTheme.orange);
```

当前提供 `defaultTheme`、`blue`、`orange` 和 `purple`，其中 `blue` 是 `defaultTheme` 的别名。

> **主题色只有一个字段：`tokens.colors.primary`。** 组件里所有"跟随主题色"的渲染（实心按钮、浅底按钮、侧边栏选中态）都读它。`tokens.colors.accent` 仅为兼容 Swift JSON schema 保留，包内不读取——变更主题色请改 `primary`。

### 运行时换主题

`EdsTheme.instance` 基于 `ValueNotifier`。`EdsThemeScope` 未显式传 tokens 时会订阅全局变化，任何时刻再次 `configure` / `applyPreset`，整棵子树自动重建，无需额外代码。也可以直接监听：

```dart
ListenableBuilder(
  listenable: EdsTheme.instance.tokensListenable,
  builder: (context, _) => const ThemeIndicator(),
)
```

### 局部主题

局部主题通过 `EdsThemeScope`（InheritedWidget）传递，不会修改 `EdsTheme.instance`：

```dart
PurchaseCard().easyDesignPreset(
  EdsPresetTheme.orange,
  style: EdsEasyStyle.card,
);
```

也可以直接传入 Token：

```dart
final customTokens = const EdsDesignTokens().copyWith(
  colors: const EdsColorTokens().copyWith(
    primary: Color(0xFFAF52DE),
  ),
);

PurchaseCard().easyDesignTokens(
  customTokens,
  style: EdsEasyStyle.card,
);
```

如果只希望传递主题，不应用任何 Easy 布局或表面：

```dart
ContentView().easyDesignThemePreset(EdsPresetTheme.purple);

ContentView().easyDesignTheme(customTokens);
```

也可以直接用 Scope 挂载局部主题或亮度覆盖：

```dart
EdsThemeScope(
  preset: EdsPresetTheme.orange,
  brightness: Brightness.dark, // 缺省跟随 MediaQuery 平台亮度
  child: const PurchaseCard(),
)
```

### 在自定义 Widget 中读取主题

需要跟随局部主题时，从 context 读取：

```dart
class CustomPanel extends StatelessWidget {
  const CustomPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens; // 局部优先，回退全局
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.spacing.md,
      children: [
        // ...
      ],
    );
  }
}
```

只关心全局主题时，仍可以使用简单的直接读取：

```dart
EdsTheme.instance.tokens.spacing.md
EdsTheme.instance.tokens.colors.primary
```

语义色（含亮暗解析）通过 `context.edsScheme` 读取：

```dart
final scheme = context.edsScheme;
scheme.textPrimary;    // 主文本
scheme.textSecondary;  // 次文本
scheme.pageBackground; // 页面背景（亮 #F7F7F7 / 暗 #1E1E20）
scheme.cardBackground; // 卡片背景（亮 #FFFFFF / 暗 #2A2A2C）
scheme.border;         // 发丝分隔线
```

## 6. 精细 API

当页面需要完整骨架、特殊布局或具体参数时，使用精细 API。

### 完整页面骨架

`EdsPage` 负责页面标题、可选滚动、内容限宽、padding 和 Section 节奏：

```dart
EdsPage(
  '设置',
  subtitle: '管理应用偏好',
  child: EdsPageSection(
    '通用',
    showsDivider: true,
    child: EdsGroup(
      '常用偏好',
      child: EdsSettingRow(
        '自动更新',
        subtitle: '启动后检查新版本。',
        trailing: EdsToggle(
          isOn: isEnabled,
          label: '启用',
          onChanged: (value) {},
        ),
      ),
    ),
  ),
)
```

`EdsPage` 默认不显式绘制背景，让宿主的语义背景自然跟随浅色与深色模式；需要时传 `showsBackground: true`。已经处于自定义 `ScrollView` 或导航容器时，可以只使用 `EdsPageStack`。

### 容器

```dart
// 默认 EdsGroup：浅色分组背景、padding 和圆角
EdsGroup('通用', subtitle: '常用偏好', child: content)

// 默认 EdsCard：只提供 padding，不绘制背景
EdsCard(child: content)

// 需要时显式提供背景
EdsCard(background: context.edsScheme.cardBackground, child: content)
```

精细组件的默认行为不强制等于 Easy Recipe。例如 Easy `.card` 会提供完整卡片表面，而精细 `EdsCard` 默认是轻量 padding 容器。

### 按钮、徽章与开关

```dart
Row(
  children: [
    EdsButton('主要操作', role: EdsButtonRole.primary, action: () {}),
    EdsButton('次要操作', role: EdsButtonRole.secondary, action: () {}),
    EdsButton('轻量操作', role: EdsButtonRole.soft, action: () {}),
    EdsButton('危险操作', role: EdsButtonRole.danger, action: () {}),
    EdsButton('已完成', role: EdsButtonRole.done, action: () {}),
  ],
)

Row(
  children: const [
    EdsBadge('Pro', style: EdsBadgeStyle.accent),
    EdsBadge('已完成', style: EdsBadgeStyle.success),
    EdsBadge('待处理', style: EdsBadgeStyle.warning),
    EdsBadge('失败', style: EdsBadgeStyle.danger),
  ],
)

EdsToggle(isOn: isEnabled, label: '启用自动处理', onChanged: (value) {})
```

> Dart 没有 `.disabled()` 修饰器：`action` 传 `null` 即渲染为禁用态并忽略点击。

#### 按钮的三个维度

按钮外观由三个**正交**维度决定，可以自由组合：

| 维度 | 取值 | 含义 |
| --- | --- | --- |
| `Emphasis` | `filled` `outline` `soft` `plain` | 视觉分量——这块按钮"多重" |
| `Tone` | `accent` `neutral` `danger` `success` `warning` | 语义色调——这块按钮"是什么性质" |
| `Size` | `small`(28) `regular`(34) `large`(44) | 尺寸档位 |

```dart
EdsButton.dimension(
  '忽略并删除',
  emphasis: EdsButtonEmphasis.soft,
  tone: EdsButtonTone.danger,
  action: () {},
);

EdsButton.dimension(
  '更多',
  emphasis: EdsButtonEmphasis.plain,
  systemImage: Icons.more_horiz,
  action: () {},
);

EdsButton.dimension(
  '刷新',
  emphasis: EdsButtonEmphasis.outline,
  size: EdsButtonSize.small,
  action: () {},
);

EdsButton.dimension(
  '开始处理',
  emphasis: EdsButtonEmphasis.filled,
  size: EdsButtonSize.large,
  action: () {},
);
```

`role:` 参数是一张**预设别名表**：一个角色等价于一组固定的三维组合。

| `Role` | 等价于 |
| --- | --- |
| `primary` | `filled` + `accent` + `regular` |
| `secondary` | `outline` + `accent` + `regular` |
| `soft` | `soft` + `accent` + `regular` |
| `danger` | `filled` + `danger` + `regular` |
| `done` | `filled` + `success` + `regular`，并自动补 `check` 图标 |

两种写法汇入同一份渲染实现，可以在同一页面里混用。需要自定义预设时，用 `EdsButtonAppearance` 组合三维后，通过 `EdsButton.label` 传自定义内容。

> 三维写法要求至少给出 `emphasis:`，与 Swift 版约束一致。

标题参数只接受 `String`（Swift 的 `LocalizedStringKey` 在 Dart 无对应物）。App 若自带本地化函数（返回 `String`），可以直接传入：

```dart
EdsButton(l('button.cancel'), role: EdsButtonRole.secondary, action: onCancel);
```

需要完全自定义按钮内容时使用 `EdsButton.label`：

```dart
EdsButton.label(
  Row(
    children: const [
      Icon(Icons.download),
      SizedBox(width: 8),
      Text('下载全部'),
    ],
  ),
  role: EdsButtonRole.primary,
  action: downloadAll,
);
```

### 文本与行

```dart
const EdsPageTitle('设置', subtitle: '管理应用偏好')
const EdsSectionTitle('通用', subtitle: '基础设置')
const EdsLabelText('输出路径')
const EdsCaptionText('修改后会影响新文件。')
const EdsMonoText('/Users/name/Documents/Exports')

const EdsSettingRow(
  '图片格式',
  subtitle: '批量处理的默认格式。',
  trailing: EdsBadge('PNG', style: EdsBadgeStyle.accent),
)

const EdsValueRow('缓存占用', value: '240 MB')
const EdsValueRow('剩余空间', value: '仅剩 1 GB', tone: Color(0xFFE54444))
```

`EdsValueRow.tone` 直接接收 `Color?`，缺省跟随主文本。行组件会跟随交互档案自动满足最小触控目标；无障碍大字号下 `EdsSettingRow` 自动切换为上下堆叠布局。

### 状态与特殊组件

```dart
EdsEmptyState(
  title: '暂无文件',
  message: '添加文件后会显示在这里。',
  actionTitle: '添加文件',
  action: addFiles,
)

EdsErrorState(
  title: '加载失败',
  message: '请检查网络后重试。',
  actionTitle: '重试',
  action: retry,
)

const EdsLoadingState(title: '正在处理', message: '这通常只需要几秒。')

EdsProgressPanel(
  '模型下载',
  subtitle: 'Model.zip',
  fractionCompleted: progress,
  statusText: '正在下载...',
)
```

其他可用组件还包括：

- `EdsHeroPanel`：关键信息或付费权益强调面板（主题渐变 + 阴影）。
- `EdsPill` / `EdsPillFlow`：标签和自动换行的标签集合，`EdsPillFlow` 内置 12 色轮转调色板与排序。
- `EdsCollapsibleSection`：可折叠内容区。
- `EdsComparisonSection`：Free/Pro 功能对比列表（窄屏自动切换单列布局）。
- `EdsSidebarGroupView` / `EdsSidebarIcon`：设置页式侧边栏分组与彩色图标。
- `EdsIconMark`：对比表里的 ✓/– 勾选标记，也可单独使用。

```dart
// 标签集合：自动换行 + 删除按钮
EdsPillFlow(
  const ['设计', '原型', '协作'],
  onRemove: (item) {},
)

// 侧边栏分组
final items = [
  EdsSidebarMenuItem(
    label: '收件箱',
    icon: Icons.inbox,
    tint: EdsSidebarIconPresetTint.blue.color,
  ),
];

EdsSidebarGroupView(
  title: '工作区',
  items: items,
  selection: items.first.id,
  onSelectionChange: (id) {},
)
```

### 直接使用 Token

`EdsDesignTokens` 包含：

| Token | 用途 |
| --- | --- |
| `colors` | 主题色、强调色、成功/警告/危险色及派生 Soft 底色 |
| `spacing` | `xxs` 到 `xxxl` 的间距尺度 |
| `radius` | `sm` 到 `xl` 的圆角尺度 |
| `typography` | Hero、页面标题、Section、正文、Caption 和等宽字体 |
| `controlSize` | 按钮、输入框和行高 |
| `adaptiveLayout` | 紧凑/常规页面边距、可读宽度和触控目标 |
| `stroke` | 边框粗细 |
| `shadow` | 阴影颜色（hex 字符串）、透明度、半径和偏移 |
| `heroGradient` | Hero 面板渐变 |

```dart
class FineGrainedPanel extends StatelessWidget {
  const FineGrainedPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius.lg),
      child: ColoredBox(
        color: scheme.cardBackground,
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('自定义面板', style: tokens.typography.sectionTitle),
              Text(
                '这里使用完整 Token 进行精细控制。',
                style: tokens.typography.body
                    .copyWith(color: scheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

需要自适应度量值（页面边距、触控目标、可读宽度）时：

```dart
final metrics = EdsResolvedMetrics.resolve(
  tokens: context.edsTokens,
  profile: context.edsInteractionProfile,
  horizontalSizeClass: context.edsSizeClass,
);

metrics.pagePadding;                 // 当前尺寸档的页面边距
metrics.minimumInteractiveDimension; // 最小触控目标（pointer 为 0）
metrics.interactiveHeight(34);       // max(视觉高度, 触控目标)
```

### JSON 主题

可以从 Asset 加载 JSON（schema 与 Swift 版完全兼容，缺失字段自动回退默认值）：

```dart
await EdsTheme.instance.configureJsonAsset('assets/theme.json');
```

从字符串加载：

```dart
EdsTheme.instance.configureJsonString('{"colors": {"primary": "#FF6B00"}}');
```

导出当前主题：

```dart
final json = EdsTheme.instance.exportJsonString();
```

加载本包内置的默认主题文件：

```dart
await EdsTheme.instance.applyDefaultThemeFromPackage();
```

## 7. 示例

仓库的 [`example/`](example/) 提供一个可直接运行的 Catalog App（对齐 Swift 版 `Examples/Catalog`），四个 Tab 全局可切换预览主题：

- **组件** — `EdsDesignSystemGallery`：精细 API 组件 Gallery（标准页面 / 状态模式 / 基础控件 / 按钮三维模型 / 行与标签 / 容器分层）
- **Easy API** — `EdsEasyApiDesignSystemGallery`：六种语义场景效果对照（含局部主题）
- **主题** — `EdsDesignSystemPreview`：Token 可视化编辑器，实时预览 + 预设切换 + 应用到 Runtime + JSON 导出
- **设置** — 设置页骨架演示：Hero 面板 + 标签流 + 功能对比表

```bash
cd example
flutter run
```

```bash
cd example
flutter test   # 5 个 widget 用例
```

## 8. 与 Swift 版的 API 对照

| Swift | Dart | 说明 |
| --- | --- | --- |
| `EDSTheme.shared` | `EdsTheme.instance` | 单例 + `ValueListenable` |
| `tokens.colors.primary = .blue` | `tokens.copyWith(colors: ...)` | Dart Token 不可变 |
| `EDSPresetTheme.default` | `EdsPresetTheme.defaultTheme` | `default` 是 Dart 保留字 |
| `configure(jsonResource:)` | `configureJsonAsset(path)` | Dart 无重载，资产路径全名 |
| `Color(hexRGB:)` | `EdsColorHex.parseRgb` | 另有 `parseArgb` / `parseRgba` |
| `EDSButton.Role.primary` | `EdsButtonRole.primary` | 枚举置于顶层 |
| `EDSButton(_:emphasis:tone:size:)` | `EdsButton.dimension(...)` | 命名构造器 |
| `.easyDesign(_:theme:options:)` | `.easyDesignPreset(theme, ...)` | 避免扩展重名 |
| `.easyDesignTheme(_:)` | `.easyDesignTheme(tokens)` / `.easyDesignThemePreset(preset)` | scope-only 修饰器 |
| `Image(systemName: "checkmark")` | `Icons.check` | SF Symbols → Material 图标 |
| `Binding<Bool>` | `isOn` + `onChanged` | 禁用态：`action` 传 `null` |

其余有意偏差（亮暗语义色经 `EdsColorScheme.resolve` 显式解析、SwiftUI 遗留 `ButtonStyle` 不移植、`EDSSidebarIconPresetTint` 为枚举 + `.color`、文本截断用 `ellipsis`、内置文案保持中文等）与 Swift 版行为逐项对齐，测试套件移植自 `EasyDesignSystemTests`。

## 9. 开发与验证

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

测试套件逐条移植自 Swift 包的 `EasyDesignSystemTests`，钉死相同的行为契约（hex 八位语义、fixture 回退、配方映射、自适应度量、按钮角色外观）。

## 10. License

MIT — 见 [`LICENSE`](LICENSE)。
