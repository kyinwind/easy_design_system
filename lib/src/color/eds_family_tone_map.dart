/// Internal mapping from semantic family roles to perceptual tone positions.
///
/// Families intentionally own independent maps even when their initial values
/// are identical. Catalog/contrast tuning can adjust Warning or another family
/// without changing public API or unrelated families.
class EdsFamilyToneMap {
  const EdsFamilyToneMap({
    required this.lightForeground,
    required this.lightSurface,
    required this.lightStrong,
    required this.lightBorder,
    required this.lightOnStrong,
    required this.darkForeground,
    required this.darkSurface,
    required this.darkStrong,
    required this.darkBorder,
    required this.darkOnStrong,
  });

  final int lightForeground;
  final int lightSurface;
  final int lightStrong;
  final int lightBorder;
  final int lightOnStrong;

  final int darkForeground;
  final int darkSurface;
  final int darkStrong;
  final int darkBorder;
  final int darkOnStrong;

  static const EdsFamilyToneMap brand = EdsFamilyToneMap(
    lightForeground: 40,
    lightSurface: 95,
    lightStrong: 40,
    lightBorder: 70,
    lightOnStrong: 100,
    darkForeground: 80,
    darkSurface: 20,
    darkStrong: 80,
    darkBorder: 60,
    darkOnStrong: 10,
  );

  static const EdsFamilyToneMap information = brand;
  static const EdsFamilyToneMap success = brand;

  /// Separate constant on purpose: Warning often needs independent tuning
  /// after visual/contrast review even when the first values match Brand.
  static const EdsFamilyToneMap warning = EdsFamilyToneMap(
    lightForeground: 40,
    lightSurface: 95,
    lightStrong: 40,
    lightBorder: 70,
    lightOnStrong: 100,
    darkForeground: 80,
    darkSurface: 20,
    darkStrong: 80,
    darkBorder: 60,
    darkOnStrong: 10,
  );

  static const EdsFamilyToneMap danger = brand;
}
