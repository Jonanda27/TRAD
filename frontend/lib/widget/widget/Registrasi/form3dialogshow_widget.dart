// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:trad/Utility/text_opensans.dart';
// import 'package:trad/Utility/warna.dart';
// import 'package:trad/Widget/component/costume_button.dart';

// class KodeReferalDialog extends StatelessWidget {
//   const KodeReferalDialog({super.key});

//   @override
//   Widget build(BuildContext context) {
//     //Tinggi full HP
//     final mediaQueryHeight = MediaQuery.of(context).size.height;
//     //Lebar  full HP
//     final mediaQueryWeight = MediaQuery.of(context).size.width;
//     int count = 0;
//     String kodeReferal = 'TRAD2024';
//     return Center(
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(right: 24, left: 24, top: 4),
//               child: PhysicalModel(
//                 color: Colors.white,
//                 elevation: 20,
//                 shadowColor: MyColors.primaryLighter(),
//                 borderRadius: BorderRadius.circular(6),
//                 child: SizedBox(
//                   height: 405,
//                   child: SingleChildScrollView(
//                       child: Stack(
//                     children: [
//                       Align(
//                         alignment: Alignment.topCenter,
//                         child: Container(
//                           height: 60,
//                           decoration: BoxDecoration(
//                             borderRadius: const BorderRadius.only(
//                                 topRight: Radius.circular(6),
//                                 topLeft: Radius.circular(6),
//                                 bottomLeft: Radius.circular(8),
//                                 bottomRight: Radius.circular(8)),
//                             color: MyColors.bluedark(),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: MyColors.primary(),
//                                 blurRadius: 2.0,
//                                 spreadRadius: 0.0,
//                                 offset: const Offset(
//                                     2.0, 2.0), // shadow direction: bottom right
//                               ),
//                             ],
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 40),
//                             child: Align(
//                               alignment: Alignment.center,
//                               child: OpenSansText.custom(
//                                   text: 'Kode Referral',
//                                   fontSize: 14,
//                                   warna: MyColors.textWhite(),
//                                   fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding:
//                             const EdgeInsets.only(left: 22, right: 18, top: 80),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             OpenSansText.custom(
//                                 text:
//                                     'Selamat Anda Berhasil Mendapatkan Kode referal! Salin dan gunakan kode referal dibawah ini  untuk melanjutkan',
//                                 fontSize: 12,
//                                 warna: MyColors.black(),
//                                 fontWeight: FontWeight.w400),
//                             const SizedBox(
//                               height: 10,
//                             ),
// Padding(
//                               padding:
//                                   EdgeInsets.only(right: 23, left: 26, top: 36),
//                               child: Container(
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     OpenSansText.custom(
//                                         text: kodeReferal,
//                                         fontSize: 20,
//                                         warna: MyColors.black(),
//                                         fontWeight: FontWeight.w700),
//                                     IconButton(
//                                         onPressed: () {
//                                           Clipboard.setData(
//                                                   ClipboardData(
//                                                       text: kodeReferal))
//                                               .then((value) => ScaffoldMessenger
//                                                       .of(context)
//                                                   .showSnackBar(SnackBar(
//                                                       content: OpenSansText.custom(
//                                                           text:
//                                                               'Kode Referal Sudah Disalin',
//                                                           fontSize: 16,
//                                                           warna: MyColors
//                                                               .primaryLighter(),
//                                                           fontWeight:
//                                                               FontWeight.w700))));
//                                         },
//                                         icon: Icon(Icons.copy_rounded))
//                                          SizedBox(
//         width: MediaQuery.of(context).size.width,
//         height: 50,
//         child: ElevatedButton(
//           onPressed:  () {
//                                 Navigator.of(context)
//                                     .popUntil((_) => count++ >= 2);
//                               },
//           child: OpenSansText.custom(
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//               warna: MyColors.textWhite(),
//               text: "Masukkan Kode",),
//           style: ElevatedButton.styleFrom(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(6), // <-- Radius
//             ),
//             side: BorderSide(
//               width: 1,
//               color: MyColors.greenDarkButton(),
//             ),
//             backgroundColor: MyColors.greenDarkButton(),
//         ),
//       ),),
//                             const Padding(padding: EdgeInsets.only(top: 11)),
//                             // CostumeButton(
//                             //   backgroundColorbtn: MyColors.greenLight(),
//                             //   buttonText: "Kembali",
//                             //   onTap: () {
//                             //     setState(() {
//                             //       activeIndex--;
//                             //     });
//                             //   },
//                             //   backgroundTextbtn: MyColors.bluedark(),
//                             // )
//                             SizedBox(
//                               width: mediaQueryWeight,
//                               height: 50,
//                               child: OutlinedButton(
//                                 onPressed: () {},
//                                 child: Text(
//                                   "Kembali",
//                                   style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w700,
//                                       color: MyColors.greenDarkButton()),
//                                 ),
//                                 style: OutlinedButton.styleFrom(
//                                   minimumSize: Size(double.infinity, 50),
//                                   side: BorderSide(
//                                       width: 2,
//                                       color: MyColors.greenDarkButton()),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(
//                                         8.0), // Set corner radius here
//                                   ),
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                       )
//                     ],
//                   )),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//     //   return Padding(
//     // padding: EdgeInsets.symmetric(horizontal: 24),
//     // child: Container(
//     //   height: 10,
//     //   decoration: BoxDecoration(
//     //     color: MyColors.textWhiteHover(),
//     //     borderRadius: BorderRadius.circular(8),
//     //   ),
//     //   child: SingleChildScrollView(
//     //     child: Stack(
//     //       children: [
//     //         Align(
//     //           heightFactor: 1,
//     //           alignment: Alignment.topCenter,
//     //           child: Container(
//     //             height: 60,
//     //             decoration: BoxDecoration(
//     //               borderRadius: BorderRadius.only(
//     //                 topRight: Radius.circular(8),
//     //                 topLeft: Radius.circular(8),
//     //               ),
//     //               color: MyColors.greenDarkButton(),
//     //               boxShadow: [
//     //                 BoxShadow(
//     //                   color: MyColors.primary(),
//     //                   blurRadius: 2.0,
//     //                   spreadRadius: 0.0,
//     //                   offset: Offset(2.0, 2.0),
//     //                 ),
//     //               ],
//     //             ),
//     //             child: Padding(
//     //               padding: EdgeInsets.symmetric(horizontal: 40),
//     //               child: Align(
//     //                 alignment: Alignment.center,
//     //                 child: OpenSansText.custom(
//     //                   text: 'Kode Referal',
//     //                   fontSize: 14,
//     //                   warna: MyColors.textWhite(),
//     //                   fontWeight: FontWeight.w600,
//     //                 ),
//     //               ),
//     //             ),
//     //           ),
//     //         ),
//     //         Padding(
//     //           padding: EdgeInsets.only(left: 22, right: 18, top: 80),
//     //           child: Column(
//     //             mainAxisAlignment: MainAxisAlignment.center,
//     //             crossAxisAlignment: CrossAxisAlignment.start,
//     //             children: [
//     //                         OpenSansText.custom(
//     //                             text:
//     //                                 'Selamat Anda Berhasil Mendapatkan Kode referal! Salin dan gunakan kode referal dibawah ini  untuk melanjutkan',
//     //                             fontSize: 12,
//     //                             warna: MyColors.black(),
//     //                             fontWeight: FontWeight.w400),
//     //                         Padding(
//     //                           padding:
//     //                               EdgeInsets.only(right: 23, left: 26, top: 36),
//     //                           child: Container(
//     //                             child: Row(
//     //                               mainAxisAlignment: MainAxisAlignment.center,
//     //                               crossAxisAlignment: CrossAxisAlignment.center,
//     //                               children: [
//     //                                 OpenSansText.custom(
//     //                                     text: kodeReferal,
//     //                                     fontSize: 20,
//     //                                     warna: MyColors.black(),
//     //                                     fontWeight: FontWeight.w700),
//     //                                 IconButton(
//     //                                     onPressed: () {
//     //                                       Clipboard.setData(
//     //                                               ClipboardData(
//     //                                                   text: kodeReferal))
//     //                                           .then((value) => ScaffoldMessenger
//     //                                                   .of(context)
//     //                                               .showSnackBar(SnackBar(
//     //                                                   content: OpenSansText.custom(
//     //                                                       text:
//     //                                                           'Kode Referal Sudah Disalin',
//     //                                                       fontSize: 16,
//     //                                                       warna: MyColors
//     //                                                           .primaryLighter(),
//     //                                                       fontWeight:
//     //                                                           FontWeight.w700))));
//     //                                     },
//     //                                     icon: Icon(Icons.copy_rounded))
//     //                               ],
//     //                             ),
//     //                           ),
//     //                         ),
//     //                         SizedBox(
//     //                           height: 31,
//     //                         ),
//     //                         // CostumeButton(
//     //                         //   backgroundColorbtn: MyColors.bluedark(),
//     //                         //   onTap: () {
//     //                         //     Navigator.of(context)
//     //                         //         .popUntil((_) => count++ >= 2);
//     //                         //   },
//     //                         //   backgroundTextbtn: MyColors.textWhite(),
//     //                         //   buttonText: 'Masukan kode',
//     //                         // )
//     //                         SizedBox(
//     //     width: MediaQuery.of(context).size.width,
//     //     height: 50,
//     //     child: ElevatedButton(
//     //       onPressed:  () {
//     //                             Navigator.of(context)
//     //                                 .popUntil((_) => count++ >= 2);
//     //                           },
//     //       child: OpenSansText.custom(
//     //           fontSize: 16,
//     //           fontWeight: FontWeight.w700,
//     //           warna: MyColors.textWhite(),
//     //           text: "Masukkan Kode",),
//     //       style: ElevatedButton.styleFrom(
//     //         shape: RoundedRectangleBorder(
//     //           borderRadius: BorderRadius.circular(6), // <-- Radius
//     //         ),
//     //         side: BorderSide(
//     //           width: 1,
//     //           color: MyColors.greenDarkButton(),
//     //         ),
//     //         backgroundColor: MyColors.greenDarkButton(),
//     //     ),
//     //   ),),
//     //                       ],
//     //                     ),
//     //                   )
//     //                 ],
//     //               )),
//     //             ),
//     //           );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trad/Utility/text_opensans.dart';
import 'package:trad/Utility/warna.dart';

