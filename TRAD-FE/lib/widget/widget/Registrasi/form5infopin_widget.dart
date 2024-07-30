import 'package:flutter/material.dart';
import 'package:trad/Utility/text_opensans.dart';
import 'package:trad/Utility/warna.dart';
import 'package:trad/Widget/component/costume_alertdialog.dart';

class AlertMassagePIN extends StatelessWidget {
  const AlertMassagePIN({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
            child: AlertDialogCustome(
                Textjudul: OpenSansText.custom(
                    text: 'Petunjuk PIN',
                    fontSize: 14,
                    warna: MyColors.textWhiteHover(),
                    fontWeight: FontWeight.w600),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OpenSansText.custom(
                        text:
                            'Kode PIN akan digunakan untuk validasi tambahan dalam aplikasi. Gunakan kombinasi 6 digit angka. ',
                        fontSize: 12,
                        warna: MyColors.black(),
                        fontWeight: FontWeight.w400),
                    SizedBox(
                      height: 20,
                    ),
                    OpenSansText.custom(
                        text: 'Pastikan kerahasiaan kode PIN terjaga',
                        fontSize: 12,
                        warna: MyColors.black(),
                        fontWeight: FontWeight.bold)
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
