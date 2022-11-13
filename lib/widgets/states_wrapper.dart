import 'package:bp_stbv1/models/states.dart';
import 'package:flutter/cupertino.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class StatesWrapper extends StatelessWidget {
  final Widget widget;
  const StatesWrapper({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      observe: () => states,
      builder: (context, model) => widget,
    );
  }
}