class KodeReferalDialog extends StatelessWidget {
  const KodeReferalDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    const String kodeReferal = 'TRAD2024';
    int count = 0;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 24, left: 24, top: 4),
              child: PhysicalModel(
                color: Colors.white,
                elevation: 20,
                shadowColor: MyColors.primaryLighter(),
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 305,
                  child: SingleChildScrollView(
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(6),
                                topLeft: Radius.circular(6),
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                              color: MyColors.greenDarkButton(),
                              boxShadow: [
                                BoxShadow(
                                  color: MyColors.primary(),
                                  blurRadius: 2.0,
                                  spreadRadius: 0.0,
                                  offset: const Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Align(
                                alignment: Alignment.center,
                                child: OpenSansText.custom(
                                  text: 'Kode Referal',
                                  fontSize: 14,
                                  warna: MyColors.textWhite(),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 22, right: 18, top: 80),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              OpenSansText.custom(
                                text: 'Selamat Anda Berhasil Mendapatkan Kode referal! Salin dan gunakan kode referal dibawah ini untuk melanjutkan',
                                fontSize: 12,
                                warna: MyColors.black(),
                                fontWeight: FontWeight.w400,
                              ),
                              const SizedBox(height: 36),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  OpenSansText.custom(
                                    text: kodeReferal,
                                    fontSize: 20,
                                    warna: MyColors.black(),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: kodeReferal))
                                          .then((_) => ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: OpenSansText.custom(
                                                    text: 'Kode Referal Sudah Disalin',
                                                    fontSize: 16,
                                                    warna: MyColors.primaryLighter(),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ));
                                    },
                                    icon: const Icon(Icons.copy_rounded),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 31),
                              SizedBox(
                                width: mediaQueryWidth,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).popUntil((_) => count++ >= 2);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    side: BorderSide(
                                      width: 1,
                                      color: MyColors.greenDarkButton(),
                                    ),
                                    backgroundColor: MyColors.greenDarkButton(),
                                  ),
                                  child: OpenSansText.custom(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    warna: MyColors.textWhite(),
                                    text: "Masukkan Kode",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
