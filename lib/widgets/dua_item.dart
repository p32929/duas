import 'package:bp_stbv1/models/dua_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

// 'Reem Kufi'
// harmattan
// mada

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
          style: GoogleFonts.mada(
            textStyle: TextStyle(
              fontSize: 40,
            ),
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
            fontSize: 12,
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
