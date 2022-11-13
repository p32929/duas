import 'dart:convert';

class DuaModel {
  DuaModel({
    required this.arabic,
    required this.source,
    required this.meaning,
  });

  final String arabic;
  final String source;
  final String meaning;

  factory DuaModel.fromRawJson(String str) =>
      DuaModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DuaModel.fromJson(Map<String, dynamic> json) => DuaModel(
        arabic: json["arabic"],
        source: json["source"],
        meaning: json["meaning"],
      );

  Map<String, dynamic> toJson() => {
        "arabic": arabic,
        "source": source,
        "meaning": meaning,
      };
}
