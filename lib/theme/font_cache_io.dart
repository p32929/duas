import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<File> _file(String hash) async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/fonts/$hash.ttf');
}

Future<Uint8List?> readFont(String hash) async {
  try {
    final f = await _file(hash);
    if (await f.exists()) return await f.readAsBytes();
  } catch (_) {}
  return null;
}

Future<void> writeFont(String hash, Uint8List bytes) async {
  try {
    final f = await _file(hash);
    await f.parent.create(recursive: true);
    await f.writeAsBytes(bytes, flush: true);
  } catch (_) {}
}
