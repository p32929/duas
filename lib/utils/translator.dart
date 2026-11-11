import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:prefs/prefs.dart';

/// Translates a dua's English meaning into another language with
/// Qwen3.5-397B on OVH AI Endpoints (free, no key, 2 requests a minute).
/// Only the meaning is translated; the Arabic and the source never are.
/// Results are kept on the device so each meaning is translated once.
class Translator {
  static const String _url =
      'https://oai.endpoints.kepler.ai.cloud.ovh.net/v1/chat/completions';
  static const String _model = 'Qwen3.5-397B-A17B';

  /// Popular languages offered in the list. People can also type any other.
  static const List<String> languages = [
    'Bengali',
    'Urdu',
    'Hindi',
    'Indonesian',
    'Malay',
    'Turkish',
    'Persian',
    'Arabic',
    'French',
    'Spanish',
    'German',
    'Portuguese',
    'Italian',
    'Dutch',
    'Russian',
    'Ukrainian',
    'Polish',
    'Czech',
    'Romanian',
    'Hungarian',
    'Greek',
    'Swedish',
    'Norwegian',
    'Danish',
    'Finnish',
    'Bosnian',
    'Albanian',
    'Serbian',
    'Croatian',
    'Bulgarian',
    'Azerbaijani',
    'Uzbek',
    'Kazakh',
    'Kyrgyz',
    'Tajik',
    'Turkmen',
    'Pashto',
    'Dari',
    'Kurdish',
    'Somali',
    'Swahili',
    'Hausa',
    'Yoruba',
    'Amharic',
    'Oromo',
    'Wolof',
    'Tamil',
    'Telugu',
    'Malayalam',
    'Kannada',
    'Marathi',
    'Gujarati',
    'Punjabi',
    'Sindhi',
    'Nepali',
    'Sinhala',
    'Chinese',
    'Japanese',
    'Korean',
    'Thai',
    'Vietnamese',
    'Filipino',
    'Burmese',
    'Khmer',
  ];

  /// A stable key for the saved translation (FNV-1a hash of the text).
  static String _key(String language, String text) {
    var h = 0x811c9dc5;
    for (final c in utf8.encode(text)) {
      h ^= c;
      h = (h * 0x01000193) & 0xffffffff;
    }
    return 'tr:$language:${h.toRadixString(16)}';
  }

  static String _listKey(String text) =>
      _key('_list', text).replaceFirst('tr:_list:', 'trl:');

  /// Translations of [text] the person chose to keep: language → text.
  static Map<String, String> savedAll(String text) {
    final langs = Prefs.getStringList(_listKey(text), const []);
    return {
      for (final l in langs)
        if (Prefs.getString(_key(l, text), '').isNotEmpty)
          l: Prefs.getString(_key(l, text), ''),
    };
  }

  /// Keeps a translation the person approved.
  static void save(String language, String text, String translation) {
    Prefs.setString(_key(language, text), translation);
    final langs = Prefs.getStringList(_listKey(text), const []).toList();
    if (!langs.contains(language)) langs.add(language);
    Prefs.setStringList(_listKey(text), langs);
  }

  static void remove(String language, String text) {
    Prefs.setString(_key(language, text), '');
    final langs = Prefs.getStringList(_listKey(text), const []).toList()
      ..remove(language);
    Prefs.setStringList(_listKey(text), langs);
  }

  /// The last language used, shown first next time.
  static String get lastLanguage => Prefs.getString('trLast', '');

  /// Asks the AI for a translation. Nothing is saved here: the person sees
  /// it next to the English first and decides with [save].
  static Future<String> translate(String language, String text,
      {http.Client? client}) async {
    Prefs.setString('trLast', language);
    final c = client ?? http.Client();
    try {
      final res = await c
          .post(
            Uri.parse(_url),
            headers: const {'Content-Type': 'application/json'},
            body: json.encode({
              'model': _model,
              'temperature': 0,
              // Qwen thinks before it answers; for less common languages the
              // thinking alone can pass 4000 tokens, so leave plenty of room
              'max_tokens': 16000,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You translate Islamic supplications (duas) from English '
                          'into natural, correct $language. Translate the whole '
                          'text without leaving out any word. Reply with only '
                          'the translation.'
                },
                {'role': 'user', 'content': text},
              ],
            }),
          )
          .timeout(const Duration(seconds: 150));
      if (res.statusCode == 429) {
        throw TranslateException(
            'The free translator is busy. Please try again in a minute.');
      }
      if (res.statusCode != 200) {
        throw TranslateException('Could not translate right now. Try again.');
      }
      final data = json.decode(utf8.decode(res.bodyBytes));
      var out = (data['choices'][0]['message']['content'] ?? '').toString();
      out = out.replaceAll(RegExp(r'<think>[\s\S]*?</think>'), '').trim();
      if (out.isEmpty) {
        throw TranslateException('Could not translate right now. Try again.');
      }
      return out;
    } on TranslateException {
      rethrow;
    } catch (_) {
      throw TranslateException(
          'Could not translate. Check your internet connection and try again.');
    } finally {
      if (client == null) c.close();
    }
  }
}

class TranslateException implements Exception {
  final String message;
  TranslateException(this.message);
  @override
  String toString() => message;
}
