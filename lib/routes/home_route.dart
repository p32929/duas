import 'package:bp_stbv1/models/dua_model.dart';
import 'package:bp_stbv1/models/states.dart';
import 'package:bp_stbv1/utils/apis.dart';
import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  getDuas() async {
    List<DuaModel>? duas = await Apis.getDuas();
    states.state.setDuas(duas!);
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      observe: () => states,
      builder: (context, model) => Scaffold(
        appBar: AppBar(
          title: Text("Duas"),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            return Text("Hello");
          },
          itemCount: 10,
        ),
      ),
    );
  }
}
