// Keeps downloaded font files on the device. On the web the browser's own
// cache does this (Google serves them with a one-year cache), so it is a no-op.
export 'font_cache_stub.dart' if (dart.library.io) 'font_cache_io.dart';
