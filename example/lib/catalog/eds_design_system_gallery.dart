import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';

import 'catalog_support.dart';
import 'eds_button_showcase.dart';

enum GallerySection {
  page('标准页面', Icons.dashboard_outlined),
  states('状态模式', Icons.blur_circular),
  controls('基础控件', Icons.toggle_on_outlined),
  buttons('按钮', Icons.touch_app_outlined),
  rows('行与标签', Icons.list_alt_outlined),
  surfaces('容器分层', Icons.layers_outlined);

  const GallerySection(this.label, this.icon);

  final String label;
  final IconData icon;

  String get id => name;

  static GallerySection fromId(String id) {
    for (final section in GallerySection.values) {
      if (section.id == id) {
        return section;
      }
    }
    return GallerySection.page;
  }

  Color get tint {
    final colors = EdsTheme.instance.tokens.colors;
    return switch (this) {
      GallerySection.page => colors.primary,
      GallerySection.states => colors.warning,
      GallerySection.controls => colors.success,
      GallerySection.buttons => colors.danger,
      GallerySection.rows => const Color(0xFFAF52DE),
      GallerySection.surfaces => const Color(0xFF30B0C7),
    };
  }

  EdsSidebarMenuItem get menuItem =>
      EdsSidebarMenuItem(id: id, label: label, icon: icon, tint: tint);
}

class EdsDesignSystemGallery extends StatefulWidget {
  const EdsDesignSystemGallery({super.key});

  @override
  State<EdsDesignSystemGallery> createState() => _EdsDesignSystemGalleryState();
}

class _EdsDesignSystemGalleryState extends State<EdsDesignSystemGallery> {
  GallerySection _selection = GallerySection.page;
  bool _isEnabled = true;
  final double _progress = 0.42;

  @override
  Widget build(BuildContext context) {
    return CatalogSplitScaffold(
      navigationTitle: 'Gallery',
      navigationSubtitle: 'DesignSystem 组件和页面模式',
      groupTitle: '页面',
      items: <EdsSidebarMenuItem>[
        for (final section in GallerySection.values) section.menuItem,
      ],
      selection: _selection.id,
      onSelectionChange: (id) => setState(() {
        _selection = GallerySection.fromId(id);
      }),
      child: _selectedContent(context),
    );
  }

  Widget _selectedContent(BuildContext context) {
    return switch (_selection) {
      GallerySection.page => _pageExample(context),
      GallerySection.states => _statesExample(context),
      GallerySection.controls => _controlsExample(context),
      GallerySection.buttons => _buttonsExample(context),
      GallerySection.rows => _rowsExample(context),
      GallerySection.surfaces => _surfacesExample(context),
    };
  }

