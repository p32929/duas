import 'dart:convert';

import 'package:bp_stbv1/models/dua_model.dart';
import 'package:http/http.dart' as http;

getDuaListFromJson(String jsonStr) {
  final List t = json.decode(jsonStr);
  final List<DuaModel> portasAbertasList =
      t.map((item) => DuaModel.fromJson(item)).toList();
  return portasAbertasList;
}

class Apis {
  static Future<List<DuaModel>?> getDuas() async {
    var request = http.Request(
        'GET', Uri.parse('https://api.npoint.io/2ac8517d3ab8e8dfea0a'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // print();
      var jsonStr = await response.stream.bytesToString();
      return getDuaListFromJson(jsonStr);
    } else {
      // print(response.reasonPhrase);
      return null;
    }
  }
}
