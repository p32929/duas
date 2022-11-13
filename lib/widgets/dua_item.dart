import 'package:bp_stbv1/models/dua_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

// 'Reem Kufi'

class DuaItem extends StatelessWidget {
  DuaModel duaModel;
  DuaItem({super.key, required this.duaModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          duaModel.arabic,
          style: TextStyle(
            fontSize: 36,
          ),
          textDirection: TextDirection.rtl,
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 16,
          ),
        ),
        Text(
          duaModel.meaning,
          textDirection: TextDirection.ltr,
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 4,
          ),
        ),
        Text(
          duaModel.source,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 16,
          ),
        ),
      ],
    );
  }
}