  Widget _page(
    BuildContext context,
    String title,
    String subtitle,
    List<Widget> sections,
  ) {
    final tokens = context.edsTokens;
    return EdsPage(
      title,
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tokens.spacing.xl,
        children: sections,
      ),
    );
  }

  Widget _buttonsExample(BuildContext context) {
    return const EdsPage(
      '按钮三维模型',
      subtitle: 'Emphasis × Tone × Size 三个正交维度，Role 是一张预设别名表',
      child: EdsButtonShowcase(embedsScrollView: false),
    );
  }

  Widget _pageExample(BuildContext context) {
    return _page(
      context,
      '标准设置页',
      '推荐结构：EDSPage -> EDSPageSection -> EDSGroup -> Row / Control',
      <Widget>[
        EdsPageSection(
          '基础设置',
          child: GalleryExample(
            'EDSPageSection + EDSGroup + EDSSettingRow',
            usage: 'EDSPageSection { EDSGroup { EDSSettingRow(...) } }',
            child: EdsGroup(
              '通用',
              subtitle: '常用偏好集中放在一个内容分组里。',
              child: Column(
                children: <Widget>[
                  EdsSettingRow(
                    '自动检查更新',
                    subtitle: '启动后自动检查是否有新版本。',
                    trailing: EdsToggle(
                      isOn: _isEnabled,
                      label: '启用',
                      onChanged: (value) => setState(() {
                        _isEnabled = value;
                      }),
                    ),
                  ),
                  EdsSettingRow(
                    '默认导出目录',
                    subtitle: '/Users/name/Documents/Exports',
                    trailing: EdsButton(
                      '更改',
                      role: EdsButtonRole.soft,
                      icon: Icons.folder_outlined,
                      action: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        EdsPageSection(
          '状态反馈',
          child: GalleryExample(
            'EDSProgressPanel',
            usage: 'EDSProgressPanel("模型下载", fractionCompleted: progress)',
            child: EdsProgressPanel(
              '模型下载',
              subtitle: 'LaMa.mlpackage.zip',
              fractionCompleted: _progress,
              statusText: '正在从最快的可用源下载...',
              actionTitle: '取消',
              actionSystemImage: Icons.close,
              action: () {},
            ),
          ),
        ),
        EdsPageSection(
          '操作',
          child: GalleryExample(
            'EDSButton',
            usage: 'EDSButton("保存设置", role: .primary, icon: "checkmark")',
            child: EdsGroup(
              null,
              style: EdsGroupStyle.plain,
              child: catalogAdaptiveRow(context, <Widget>[
                EdsButton('保存设置', icon: Icons.check, action: () {}),
                EdsButton(
                  '恢复默认',
                  role: EdsButtonRole.soft,
                  icon: Icons.refresh,
                  action: () {},
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statesExample(BuildContext context) {
    return _page(context, '状态模式', '空状态、错误状态、加载状态和进度面板是最常见的页面片段。', <Widget>[
      EdsPageSection(
        '空状态',
        child: GalleryExample(
          'EDSEmptyState',
          usage: 'EDSEmptyState(icon: "tray", title: "暂无文件")',
          child: EdsGroup(
            null,
            child: EdsEmptyState(
              systemImage: Icons.inbox_outlined,
              title: '暂无文件',
              message: '添加文件后会显示在这里。',
              actionTitle: '添加文件',
              actionSystemImage: Icons.add,
              action: () {},
            ),
          ),
        ),
      ),
      EdsPageSection(
        '错误和加载',
        child: catalogAdaptiveRow(context, <Widget>[
          GalleryExample(
            'EDSErrorState',
            usage: 'EDSErrorState(title: "加载失败", actionTitle: "重试")',
            child: EdsGroup(
              null,
              child: EdsErrorState(
                title: '加载失败',
                message: '请检查网络后重试。',
                actionTitle: '重试',
                action: () {},
              ),
            ),
          ),
          const GalleryExample(
            'EDSLoadingState',
            usage: 'EDSLoadingState("正在处理", message: "...")',
            child: EdsGroup(null, child: EdsLoadingState(message: '这通常只需要几秒。')),
          ),
        ]),
      ),
    ]);
  }

  Widget _controlsExample(BuildContext context) {
    final tokens = context.edsTokens;
    return _page(context, '基础控件', '按钮、徽章和开关默认跟随 EDSTheme。', <Widget>[
      EdsPageSection(
        '按钮',
        child: GalleryExample(
          'EDSButton',
          usage: 'EDSButton("主要操作", role: .primary, icon: "checkmark")',
          child: EdsGroup(
            null,
            child: catalogAdaptiveRow(context, <Widget>[
              EdsButton('主要操作', icon: Icons.check, action: () {}),
              EdsButton(
                '次要操作',
                role: EdsButtonRole.secondary,
                icon: Icons.tune,
                action: () {},
              ),
              EdsButton(
                '轻量操作',
                role: EdsButtonRole.soft,
                icon: Icons.auto_awesome,
                action: () {},
              ),
              EdsButton(
                '危险操作',
                role: EdsButtonRole.danger,
                icon: Icons.delete_outline,
                action: () {},
              ),
            ]),
          ),
        ),
      ),
      EdsPageSection(
        '徽章和开关',
        child: GalleryExample(
          'EDSBadge + EDSToggle',
          usage: 'EDSBadge("已完成", style: .success) / EDSToggle(isOn: \$value)',
          child: EdsGroup(
            null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: tokens.spacing.sm,
              children: <Widget>[
                catalogAdaptiveRow(context, <Widget>[
                  const EdsBadge('Pro'),
                  const EdsBadge('已完成', style: EdsBadgeStyle.success),
                  const EdsBadge('待处理', style: EdsBadgeStyle.warning),
                  const EdsBadge('失败', style: EdsBadgeStyle.danger),
                  const EdsBadge.verbatim(
                    'v1.0.0',
                    style: EdsBadgeStyle.neutral,
                  ),
                ]),
                EdsSettingRow(
                  '启用自动处理',
                  subtitle: '适合二元开关型设置。',
                  trailing: EdsToggle(
                    isOn: _isEnabled,
                    label: '启用',
                    onChanged: (value) => setState(() {
                      _isEnabled = value;
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _rowsExample(BuildContext context) {
    final tokens = context.edsTokens;
    return _page(context, '行和标签', '设置行、键值行、内联字段和流式标签。', <Widget>[
      EdsPageSection(
        '设置行',
        child: GalleryExample(
          'EDSSettingRow + EDSValueRow',
          usage: 'EDSSettingRow("标题") { trailing } / EDSValueRow("标题", value: "值")',
          child: EdsGroup(
            null,
            child: Column(
              children: <Widget>[
                const EdsSettingRow(
                  '图片输出格式',
                  subtitle: '用于批量处理后的默认格式。',
                  trailing: EdsBadge('PNG'),
                ),
                EdsValueRow(
                  '今日处理',
                  value: '128 张',
                  tone: tokens.colors.success,
                ),
                EdsValueRow(
                  '缓存占用',
                  value: '240 MB',
                  tone: tokens.colors.warning,
                ),
              ],
            ),
          ),
        ),
      ),
      const EdsPageSection(
        '流式标签',
        child: GalleryExample(
          'EDSPillFlow',
          usage: 'EDSPillFlow(items, sortOrder: .ascending, showsRemoveButton: true)',
          child: EdsGroup(
            null,
            child: EdsPillFlow(
              <String>[
                '75%',
                '100%',
                '110%',
                '1280x720',
                '1920x1080',
                '2560x1600',
                '4K',
              ],
              sortOrder: EdsPillFlowSortOrder.ascending,
              minItemWidth: 88,
              showsRemoveButton: true,
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _surfacesExample(BuildContext context) {
    final tokens = context.edsTokens;
    return _page(
      context,
      '容器分层',
      'PageSection 管章节，Group 管内容分组，Card 是底层视觉容器。',
      <Widget>[
        const EdsPageSection(
          '分组',
          child: GalleryExample(
            'EDSGroup',
            usage: 'EDSGroup("默认分组", subtitle: "...") { content }',
            child: EdsGroup(
              '默认分组',
              subtitle: '默认浅背景，无边框。',
              child: Column(
                children: <Widget>[
                  EdsValueRow('语义', value: '内容分组'),
                  EdsValueRow('默认背景', value: '浅色'),
                ],
              ),
            ),
          ),
        ),
        EdsPageSection(
          '强调面板',
          child: GalleryExample(
            'EDSHeroPanel',
            usage: 'EDSHeroPanel { content }',
            child: EdsHeroPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: tokens.spacing.sm,
                children: <Widget>[
                  Text(
                    'Hero Panel',
                    style: tokens.typography.hero.copyWith(color: Colors.white),
                  ),
                  Text(
                    '用于第一屏强调、关键状态或付费权益说明。',
                    style: tokens.typography.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        EdsPageSection(
          '底层卡片',
          child: GalleryExample(
            'EDSCard',
            usage: 'EDSCard { ... } / EDSCard(background: ...) { ... }',
            child: catalogAdaptiveRow(context, <Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: SizedBox(
                  width: double.infinity,
                  child: EdsCard(
                    child: Text(
                      '默认 EDSCard 只提供 padding，不绘制背景。',
                      style: tokens.typography.body,
                    ),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: SizedBox(
                  width: double.infinity,
                  child: EdsCard(
                    background: tokens.colors.accentSoft,
                    child: Text(
                      '显式传入 background 时才绘制背景和圆角。',
                      style: tokens.typography.body,
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
        const EdsPageSection(
          '功能对比',
          child: GalleryExample(
            'EDSComparisonSection',
            usage: 'EDSComparisonSection(features: [(String, Bool, Bool)])',
            child: EdsComparisonSection(
              features: <(String, bool, bool)>[
                ('跨平台统一 API', true, true),
                ('高级主题定制', false, true),
                ('这是一项用于验证窄屏和大字号换行的较长功能说明', true, true),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
