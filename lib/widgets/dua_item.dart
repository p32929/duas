import 'package:duas/models/dua_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

// 'Reem Kufi'
// harmattan
// mada

class DuaItem extends StatelessWidget {
  final DuaModel duaModel;
  const DuaItem({super.key, required this.duaModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          duaModel.arabic,
          style: GoogleFonts.mada(
            textStyle: TextStyle(
              fontSize: 40,
              height: 1.6,
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
          '${duaModel.meaning} *** ${duaModel.source} ***',
          textDirection: TextDirection.ltr,
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
