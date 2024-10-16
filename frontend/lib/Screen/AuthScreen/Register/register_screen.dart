import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:im_stepper/stepper.dart';
import 'package:trad/Model/RestAPI/service_api.dart';
import 'package:trad/Model/RestAPI/service_auth.dart';
import 'package:trad/Model/RestAPI/service_referralcode.dart';
import 'package:trad/Screen/AuthScreen/Login/login.dart';
import 'package:trad/Utility/icon.dart';
import 'package:trad/Utility/text_opensans.dart';
import 'package:trad/Utility/warna.dart';
import 'package:trad/Widget/component/costume_button.dart';
import 'package:trad/Widget/component/costume_teksfield.dart';
import 'package:trad/Widget/component/costume_teksfield2.dart';
import 'package:trad/Widget/component/costume_teksfield3.dart';
import 'package:trad/Widget/component/costume_textfield_verify_password.dart';
import 'package:trad/Widget/component/costume_textfield_verify_id.dart';
import 'package:trad/Widget/widget/Registrasi/berhasilregis_widget.dart';
import 'package:trad/Widget/widget/Registrasi/form3referaldaftar_widget.dart';
import 'package:trad/Widget/widget/Registrasi/form4infopassword_widget.dart';
import 'package:trad/Widget/widget/Registrasi/form5infopin_widget.dart';
import 'package:trad/widget/component/costume_buttonLanjut.dart';
import 'package:trad/widget/component/costume_textField_referral.dart';
import 'package:trad/widget/component/costume_textfield_temp.dart';
import 'package:trad/widget/component/costume_textfield_verify_password_lagi.dart';

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
  final TextEditingController konfirmasiPinBaruController =
      TextEditingController();
  final TextEditingController passwordBaruController = TextEditingController();
  final TextEditingController konfirmasipasswordBaruController =
      TextEditingController();
  String? accountType;
  String otpCode = '';
  String _lastCheckedUserId = '';
  final FocusNode _idPenggunaFocusNode = FocusNode();
  final FocusNode _namaFocusNode = FocusNode();
  final FocusNode _nomorPonselFocusNode = FocusNode();
  final FocusNode _alamatEmailFocusNode = FocusNode();
  final FocusNode _alamatRumahFocusNode = FocusNode();

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
  String? idPenggunaError;
  bool _isValidating = false;
  Timer? _debounceTimer;
  bool _passwordMinLength = false;
  bool _passwordUppercase = false;
  bool _passwordNumber = false;
  bool _userIdAvailability = false;
  bool _userIdFieldTouched = false;
  bool _userIdMinLength = false;
  bool _canResendCode = false;
  bool _userIdThreeLetters = false;
  bool _userIdAlphanumeric = false;
  bool _isNamaValid = false;
  bool _namaMinLength = false;
  bool _namaNotEmpty = false;
  bool _namaFieldTouched = false;
  bool _isTeleponValid = false;
  bool _teleponLength = false;
  bool _teleponNotEmpty = false;
  bool _teleponFormat = false;
  bool _teleponStarts = false;
  bool _teleponFieldTouched = false;
  bool _isEmailValid = false;
  bool _emailNotEmpty = false;
  bool _emailFormat = false;
  bool _emailFieldTouched = false;
  bool _isAlamatValid = false;
  bool _alamatNotEmpty = false;
  bool _alamatLength = false;
  bool _alamatFieldTouched = false;
  bool pinError = false;
  bool confirmPinError = false;
  late Timer _resendTimer;

  @override
  void dispose() {
    _idPenggunaFocusNode.dispose();
    _namaFocusNode.dispose();
    _nomorPonselFocusNode.dispose();
    _alamatEmailFocusNode.dispose();
    _alamatRumahFocusNode.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  String? getNamaError() {
    if (!_namaNotEmpty) {
      return "Nama tidak boleh kosong";
    } else if (!_namaMinLength) {
      return "Nama minimal 4 karakter";
    }
    return null;
  }

  String? getTeleponError() {
    if (!_teleponNotEmpty) {
      return 'Nomor Ponsel tidak boleh kosong';
    } else if (!_teleponStarts) {
      return 'Nomor harus diawali angka 8';
    } else if (!_teleponLength) {
      return 'Nomor harus terdiri dari 10 hingga 13 digit';
    }else if (!_teleponFormat) {
      return 'Nomor harus berupa angka yang valid';
    } 
    return null; // Tidak ada error
  }

  String? getEmailError() {
    if (!_emailNotEmpty) {
      return 'Alamat Email tidak boleh kosong';
    } else if (!_emailFormat) {
      return 'Alamat Email tidak valid';
    }
    return null;
  }

  String? getAlamatError() {
    if (!_emailNotEmpty) {
      return 'Alamat rumah tidak boleh kosong';
    } else if (!_alamatLength) {
      return 'Alamat rumah harus terdiri dari 7 hingga 200 karakter';
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

  Widget startResendTimer() {
    _canResendCode = false;

    return TweenAnimationBuilder<Duration>(
      duration: Duration(minutes: 3),
      tween: Tween(begin: Duration(minutes: 3), end: Duration.zero),
      onEnd: () {
        setState(() {
          _canResendCode = true;
        });
      },
      builder: (BuildContext context, Duration value, Widget? child) {
        final minutes = value.inMinutes;
        final seconds = value.inSeconds % 60;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: OpenSansText.custom(
            text: "$minutes:${seconds.toString().padLeft(2, '0')}",
            fontSize: 20,
            warna: MyColors.textWhite(),
            fontWeight: FontWeight.w400,
          ),
        );
      },
    );
  }

  Future<void> sendOtp() async {
    try {
      await ApiService().sendOtp(
        userId: iDPenggunaController.text,
        noHp: '+62${nomorPonselController.text}',
      );
      startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent successfully')),
      );
    } catch (s) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent successfully')),
      );
    }
  }

  Future<bool> checkUserIdAvailability(String userId) async {
    if (_isValidating || userId == _lastCheckedUserId) return _userIdAvailability;

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(Duration(milliseconds: 500), () async {
      setState(() {
        _isValidating = true;
      });

      try {
        final result = await RestAPI().checkUserId(userId);
        setState(() {
          if (result['success']) {
            idPenggunaError = 'User ID sudah digunakan';
            _userIdAvailability = false;
          } else {
            idPenggunaError = null;
            _userIdAvailability = true;
          }
          _lastCheckedUserId = userId;
        });
      } catch (e) {
        if (e.toString().contains('429')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Too many requests. Please wait a moment.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } finally {
        setState(() {
          _isValidating = false;
        });
      }
    });

    return _userIdAvailability;
  }

  Future<void> referal() async {
    try {
      var response = await ApiService()
          .processReferral(userID: iDPenggunaController.text, otp: otpCode);

      // You can check or use the response body here if needed
      print('Response from referal: $response');
    } catch (e) {
      print('Error: $e');
      throw e; // Re-throw the error to handle it in the UI
    }
  }

  void _checkPassword(String password) {
    setState(() {
      _passwordMinLength = password.length >= 8;
      _passwordUppercase = password.contains(RegExp(r'[A-Z]'));
      _passwordNumber = password.contains(RegExp(r'[0-9]'));
      _isNewPasswordValid = _passwordMinLength && _passwordUppercase && _passwordNumber;
    });
  }

  void _checkUserId(String userId) {
  setState(() {
    _userIdFieldTouched = true; // Menandai bahwa field telah disentuh
    _userIdMinLength = userId.length >= 4;
    _userIdThreeLetters = RegExp(r'[a-zA-Z]{3,}').hasMatch(userId);
    _userIdAlphanumeric = RegExp(r'^[a-zA-Z0-9]+$').hasMatch(userId);
  });

  if (_userIdMinLength && _userIdThreeLetters && _userIdAlphanumeric) {
    // Panggil checkUserIdAvailability dan update _userIdAvailability
    checkUserIdAvailability(userId).then((isAvailable) {
      setState(() {
        _userIdAvailability = isAvailable;
      });
    });
  }
}

  void _checkNama(String nama) {
    setState(() {
      _namaFieldTouched = true;
      _namaNotEmpty = nama.isNotEmpty;
      _namaMinLength = nama.length >= 4;
    });
  }

  void _checkTelepon(String telepon) {
    setState(() {
      _teleponFieldTouched = true;
      _teleponNotEmpty = telepon.isNotEmpty;
      _teleponLength = telepon.length >= 10 && telepon.length <= 13;
      _teleponStarts = telepon.startsWith('8');
      _teleponFormat = RegExp(r'^8[0-9]{9,12}$').hasMatch(telepon); // Nomor yang valid harus diawali 8 dan diikuti 9-12 angka
    });
  }

  void _checkEmail(String email) {
    setState(() {
      _emailFieldTouched = true;
      _emailNotEmpty = email.isNotEmpty;
      _emailFormat = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email); // Nomor yang valid harus diawali 8 dan diikuti 9-12 angka
    });
  }

  void _checkAlamat(String alamat) {
    setState(() {
      _alamatFieldTouched = true;
      _alamatNotEmpty = alamat.isNotEmpty;
      _alamatLength = alamat.length >= 7 && alamat.length <= 200;
    });
  }

  @override
  void initState() {
    super.initState();

    void updateButtonState() {
      setState(() {
        _btnactive = _userIdMinLength &&
            _userIdThreeLetters &&
            _userIdAlphanumeric &&
            _userIdAvailability &&
            _teleponNotEmpty && _teleponFormat && _teleponStarts && _teleponLength &&
            _namaMinLength && _namaNotEmpty &&
            _emailNotEmpty && _emailFormat && 
            _alamatNotEmpty && _alamatLength;
      });
    }

    iDPenggunaController.addListener(() {
      _checkUserId(iDPenggunaController.text);
      updateButtonState();
    });

    namaController.addListener(() {
      _checkNama(namaController.text);
      updateButtonState();
    });

    nomorPonselController.addListener(() {
      _checkTelepon(nomorPonselController.text);
      updateButtonState();
    });

    alamatEmailController.addListener(() {
      _checkEmail(alamatEmailController.text);
      updateButtonState();
    });

    alamatRumahController.addListener(() {
      _checkAlamat(alamatRumahController.text);
      updateButtonState();
    });

    kodeReferalController.addListener(() {
      setState(() {
        _btnactiveform3 = kodeReferalController.text.isNotEmpty;
      });
    });
  }
  // @override
  // void initState() {
  //   // TODO: implement initState

  //   // void updateButtonState() {
  //   //   setState(() {
  //   //     _btnactive = iDPenggunaController.text.isNotEmpty &&
  //   //         namaController.text.isNotEmpty &&
  //   //         nomorPonselController.text.isNotEmpty &&
  //   //         alamatRumahController.text.isNotEmpty &&
  //   //         alamatEmailController.text.isNotEmpty;
  //   //   });
  //   // }
  //   void updateButtonState() {
  //     setState(() {
  //       _btnactive = _userIdMinLength &&
  //           _userIdThreeLetters &&
  //           _userIdAlphanumeric &&
  //           _userIdAvailability &&
  //           _isTeleponValid &&
  //           _isNamaValid &&
  //           _isEmailValid &&
  //           _isAlamatValid;
  //     });
  //   }

  //   iDPenggunaController.addListener(updateButtonState);
  //   namaController.addListener(updateButtonState);
  //   nomorPonselController.addListener(updateButtonState);
  //   alamatEmailController.addListener(updateButtonState);
  //   alamatRumahController.addListener(updateButtonState);
  //   kodeReferalController.addListener(() {
  //     setState(() {
  //       _btnactiveform3 = kodeReferalController.text.isNotEmpty;
  //     });
  //   });

  //   super.initState();
  // }

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
      // case 0:
      //   return _buildAccountTypeScreen();
      case 0:
        return formPertama();
      case 1:
        return formKedua();
      case 2:
        return formketiga(context);
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
      autovalidateMode: AutovalidateMode.disabled,
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
                  fontWeight: FontWeight.w700,
                ),
                OpenSansText.custom(
                  text: "Daftar Pengguna",
                  fontSize: 18,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w400,
                ),
                const Padding(padding: EdgeInsets.only(top: 11)),
                OpenSansText.custom(
                  text: "ID Pengguna",
                  fontSize: 14,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w600,
                ),

                // Custom text field for ID Pengguna
                CostumeTextfieldVerifyId(
                  textformController: iDPenggunaController,
                  hintText: 'Contoh: michael123',
                  fillColors: MyColors.textWhiteHover(),
                  iconSuffixColor: MyColors.textBlack(),
                  showCancelIcon: true, // Optional, show cancel icon
                  isFieldValid: _userIdMinLength && _userIdThreeLetters && _userIdAlphanumeric && _userIdAvailability, // Real-time validation logic
                  onChanged: (value) {
                    _checkUserId(value);
                  },
                ),

                // Display validation messages only after the user interacts with the field
                if (_userIdFieldTouched && (!_userIdMinLength || !_userIdThreeLetters || !_userIdAlphanumeric || !_userIdAvailability)) 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRequirementRow(_userIdMinLength, "Minimal 4 karakter"),
                      _buildRequirementRow(_userIdThreeLetters, "Minimal 3 huruf"),
                      _buildRequirementRow(_userIdAlphanumeric, "Hanya boleh huruf dan angka"),
                      _buildRequirementRow(_userIdAvailability, "User ID tersedia"),
                    ],
                  ),


                const Padding(padding: EdgeInsets.only(top: 11)),
                OpenSansText.custom(
                  text: "Nama",
                  fontSize: 14,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w600,
                ),
                CostumeTextFormFieldTemp(
                  textformController: namaController,
                  hintText: 'Contoh: Michael',
                  fillColors: MyColors.textWhiteHover(),
                  iconSuffixColor: MyColors.textBlack(),
                  errorText: getNamaError(),
                  isFieldValid: _isNamaValid,
                  showCancelIcon: true,
                  onChanged: (value) {
                    _checkNama(value);
                    setState(() {
                      _isNamaValid = _namaMinLength && _namaNotEmpty && _namaFieldTouched;
                    });
                  },
                ),
                const Padding(padding: EdgeInsets.only(top: 11)),
                OpenSansText.custom(
                  text: "Nomor Ponsel",
                  fontSize: 14,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w600,
                ),
                Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: MyColors.iconGrey(),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: OpenSansText.custom(
                        text: '+62',
                        fontSize: 14,
                        warna: MyColors.black(),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Expanded(
                      child: 
                        CostumeTextFormFieldTemp(
                          textformController: nomorPonselController,
                          hintText: 'Contoh: 812345678',
                          fillColors: MyColors.textWhiteHover(),
                          iconSuffixColor: MyColors.textBlack(),
                          errorText: getTeleponError(), // Dapatkan pesan error dari getTeleponError
                          isFieldValid: _isTeleponValid,
                          showCancelIcon: true,
                          onChanged: (value) {
                            _checkTelepon(value); // Cek validasi telepon setiap ada perubahan
                            setState(() {
                              _isTeleponValid = _teleponNotEmpty && _teleponFormat && _teleponStarts && _teleponLength && _teleponFieldTouched; // Pastikan semua validasi terpenuhi
                            });
                          },
                        ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 11)),
                OpenSansText.custom(
                  text: "Alamat Email",
                  fontSize: 14,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w600,
                ),
                CostumeTextFormFieldTemp(
                  textformController: alamatEmailController,
                  hintText: 'Contoh: michael@gmail.com',
                  fillColors: MyColors.textWhiteHover(),
                  iconSuffixColor: MyColors.textBlack(),
                  errorText: getEmailError(), // Dapatkan pesan error dari getTeleponError
                  isFieldValid: _isEmailValid,
                  showCancelIcon: true,
                  onChanged: (value) {
                    _checkEmail(value); // Cek validasi telepon setiap ada perubahan
                    setState(() {
                      _isEmailValid = _emailNotEmpty && _emailFormat && _emailFieldTouched; // Pastikan semua validasi terpenuhi
                    });
                  },
                ),
                const Padding(padding: EdgeInsets.only(top: 11)),
                OpenSansText.custom(
                  text: "Alamat Rumah",
                  fontSize: 14,
                  warna: MyColors.textWhite(),
                  fontWeight: FontWeight.w600,
                ),
                CostumeTextFormFieldTemp(
                  textformController: alamatRumahController,
                  hintText: 'Contoh: Jalan Buyun, Komplek Pasadena',
                  fillColors: MyColors.textWhiteHover(),
                  iconSuffixColor: MyColors.textBlack(),
                  errorText: getAlamatError(), 
                  isFieldValid: _isAlamatValid,
                  showCancelIcon: true,
                  onChanged: (value) {
                    _checkAlamat(value); 
                    setState(() {
                      _isAlamatValid = _alamatNotEmpty && _alamatLength && _alamatFieldTouched; 
                    });
                  },
                ),
                const Padding(padding: EdgeInsets.only(top: 21)),
                CostumeButtonLanjut(
                  buttonText: "Lanjut",
                  backgroundColorbtn: MyColors.greenDarkButton(),
                  backgroundTextbtn: MyColors.textWhite(),
                  inactiveBackgroundColor: MyColors.iconGreyDisable(), 
                  onTap: _btnactive
                      ? () {
                          if (_formmkey.currentState?.validate() ?? false) {
                            setState(() {
                              activeIndex++;
                            });
                          }
                        }
                      : null,
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
                ),
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
                color: Colors.white,
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
                            color: MyColors.greenDarkButton(),
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
                            CostumeButtonLanjut(
                              buttonText: "Lanjut",
                              backgroundColorbtn: MyColors.greenDarkButton(),
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
                            SizedBox(
                              width: mediaQueryWeight,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    activeIndex--;
                                  });
                                },
                                child: Text(
                                  "Kembali",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: MyColors.greenDarkButton()),
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 50),
                                  side: BorderSide(
                                      width: 2,
                                      color: MyColors.greenDarkButton()),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8.0), // Set corner radius here
                                  ),
                                ),
                              ),
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
// bool _isValidating = false;
// Timer? _debounceTimer;

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
  // Debounce timer for controlling API call frequency
  Timer? _debounceTimer;

  // Add a listener to the controller with debounce
  void debouncedValidation(String value) {
    // Cancel the previous timer if it's active
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    // Start a new debounce timer
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      // Check if the length of the input is 8
      if (value.length >= 8) {
        validateReferralCode(value, context); // Call the API
      } else {
        setState(() {
          _isReferralValid = false; // Invalid state if not 8 characters
        });
        ScaffoldMessenger.of(context).clearSnackBars(); // Clear any existing messages
      }
    });
  }

  // Listener for the referral code input
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
            CostumeTextFormFieldWithVerification(
  textformController: kodeReferalController,
  icon: MyIcon.iconLink(size: 20),
  hintText: 'Contoh: TRAD01',
  fillColors: MyColors.textWhiteHover(),
  iconSuffixColor: MyColors.textBlack(),
  showCancelIcon: true,
  isFieldValid: _isReferralValid, // Boolean value to represent validation status
  // onChanged: (value) {
  //   _checkReferalValidity(value); // Your validation logic
  // },
  onCancelIconPressed: () {
    setState(() {
      kodeReferalController.clear(); // Clear the field on cancel press
    });
  },
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
            CostumeButtonLanjut(
              buttonText: "Lanjut",
              backgroundColorbtn: MyColors.greenDarkButton(),
              onTap: (_btnactiveform3 && _isReferralValid && !_isValidating)
                  ? () {
                      if (_formmkey.currentState?.validate() ?? false) {
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


  Widget _buildRequirementRow(bool isMet, String requirement) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
          color: isMet ? Colors.green : Colors.grey,
          size: 16,
        ),
        SizedBox(width: 8),
        Text(
          requirement,
          style: TextStyle(color: MyColors.textWhite(), fontSize: 12),
        ),
      ],
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
                text: "Sandi",
                fontSize: 14,
                warna: MyColors.textWhite(),
                fontWeight: FontWeight.w400),
            CostumeTextfieldVerifyPassword(
              textformController: passwordBaruController,
              hintText: 'Contoh: P@ssw0rd',
              fillColors: MyColors.textWhiteHover(),
              iconSuffixColor: MyColors.textBlack(),
              isPasswordField: true,
              showCancelIcon: !_isNewPasswordValid && _isPasswordDirty,
              isFieldValid: _isNewPasswordValid,
              isDirty: _isPasswordDirty, // This flag controls whether the user has typed or not
              onChanged: (value) {
                setState(() {
                  _isPasswordDirty = true; // Set to true once user starts typing
                  _checkPassword(value);  // Check password requirements
                  _btnactiveform3 = _isNewPasswordValid && _isConfirmationPasswordValid;
                });
              },
            ),

            // Show password requirements only if password is invalid and user has typed
            if (!_isNewPasswordValid && _isPasswordDirty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRequirementRow(_passwordMinLength, "Minimal 8 karakter"),
                  _buildRequirementRow(_passwordUppercase, "Mengandung huruf kapital"),
                  _buildRequirementRow(_passwordNumber, "Mengandung angka"),
                ],
              ),

            const Padding(padding: EdgeInsetsDirectional.only(top: 6)),
            OpenSansText.custom(
                text: "Konfirmasi Sandi",
                fontSize: 14,
                warna: MyColors.textWhite(),
                fontWeight: FontWeight.w400),
            CostumeTextfieldVerifyPassword2(
              textformController: konfirmasipasswordBaruController,
              icon: Icon(Icons.lock, color: MyColors.iconGrey()),
              hintText: 'Masukkan Kembali Sandi',
              fillColors: MyColors.textWhiteHover(),
              iconSuffixColor: MyColors.textBlack(),
              errorText: !_isConfirmationPasswordValid && _isConfirmationPasswordDirty ? "Konfirmasi Sandi tidak cocok." : null,
              onChanged: (value) {
                setState(() {
                  _isConfirmationPasswordDirty = true;
                  _isConfirmationPasswordValid = (passwordBaruController.text == value);
                  _btnactiveform3 = _isNewPasswordValid && _isConfirmationPasswordValid;
                });
              },
            ),
            const Padding(padding: EdgeInsetsDirectional.only(top: 167)),
            CostumeButtonLanjut(
              buttonText: "Lanjut",
              backgroundColorbtn: _btnactiveform3 ? MyColors.greenDarkButton() : MyColors.iconGreyDisable(),
              onTap: _btnactiveform3
                  ? () {
                      String newPassword = passwordBaruController.text;
                      String confirmPassword = konfirmasipasswordBaruController.text;

                      if (_isNewPasswordValid && _isConfirmationPasswordValid) {
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

bool _isNewPasswordValid = false;
bool _isConfirmationPasswordValid = false;

bool _isPasswordDirty = false;  // Flag to check if user has typed in the password field
bool _isConfirmationPasswordDirty = false;  // Flag to check if user has typed in the confirm password field

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
                fontWeight: FontWeight.w400),CostumeTextfieldVerifyPassword(
  textformController: pinBaruController,
  hintText: 'Contoh: 123456',
  fillColors: MyColors.textWhiteHover(),
  iconSuffixColor: MyColors.textBlack(),
  isPasswordField: true, // Supaya mendukung toggle visibility
  showCancelIcon: pinError, // Tampilkan ikon cancel jika ada error
  isFieldValid: !pinError, // Validasi real-time
  onChanged: (value) {
    setState(() {
      pinError = !_validatePinFormat(value); // Validasi PIN
      // Reset confirmPinError jika PIN valid
      if (!_validatePinFormat(value)) {
        confirmPinError = false;
      }
    });
  },
  suffixIconColor: Colors.red, // Warna ikon cancel
  suffixIcon: Icons.cancel, // Ikon cancel ketika ada error
  onCancelIconPressed: () {
    // Logika untuk ikon cancel (reset field, misalnya)
    setState(() {
      pinBaruController.clear();
      pinError = false;
    });
  },
),

            const Padding(padding: EdgeInsetsDirectional.only(top: 6)),
            OpenSansText.custom(
                text: "Konfirmasi PIN",
                fontSize: 14,
                warna: MyColors.textWhite(),
                fontWeight: FontWeight.w400),
            CostumeTextfieldVerifyPassword2(
  textformController: konfirmasiPinBaruController,
  icon: Icon(Icons.lock, color: MyColors.iconGreyDisable()), // Ikon di awal field
  hintText: 'Masukkan Kembali Kode PIN',
  fillColors: MyColors.textWhiteHover(),
  iconSuffixColor: MyColors.textBlack(),
  errorText: confirmPinError ? 'PIN tidak cocok atau bukan 6 digit angka' : null,
  keyboardType: TextInputType.number,
  inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Hanya angka
  onChanged: (value) {
    setState(() {
      // Validasi konfirmasi PIN jika PIN utama valid
      if (_validatePinFormat(pinBaruController.text)) {
        confirmPinError = !_validatePinMatch(pinBaruController.text, value); // Validasi PIN
      }
    });
  },
),

            const Padding(padding: EdgeInsetsDirectional.only(top: 167)),
            CostumeButtonLanjut(
              buttonText: "Lanjut",
              backgroundColorbtn: MyColors.greenDarkButton(),
              onTap: _btnactiveform3 && !pinError && !confirmPinError // Disable the button if errors exist
                  ? () async {
                      setState(() {
                        _btnactiveform3 = false;
                      });

                      bool isValid = _validatePIN();
                      if (isValid) {
                        try {
                          await registerPembeli();
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
              backgroundTextbtn: MyColors.textWhite(),
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

// Helper functions for validation
bool _validatePinFormat(String pin) {
  // PIN must be 6 digits
  return pin.length == 6 && RegExp(r'^[0-9]+$').hasMatch(pin);
}

bool _validatePinMatch(String pin, String confirmPin) {
  // Check if PIN and confirm PIN match
  return pin == confirmPin && _validatePinFormat(confirmPin);
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
                    'Masukan kode verifikasi yang telah dikirim ke nomor handphone +62${nomorPonselController.text} melalui WhatsApp atau SMS',
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
              child: Column(
                children: [
                  TextButton(
                    onPressed: _canResendCode
                        ? () async {
                            setState(() {
                              _canResendCode = false;
                            });
                            try {
                              await ApiService().sendOtp(
                                userId: iDPenggunaController.text,
                                noHp: '${nomorPonselController.text}',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'OTP telah dikirim ke nomor telepon Anda.')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Gagal mengirim OTP. Silakan coba lagi. $e')),
                              );
                            }
                          }
                        : null,
                    child: OpenSansText.custom(
                      text: 'Kirim Ulang Kode',
                      fontSize: 14,
                      warna: _canResendCode
                          ? MyColors.bluedark()
                          : MyColors.iconGrey(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!_canResendCode) startResendTimer(),
                ],
              ),
            ),

            const Padding(padding: EdgeInsetsDirectional.only(top: 68)),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: ElevatedButton(
                onPressed: _btnactiveform3
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
                          if (e
                              .toString()
                              .contains('Failed to activate referral')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Verifikasi OTP Gagal. Mohon coba lagi.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Terjadi kesalahan, silakan coba lagi.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    : null,
                child: OpenSansText.custom(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  warna: MyColors.textWhite(),
                  text: "Daftar",
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6), // <-- Radius
                  ),
                  side: BorderSide(
                    width: 1,
                    color: MyColors.greenDarkButton(),
                  ),
                  backgroundColor: MyColors.greenDarkButton(),
                ),
              ),
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
