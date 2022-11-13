import 'package:bp_stbv1/models/states.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class AnotherRoute extends StatelessWidget {
  const AnotherRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      observe: () => states,
      builder: (context, model) => Scaffold(
        appBar: AppBar(
          title: Text("Counter: ${states.state.counter}"),
        ),
        body: ElevatedButton(
          child: Text("ANOTHER BUTTOM"),
          onPressed: () {
            states.state.increase(1);
          },
        ),
      ),
    );
  }
}
