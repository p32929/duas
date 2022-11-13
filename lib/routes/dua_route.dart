import 'package:bp_stbv1/models/dua_model.dart';
import 'package:bp_stbv1/models/states.dart';
import 'package:bp_stbv1/utils/apis.dart';
import 'package:bp_stbv1/widgets/dua_item.dart';
import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';
import 'package:prefs/prefs.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class DuaRoute extends StatefulWidget {
  const DuaRoute({super.key});

  @override
  State<DuaRoute> createState() => _DuaRouteState();
}

class _DuaRouteState extends State<DuaRoute> {
  @override
  void initState() {
    super.initState();
    getDuas();
  }

  getDuas() async {
    // Prefs.clear();
    String data = Prefs.getString("data");
    if (data == "") {
      List<DuaModel>? duas = await Apis.getDuas();
      states.state.setDuas(duas!);
    } else {
      List<DuaModel>? duas = getDuaListFromJson(data);
      states.state.setDuas(duas!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      observe: () => states,
      builder: (context, model) => Scaffold(
        appBar: AppBar(
          title: Text(
            "Duas",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemBuilder: (context, index) {
              return DuaItem(
                duaModel: states.state.duas[index],
              );
            },
            itemCount: states.state.duas.length,
          ),
        ),
      ),
    );
  }
}
