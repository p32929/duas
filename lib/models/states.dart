import 'dart:convert';

import 'package:duas/models/dua_model.dart';
import 'package:duas/theme/app_fonts.dart';
import 'package:duas/theme/app_theme.dart';
import 'package:duas/utils/apis.dart';
import 'package:flutter/material.dart';
import 'package:prefs/prefs.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class States {
  /// The ready-made duas loaded from the data source.
  List<DuaModel> duas = [];

  // --- The user's own duas (persisted on this device) ---
  List<DuaModel> myDuas = _loadMyDuas();

  /// Whether the ready-made duas are shown next to the user's own. On by
  /// default: new users start with them and delete what they do not want.
  bool showReadyMade = Prefs.getBool("showReadyMade", true);

  /// Ready-made duas the person deleted (they are hidden, so they can be
  /// restored).
  Set<String> hidden = Prefs.getStringList("hiddenDuas", const []).toSet();

  /// A stable key for a ready-made dua (they have no id).
  static String keyOf(DuaModel d) {
    var h = 0x811c9dc5;
    for (final c in utf8.encode('${d.arabic}|${d.meaning}')) {
      h ^= c;
      h = (h * 0x01000193) & 0xffffffff;
    }
    return h.toRadixString(16);
  }

  /// What the list shows: the user's own duas first, then the ready-made ones
  /// they have not deleted.
  List<DuaModel> get allDuas => [
        ...myDuas,
        if (showReadyMade) ...duas.where((d) => !hidden.contains(keyOf(d))),
      ];

  static List<DuaModel> _loadMyDuas() {
    final raw = Prefs.getString("myDuas", "");
    if (raw.isEmpty) return [];
    try {
      final List list = json.decode(raw);
      return list
          .map((e) => DuaModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void _saveMyDuas() {
    Prefs.setString(
        "myDuas", json.encode(myDuas.map((d) => d.toJson()).toList()));
  }

  void setShowReadyMade(bool value) {
    showReadyMade = value;
    Prefs.setBool("showReadyMade", value);
    states.notify();
  }

  void addDua(
      {required String arabic,
      required String meaning,
      required String source}) {
    myDuas.insert(
      0,
      DuaModel(
        arabic: arabic.trim(),
        meaning: meaning.trim(),
        source: source.trim(),
        id: DateTime.now().microsecondsSinceEpoch.toString(),
      ),
    );
    _saveMyDuas();
    states.notify();
  }

  void updateDua(String id,
      {required String arabic,
      required String meaning,
      required String source}) {
    final i = myDuas.indexWhere((d) => d.id == id);
    if (i < 0) return;
    myDuas[i] = DuaModel(
      arabic: arabic.trim(),
      meaning: meaning.trim(),
      source: source.trim(),
      id: id,
    );
    _saveMyDuas();
    states.notify();
  }

  /// Deletes any dua: the person's own are removed, ready-made ones are
  /// hidden (see [restoreDeleted]).
  void deleteDua(DuaModel dua) {
    if (dua.isMine) {
      myDuas.removeWhere((d) => d.id == dua.id);
      _saveMyDuas();
    } else {
      hidden.add(keyOf(dua));
      Prefs.setStringList("hiddenDuas", hidden.toList());
    }
    states.notify();
  }

  /// Brings back every ready-made dua the person deleted.
  void restoreDeleted() {
    hidden.clear();
    Prefs.setStringList("hiddenDuas", const []);
    states.notify();
  }

  // --- Data source (persisted) ---
  String dataUrl = Prefs.getString("dataUrl", Apis.defaultDataUrl);

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

  /// Persists a new data-source URL. Falls back to the default when blank.
  /// Clears the cached response so the next load fetches from the new URL.
  /// Returns true if the URL actually changed.
  bool setDataUrl(String url) {
    final trimmed = url.trim();
    final next = trimmed.isEmpty ? Apis.defaultDataUrl : trimmed;
    if (next == dataUrl) return false;
    dataUrl = next;
    Prefs.setString("dataUrl", next);
    Prefs.setString("data", ""); // invalidate cache
    states.notify();
    return true;
  }

  void resetDataUrl() => setDataUrl(Apis.defaultDataUrl);

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
