/// Label printing format options
enum LabelFormat {
  /// One label per A6 page (10.5 x 14.8 cm landscape)
  a6,

  /// Two labels per A4 page (current default)
  a4TwoPerPage,
}

extension LabelFormatExtension on LabelFormat {
  String get displayName {
    switch (this) {
      case LabelFormat.a6:
        return 'A6 (one per page)';
      case LabelFormat.a4TwoPerPage:
        return 'A4 (2×2 grid - 4 per page)';
    }
  }
}
