import 'package:duas/models/dua_model.dart';
import 'package:duas/models/states.dart';
import 'package:duas/utils/apis.dart';
import 'package:duas/widgets/dua_item.dart';
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

  showLoading() {
    OneContext().showDialog(
      builder: (p0) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(
                Icons.rotate_right_rounded,
              ),
              title: Text("Loading"),
              subtitle: Text("Please wait..."),
            ),
          ),
        );
      },
    );
  }

  hideLoading() {
    OneContext().popAllDialogs();
  }

  getDuas({bool force = false}) async {
    String data = Prefs.getString("data");
    if (data == "" || force) {
      showLoading();
      List<DuaModel>? duas = await Apis.getDuas();
      states.state.setDuas(duas!);
      hideLoading();
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
          actions: [
            IconButton(
              onPressed: () {
                getDuas(force: true);
              },
              icon: Icon(
                Icons.rotate_right_rounded,
              ),
            ),
          ],
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
