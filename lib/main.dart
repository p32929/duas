import 'package:duas/models/states.dart';
import 'package:duas/routes/dua_route.dart';
import 'package:flutter/material.dart';
import 'package:prefs/prefs.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      observe: () => states,
      builder: (context, model) => MaterialApp(
        // initialRoute: "/",
        // routes: {
        //   "/": (_) => DuaRoute(),
        //   // "/another": (_) => AnotherRoute(),
        // },
        // builder: OneContext().builder,
        // navigatorKey: OneContext().key,
        home: DuaRoute(),
        theme: ThemeData(
          brightness: Brightness.dark,
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
