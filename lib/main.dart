import 'package:bp_stbv1/models/states.dart';
import 'package:bp_stbv1/routes/dua_route.dart';
import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';
import 'package:prefs/prefs.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

Future<void> main() async {
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
      ),
    );
  }
}
