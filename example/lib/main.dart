import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EdsThemeScope(
      child: MaterialApp(
        theme: ThemeData(fontFamily: 'PingFang SC'),
        home: const DemoPage(),
      ),
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return EdsPage(
      '设置',
      subtitle: '管理应用偏好',
      showsBackground: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EdsPageSection(
            '账户',
            subtitle: 'Pro 订阅有效',
            showsDivider: true,
            child: EdsGroup(
              '同步',
              child: Column(
                children: [
                  EdsSettingRow(
                    '自动同步',
                    subtitle: '仅在 Wi-Fi 下传输',
                    trailing: EdsToggle(
                      isOn: true,
                      label: '启用',
                      onChanged: (value) {},
                    ),
                  ),
                  const EdsValueRow('存储空间', value: '128 GB'),
                  EdsInlineField(
                    '显示名称',
                    child: TextField(
                      controller: TextEditingController(text: '蓝鲸'),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          EdsPageSection(
            '外观',
            showsDivider: true,
            child: Column(
              children: [
                EdsHeroPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const EdsPageTitle('升级 Pro'),
                      const EdsCaptionText('解锁无限画布、团队协作与云同步'),
                      const SizedBox(height: 16),
                      EdsButton(
                        '立即升级',
                        role: EdsButtonRole.done,
                        systemImage: Icons.check,
                        action: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const EdsGroup(
                  '标签',
                  style: EdsGroupStyle.subtle,
                  child: EdsPillFlow(['设计', '原型', '协作', '云端']),
                ),
                const SizedBox(height: 16),
                const EdsComparisonSection(
                  features: [
                    ('无限画布', true, true),
                    ('团队协作', false, true),
                    ('云同步', false, true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
