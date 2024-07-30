import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:im_stepper/stepper.dart';
import 'package:trad/Utility/icon.dart';
import 'package:trad/Utility/text_opensans.dart';
import 'package:trad/Utility/warna.dart';
import 'package:trad/Widget/component/costume_button.dart';
import 'package:trad/Widget/component/costume_teksfield.dart';
import 'package:trad/Widget/component/costume_teksfield2.dart';
import 'package:trad/Widget/component/costume_teksfield3.dart';
import 'package:trad/Widget/widget/Registrasi/berhasilregis_widget.dart';
import 'package:trad/Widget/widget/Registrasi/form3referaldaftar_widget.dart';
import 'package:trad/Widget/widget/Registrasi/form4infopassword_widget.dart';
import 'package:trad/Widget/widget/Registrasi/form5infopin_widget.dart';
import 'package:trad/Widget/widget/Registrasi/gagalregis_widget.dart';
import 'package:trad/login.dart';

class RegisterScreen extends StatefulWidget {
  final int? activeIndex;
  const RegisterScreen({super.key, this.activeIndex});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  int activeIndex = 0;
  int totalIndex = 6;
  final TextEditingController iDPenggunaController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nomorPonselController = TextEditingController();
  final TextEditingController alamatEmailController = TextEditingController();
  final TextEditingController kodeReferalController = TextEditingController();
  final TextEditingController pinBaruController = TextEditingController();
  final TextEditingController konfirmasiPinBaruController =
      TextEditingController();
  final TextEditingController passwordBaruController = TextEditingController();
  final TextEditingController konfirmasipasswordBaruController =
      TextEditingController();

  

  late Duration _controller;

  GlobalKey<FormState> _formmkey = GlobalKey<FormState>();
  bool _btnactive = false;
  bool _btnactiveform3 = false;
  bool isChecked = false;
  bool _obscureText = true;
  bool _obscureText2 = true;
  bool _obscureText3 = true;
  bool _obscureText4 = true;
  bool _timeOut = true;

