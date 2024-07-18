import 'package:flutter/material.dart';
import 'package:trad/Utility/text_opensans.dart';
import 'package:trad/Utility/warna.dart';
import 'package:trad/Widget/component/costume_alertdialog.dart';

class AlertMassagePassword extends StatelessWidget {
  const AlertMassagePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: 200,
            child: AlertDialogCustome(
              Textjudul: OpenSansText.custom(
                  text: 'Petunjuk Kata Sandi',
                  fontSize: 14,
                  warna: MyColors.textWhiteHover(),
                  fontWeight: FontWeight.w600),
              content: OpenSansText.custom(
                  text:
                      'Gunakan gabungan angka, huruf kecil, dan huruf besar. Panjang password minimal 8 karakter',
                  fontSize: 12,
                  warna: MyColors.black(),
                  fontWeight: FontWeight.w400),
            ),
          ),
        )
      ],
    );
  }
}
