import 'dart:convert';

class DuaModel {
  DuaModel({
    required this.arabic,
    required this.source,
    required this.meaning,
    this.id,
  });

  final String arabic;
  final String source;
  final String meaning;

  /// Set only for duas the user added on this device. Ready-made duas have none.
  final String? id;

  bool get isMine => id != null;

  factory DuaModel.fromRawJson(String str) =>
      DuaModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DuaModel.fromJson(Map<String, dynamic> json) => DuaModel(
        arabic: (json["arabic"] ?? "").toString(),
        source: (json["source"] ?? "").toString(),
        meaning: (json["meaning"] ?? "").toString(),
        id: json["id"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "arabic": arabic,
        "source": source,
        "meaning": meaning,
        if (id != null) "id": id,
      };
}