  String? validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor Ponsel tidak boleh kosong';
    } else if (!RegExp(r'^[0-9]{10,13}$').hasMatch(value)) {
      return 'Nomor Ponsel harus angka dan terdiri dari 10-13 digit';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Alamat Email tidak boleh kosong';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
      return 'Alamat Email tidak valid';
    }
    return null;
  }

  @override
  void initState() {
    // TODO: implement initState

    void updateButtonState() {
      setState(() {
        _btnactive = iDPenggunaController.text.isNotEmpty &&
            namaController.text.isNotEmpty &&
            nomorPonselController.text.isNotEmpty &&
            alamatEmailController.text.isNotEmpty;
      });
    }

    iDPenggunaController.addListener(updateButtonState);
    namaController.addListener(updateButtonState);
    nomorPonselController.addListener(updateButtonState);
    alamatEmailController.addListener(updateButtonState);
    kodeReferalController.addListener(() {
      setState(() {
        _btnactiveform3 = kodeReferalController.text.isNotEmpty;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Tinggi full HP
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    //Lebar  full HP
    final mediaQueryWeight = MediaQuery.of(context).size.width;

    return WillPopScope(
        onWillPop: () async {
          if (activeIndex != 0) {
            activeIndex--;
            setState(() {});
            return false;
          }
          return true;
        },
        child: Scaffold(
            body: Stack(
          children: [
            Image.asset(
              'assets/img/background.png',
              fit: BoxFit.cover,
              height: mediaQueryHeight,
              width: mediaQueryWeight,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 50,
                right: 40,
                left: 40,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: DotStepper(
                  dotCount: totalIndex,
                  activeStep: activeIndex,
                  dotRadius: 10.0,
                  shape: Shape.pipe,
                  spacing: 10,
                  indicatorDecoration: IndicatorDecoration(
                      color: MyColors.greenLight(),
                      strokeColor: MyColors.greenLight()),
                ),
              ),
            ),
            bodyBuilder(activeIndex: activeIndex),
          ],
        )));
  }

  Widget bodyBuilder({required int activeIndex}) {
    switch (activeIndex) {
      case 0:
        return formPertama();
      case 1:
        return formKedua();
      case 2:
        return formketiga();
      case 3:
        return formkeempat();
      case 4:
        return formkelima();
      case 5:
        return formkeenam();
      default:
        return formPertama();
    }
  }

  Widget formPertama() {
    return Form(
      key: _formmkey,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/svg/Logo Icon.svg'),
                OpenSansText.custom(
                    text: "Daftar",
                    fontSize: 24,
                    warna: MyColors.textWhite(),
                    fontWeight: FontWeight.w700),
                OpenSansText.custom(
                    text: "Daftar Pengguna",
                    fontSize: 18,
                    warna: MyColors.textWhite(),
                    fontWeight: FontWeight.w400),
                const Padding(padding: EdgeInsets.only(top: 11)),
                OpenSansText.custom(
                    text: "ID Pengguna",
                    fontSize: 14,
                    warna: MyColors.textWhite(),
                    fontWeight: FontWeight.w600),
                CostumeTextFormFieldWithoutBorderPrefix2(
                  textformController: iDPenggunaController,
                  hintText: 'ID Pengguna',
                  fillColors: MyColors.textWhiteHover(),
                  iconSuffixColor: MyColors.textBlack(),
                  validator: (value) => validateField(value, 'ID Pengguna'),
                ),
                const Padding(padding: EdgeInsets.only(top: 11)),
                OpenSansText.custom(
                    text: "Nama",
                    fontSize: 14,
                    warna: MyColors.textWhite(),
                    fontWeight: FontWeight.w600),
                CostumeTextFormFieldWithoutBorderPrefix2(
                  textformController: namaController,
                  hintText: 'Masukan Nama',
                  fillColors: MyColors.textWhiteHover(),
                  iconSuffixColor: MyColors.textBlack(),
                  validator: (value) => validateField(value, 'Nama'),
                ),
                const Padding(padding: EdgeInsets.only(top: 11)),
                OpenSansText.custom(
                    text: "Nomor Ponsel",
                    fontSize: 14,
                    warna: MyColors.textWhite(),
                    fontWeight: FontWeight.w600),
                CostumeTextFormFieldWithoutBorderPrefix2(
                  textformController: nomorPonselController,
                  hintText: 'Masukan Nomor Ponsel',
                  fillColors: MyColors.textWhiteHover(),
                  iconSuffixColor: MyColors.textBlack(),
                  validator: validatePhoneNumber,
                ),
                const Padding(padding: EdgeInsets.only(top: 11)),
                OpenSansText.custom(
                    text: "Alamat Email",
                    fontSize: 14,
                    warna: MyColors.textWhite(),
                    fontWeight: FontWeight.w600),
                CostumeTextFormFieldWithoutBorderPrefix2(
                  textformController: alamatEmailController,
                  hintText: 'Masukan Alamat Email',
                  fillColors: MyColors.textWhiteHover(),
                  iconSuffixColor: MyColors.textBlack(),
                  validator: validateEmail,
                ),
                const Padding(padding: EdgeInsets.only(top: 21)),
                CostumeButton(
                  buttonText: "Lanjut",
                  backgroundColorbtn: MyColors.iconGrey(),
                  onTap: _btnactive
                      ? () {
                          if (_formmkey.currentState?.validate() ?? false) {
                            // next
                            setState(() {
                              activeIndex++;
                            });
                          }
                        }
                      : null,
                  backgroundTextbtn: MyColors.black(),
                ),
                const Padding(padding: EdgeInsets.only(top: 11)),
                CostumeButton(
                  buttonText: "Kembali",
                  backgroundColorbtn: MyColors.Transparent(),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HalamanAwal()),
                    );
                  },
                  backgroundTextbtn: MyColors.textWhite(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget formKedua() {
    Color getColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return MyColors.bluedark();
      }
      return Colors.white;
    }

    //Tinggi full HP
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    //Lebar  full HP
    final mediaQueryWeight = MediaQuery.of(context).size.width;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 72, right: 40, left: 40),
                child: SvgPicture.asset('assets/svg/Logo Icon.svg')),
            const Padding(padding: EdgeInsetsDirectional.only(top: 16)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: OpenSansText.custom(
                  text: "Aturan Dan Kondisi",
                  fontSize: 24,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w700),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 24, left: 24, top: 4),
              child: PhysicalModel(
                color: MyColors.textWhiteHover(),
                elevation: 20,
                shadowColor: MyColors.primaryLighter(),
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 405,
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
                                bottomRight: Radius.circular(8)),
                            color: MyColors.bluedark(),
                            boxShadow: [
                              BoxShadow(
                                color: MyColors.primary(),
                                blurRadius: 2.0,
                                spreadRadius: 0.0,
                                offset: const Offset(
                                    2.0, 2.0), // shadow direction: bottom right
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Align(
                              alignment: Alignment.center,
                              child: OpenSansText.custom(
                                  text: 'Aturan dan Kondisi Aplikasi TRAD',
                                  fontSize: 14,
                                  warna: MyColors.textWhite(),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 22, right: 18, top: 80),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OpenSansText.custom(
                                text:
                                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed quis nisl bibendum, pharetra lacus a, blandit neque. Etiam molestie justo id.',
                                fontSize: 12,
                                warna: MyColors.black(),
                                fontWeight: FontWeight.w400),
                            const SizedBox(
                              height: 10,
                            ),
                            OpenSansText.custom(
                                text:
                                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed quis nisl bibendum, pharetra lacus a, blandit neque. Etiam molestie justo id.',
                                fontSize: 12,
                                warna: MyColors.black(),
                                fontWeight: FontWeight.w400),
                            const SizedBox(
                              height: 14,
                            ),
                            Container(
                              height: 1,
                              color: MyColors.iconGrey(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  checkColor: MyColors.bluedark(),
                                  fillColor:
                                      WidgetStateProperty.resolveWith(getColor),
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isChecked = value!;
                                    });
                                  },
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        OpenSansText.custom(
                                            text: "Saya Sudah",
                                            fontSize: 10,
                                            warna: MyColors.black(),
                                            fontWeight: FontWeight.w400),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        OpenSansText.custom(
                                            text: "Membaca dan Menyetujui",
                                            fontSize: 10,
                                            warna: MyColors.black(),
                                            fontWeight: FontWeight.bold),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        OpenSansText.custom(
                                            text: "Untuk",
                                            fontSize: 10,
                                            warna: MyColors.black(),
                                            fontWeight: FontWeight.w400),
                                      ],
                                    ),
                                    OpenSansText.custom(
                                        text:
                                            "Mematuhi seluruh aturan dan kondisi",
                                        fontSize: 10,
                                        warna: MyColors.black(),
                                        fontWeight: FontWeight.w400),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 21,
                            ),
                            CostumeButton(
                              buttonText: "Lanjut",
                              backgroundColorbtn: MyColors.bluedark(),
                              onTap: isChecked
                                  ? () {
                                      {
                                        //next
                                        setState(() {
                                          activeIndex++;
                                        });
                                      }
                                    }
                                  : null,
                              backgroundTextbtn: MyColors.textWhite(),
                            ),
                            const Padding(padding: EdgeInsets.only(top: 11)),
                            CostumeButton(
                              buttonText: "Kembali",
                              backgroundColorbtn: MyColors.textWhite(),
                              onTap: () {
                                setState(() {
                                  activeIndex--;
                                });
                              },
                              backgroundTextbtn: MyColors.bluedark(),
                            )
                          ],
                        ),
                      )
                    ],
                  )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget formketiga() {
    return Form(
      key: _formmkey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(right: 40, left: 40, top: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset('assets/svg/Logo Icon.svg'),
              const Padding(padding: EdgeInsetsDirectional.only(top: 16)),
              OpenSansText.custom(
                  text: "Daftar",
                  fontSize: 24,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w700),
              const Padding(padding: EdgeInsetsDirectional.only(top: 6)),
              OpenSansText.custom(
                  text: "Kode Referal",
                  fontSize: 18,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w400),
              const Padding(padding: EdgeInsetsDirectional.only(top: 12)),
              CostumeTextFormField(
                icon: MyIcon.iconLink(size: 20),
                textformController: kodeReferalController,
                hintText: 'Kode Referal',
                fillColors: MyColors.textWhiteHover(),
                iconSuffixColor: MyColors.textBlack(),
              ),
              Row(
                children: [
                  OpenSansText.custom(
                      text: 'Belum Punya Kode Referal ?',
                      fontSize: 12,
                      warna: MyColors.textWhite(),
                      fontWeight: FontWeight.w400),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FormKetiga(),
                          ));
                    },
                    child: OpenSansText.custom(
                        text: 'Klik disini',
                        fontSize: 12,
                        warna: MyColors.primaryLighter(),
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsetsDirectional.only(top: 268)),
              CostumeButton(
                buttonText: "Lanjut",
                backgroundColorbtn: MyColors.iconGrey(),
                onTap: _btnactiveform3
                    ? () {
                        {
                          if (_formmkey.currentState?.validate() ?? false) {
                            //next
                            setState(() {
                              activeIndex++;
                            });
                          }
                        }
                      }
                    : null,
                backgroundTextbtn: MyColors.textBlack(),
              ),
              const Padding(padding: EdgeInsets.only(top: 11)),
              CostumeButton(
                buttonText: "Kembali",
                backgroundColorbtn: MyColors.Transparent(),
                onTap: () {
                  setState(() {
                    activeIndex--;
                  });
                },
                backgroundTextbtn: MyColors.textWhite(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget formkeempat() {
    return Form(
      key: _formmkey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(right: 40, left: 40, top: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset('assets/svg/Logo Icon.svg'),
              const Padding(padding: EdgeInsetsDirectional.only(top: 16)),
              OpenSansText.custom(
                  text: "Daftar",
                  fontSize: 24,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w700),
              const Padding(padding: EdgeInsetsDirectional.only(top: 6)),
              Row(
                children: [
                  OpenSansText.custom(
                      text: "Buat Kata Sandi",
                      fontSize: 18,
                      warna: MyColors.textWhite(),
                      fontWeight: FontWeight.w400),
                  IconButton(
                      onPressed: () => showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                const AlertMassagePassword(),
                          ),
                      icon: Icon(
                        Icons.info_rounded,
                        color: MyColors.iconGrey(),
                      ))
                ],
              ),
              const Padding(padding: EdgeInsetsDirectional.only(top: 12)),
              OpenSansText.custom(
                  text: "Sandi Baru",
                  fontSize: 14,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w400),
              CostumeTextFormFieldWithoutBorderPrefix(
                obscureText: _obscureText,
                icon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: MyColors.iconGrey(),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                textformController: passwordBaruController,
                hintText: 'Sandi Baru',
                fillColors: MyColors.textWhiteHover(),
                iconSuffixColor: MyColors.textBlack(),
              ),
              const Padding(padding: EdgeInsetsDirectional.only(top: 6)),
              OpenSansText.custom(
                  text: "Konfirmasi Sandi Baru",
                  fontSize: 14,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w400),
              CostumeTextFormFieldWithoutBorderPrefix(
                obscureText: _obscureText2,
                icon: IconButton(
                  icon: Icon(
                    _obscureText2 ? Icons.visibility : Icons.visibility_off,
                    color: MyColors.iconGrey(),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText2 = !_obscureText2;
                    });
                  },
                ),
                textformController: konfirmasipasswordBaruController,
                hintText: 'Konfirmasi Sandi Baru',
                fillColors: MyColors.textWhiteHover(),
                iconSuffixColor: MyColors.textBlack(),
              ),
              const Padding(padding: EdgeInsetsDirectional.only(top: 167)),
              CostumeButton(
                buttonText: "Lanjut",
                backgroundColorbtn: MyColors.iconGrey(),
                onTap: _btnactiveform3
                    ? () {
                        {
                          if (_formmkey.currentState?.validate() ?? false) {
                            //next
                            setState(() {
                              activeIndex++;
                            });
                          }
                        }
                      }
                    : null,
                backgroundTextbtn: MyColors.textBlack(),
              ),
              const Padding(padding: EdgeInsets.only(top: 11)),
              CostumeButton(
                buttonText: "Kembali",
                backgroundColorbtn: MyColors.Transparent(),
                onTap: () {
                  setState(() {
                    activeIndex--;
                  });
                },
                backgroundTextbtn: MyColors.textWhite(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget formkelima() {
    return Form(
      key: _formmkey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(right: 40, left: 40, top: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset('assets/svg/Logo Icon.svg'),
              const Padding(padding: EdgeInsetsDirectional.only(top: 16)),
              OpenSansText.custom(
                  text: "Daftar",
                  fontSize: 24,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w700),
              const Padding(padding: EdgeInsetsDirectional.only(top: 6)),
              Row(
                children: [
                  OpenSansText.custom(
                      text: "Buat Pin",
                      fontSize: 18,
                      warna: MyColors.textWhite(),
                      fontWeight: FontWeight.w400),
                  IconButton(
                      onPressed: () => showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                const AlertMassagePIN(),
                          ),
                      icon: Icon(
                        Icons.info_rounded,
                        color: MyColors.iconGrey(),
                      ))
                ],
              ),
              const Padding(padding: EdgeInsetsDirectional.only(top: 12)),
              OpenSansText.custom(
                  text: "PIN",
                  fontSize: 14,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w400),
              CostumeTextFormFieldWithoutBorderPrefix(
                obscureText: _obscureText3,
                icon: IconButton(
                  icon: Icon(
                    _obscureText3 ? Icons.visibility : Icons.visibility_off,
                    color: MyColors.iconGrey(),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText3 = !_obscureText3;
                    });
                  },
                ),
                textformController: pinBaruController,
                hintText: 'PIN',
                fillColors: MyColors.textWhiteHover(),
                iconSuffixColor: MyColors.textBlack(),
              ),
              const Padding(padding: EdgeInsetsDirectional.only(top: 6)),
              OpenSansText.custom(
                  text: "Konfirmasi PIN",
                  fontSize: 14,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w400),
              CostumeTextFormFieldWithoutBorderPrefix(
                obscureText: _obscureText4,
                icon: IconButton(
                  icon: Icon(
                    _obscureText4 ? Icons.visibility : Icons.visibility_off,
                    color: MyColors.iconGrey(),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText4 = !_obscureText4;
                    });
                  },
                ),
                textformController: konfirmasiPinBaruController,
                hintText: 'Konfirmasi Kode PIN',
                fillColors: MyColors.textWhiteHover(),
                iconSuffixColor: MyColors.textBlack(),
              ),
              const Padding(padding: EdgeInsetsDirectional.only(top: 167)),
              CostumeButton(
                buttonText: "Lanjut",
                backgroundColorbtn: MyColors.iconGrey(),
                onTap: _btnactiveform3
                    ? () {
                        {
                          if (_formmkey.currentState?.validate() ?? false) {
                            //next
                            setState(() {
                              activeIndex++;
                            });
                          }
                        }
                      }
                    : null,
                backgroundTextbtn: MyColors.textBlack(),
              ),
              const Padding(padding: EdgeInsets.only(top: 11)),
              CostumeButton(
                buttonText: "Kembali",
                backgroundColorbtn: MyColors.Transparent(),
                onTap: () {
                  setState(() {
                    activeIndex--;
                  });
                },
                backgroundTextbtn: MyColors.textWhite(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget formkeenam() {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.only(right: 40, left: 40, top: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset('assets/svg/Logo Icon.svg'),
              const Padding(padding: EdgeInsetsDirectional.only(top: 16)),
              OpenSansText.custom(
                  text: "Daftar",
                  fontSize: 24,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w700),
              const Padding(padding: EdgeInsetsDirectional.only(top: 6)),
              OpenSansText.custom(
                  text: "Verifikasi Pendaftaran",
                  fontSize: 18,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w400),
              const Padding(padding: EdgeInsetsDirectional.only(top: 25)),
              OpenSansText.custom(
                  text:
                      'Masukan kode verifikasi yang telah dikirim ke nomor handphone ${nomorPonselController.text} melalui WhatsApp atau SMS',
                  fontSize: 14,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w400),
              const Padding(padding: EdgeInsetsDirectional.only(top: 45)),
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: OtpTextField(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textStyle: TextStyle(color: MyColors.textWhite()),

                    fieldWidth: 30,
                    numberOfFields: 6,
                    borderColor: MyColors.textWhite(),
                    focusedBorderColor: MyColors.textWhite(),
                    showFieldAsBox: false,
                    borderWidth: 0.5,
                    //runs when a code is typed in
                    onCodeChanged: (String code) {
                      //handle validation or checks here if necessary
                    },
                    //runs when every textfield is filled
                    onSubmit: (String verificationCode) {},
                  ),
                ),
              ),
              const Padding(padding: EdgeInsetsDirectional.only(top: 40)),
              Center(
                child: TextButton(
                    onPressed: _timeOut
                        ? () {
                            Timer(Duration.zero, () {
                              setState(() {
                                _timeOut = true;
                              });
                            });
                          }
                        : null,
                    child: OpenSansText.custom(
                        text: 'Kirim Ulang Kode',
                        fontSize: 14,
                        warna: MyColors.bluedark(),
                        fontWeight: FontWeight.w600)),
              ),
              Center(
                child: TweenAnimationBuilder<Duration>(
                    duration: const Duration(minutes: 3),
                    tween: Tween(
                        begin: const Duration(minutes: 3), end: Duration.zero),
                    onEnd: () {},
                    builder:
                        (BuildContext context, Duration value, Widget? child) {
                      final minutes = value.inMinutes;
                      final seconds = value.inSeconds % 60;
                      return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: OpenSansText.custom(
                              text: "$minutes:$seconds",
                              fontSize: 20,
                              warna: MyColors.textWhite(),
                              fontWeight: FontWeight.w400));
                    }),
              ),
              const Padding(padding: EdgeInsetsDirectional.only(top: 68)),
              CostumeButton(
                buttonText: "Daftar",
                backgroundColorbtn: MyColors.iconGrey(),
                onTap:
                    // () => showDialog(
                    //   barrierColor: Colors.transparent,
                    //   context: context,
                    //   builder: (BuildContext context) => GagalRegisDialog(),
                    // ),

                    _btnactiveform3
                        ? () {
                            {
                              // next
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) {
                                    return const SuccessRegistrasi();
                                  },
                                ),
                              );
                            }
                          }
                        : null,
                backgroundTextbtn: MyColors.textBlack(),
              ),
              const Padding(padding: EdgeInsets.only(top: 11)),
              CostumeButton(
                buttonText: "Kembali",
                backgroundColorbtn: MyColors.Transparent(),
                onTap: () {
                  setState(() {
                    activeIndex--;
                  });
                },
                backgroundTextbtn: MyColors.textWhite(),
              ),
            ],
          )),
    );
  }
}
