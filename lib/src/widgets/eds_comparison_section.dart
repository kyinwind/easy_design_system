import 'package:flutter/material.dart';

import '../adaptive/eds_size_class.dart';
import '../primitives/eds_font.dart';
import '../theme/eds_theme_scope.dart';
import '../tokens/eds_color_scheme.dart';
import 'eds_icon_mark.dart';
import 'eds_section.dart';
import 'eds_text.dart';

/// A comparison feature: `(name, free, pro)`.
typedef EdsComparisonFeature = (String, bool, bool);

const String _kFeaturesTitle = '功能对比';
const String _kFeaturesLabel = '功能';
const String _kFreeLabel = 'Free';
const String _kProLabel = 'Pro';

/// The standard Free / Pro feature comparison section, mirroring Swift's
/// `EDSComparisonSection`.
///
/// The localized labels are inlined as Chinese/English literals, matching
/// the Swift package's bundled strings table. Under compact width or
/// accessibility text sizes a stacked layout is used instead of the table.
class EdsComparisonSection extends StatelessWidget {
  const EdsComparisonSection({
    super.key,
    required this.features,
    this.title = _kFeaturesTitle,
    this.featureLabel = _kFeaturesLabel,
    this.freeLabel = _kFreeLabel,
    this.proLabel = _kProLabel,
  });

  final List<EdsComparisonFeature> features;
  final String title;
  final String featureLabel;
  final String freeLabel;
  final String proLabel;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.edsSizeClass == EdsSizeClass.compact ||
        context.edsIsAccessibilityTextSize;

    return EdsSection(
      header: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: EdsSectionTitle(title),
      ),
      child: isCompact ? _compactContent(context) : _tableContent(context),
    );
  }

  Widget _tableContent(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.spacing.sm,
      children: <Widget>[
        Row(
          children: <Widget>[
            _header(context, featureLabel, 55),
            const Spacer(),
            _header(context, freeLabel, 72),
            _header(context, proLabel, 72),
          ],
        ),
        Divider(height: 1, thickness: 1, color: scheme.border),
        for (var index = 0; index < features.length; index++)
          Row(
            spacing: tokens.spacing.md,
            children: <Widget>[
              Text(
                '${index + 1}.',
                style: tokens.typography
                    .edsTextStyle(EdsFontRole.body)
                    .copyWith(color: scheme.textPrimary),
              ),
              Expanded(
                child: Text(
                  features[index].$1,
                  style: tokens.typography
                      .edsTextStyle(EdsFontRole.body)
                      .copyWith(color: scheme.textPrimary),
                ),
              ),
              SizedBox(width: 72, child: EdsIconMark(isOn: features[index].$2)),
              SizedBox(width: 72, child: EdsIconMark(isOn: features[index].$3)),
            ],
          ),
      ],
    );
  }

  Widget _compactContent(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final children = <Widget>[];
    for (var index = 0; index < features.length; index++) {
      final (feature, free, pro) = features[index];
      children.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: tokens.spacing.sm,
          children: <Widget>[
            Text(
              '${index + 1}. $feature',
              style: tokens.typography
                  .edsTextStyle(EdsFontRole.body)
                  .copyWith(color: scheme.textPrimary),
            ),
            Row(
              spacing: tokens.spacing.lg,
              children: <Widget>[
                _compactValue(context, freeLabel, free),
                _compactValue(context, proLabel, pro),
              ],
            ),
          ],
        ),
      );
      if (index != features.length - 1) {
        children.add(Divider(height: 1, thickness: 1, color: scheme.border));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.spacing.md,
      children: children,
    );
  }

  Widget _compactValue(BuildContext context, String label, bool isOn) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Row(
      spacing: tokens.spacing.xs,
      children: <Widget>[
        Text(
          label,
          style: tokens.typography
              .edsTextStyle(EdsFontRole.captionStrong)
              .copyWith(color: scheme.textSecondary),
        ),
        EdsIconMark(isOn: isOn),
      ],
    );
  }

  Widget _header(BuildContext context, String label, double width) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return SizedBox(
      width: width,
      child: Text(
        label,
        style: tokens.typography
            .edsTextStyle(EdsFontRole.captionStrong)
            .copyWith(color: scheme.textSecondary),
      ),
    );
  }
}
