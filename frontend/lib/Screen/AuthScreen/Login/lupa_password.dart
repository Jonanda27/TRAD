// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trad/Model/RestAPI/service_password.dart';
import 'package:trad/Screen/AuthScreen/Login/login_screen.dart';
import 'package:trad/Utility/icon.dart';
import 'package:trad/Utility/text_opensans.dart' as opensans1;
import 'package:trad/Widget/component/costume_button.dart';
import 'package:trad/utility/warna.dart';
import '../../../widget/component/costume_teksfield.dart';
// import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lupa Kata Sandi',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: ForgotPasswordScreen(),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _activeIndex = 0;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _idPenggunaController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final PasswordService _passwordService = PasswordService();

  List<Widget> _forms() {
    return [
      _buildFormContent(
        context,
        title: 'Lupa Kata Sandi',
        subtitle: 'Masukkan Data Pengguna',
        fields: [
          _buildCustomTextField(_idPenggunaController, 'ID Pengguna', MyIcon.iconUser(size: 20)),
          _buildCustomTextField(_phoneNumberController, 'No Telepon', MyIcon.iconUser(size: 20)),
        ],
        onSubmit: _handleSubmitUserData,
      ),
      _buildOTPForm(),
      _buildFormContent(
        context,
        title: 'Atur Ulang Kata Sandi',
        fields: [
          _buildCustomTextField(_newPasswordController, 'Kata Sandi Baru', MyIcon.iconLock(size: 20)),
          _buildCustomTextField(_confirmPasswordController, 'Konfirmasi Kata Sandi Baru', MyIcon.iconLock(size: 20)),
        ],
        onSubmit: _handleSubmitNewPassword,
      ),
      _buildSuccessForm(),
    ];
  }

  Future<void> _handleSubmitUserData() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final userId = _idPenggunaController.text;
        final phoneNumber = _phoneNumberController.text;
        final success = await _passwordService.sendOtp(userId, phoneNumber);

        if (success) {
          setState(() {
            _activeIndex++;
          });
        }
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _handleSubmitNewPassword() async {
    if (_newPasswordController.text == _confirmPasswordController.text) {
      try {
        final userId = _idPenggunaController.text; // Fetching userId
        final otp = _otpController.text; // Fetching OTP
        final success = await _passwordService.resetPassword(
          userId: userId,
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
        );
        if (success) {
          setState(() {
            _activeIndex++;
          });
        }
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } else {
      // Show error message for password mismatch
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match')));
    }
  }

  Widget _buildBackground(BuildContext context) {
    return Image.asset(
      'assets/img/background.png',
      fit: BoxFit.cover,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
    );
  }

  Widget _buildFormContent(
    BuildContext context, {
    required String title,
    String? subtitle,
    required List<Widget> fields,
    required VoidCallback onSubmit,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            _buildBackground(context),
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 49,
                          width: 60,
                          child: SvgPicture.asset("assets/svg/Logo Icon.svg"),
                        ),
                        const SizedBox(height: 5),
                        opensans1.OpenSansText.custom(
                          text: title,
                          fontSize: 30,
                          warna: MyColors.textWhite(),
                          fontWeight: FontWeight.w700,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 5),
                          opensans1.OpenSansText.custom(
                            text: subtitle,
                            fontSize: 20,
                            warna: MyColors.textWhite(),
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                        const SizedBox(height: 30),
                        ...fields,
                        const SizedBox(height: 21),
                        CostumeButton(
                          buttonText: "Lanjut",
                          onTap: onSubmit,
                          backgroundColorbtn: MyColors.iconGrey(),
                          backgroundTextbtn: MyColors.black(),
                        ),
                        const SizedBox(height: 11),
                        CostumeButton(
  buttonText: "Kembali",
  onTap: () {
    setState(() {
      if (_activeIndex <= 0) {
        // Navigate to LoginScreen if index is 0 or below
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        // Otherwise, just decrement the index
        _activeIndex--;
      }
    });
  },
  backgroundColorbtn: MyColors.Transparent(),
  backgroundTextbtn: MyColors.textWhite(),
),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomTextField(
    TextEditingController controller,
    String hintText,
    Widget icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: CostumeTextFormField(
        textformController: controller,
        hintText: hintText,
        icon: icon,
        fillColors: MyColors.textWhite(),
        iconSuffixColor: MyColors.iconGrey(),
      ),
    );
  }

  Widget _buildOTPForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          opensans1.OpenSansText.custom(
            text: "Verifikasi Pendaftaran",
            fontSize: 18,
            warna: MyColors.textWhite(),
            fontWeight: FontWeight.w400,
          ),
          const SizedBox(height: 25),
          opensans1.OpenSansText.custom(
            text: 'Masukan kode verifikasi yang telah dikirim ke nomor handphone ${_phoneNumberController.text}',
            fontSize: 14,
            warna: MyColors.textWhite(),
            fontWeight: FontWeight.w400,
          ),
          const SizedBox(height: 45),
          OtpTextField(
            mainAxisAlignment: MainAxisAlignment.center,
            textStyle: TextStyle(color: MyColors.textWhite()),
            fieldWidth: 30,
            numberOfFields: 6,
            borderColor: MyColors.textWhite(),
            focusedBorderColor: MyColors.textWhite(),
            showFieldAsBox: false,
            borderWidth: 0.5,
            onCodeChanged: (String code) {
              print('Current code: $code');
            },
            onSubmit: (String verificationCode) async {
              try {
                // final userId = _idPenggunaController.text; // Fetching userId
                final success = await _passwordService.verifyOtp(
                  _phoneNumberController.text,
                  verificationCode,
                );
                if (success) {
                  setState(() {
                    _activeIndex++;
                  });
                }
              } catch (e) {
                // Handle error
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
          ),
          const SizedBox(height: 21),
          CostumeButton(
            buttonText: "Lanjut",
            onTap: () {
              setState(() {
                _activeIndex++;
              });
            },
            backgroundColorbtn: MyColors.iconGrey(),
            backgroundTextbtn: MyColors.black(),
          ),
          const SizedBox(height: 11),
          CostumeButton(
            buttonText: "Kembali",
            onTap: () {
              setState(() {
                _activeIndex--;
              });
            },
            backgroundColorbtn: MyColors.Transparent(),
            backgroundTextbtn: MyColors.textWhite(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessForm() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            _buildBackground(context),
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 100,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 20),
                              opensans1.OpenSansText.custom(
                                text: "Kata Sandi Berhasil Diperbarui",
                                fontSize: 20,
                                warna: MyColors.textWhite(),
                                fontWeight: FontWeight.w700,
                              ),
                              const SizedBox(height: 40),
                              CostumeButton(
                                buttonText: "Selesai",
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginScreen()),
                                  );
                                },
                                backgroundColorbtn: MyColors.iconGrey(),
                                backgroundTextbtn: MyColors.black(),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(context),
          Form(
            key: _formKey,
            child: IndexedStack(
              index: _activeIndex,
              children: _forms(),
            ),
          ),
        ],
      ),
    );
  }
}
