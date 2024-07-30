import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trad/Model/RestAPI/service_api.dart';
import 'package:trad/Screen/HomeScreen/home_screen.dart'; // Pastikan ini mengarah ke HalamanAwal
import 'package:trad/Screen/WelcomeScreen/welcome_screen.dart';
import 'package:trad/Utility/icon.dart';
import 'package:trad/Utility/text_opensans.dart';
import 'package:trad/Utility/warna.dart';
import 'package:trad/Widget/component/costume_button.dart';
import 'package:trad/Widget/component/costume_teksfield.dart';
import 'package:trad/login.dart';
import 'package:trad/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

TextEditingController idController = TextEditingController();
TextEditingController passwordController = TextEditingController();
String? _errorText;
bool _btnactive = false;
GlobalKey<FormState> _formmkey = GlobalKey<FormState>();

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    idController.addListener(() {
      if (idController.text.isEmpty && passwordController.text.isEmpty) {
        setState(() {
          _errorText = 'Input has Error';
        });
      } else {
        setState(() {
          _errorText = null;
        });
      }
      _btnactive = idController.text.isNotEmpty;
    });
    passwordController.addListener(() {
      if (passwordController.text.isNotEmpty) {
        setState(() {
          // _errorText = 'Input has Error';
        });
      } else {
        setState(() {
          // _errorText = null;
        });
      }
      _btnactive = passwordController.text.isNotEmpty;
    });

    super.initState();
  }

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formmkey.currentState!.validate()) {
      // show snackbar to indicate loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Login'),
        backgroundColor: Colors.green.shade300,
      ));
      // get response from ApiClient
      final res = await RestAPI().login(
        idController.text,
        passwordController.text,
      );

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (res == null) {
        Fluttertoast.showToast(msg: 'Invalid username / Password');
        return;
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HalamanAwal()), // Pastikan ini mengarah ke halaman utama
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tinggi full HP
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    // Lebar full HP
    final mediaQueryWeight = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Form(
        key: _formmkey,
        child: SafeArea(
          child: Stack(
            children: [
              Image.asset(
                'assets/img/background.png',
                fit: BoxFit.cover,
                height: mediaQueryHeight,
                width: mediaQueryWeight,
              ),
              Center(
                child: SingleChildScrollView(
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
                        const SizedBox(
                          height: 5,
                        ),
                        GestureDetector(
                          child: OpenSansText.custom(
                            text: 'Masuk',
                            fontSize: 30,
                            warna: MyColors.textWhite(),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        OpenSansText.custom(
                          text: 'Merchant',
                          fontSize: 20,
                          warna: MyColors.textWhite(),
                          fontWeight: FontWeight.w400,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        CostumeTextFormField(
                          errorText: _errorText,
                          icon: MyIcon.iconUser(size: 20),
                          textformController: idController,
                          hintText: 'ID Pengguna',
                          fillColors: MyColors.textWhite(),
                          iconSuffixColor: MyColors.iconGrey(),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CostumeTextFormField(
                          errorText: _errorText,
                          icon: MyIcon.iconLock(size: 20),
                          textformController: passwordController,
                          hintText: 'Kata Sandi',
                          fillColors: MyColors.textWhite(),
                          iconSuffixColor: MyColors.iconGrey(),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: () {},
                            child: OpenSansText.custom(
                              text: 'Lupa Kata Sandi ? ',
                              fontSize: 12,
                              warna: MyColors.textWhite(),
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        CostumeButton(
                          backgroundColorbtn: MyColors.iconGrey(),
                          backgroundTextbtn: MyColors.textBlack(),
                          onTap: _btnactive ? _login : null,
                          buttonText: 'Masuk',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
