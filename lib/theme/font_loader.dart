import 'package:duas/theme/font_cache.dart';
import 'package:duas/theme/font_files.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Loads the few fonts the app uses, on demand. This replaces the
/// google_fonts package, which carried data for 1,500+ fonts (8 MB of app
/// code). Until a font arrives, text shows in the system font.
class AppFontLoader {
  static final Set<String> _started = {};

  static Future<void> load(String family) async {
    final files = kFontFiles[family];
    if (files == null || !_started.add(family)) return;
    try {
      final loader = FontLoader(family);
      for (final hash in files.values) {
        loader.addFont(_bytes(hash));
      }
      await loader.load();
    } catch (_) {
      _started.remove(family); // try again next time
    }
  }

  static Future<ByteData> _bytes(String hash) async {
    final cached = await readFont(hash);
    if (cached != null) return ByteData.sublistView(cached);
    final res = await http
        .get(Uri.parse('https://fonts.gstatic.com/s/a/$hash.ttf'))
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) {
      throw Exception('font $hash: ${res.statusCode}');
    }
    await writeFont(hash, res.bodyBytes);
    return ByteData.sublistView(res.bodyBytes);
  }
}
