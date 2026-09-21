import 'package:flutter/material.dart';

/// A universal section wrapper, mirroring Swift's `EDSSection`.
///
/// Swift's `EDSSection` wraps SwiftUI's native `Section`, which is a
/// semantic grouping only rendered meaningfully inside a `List`. The Dart
/// port renders header, content and footer as a plain column; visual
/// grouping depends on the surrounding container, exactly like a `Section`
/// outside a list contributes no chrome of its own.
///
/// The eight Swift initializer permutations collapse into this constructor
/// plus the [EdsSection.labeled] string convenience.
class EdsSection extends StatelessWidget {
  const EdsSection({super.key, this.header, this.footer, required this.child});

  /// Section header/footer from plain strings, mirroring
  /// `EDSSection(header: "Title", footer: "Text") { content }`.
  factory EdsSection.labeled(
    String? header,
    String? footer, {
    Key? key,
    required Widget child,
  }) {
    return EdsSection(
      key: key,
      header: header == null ? null : Text(header),
      footer: footer == null ? null : Text(footer),
      child: child,
    );
  }

  final Widget? header;
  final Widget? footer;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (header != null) header!,
        child,
        if (footer != null) footer!,
      ],
    );
  }
}
