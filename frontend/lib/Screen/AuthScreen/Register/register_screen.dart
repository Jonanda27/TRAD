import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:im_stepper/stepper.dart';
import 'package:trad/Model/RestAPI/service_auth.dart';
import 'package:trad/Model/RestAPI/service_referralcode.dart';
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
// import 'package:trad/Widget/widget/Registrasi/gagalregis_widget.dart';
import 'package:trad/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: RegisterScreen(),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  final int? activeIndex;
  const RegisterScreen({super.key, this.activeIndex});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  int activeIndex = 0;
  int totalIndex = 7;
  final TextEditingController iDPenggunaController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nomorPonselController = TextEditingController();
  final TextEditingController alamatEmailController = TextEditingController();
  final TextEditingController alamatRumahController = TextEditingController();
  final TextEditingController kodeReferalController = TextEditingController();
  final TextEditingController pinBaruController = TextEditingController();
  final TextEditingController konfirmasiPinBaruController = TextEditingController();
  final TextEditingController passwordBaruController = TextEditingController();
  final TextEditingController konfirmasipasswordBaruController =
      TextEditingController();
      String? accountType;
String otpCode = '';
  

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
    bool isCheckingReferralCode = false;
  String? referralValidationMessage;
  
  // Declare the state variables for errors
  bool pinError = false;
  bool confirmPinError = false;


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

  String? validateRumah(String? value) {
    if (value == null || value.isEmpty) {
      return '$value tidak boleh kosong';
    }
    return null;
  }

  

  Future<void> registerPenjual() async {
  try {
    await ApiService().registerPenjual(
      userID: iDPenggunaController.text,
      name: namaController.text,
      phone: nomorPonselController.text,
      email: alamatEmailController.text,
      alamat: alamatRumahController.text,
      noReferal: kodeReferalController.text,
      password: passwordBaruController.text,
      pin: pinBaruController.text,
    );
    print('Registration as Penjual completed successfully');
  } catch (e) {
    print('Registration failed: $e');
  }
}

  Future<void> registerPembeli() async {
  try {
    await ApiService().registerPembeli(
      userID: iDPenggunaController.text,
      name: namaController.text,
      phone: nomorPonselController.text,
      email: alamatEmailController.text,
      alamat: alamatRumahController.text,
      noReferal: kodeReferalController.text,
      password: passwordBaruController.text,
      pin: pinBaruController.text,
    );
    print('Registration as Pembeli completed successfully');
  } catch (e) {
    print('Registration failed: $e');
  }
}


Future<void> referal() async {
  try {
    var response = await ApiService().processReferral(
      userID: iDPenggunaController.text, 
      otp: otpCode
    );
    
    // You can check or use the response body here if needed
    print('Response from referal: $response');
  } catch (e) {
    print('Error: $e');
    throw e; // Re-throw the error to handle it in the UI
  }
}

  @override
  void initState() {
    // TODO: implement initState

    void updateButtonState() {
      setState(() {
        _btnactive = iDPenggunaController.text.isNotEmpty &&
            namaController.text.isNotEmpty &&
            nomorPonselController.text.isNotEmpty &&
            alamatRumahController.text.isNotEmpty &&
            alamatEmailController.text.isNotEmpty;
      });
    }

    iDPenggunaController.addListener(updateButtonState);
    namaController.addListener(updateButtonState);
    nomorPonselController.addListener(updateButtonState);
    alamatEmailController.addListener(updateButtonState);
    alamatRumahController.addListener(updateButtonState);
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
        return _buildAccountTypeScreen();
      case 1:
        return formPertama();
      case 2:
        return formKedua();
      case 3:
        return formketiga(context);
      case 4:
        return formkeempat();
      case 5:
        return formkelima();
      case 6:
        return formkeenam();
      default:
        return _buildAccountTypeScreen();
    }
  }

Widget _buildAccountTypeScreen() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Text(
            'Pilih tipe akun',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        AccountTypeButton(
          icon: Icons.store,
          title: 'Merchant',
          subtitle: 'Masuk disini untuk mengelola toko',
          onTap: () {
            setState(() {
              accountType = 'Penjual';
              activeIndex++;
            });
          },
        ),
        SizedBox(height: 20),
        AccountTypeButton(
          icon: Icons.person,
          title: 'Customer',
          subtitle: 'Masuk disini untuk belanja',
          onTap: () {
            setState(() {
              accountType = 'Pembeli';
              activeIndex++;
            });
          },
        ),
      ],
    ),
  );
}

