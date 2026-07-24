import 'dart:convert';

import 'package:duas/models/dua_model.dart';
import 'package:http/http.dart' as http;
import 'package:prefs/prefs.dart';

getDuaListFromJson(String jsonStr) {
  final List t = json.decode(jsonStr);
  final List<DuaModel> portasAbertasList =
      t.map((item) => DuaModel.fromJson(item)).toList();
  return portasAbertasList;
}

class Apis {
  /// The URL used out of the box. Users can override this from Settings.
  static const String defaultDataUrl =
      'https://api.npoint.io/2ac8517d3ab8e8dfea0a';

  /// The URL currently in effect (user override, falling back to the default).
  static String get dataUrl => Prefs.getString("dataUrl", defaultDataUrl);

  static Future<List<DuaModel>?> getDuas() async {
    var request = http.Request('GET', Uri.parse(dataUrl));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // print();
      var jsonStr = await response.stream.bytesToString();
      Prefs.setString("data", jsonStr);
      return getDuaListFromJson(jsonStr);
    } else {
      // print(response.reasonPhrase);
      return null;
    }
  }
}
