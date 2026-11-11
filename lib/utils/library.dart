import 'dart:convert';

import 'package:duas/utils/hisn_muslim.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

/// One dua from a collection, with the topic it belongs to (for search).
class LibDua {
  final String topic;
  final String arabic;
  final String meaning;
  final String source;
  const LibDua(this.topic, this.arabic, this.meaning, this.source);

  DuaSuggestion toSuggestion() =>
      DuaSuggestion(arabic: arabic, meaning: meaning, source: source);
}

/// A collection of duas besides Hisn al-Muslim. Nothing in them is written by
/// AI, except where a source says "meaning translated by AI" (the Arabic-only
/// Majmu' al-Adhkar hadith duas, whose Arabic and sources are exact).
class Collection {
  final String name;
  final String about;
  final Future<List<LibDua>> Function() _load;
  List<LibDua>? _cache;

  Collection(this.name, this.about, this._load);

  Future<List<LibDua>> duas() async => _cache ??= await _load();

  /// The topics (groups) in this collection, in their original order.
  Future<List<String>> topics() async {
    final seen = <String>{};
    return [
      for (final d in await duas())
        if (seen.add(d.topic)) d.topic
    ];
  }
}

class Library {
  static final Collection fitrahive = Collection(
    'Dua & Dhikr',
    'fitrahive/dua-dhikr, with hadith references',
    () => _asset('assets/data/fitrahive.json'),
  );

  static final Collection majmu = Collection(
    "Majmu' al-Adhkar",
    "Sa'id al-Qahtani's book, with exact hadith and Quran references",
    () => _asset('assets/data/majmu.json'),
  );

  static final Collection deenOne = Collection(
    'DeenOne',
    'DeenOne dua collection (references in Bengali)',
    _deenOne,
  );

  static List<Collection> get all => [fitrahive, deenOne, majmu];

  static Future<List<LibDua>> _asset(String path) async {
    final list = json.decode(await rootBundle.loadString(path)) as List;
    return [
      for (final e in list)
        LibDua(e['topic'].toString(), e['arabic'].toString(),
            e['meaning'].toString(), e['source'].toString())
    ];
  }

  /// Loaded from the project's own repository (pinned to one version), not
  /// copied into this app.
  static Future<List<LibDua>> _deenOne() async {
    const url = 'https://raw.githubusercontent.com/riadmonir/dua-api/'
        'eba1fd596c1d41ec01a5613e6bcc9fb2aa2198d5/deenone_all_duas.json';
    final res =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) throw Exception('DeenOne ${res.statusCode}');
    return parseDeenOne(utf8.decode(res.bodyBytes));
  }

  /// Keeps entries with Arabic and a real English meaning. In some entries
  /// the English box holds a reference instead of a meaning; those are left
  /// out.
  static List<LibDua> parseDeenOne(String body) {
    final data = json.decode(body);
    final out = <LibDua>[];
    for (final e in (data['duas'] as List)) {
      final arabic = (e['arabic'] ?? '').toString().trim();
      final english = (e['english'] ?? '').toString().trim();
      if (arabic.isEmpty || english.isEmpty) continue;
      if (RegExp(r'^\s*(reference|ref\.)', caseSensitive: false)
          .hasMatch(english)) {
        continue;
      }
      final ref = (e['reference'] ?? '').toString().trim();
      final topic = (e['category_name_en'] ?? 'Duas').toString().trim();
      out.add(LibDua(
        topic,
        arabic,
        english,
        ref.isEmpty ? 'DeenOne · $topic' : 'DeenOne · $ref',
      ));
    }
    return out;
  }

  /// The duas of [entries] that match [query], best first. The topic counts
  /// more than the meaning.
  static List<LibDua> search(List<LibDua> entries, String query,
      {int limit = 6}) {
    final asked = HisnMuslim.askedWords(query);
    if (asked.isEmpty) return [];
    final terms = HisnMuslim.expand(asked);
    final scored = <MapEntry<LibDua, int>>[];
    for (final d in entries) {
      final s = 3 * HisnMuslim.score(d.topic, asked, terms) +
          HisnMuslim.score(d.meaning, asked, terms);
      // at least one of the person's own words, not only an extra word
      if (s >= 2) scored.add(MapEntry(d, s));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(limit).map((e) => e.key).toList();
  }
}
