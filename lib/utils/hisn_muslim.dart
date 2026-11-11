import 'dart:convert';

import 'package:http/http.dart' as http;

/// One dua ready to add: the text and source come straight from the book.
class DuaSuggestion {
  final String arabic;
  final String meaning;
  final String source;

  const DuaSuggestion({
    required this.arabic,
    required this.meaning,
    required this.source,
  });
}

/// One topic (chapter) of the book, for example "Invocation for entering the
/// mosque".
class HisnChapter {
  final int id;
  final String title;
  const HisnChapter(this.id, this.title);
}

/// Duas from Hisn al-Muslim (Fortress of the Muslim), using the free
/// hisnmuslim.com API. Nothing is generated: every word and every source is
/// the book's own. The API is free, needs no key and allows browser calls.
class HisnMuslim {
  static const String _base = 'https://www.hisnmuslim.com/api/en';
  static const String bookName = 'Hisn al-Muslim';

  static List<HisnChapter>? _chapters;
  static final Map<int, List<DuaSuggestion>> _duas = {};

  /// [client] is only for tests.
  static http.Client Function() clientFactory = http.Client.new;

  static Future<String> _get(String path) async {
    final c = clientFactory();
    try {
      final res = await c
          .get(Uri.parse('$_base/$path'))
          .timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) {
        throw HisnException('The book could not be loaded right now.');
      }
      // the files start with a byte-order mark
      return utf8.decode(res.bodyBytes).replaceFirst('﻿', '');
    } finally {
      c.close();
    }
  }

  /// All 132 topics of the book (loaded once).
  static Future<List<HisnChapter>> chapters() async {
    if (_chapters != null) return _chapters!;
    final data = json.decode(await _get('husn_en.json'));
    final list = (data['English'] as List)
        .map((e) => HisnChapter(
            int.parse(e['ID'].toString()), e['TITLE'].toString().trim()))
        .toList();
    return _chapters = list;
  }

  /// The duas of one topic (loaded once per topic).
  static Future<List<DuaSuggestion>> duas(HisnChapter chapter) async {
    final cached = _duas[chapter.id];
    if (cached != null) return cached;
    final list = parseChapter(await _get('${chapter.id}.json'), chapter.title);
    return _duas[chapter.id] = list;
  }

  /// Reads one chapter file of the API.
  static List<DuaSuggestion> parseChapter(String body, String title) {
    final data = json.decode(body.replaceFirst('﻿', ''));
    if (data is! Map || data.isEmpty) return [];
    final items = data.values.first;
    if (items is! List) return [];
    final out = <DuaSuggestion>[];
    for (final e in items) {
      if (e is! Map) continue;
      final arabic = (e['ARABIC_TEXT'] ?? '').toString().trim();
      final meaning = (e['TRANSLATED_TEXT'] ?? '').toString().trim();
      if (arabic.isEmpty && meaning.isEmpty) continue;
      final note =
          (e['LANGUAGE_ARABIC_TRANSLATED_TEXT'] ?? '').toString().trim();
      // this field is mostly a transliteration; only "Recite …" notes are
      // references (Quran verses), so only those go into the source
      final reference = note.toLowerCase().startsWith('recite') ||
              note.toLowerCase().startsWith('then recite')
          ? note
          : '';
      final repeat = int.tryParse((e['REPEAT'] ?? '').toString()) ?? 1;
      final source = [
        '$bookName: $title',
        if (reference.isNotEmpty) reference,
        if (repeat > 1) 'say $repeat times',
      ].join(' · ');
      out.add(DuaSuggestion(arabic: arabic, meaning: meaning, source: source));
    }
    return out;
  }

  // ------------------------------------------------------------------ search

  static const Set<String> _stop = {
    'dua',
    'duas',
    'doa',
    'dhikr',
    'supplication',
    'supplications',
    'invocation',
    'invocations',
    'for',
    'the',
    'a',
    'an',
    'to',
    'of',
    'and',
    'or',
    'when',
    'what',
    'say',
    'my',
    'me',
    'i',
    'you',
    'your',
    'in',
    'on',
    'at',
    'is',
    'it',
    'with',
    'from',
    'want',
    'need',
    'some',
    'about',
  };

  /// Everyday words mapped to the words the book's titles use.
  static const Map<String, List<String>> _also = {
    'anxiety': ['worry', 'grief', 'anguish'],
    'anxious': ['worry', 'grief', 'anguish'],
    'stress': ['worry', 'anguish'],
    'sad': ['grief', 'worry', 'depressed'],
    'sadness': ['grief', 'worry', 'depressed'],
    'sorrow': ['grief'],
    'depression': ['depressed', 'grief'],
    'scared': ['afraid', 'frightened', 'fear'],
    'fear': ['afraid', 'frightened'],
    'sleep': ['sleeping'],
    'bed': ['sleeping'],
    'nightmare': ['dream'],
    'travel': ['traveling', 'journey', 'traveler'],
    'travelling': ['traveling', 'journey'],
    'trip': ['traveling', 'journey'],
    'journey': ['traveling'],
    'car': ['vehicle'],
    'house': ['home'],
    'toilet': ['restroom'],
    'bathroom': ['restroom'],
    'wudu': ['ablution'],
    'wudhu': ['ablution'],
    'adhan': ['athan'],
    'azan': ['athan'],
    'masjid': ['mosque'],
    'food': ['eating'],
    'meal': ['eating'],
    'eat': ['eating'],
    'iftar': ['fast', 'breaking'],
    'fasting': ['fast'],
    'sick': ['sick', 'ill'],
    'ill': ['sick'],
    'illness': ['sick', 'ill'],
    'death': ['dead', 'dying'],
    'funeral': ['dead', 'funeral'],
    'forgive': ['forgiveness', 'repentance', 'sin'],
    'forgiveness': ['repentance', 'sin'],
    'tawbah': ['repentance', 'forgiveness'],
    'repent': ['repentance', 'forgiveness'],
    'loan': ['debt'],
    'angry': ['anger'],
    'protect': ['protection', 'harm'],
    'protection': ['harm'],
    'marriage': ['groom', 'wedding'],
    'wedding': ['groom'],
    'baby': ['children', 'child', 'parents'],
    'kids': ['children'],
    'salah': ['prayer'],
    'namaz': ['prayer'],
    'shaytan': ['devil', 'satan'],
    'satan': ['devil'],
  };

  /// Lower-case words of [s], letters and digits only.
  static List<String> words(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r"[^a-z0-9\s]"), ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();

  /// True when a search word and a text word are the same word (sleep and
  /// sleeping, travel and travels).
  static bool wordMatch(String query, String title) {
    if (query == title) return true;
    // sleep → sleeping, travels → travel
    if (query.length >= 3 && title.startsWith(query)) return true;
    if (title.length >= 4 && query.startsWith(title)) return true;
    return false;
  }

  /// The meaningful words the person typed (filler words dropped).
  static List<String> askedWords(String query) =>
      words(query).where((w) => !_stop.contains(w)).toList();

  /// The person's words plus the words the books use for the same thing.
  static Set<String> expand(List<String> asked) => {
        for (final w in asked) ...[w, ...?_also[w]],
      };

  /// How well [text] matches: the person's own words count 2, the extra
  /// words 1. Zero means no match.
  static int score(String text, List<String> asked, Set<String> terms) {
    final textWords = words(text).where((w) => !_stop.contains(w)).toList();
    var score = 0;
    for (final t in terms) {
      if (textWords.any((tw) => wordMatch(t, tw))) {
        score += asked.contains(t) ? 2 : 1;
      }
    }
    return score;
  }

  /// The topics that best match what the person typed, best first.
  static List<HisnChapter> match(List<HisnChapter> all, String query) {
    final asked = askedWords(query);
    if (asked.isEmpty) return [];
    final terms = expand(asked);
    final scored = <MapEntry<HisnChapter, int>>[];
    for (final c in all) {
      final s = score(c.title, asked, terms);
      if (s > 0) scored.add(MapEntry(c, s));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).toList();
  }
}

class HisnException implements Exception {
  final String message;
  HisnException(this.message);
  @override
  String toString() => message;
}
