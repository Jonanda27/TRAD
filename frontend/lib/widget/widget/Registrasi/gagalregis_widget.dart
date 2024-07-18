import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trad/Utility/icon.dart';
import 'package:trad/Utility/text_opensans.dart';
import 'package:trad/Utility/warna.dart';
import 'package:trad/Widget/component/costume_button.dart';

class GagalRegisDialog extends StatefulWidget {
  const GagalRegisDialog({super.key});

  @override
  State<GagalRegisDialog> createState() => _GagalRegisDialogState();
}

class _GagalRegisDialogState extends State<GagalRegisDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late final Animation<AlignmentGeometry> _alignAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _alignAnimation = Tween<AlignmentGeometry>(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: AlertDialog(
          backgroundColor: Colors.black,
          elevation: 20,
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          content: SizedBox(
            height: 190,
            child: PhysicalModel(
              color: MyColors.textWhiteHover(),
              elevation: 20,
              shadowColor: MyColors.primaryLighter(),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                height: 190,
                child: SingleChildScrollView(
                    child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 44,
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
                                text: 'Verifikasi Gagal',
                                fontSize: 14,
                                warna: MyColors.textWhite(),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 14, top: 58),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MyIcon.iconError(size: 41),
                          Padding(padding: EdgeInsets.only(top: 12)),
                          OpenSansText.custom(
                              text:
                                  'Kode verifikasi tidak valid atau sudah kadaluarsa,',
                              fontSize: 12,
                              warna: MyColors.black(),
                              fontWeight: FontWeight.w400),
                          OpenSansText.custom(
                              text: 'silakan input kembali atau kirim ulang',
                              fontSize: 12,
                              warna: MyColors.black(),
                              fontWeight: FontWeight.w400),
                          OpenSansText.custom(
                              text: 'permintaan kode',
                              fontSize: 12,
                              warna: MyColors.black(),
                              fontWeight: FontWeight.w400),
                          Padding(padding: EdgeInsets.only(top: 29)),
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