Widget formPertama() {
  return Form(
    key: _formmkey,
    autovalidateMode: AutovalidateMode.onUserInteraction,  // Step 1: Trigger validation after user interaction
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
                hintText: 'Contoh: michael123',
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
                hintText: 'Contoh: Michael',
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
              Row(
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                        color: MyColors.iconGrey(),
                        borderRadius: BorderRadius.circular(4)),
                    alignment: Alignment.center,
                    child: OpenSansText.custom(
                      text: '+62',
                      fontSize: 14,
                      warna: MyColors.black(),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Expanded(
                    child: CostumeTextFormFieldWithoutBorderPrefix2(
                      textformController: nomorPonselController,
                      hintText: 'Contoh: 0812345678',
                      fillColors: MyColors.textWhiteHover(),
                      iconSuffixColor: MyColors.textBlack(),
                      validator: (value) => validatePhoneNumber(value),
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 11)),
              OpenSansText.custom(
                  text: "Alamat Email",
                  fontSize: 14,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w600),
              CostumeTextFormFieldWithoutBorderPrefix2(
                textformController: alamatEmailController,
                hintText: 'Contoh: michael@gmail.com',
                fillColors: MyColors.textWhiteHover(),
                iconSuffixColor: MyColors.textBlack(),
                validator: (value) => validateEmail(value),
              ),
              const Padding(padding: EdgeInsets.only(top: 11)),
              OpenSansText.custom(
                  text: "Alamat Rumah",
                  fontSize: 14,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w600),
              CostumeTextFormFieldWithoutBorderPrefix2(
                textformController: alamatRumahController,
                hintText: 'Contoh: Jalan Buyun, Komplek Pasadena',
                fillColors: MyColors.textWhiteHover(),
                iconSuffixColor: MyColors.textBlack(),
                validator: validateRumah,
              ),
              const Padding(padding: EdgeInsets.only(top: 21)),
              CostumeButton(
                buttonText: "Lanjut",
                backgroundColorbtn: MyColors.iconGrey(),
                onTap: _btnactive
                    ? () {
                        if (_formmkey.currentState?.validate() ?? false) {
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


final ReferralService _referralService = ReferralService();
bool _isReferralValid = false;
bool _isValidating = false;
Timer? _debounceTimer;

Future<void> validateReferralCode(String value, BuildContext context) async {
  if (_isValidating) return; // Prevent multiple simultaneous validations
  
  setState(() {
    _isValidating = true;
  });

  try {
    await _referralService.checkReferralCode(value);
    setState(() {
      _isReferralValid = true;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kode Referal valid'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    setState(() {
      _isReferralValid = false;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    if (e.toString().contains('429')) {
      // Handle rate limiting error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terlalu banyak permintaan. Mohon tunggu sebentar.'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kode Referal tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    setState(() {
      _isValidating = false;
    });
  }
}


Widget formketiga(BuildContext context) {
  // Add a listener to the controller with debounce
  void debouncedValidation(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      if (value.isNotEmpty) {
        validateReferralCode(value, context);
      } else {
        setState(() {
          _isReferralValid = false;
        });
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    });
  }

  kodeReferalController.addListener(() {
    debouncedValidation(kodeReferalController.text);
  });
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
              fontWeight: FontWeight.w700,
            ),
            const Padding(padding: EdgeInsetsDirectional.only(top: 6)),
            OpenSansText.custom(
              text: "Kode Referal",
              fontSize: 18,
              warna: MyColors.textWhite(),
              fontWeight: FontWeight.w400,
            ),
            const Padding(padding: EdgeInsetsDirectional.only(top: 12)),
            CostumeTextFormField(
              icon: MyIcon.iconLink(size: 20),
              textformController: kodeReferalController,
              hintText: 'Contoh: TRAD01',
              fillColors: MyColors.textWhiteHover(),
              iconSuffixColor: MyColors.textBlack(),
            ),
            if (_isReferralValid)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Kode Referal valid',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            Row(
              children: [
                OpenSansText.custom(
                  text: 'Belum Punya Kode Referal ?',
                  fontSize: 12,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w400,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FormKetiga(),
                      ),
                    );
                  },
                  child: OpenSansText.custom(
                    text: 'Klik disini',
                    fontSize: 12,
                    warna: MyColors.primaryLighter(),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsetsDirectional.only(top: 268)),
            CostumeButton(
              buttonText: "Lanjut",
              backgroundColorbtn: MyColors.iconGrey(),
              onTap: (_btnactiveform3 && _isReferralValid && !_isValidating)
                  ? () {
                      if (_formmkey.currentState?.validate() ?? false) {
                        setState(() {
                          activeIndex++;
                        });
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
              hintText: 'Contoh: P@ssw0rd',
              fillColors: MyColors.textWhiteHover(),
              iconSuffixColor: MyColors.textBlack(),
              errorText: _isNewPasswordValid
                  ? null
                  : "Sandi harus memiliki minimal satu huruf kapital dan satu angka atau simbol.",
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
              hintText: 'Masukkan Kembali Sandi Baru',
              fillColors: MyColors.textWhiteHover(),
              iconSuffixColor: MyColors.textBlack(),
              errorText: _isConfirmationPasswordValid
                  ? null
                  : "Konfirmasi Sandi Baru tidak cocok.",
            ),
            const Padding(padding: EdgeInsetsDirectional.only(top: 167)),
            CostumeButton(
              buttonText: "Lanjut",
              backgroundColorbtn: MyColors.iconGrey(),
              onTap: _btnactiveform3
                  ? () {
                      String newPassword = passwordBaruController.text;
                      String confirmPassword = konfirmasipasswordBaruController.text;

                      setState(() {
                        _isNewPasswordValid = isPasswordValid(newPassword);
                        _isConfirmationPasswordValid = _isNewPasswordValid && (newPassword == confirmPassword);

                        if (_isNewPasswordValid && _isConfirmationPasswordValid) {
                          activeIndex++;
                        }
                      });
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


bool _isNewPasswordValid = true;
bool _isConfirmationPasswordValid = true;

bool isPasswordValid(String password) {
  final hasUppercase = password.contains(RegExp(r'[A-Z]'));
  final hasDigits = password.contains(RegExp(r'[0-9]'));
  final hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  return hasUppercase && (hasDigits || hasSpecialCharacters);
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
                hintText: 'Contoh: 123456',
                fillColors: MyColors.textWhiteHover(),
                iconSuffixColor: MyColors.textBlack(),
                errorText: pinError ? 'Invalid PIN format' : null,
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
                hintText: 'Masukkan Kembali Kode PIN',
                fillColors: MyColors.textWhiteHover(),
                iconSuffixColor: MyColors.textBlack(),
                errorText: confirmPinError ? 'PINs do not match' : null,
              ),
              const Padding(padding: EdgeInsetsDirectional.only(top: 167)),
              CostumeButton(
                buttonText: "Lanjut",
            backgroundColorbtn: MyColors.iconGrey(),
            onTap: _btnactiveform3
                ? () async {
                    setState(() {
                      _btnactiveform3 = false;
                      pinError = false;
                      confirmPinError = false;
                    });

                    bool isValid = _validatePIN();
                    if (isValid) {
                      try {
                        if (accountType == 'Penjual') {
                          await registerPenjual();
                        } else {
                          await registerPembeli();
                        }
                        setState(() {
                          activeIndex++;
                        });
                      } catch (error) {
                        print("Error during registration: $error");
                      }
                    } else {
                      print("PIN validation failed");
                    }

                    setState(() {
                      _btnactiveform3 = true;
                    });
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

  bool _validatePIN() {
    final pin = pinBaruController.text;
    final confirmPin = konfirmasiPinBaruController.text;

    bool pinError = false;
    bool confirmPinError = false;

    if (pin.isEmpty || pin.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(pin)) {
      pinError = true;
    }
    if (pin != confirmPin) {
      confirmPinError = true;
    }

    setState(() {
      this.pinError = pinError;
      this.confirmPinError = confirmPinError;
    });

    return !pinError && !confirmPinError;
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
                onCodeChanged: (String code) {
                  otpCode = code;
                  print('Current code: $otpCode');
                },
                onSubmit: (String verificationCode) {
                  otpCode = verificationCode;
                  print('Complete OTP code: $otpCode');
                },
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
                  fontWeight: FontWeight.w600),
            ),
          ),
          Center(
            child: TweenAnimationBuilder<Duration>(
              duration: const Duration(minutes: 3),
              tween: Tween(begin: const Duration(minutes: 3), end: Duration.zero),
              onEnd: () {},
              builder: (BuildContext context, Duration value, Widget? child) {
                final minutes = value.inMinutes;
                final seconds = value.inSeconds % 60;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: OpenSansText.custom(
                      text: "$minutes:$seconds",
                      fontSize: 20,
                      warna: MyColors.textWhite(),
                      fontWeight: FontWeight.w400),
                );
              },
            ),
          ),
          const Padding(padding: EdgeInsetsDirectional.only(top: 68)),
          CostumeButton(
  buttonText: "Daftar",
  backgroundColorbtn: MyColors.iconGrey(),
  onTap: _btnactiveform3
      ? () async {
          try {
            await referal(); // Call your referral method
            // If no exception is thrown, navigate to SuccessRegistrasi
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return const SuccessRegistrasi();
                },
              ),
            );
          } catch (e) {
            if (e.toString().contains('Failed to activate referral')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('OTP verification failed. Please try again.'),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Terjadi kesalahan, silakan coba lagi.'),
                  backgroundColor: Colors.red,
                ),
              );
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
  );
}

  
  checkReferralCode(String text) {}
}

class AccountTypeButton extends StatelessWidget {
    final IconData icon;
    final String title;
    final String subtitle;
    final VoidCallback onTap;

    const AccountTypeButton({
      Key? key,
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: Color(0xFF00617F),
              ),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00617F),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
