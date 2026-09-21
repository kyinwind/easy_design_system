import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';

const double catalogSplitBreakpoint = 760;

class CatalogSplitScaffold extends StatelessWidget {
  const CatalogSplitScaffold({
    super.key,
    required this.navigationTitle,
    required this.navigationSubtitle,
    required this.groupTitle,
    required this.items,
    required this.selection,
    required this.onSelectionChange,
    required this.child,
  });

  final String navigationTitle;
  final String navigationSubtitle;
  final String groupTitle;
  final List<EdsSidebarMenuItem> items;
  final String selection;
  final ValueChanged<String> onSelectionChange;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= catalogSplitBreakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                width: 256,
                child: _sidebar(context),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: context.edsScheme.border,
              ),
              Expanded(child: child),
            ],
          );
        }
        return Column(
          children: <Widget>[
            _chipRow(context),
            Divider(
              height: 1,
              thickness: 1,
              color: context.edsScheme.border,
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }

  Widget _sidebar(BuildContext context) {
    final tokens = context.edsTokens;
    return Container(
      color: context.edsScheme.cardBackground,
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          EdsPageTitle(navigationTitle, subtitle: navigationSubtitle),
          SizedBox(height: tokens.spacing.lg),
          EdsSidebarGroupView(
            title: groupTitle,
            items: items,
            selection: selection,
            onSelectionChange: onSelectionChange,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _chipRow(BuildContext context) {
    final tokens = context.edsTokens;
    return Container(
      color: context.edsScheme.cardBackground,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.xs,
      ),
      child: SizedBox(
        height: 48,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            for (final item in items)
              Padding(
                padding: EdgeInsets.only(right: tokens.spacing.sm),
                child: ChoiceChip(
                  label: Text(item.label),
                  selected: selection == item.id,
                  onSelected: (_) => onSelectionChange(item.id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GalleryExample extends StatelessWidget {
  const GalleryExample(
    this.title, {
    super.key,
    required this.usage,
    required this.child,
  });

  final String title;
  final String usage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.spacing.sm,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: tokens.spacing.xs,
          children: <Widget>[
            Text(
              title,
              style: tokens.typography.bodyStrong
                  .copyWith(color: tokens.colors.primary),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing.sm,
                vertical: tokens.spacing.xs,
              ),
              decoration: BoxDecoration(
                color: scheme.subtleFill,
                borderRadius: BorderRadius.circular(tokens.radius.sm),
              ),
              child: Text(
                usage,
                style: tokens.typography.monoCaption
                    .copyWith(color: scheme.textSecondary),
              ),
            ),
          ],
        ),
        child,
      ],
    );
  }
}

class EasyApiExample extends StatelessWidget {
  const EasyApiExample(
    this.title, {
    super.key,
    required this.usage,
    required this.child,
  });

  final String title;
  final String usage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        EdsSectionTitle(title, subtitle: usage),
        child,
      ],
    ).easyDesign(style: EdsEasyStyle.section);
  }
}

Widget catalogAdaptiveRow(BuildContext context, List<Widget> children) {
  final tokens = context.edsTokens;
  if (context.edsSizeClass == EdsSizeClass.compact ||
      context.edsIsAccessibilityTextSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.spacing.md,
      children: children,
    );
  }
  return Wrap(
    spacing: tokens.spacing.md,
    runSpacing: tokens.spacing.md,
    crossAxisAlignment: WrapCrossAlignment.start,
    children: children,
  );
}
