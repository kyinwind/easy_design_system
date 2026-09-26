import 'package:flutter/material.dart';

import '../adaptive/eds_interaction_profile.dart';
import '../adaptive/eds_resolved_metrics.dart';
import '../adaptive/eds_size_class.dart';
import '../primitives/eds_font.dart';
import '../theme/eds_theme.dart';
import '../theme/eds_theme_scope.dart';
import '../tokens/eds_color_scheme.dart';

/// A sidebar menu item, mirroring Swift's `EDSSidebarMenuItem`.
///
/// Deviation from Swift: [icon] holds Material [IconData] instead of an SF
/// Symbol name, and [id] falls back to a package-generated unique string
/// instead of `UUID().uuidString`.
class EdsSidebarMenuItem {
  EdsSidebarMenuItem({
    String? id,
    required this.label,
    required this.icon,
    this.tint,
    this.presetTint,
  })  : assert(
          tint != null || presetTint != null,
          'Either tint or presetTint must be provided.',
        ),
        id = id ?? _autoId();

  static int _counter = 0;

  static String _autoId() => 'eds-sidebar-item-${_counter++}';

  final String id;
  final String label;
  final IconData icon;

  /// Explicit fixed tint. Prefer [presetTint] when the color should follow
  /// the scoped EDS theme.
  final Color? tint;

  /// Theme-aware preset tint resolved at build time.
  final EdsSidebarIconPresetTint? presetTint;

  Color resolveTint(BuildContext context) =>
      presetTint?.resolve(context) ?? tint!;

  @override
  bool operator ==(Object other) {
    return other is EdsSidebarMenuItem &&
        other.id == id &&
        other.label == label &&
        other.icon == icon &&
        other.tint == tint &&
        other.presetTint == presetTint;
  }

  @override
  int get hashCode => Object.hash(id, label, icon, tint, presetTint);
}

/// Icon size tiers for [EdsSidebarIcon]. Mirrors Swift's
/// `EDSSidebarIcon.IconSize`.
enum EdsSidebarIconSize {
  /// 24pt background, 11pt icon.
  small,

  /// 28pt background, 14pt icon.
  medium,

  /// 32pt background, 16pt icon.
  large;

  /// The icon font size.
  double get iconSize => switch (this) {
        EdsSidebarIconSize.small => 11,
        EdsSidebarIconSize.medium => 14,
        EdsSidebarIconSize.large => 16,
      };

  /// The background square size.
  double get frameSize => switch (this) {
        EdsSidebarIconSize.small => 24,
        EdsSidebarIconSize.medium => 28,
        EdsSidebarIconSize.large => 32,
      };
}

/// A rounded tinted square with a white icon, mirroring Swift's
/// `EDSSidebarIcon`.
class EdsSidebarIcon extends StatelessWidget {
  const EdsSidebarIcon({
    super.key,
    required this.icon,
    required this.tint,
    this.size = EdsSidebarIconSize.medium,
  });

  final IconData icon;
  final Color tint;
  final EdsSidebarIconSize size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.frameSize,
      height: size.frameSize,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(size.frameSize * 0.22),
      ),
      child: Center(
        child: Icon(icon, size: size.iconSize, color: Colors.white),
      ),
    );
  }
}

/// Preset tints for sidebar icons, mirroring Swift's
/// `EDSSidebarIconPresetTint`.
///
/// Theme-backed cases should be resolved with [resolve] so local
/// [EdsThemeScope] overrides are honored. The legacy [color] getter is kept
/// for source compatibility and reads the global [EdsTheme.instance].
///
/// Fixed platform colors (gray/pink/purple/teal/indigo) use their
/// light-appearance values because Dart colors do not resolve dynamically per
/// appearance.
enum EdsSidebarIconPresetTint {
  blue,
  green,
  orange,
  red,
  gray,
  pink,
  purple,
  teal,
  indigo;

