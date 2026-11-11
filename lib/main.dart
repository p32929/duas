import 'package:duas/models/states.dart';
import 'package:duas/routes/dua_route.dart';
import 'package:duas/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:prefs/prefs.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:duas/theme/font_loader.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await Prefs.init();
  // the fonts arrive in the background; text shows in the system font first
  AppFontLoader.load('Inter');
  AppFontLoader.load('Newsreader');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      observe: () => states,
      builder: (context, model) {
        final seed = states.state.accent.seed;
        return MaterialApp(
          home: DuaRoute(),
          theme: AppTheme.light(seed),
          darkTheme: AppTheme.dark(seed),
          themeMode: states.state.themeMode,
          debugShowCheckedModeBanner: false,
          title: "Duas",
        );
      },
    );
  }
}
