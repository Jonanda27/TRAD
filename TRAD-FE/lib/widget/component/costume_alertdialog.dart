import 'package:flutter/material.dart';
import 'package:trad/Utility/text_opensans.dart';
import 'package:trad/Utility/warna.dart';

class AlertDialogCustome extends StatelessWidget {
  final Widget Textjudul;
  final Widget content;
  const AlertDialogCustome(
      {super.key, required this.Textjudul, required this.content});

  @override
  Widget build(BuildContext context) {
    //Tinggi full HP
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    //Lebar  full HP
    final mediaQueryWeight = MediaQuery.of(context).size.width;
    return AlertDialog(
      backgroundColor: Colors.black,
      elevation: 20,
      insetPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      content: SizedBox(
        height: mediaQueryHeight,
        width: mediaQueryWeight,
        child: PhysicalModel(
          color: MyColors.textWhiteHover(),
          elevation: 20,
          shadowColor: MyColors.primaryLighter(),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 405,
            child: SingleChildScrollView(
                child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(6),
                          topLeft: Radius.circular(6),
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8)),
                      color: MyColors.bluedark(),
                      boxShadow: [
                        BoxShadow(
                          color: MyColors.primary(),
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                          offset: Offset(
                              2.0, 2.0), // shadow direction: bottom right
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_rounded,
                              color: MyColors.textWhite(),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Textjudul,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 22, right: 18, top: 80),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [content],
                  ),
                )
              ],
            )),
          ),
        ),
      ),
    );
  }
}