  Color resolve(BuildContext context) => switch (this) {
        EdsSidebarIconPresetTint.blue => context.edsTokens.colors.primary,
        EdsSidebarIconPresetTint.green => context.edsTokens.colors.success,
        EdsSidebarIconPresetTint.orange => context.edsTokens.colors.warning,
        EdsSidebarIconPresetTint.red => context.edsTokens.colors.danger,
        EdsSidebarIconPresetTint.gray => const Color(0xFF8E8E93),
        EdsSidebarIconPresetTint.pink => const Color(0xFFFF2D55),
        EdsSidebarIconPresetTint.purple => const Color(0xFFAF52DE),
        EdsSidebarIconPresetTint.teal => const Color(0xFF30B0C7),
        EdsSidebarIconPresetTint.indigo => const Color(0xFF5856D6),
      };

  @Deprecated('Use resolve(context) so local EdsThemeScope is respected.')
  Color get color => switch (this) {
        EdsSidebarIconPresetTint.blue => EdsTheme.instance.colors.primary,
        EdsSidebarIconPresetTint.green => EdsTheme.instance.colors.success,
        EdsSidebarIconPresetTint.orange => EdsTheme.instance.colors.warning,
        EdsSidebarIconPresetTint.red => EdsTheme.instance.colors.danger,
        EdsSidebarIconPresetTint.gray => const Color(0xFF8E8E93),
        EdsSidebarIconPresetTint.pink => const Color(0xFFFF2D55),
        EdsSidebarIconPresetTint.purple => const Color(0xFFAF52DE),
        EdsSidebarIconPresetTint.teal => const Color(0xFF30B0C7),
        EdsSidebarIconPresetTint.indigo => const Color(0xFF5856D6),
      };
}

/// A single sidebar menu entry, mirroring Swift's `EDSSidebarItemButton`.
class EdsSidebarItemButton extends StatelessWidget {
  const EdsSidebarItemButton({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final EdsSidebarMenuItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final metrics = EdsResolvedMetrics.resolve(
      tokens: tokens,
      profile: context.edsInteractionProfile,
      horizontalSizeClass: context.edsSizeClass,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? tokens.colors.accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(tokens.radius.sm),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: metrics.minimumInteractiveDimension,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing.sm,
                vertical: tokens.spacing.xs,
              ),
              child: Row(
                spacing: tokens.spacing.sm,
                children: <Widget>[
                  EdsSidebarIcon(
                    icon: item.icon,
                    tint: item.resolveTint(context),
                    size: EdsSidebarIconSize.small,
                  ),
                  Expanded(
                    child: Text(
                      item.label,
                      style: tokens.typography
                          .edsTextStyle(EdsFontRole.body15)
                          .copyWith(
                            color: isSelected
                                ? tokens.colors.primary
                                : scheme.textPrimary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A grouped sidebar menu, mirroring Swift's `EDSSidebarGroupView`.
///
/// Deviation from Swift: `Binding<String>` maps to [selection] plus
/// [onSelectionChange].
class EdsSidebarGroupView extends StatelessWidget {
  const EdsSidebarGroupView({
    super.key,
    this.title,
    required this.items,
    required this.selection,
    required this.onSelectionChange,
  });

  final String? title;
  final List<EdsSidebarMenuItem> items;

  /// The currently selected item id.
  final String selection;

  /// Invoked with the new selected item id.
  final ValueChanged<String> onSelectionChange;

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final titleText = title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.spacing.xs,
      children: <Widget>[
        if (titleText != null)
          Padding(
            padding: EdgeInsets.only(left: tokens.spacing.sm),
            child: Text(
              titleText,
              style: tokens.typography
                  .edsTextStyle(EdsFontRole.captionStrong)
                  .copyWith(color: scheme.textTertiary),
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: tokens.spacing.xxs,
          children: <Widget>[
            for (final item in items)
              EdsSidebarItemButton(
                item: item,
                isSelected: selection == item.id,
                onTap: () => onSelectionChange(item.id),
              ),
          ],
        ),
      ],
    );
  }
}
