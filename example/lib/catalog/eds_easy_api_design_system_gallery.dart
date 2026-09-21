import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';

import 'catalog_support.dart';

enum EasyGallerySection {
  overview('Easy API 概览', Icons.auto_awesome),
  layout('布局场景', Icons.dashboard_outlined),
  surfaces('视觉表面', Icons.layers_outlined),
  themes('局部主题', Icons.palette_outlined),
  stress('嵌套与性能', Icons.grid_view_outlined);

  const EasyGallerySection(this.label, this.icon);

  final String label;
  final IconData icon;

  String get id => name;

  static EasyGallerySection fromId(String id) {
    for (final section in EasyGallerySection.values) {
      if (section.id == id) {
        return section;
      }
    }
    return EasyGallerySection.overview;
  }

  Color get tint => switch (this) {
        EasyGallerySection.overview => const Color(0xFF007AFF),
        EasyGallerySection.layout => const Color(0xFF5856D6),
        EasyGallerySection.surfaces => const Color(0xFF30B0C7),
        EasyGallerySection.themes => const Color(0xFFFF9500),
        EasyGallerySection.stress => const Color(0xFFAF52DE),
      };

  EdsSidebarMenuItem get menuItem =>
      EdsSidebarMenuItem(id: id, label: label, icon: icon, tint: tint);
}

class EdsEasyApiDesignSystemGallery extends StatefulWidget {
  const EdsEasyApiDesignSystemGallery({super.key});

  @override
  State<EdsEasyApiDesignSystemGallery> createState() =>
      _EdsEasyApiDesignSystemGalleryState();
}

