import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:im_stepper/stepper.dart';
import 'package:trad/Screen/AuthScreen/Register/register_screen.dart';
import 'package:trad/Utility/text_opensans.dart';
import 'package:trad/Utility/warna.dart';
import 'package:trad/Widget/component/costume_checkbox.dart';
import 'package:trad/Widget/component/costume_button.dart';
import 'package:trad/Widget/widget/Registrasi/form3dialogshow_widget.dart';

class FormKetiga extends StatefulWidget {
  const FormKetiga({super.key});

  @override
  State<FormKetiga> createState() => _FormKetigaState();
}

class _FormKetigaState extends State<FormKetiga> {
  bool isChecked = false;
  bool isChecked2 = false;
  bool isChecked3 = false;
  bool isChecked4 = false;
  bool isChecked5 = false;
  bool isChecked6 = false;
  bool isChecked7 = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return MyColors.success();
      }
      return MyColors.success();
    }

    //Tinggi full HP
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    //Lebar  full HP
    final mediaQueryWeight = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Stack(
      children: [
        Image.asset(
          'assets/img/background.png',
          fit: BoxFit.cover,
          height: mediaQueryHeight,
          width: mediaQueryWeight,
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 50,
            right: 40,
            left: 40,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: DotStepper(
              dotCount: 6,
              activeStep: 2,
              dotRadius: 10.0,
              shape: Shape.pipe,
              spacing: 10,
              indicatorDecoration: IndicatorDecoration(
                  color: MyColors.greenLight(),
                  strokeColor: MyColors.greenLight()),
            ),
          ),
        ),
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 40, right: 40, top: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset('assets/svg/Logo Icon.svg'),
                Padding(padding: EdgeInsetsDirectional.only(top: 16)),
                OpenSansText.custom(
                    text: "Survey Pengguna",
                    fontSize: 24,
                    warna: MyColors.textWhite(),
                    fontWeight: FontWeight.w700),
                Padding(padding: EdgeInsetsDirectional.only(top: 6)),
                OpenSansText.custom(
                    text: "Bagaimana Anda Mengetahui aplikasi TRAD ?",
                    fontSize: 18,
                    warna: MyColors.textWhite(),
                    fontWeight: FontWeight.w400),
                Row(
                  children: [
                    CostumeCheckBox(
                      activedColor: MyColors.success(),
                      checkedColor: MyColors.black(),
                      isChecked: isChecked,
                      unSelectedColor: MyColors.Transparent(),
                      onTap: (bool? value) {
                        setState(() {
                          isChecked = value!;
                        });
                      },
                    ),
                    OpenSansText.custom(
                        text: 'Saudara/Teman/Kerabat',
                        fontSize: 14,
                        warna: MyColors.textWhite(),
                        fontWeight: FontWeight.w400)
                  ],
                ),
                Row(
                  children: [
                    CostumeCheckBox(
                      activedColor: MyColors.success(),
                      checkedColor: MyColors.black(),
                      isChecked: isChecked2,
                      unSelectedColor: MyColors.Transparent(),
                      onTap: (bool? value) {
                        setState(() {
                          isChecked2 = value!;
                        });
                      },
                    ),
                    OpenSansText.custom(
                        text: 'Iklan di Instagram',
                        fontSize: 14,
                        warna: MyColors.textWhite(),
                        fontWeight: FontWeight.w400)
                  ],
                ),
                Row(
                  children: [
                    CostumeCheckBox(
                      activedColor: MyColors.success(),
                      checkedColor: MyColors.black(),
                      isChecked: isChecked3,
                      unSelectedColor: MyColors.Transparent(),
                      onTap: (bool? value) {
                        setState(() {
                          isChecked3 = value!;
                        });
                      },
                    ),
                    OpenSansText.custom(
                        text: 'Iklan Facebook',
                        fontSize: 14,
                        warna: MyColors.textWhite(),
                        fontWeight: FontWeight.w400)
                  ],
                ),
                Row(
                  children: [
                    CostumeCheckBox(
                      activedColor: MyColors.success(),
                      checkedColor: MyColors.black(),
                      isChecked: isChecked4,
                      unSelectedColor: MyColors.Transparent(),
                      onTap: (bool? value) {
                        setState(() {
                          isChecked4 = value!;
                        });
                      },
                    ),
                    OpenSansText.custom(
                        text: 'Iklan Google',
                        fontSize: 14,
                        warna: MyColors.textWhite(),
                        fontWeight: FontWeight.w400)
                  ],
                ),
                Row(
                  children: [
                    CostumeCheckBox(
                      activedColor: MyColors.success(),
                      checkedColor: MyColors.black(),
                      isChecked: isChecked5,
                      unSelectedColor: MyColors.Transparent(),
                      onTap: (bool? value) {
                        setState(() {
                          isChecked5 = value!;
                        });
                      },
                    ),
                    OpenSansText.custom(
                        text: 'Iklan Youtube',
                        fontSize: 14,
                        warna: MyColors.textWhite(),
                        fontWeight: FontWeight.w400)
                  ],
                ),
                Row(
                  children: [
                    CostumeCheckBox(
                      activedColor: MyColors.success(),
                      checkedColor: MyColors.black(),
                      isChecked: isChecked6,
                      unSelectedColor: MyColors.Transparent(),
                      onTap: (bool? value) {
                        setState(() {
                          isChecked6 = value!;
                        });
                      },
                    ),
                    OpenSansText.custom(
                        text: 'Iklan Media Sosial Lainnya',
                        fontSize: 14,
                        warna: MyColors.textWhite(),
                        fontWeight: FontWeight.w400)
                  ],
                ),
                Row(
                  children: [
                    CostumeCheckBox(
                      activedColor: MyColors.success(),
                      checkedColor: MyColors.black(),
                      isChecked: isChecked7,
                      unSelectedColor: MyColors.Transparent(),
                      onTap: (bool? value) {
                        setState(() {
                          isChecked7 = value!;
                        });
                      },
                    ),
                    OpenSansText.custom(
                        text: 'Komunitas Sekitar Saya',
                        fontSize: 14,
                        warna: MyColors.textWhite(),
                        fontWeight: FontWeight.w400)
                  ],
                ),
                SizedBox(
                  height: 56,
                ),
                CostumeButton(
                  buttonText: "Lanjut",
                  backgroundColorbtn: MyColors.iconGrey(),
                  onTap: () => showDialog(
                    context: context,
                    builder: (BuildContext context) => KodeReferalDialog(),
                  ),
                  backgroundTextbtn: MyColors.textBlack(),
                ),
                Padding(padding: EdgeInsets.only(top: 11)),
                CostumeButton(
                  buttonText: "Kembali",
                  backgroundColorbtn: MyColors.Transparent(),
                  onTap: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                  backgroundTextbtn: MyColors.textWhite(),
                )
              ],
            ),
          ),
        )
      ],
    ));
  }
}
