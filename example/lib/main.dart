import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';

import 'catalog/eds_catalog_theme_playground.dart';
import 'catalog/eds_design_system_gallery.dart';
import 'catalog/eds_design_system_preview.dart';
import 'catalog/eds_easy_api_design_system_gallery.dart';
import 'settings_demo_page.dart';

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
        home: const CatalogHomePage(),
      ),
    );
  }
}

class CatalogHomePage extends StatelessWidget {
  const CatalogHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: scheme.cardBackground,
          foregroundColor: scheme.textPrimary,
          title: const Text('EasyDesignSystem Catalog'),
          bottom: TabBar(
            indicatorColor: tokens.colors.primary,
            labelColor: scheme.textPrimary,
            unselectedLabelColor: scheme.textSecondary,
            tabs: const <Widget>[
              Tab(icon: Icon(Icons.grid_view_outlined), text: '组件'),
              Tab(icon: Icon(Icons.auto_awesome), text: 'Easy API'),
              Tab(icon: Icon(Icons.palette_outlined), text: '主题'),
              Tab(icon: Icon(Icons.settings_outlined), text: '设置'),
            ],
          ),
        ),
        body: Column(
          children: <Widget>[
            const CatalogThemeBar(),
            Divider(height: 1, thickness: 1, color: scheme.border),
            const Expanded(
              child: TabBarView(
                children: <Widget>[
                  EdsDesignSystemGallery(),
                  EdsEasyApiDesignSystemGallery(),
                  EdsDesignSystemPreview(),
                  SettingsDemoPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
