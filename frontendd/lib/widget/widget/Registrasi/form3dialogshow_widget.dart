import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trad/Utility/text_opensans.dart';
import 'package:trad/Utility/warna.dart';
import 'package:trad/Widget/component/costume_button.dart';

class KodeReferalDialog extends StatelessWidget {
  const KodeReferalDialog({super.key});

  @override
  Widget build(BuildContext context) {
    //Tinggi full HP
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    //Lebar  full HP
    final mediaQueryWeight = MediaQuery.of(context).size.width;
    int count = 0;
    String kodeReferal = 'ADDDSSSCCC';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: AlertDialog(
          backgroundColor: Colors.black,
          elevation: 20,
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          content: SizedBox(
            height: 301,
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
                            child: OpenSansText.custom(
                                text: 'Kode Referal',
                                fontSize: 14,
                                warna: MyColors.textWhite(),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 22, right: 18, top: 80),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OpenSansText.custom(
                              text:
                                  'Selamat Anda Berhasil Mendapatkan Kode referal! Salin dan gunakan kode referal dibawah ini  untuk melanjutkan',
                              fontSize: 12,
                              warna: MyColors.black(),
                              fontWeight: FontWeight.w400),
                          Padding(
                            padding:
                                EdgeInsets.only(right: 23, left: 26, top: 36),
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  OpenSansText.custom(
                                      text: kodeReferal,
                                      fontSize: 20,
                                      warna: MyColors.black(),
                                      fontWeight: FontWeight.w700),
                                  IconButton(
                                      onPressed: () {
                                        Clipboard.setData(
                                                ClipboardData(
                                                    text: kodeReferal))
                                            .then((value) => ScaffoldMessenger
                                                    .of(context)
                                                .showSnackBar(SnackBar(
                                                    content: OpenSansText.custom(
                                                        text:
                                                            'Kode Referal Sudah Disalin',
                                                        fontSize: 16,
                                                        warna: MyColors
                                                            .primaryLighter(),
                                                        fontWeight:
                                                            FontWeight.w700))));
                                      },
                                      icon: Icon(Icons.copy_rounded))
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 31,
                          ),
                          CostumeButton(
                            backgroundColorbtn: MyColors.bluedark(),
                            onTap: () {
                              Navigator.of(context)
                                  .popUntil((_) => count++ >= 2);
                            },
                            backgroundTextbtn: MyColors.textWhite(),
                            buttonText: 'Masukan kode',
                          )
                        ],
                      ),
                    )
                  ],
                )),
              ),
            ),
          )),
    );
  }
}
