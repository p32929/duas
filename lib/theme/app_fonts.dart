import 'package:flutter/material.dart';
import 'package:duas/theme/font_loader.dart';

/// A selectable Arabic typeface (downloaded on first use, see [AppFontLoader]).
class AppArabicFont {
  /// Label shown in the UI.
  final String label;

  /// Google Fonts family name (must be a key of kFontFiles).
  final String family;

  const AppArabicFont(this.label, this.family);
}

/// Curated Arabic fonts that render Quranic / dua text well.
const List<AppArabicFont> kArabicFonts = [
  AppArabicFont('Mada', 'Mada'),
  AppArabicFont('Amiri', 'Amiri'),
  AppArabicFont('Amiri Quran', 'Amiri Quran'),
  AppArabicFont('Scheherazade', 'Scheherazade New'),
  AppArabicFont('Noto Naskh', 'Noto Naskh Arabic'),
  AppArabicFont('Lateef', 'Lateef'),
  AppArabicFont('Reem Kufi', 'Reem Kufi'),
  AppArabicFont('Cairo', 'Cairo'),
];

class AppFonts {
  // Arabic reading size bounds.
  static const double minArabicSize = 22;
  static const double maxArabicSize = 52;
  static const double defaultArabicSize = 32;

  // Translation reading size bounds.
  static const double minTranslationSize = 12;
  static const double maxTranslationSize = 26;
  static const double defaultTranslationSize = 16;

  /// Builds the text style for an Arabic font by index, falling back to the
  /// first font if the index is out of range.
  static TextStyle arabicStyle({
    required int fontIndex,
    required double fontSize,
    Color? color,
  }) {
    final font = kArabicFonts[fontIndex.clamp(0, kArabicFonts.length - 1)];
    AppFontLoader.load(font.family); // no-op once loaded
    return TextStyle(
      fontFamily: font.family,
      fontSize: fontSize,
      height: 1.7,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }
}
