import 'package:duas/models/dua_model.dart';
import 'package:duas/theme/app_fonts.dart';
import 'package:duas/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:prefs/prefs.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class States {
  List<DuaModel> duas = [];

  // --- Theme preferences (persisted) ---
  ThemeMode themeMode = ThemeMode.values[Prefs.getInt("themeMode", 0)];
  int accentIndex =
      Prefs.getInt("accentIndex", 0).clamp(0, kAppAccents.length - 1);

  AppAccent get accent => kAppAccents[accentIndex];

  // --- Reading preferences (persisted) ---
  int arabicFontIndex =
      Prefs.getInt("arabicFont", 0).clamp(0, kArabicFonts.length - 1);
  double arabicFontSize =
      Prefs.getDouble("arabicSize", AppFonts.defaultArabicSize)
          .clamp(AppFonts.minArabicSize, AppFonts.maxArabicSize);
  double translationFontSize =
      Prefs.getDouble("translationSize", AppFonts.defaultTranslationSize)
          .clamp(AppFonts.minTranslationSize, AppFonts.maxTranslationSize);

  AppArabicFont get arabicFont => kArabicFonts[arabicFontIndex];

  void setDuas(List<DuaModel> duas) {
    this.duas = duas;
    states.notify();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    Prefs.setInt("themeMode", mode.index);
    states.notify();
  }

  void setAccentIndex(int index) {
    accentIndex = index.clamp(0, kAppAccents.length - 1);
    Prefs.setInt("accentIndex", accentIndex);
    states.notify();
  }

  void setArabicFontIndex(int index) {
    arabicFontIndex = index.clamp(0, kArabicFonts.length - 1);
    Prefs.setInt("arabicFont", arabicFontIndex);
    states.notify();
  }

  void setArabicFontSize(double size) {
    arabicFontSize =
        size.clamp(AppFonts.minArabicSize, AppFonts.maxArabicSize).toDouble();
    Prefs.setDouble("arabicSize", arabicFontSize);
    states.notify();
  }

  void setTranslationFontSize(double size) {
    translationFontSize = size
        .clamp(AppFonts.minTranslationSize, AppFonts.maxTranslationSize)
        .toDouble();
    Prefs.setDouble("translationSize", translationFontSize);
    states.notify();
  }
}

final states = RM.inject(() => States());