class _EdsEasyApiDesignSystemGalleryState
    extends State<EdsEasyApiDesignSystemGallery> {
  EasyGallerySection _selection = EasyGallerySection.overview;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return CatalogSplitScaffold(
      navigationTitle: 'Easy API',
      navigationSubtitle: '场景化最佳实践',
      groupTitle: '示例',
      items: <EdsSidebarMenuItem>[
        for (final section in EasyGallerySection.values) section.menuItem,
      ],
      selection: _selection.id,
      onSelectionChange: (id) => setState(() {
        _selection = EasyGallerySection.fromId(id);
      }),
      child: _selectedContent(context),
    );
  }

  Widget _selectedContent(BuildContext context) {
    return switch (_selection) {
      EasyGallerySection.overview => _overviewPage(context),
      EasyGallerySection.layout => _layoutPage(context),
      EasyGallerySection.surfaces => _surfacesPage(context),
      EasyGallerySection.themes => _themesPage(context),
      EasyGallerySection.stress => _stressPage(context),
    };
  }

  Widget _detailPage(BuildContext context, String title, String subtitle,
      List<Widget> children) {
    final tokens = context.edsTokens;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tokens.spacing.lg,
        children: <Widget>[
          EdsPageTitle(title, subtitle: subtitle),
          ...children,
        ],
      ).easyDesign(),
    );
  }

  Widget _overviewPage(BuildContext context) {
    final tokens = context.edsTokens;
    return _detailPage(
      context,
      'Easy API 概览',
      '调用方只描述这是什么，设计系统决定如何呈现。',
      <Widget>[
        EasyApiExample(
          '一行启用页面最佳实践',
          usage: 'ContentView().easyDesign()',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: tokens.spacing.xs,
            children: const <Widget>[
              Text('默认等价于 .easyDesign(.page)'),
              EdsBadge('最大内容宽度'),
              EdsBadge('页面 padding', style: EdsBadgeStyle.success),
              EdsBadge('主题前景色与 tint', style: EdsBadgeStyle.neutral),
            ],
          ).easyDesign(style: EdsEasyStyle.group),
        ),
        EasyApiExample(
          '层次是语义化的',
          usage: 'Page -> Section -> Group / Card -> 业务组件',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: tokens.spacing.xs,
            children: <Widget>[
              const Text('容器使用 Easy API，按钮继续提供业务语义。'),
              Row(
                spacing: tokens.spacing.sm,
                children: <Widget>[
                  EdsButton('确定', action: () {}),
                  EdsButton('删除', role: EdsButtonRole.danger, action: () {}),
                ],
              ),
            ],
          ).easyDesign(style: EdsEasyStyle.card),
        ),
      ],
    );
  }

  Widget _layoutPage(BuildContext context) {
    final tokens = context.edsTokens;
    return _detailPage(
      context,
      '布局场景',
      'Page、Content、Section 和 Plain 负责从页面到内容区的结构。',
      <Widget>[
        const EasyApiExample(
          'Page',
          usage: '.easyDesign()',
          child: Text('右侧整个详情页就是 Page：内容限宽、居中并应用标准外边距。'),
        ),
        EasyApiExample(
          'Content',
          usage: '.easyDesign(.content)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: tokens.spacing.xs,
            children: const <Widget>[
              Text('适合已位于导航或滚动容器内的内容。'),
              Text('默认填满可用宽度，不额外制造视觉表面。'),
            ],
          ).easyDesign(style: EdsEasyStyle.content),
        ),
        EasyApiExample(
          'Section',
          usage: '.easyDesign(.section)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: tokens.spacing.xs,
            children: <Widget>[
              const EdsSectionTitle('通知', subtitle: 'Section 负责信息结构和垂直节奏。'),
              EdsToggle(
                isOn: _notificationsEnabled,
                label: '接收更新通知',
                onChanged: (value) => setState(() {
                  _notificationsEnabled = value;
                }),
              ),
            ],
          ).easyDesign(style: EdsEasyStyle.section),
        ),
        EasyApiExample(
          'Plain',
          usage: '.easyDesign(.plain)',
          child: const Text('Plain 只传递主题、tint 和默认文本样式，不改变几何尺寸。')
              .easyDesign(style: EdsEasyStyle.plain),
        ),
      ],
    );
  }

  Widget _surfacesPage(BuildContext context) {
    final tokens = context.edsTokens;
    return _detailPage(
      context,
      '视觉表面',
      'Group 表达同一功能集合，Card 表达独立视觉层级。',
      <Widget>[
        EasyApiExample(
          'Group',
          usage: '.easyDesign(.group)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: tokens.spacing.xs,
            children: <Widget>[
              const EdsSectionTitle('通用设置',
                  subtitle: '自适应 subtle 表面、标准 padding 和圆角。'),
              EdsSettingRow(
                '自动更新',
                subtitle: '定期检查新版本。',
                trailing: EdsToggle(
                  isOn: _notificationsEnabled,
                  label: '启用',
                  onChanged: (value) => setState(() {
                    _notificationsEnabled = value;
                  }),
                ),
              ),
            ],
          ).easyDesign(style: EdsEasyStyle.group),
        ),
        EasyApiExample(
          'Card',
          usage: '.easyDesign(.card)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: tokens.spacing.xs,
            children: <Widget>[
              const EdsSectionTitle('专业版', subtitle: '语义卡片背景、边框和轻量阴影建立独立层级。'),
              Row(
                children: <Widget>[
                  const EdsBadge('已解锁', style: EdsBadgeStyle.success),
                  const Spacer(),
                  EdsButton('管理', role: EdsButtonRole.soft, action: () {}),
                ],
              ),
            ],
          ).easyDesign(style: EdsEasyStyle.card),
        ),
      ],
    );
  }

  Widget _themesPage(BuildContext context) {
    final tokens = context.edsTokens;
    return _detailPage(
      context,
      '局部主题',
      'Environment 保存值类型 Token，局部主题不会修改全局状态。',
      <Widget>[
        EasyApiExample(
          'Preset 主题',
          usage: '.easyDesign(.card, theme: .orange)',
          child: Wrap(
            spacing: tokens.spacing.md,
            runSpacing: tokens.spacing.md,
            children: <Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: tokens.spacing.xs,
                  children: <Widget>[
                    const Text('继承当前主题'),
                    EdsButton('继续', action: () {}),
                  ],
                ).easyDesign(style: EdsEasyStyle.card),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: tokens.spacing.xs,
                  children: <Widget>[
                    const Text('仅这个子树使用橙色主题'),
                    EdsButton('继续', action: () {}),
                  ],
                ).easyDesignPreset(
                  EdsPresetTheme.orange,
                  style: EdsEasyStyle.card,
                ),
              ),
            ],
          ),
        ),
        EasyApiExample(
          '仅传递主题',
          usage: '.easyDesignTheme(.purple)',
          child: EdsButton('紫色主题按钮', action: () {})
              .easyDesignThemePreset(EdsPresetTheme.purple),
        ),
      ],
    );
  }

  Widget _stressPage(BuildContext context) {
    final tokens = context.edsTokens;
    return _detailPage(
      context,
      '嵌套与性能',
      '正常页面保持 Page -> Section -> Group/Card 两到四层语义嵌套。',
      <Widget>[
        for (var section = 0; section < 4; section++)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: tokens.spacing.xs,
            children: <Widget>[
              EdsSectionTitle('功能区 ${section + 1}'),
              Wrap(
                spacing: tokens.spacing.md,
                runSpacing: tokens.spacing.md,
                children: <Widget>[
                  for (var item = 0; item < 3; item++)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: tokens.spacing.xs,
                        children: <Widget>[
                          Text('项目 ${item + 1}'),
                          const EdsBadge('正常', style: EdsBadgeStyle.success),
                        ],
                      ).easyDesign(
                        style: item % 2 == 0
                            ? EdsEasyStyle.group
                            : EdsEasyStyle.card,
                      ),
                    ),
                ],
              ),
            ],
          ).easyDesign(style: EdsEasyStyle.section),
      ],
    );
  }
}
