import 'package:duas/models/dua_model.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class States {
  int counter = 0;
  List<DuaModel> duas = [];

  increase(int num) {
    counter += num;
    states.notify();
  }

  setDuas(List<DuaModel> duas) {
    this.duas = duas;
    states.notify();
  }
}

final states = RM.inject(() => States());
