import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_api.dart';
import 'package:trad/Screen/AuthScreen/Login/lupa_password.dart';
import 'package:trad/Screen/AuthScreen/Register/register_screen.dart';
import 'package:trad/Screen/HomeScreen/home_screen.dart';
import 'package:trad/main.dart';
import 'package:trad/profile.dart';
import 'package:trad/Utility/icon.dart';
import 'package:trad/Utility/text_opensans.dart';
import 'package:trad/Utility/warna.dart';
import 'package:trad/widget/component/costume_button.dart';
import 'package:trad/widget/component/costume_teksfield.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController iDPenggunaController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? _userIdErrorText;
  String? _passwordErrorText;
  bool _btnactive = false;
  final GlobalKey<FormState> _formmkey = GlobalKey<FormState>();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    iDPenggunaController.addListener(_onUserIdChanged);
    passwordController.addListener(_validate);
  }

  @override
  void dispose() {
    iDPenggunaController.removeListener(_onUserIdChanged);
    passwordController.removeListener(_validate);
    _debounce?.cancel();
    iDPenggunaController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onUserIdChanged() {
    _validate();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1500), () {
      if (iDPenggunaController.text.length >= 4) {
        _checkUserId();
      } else {
        setState(() {
          _userIdErrorText = null;
        });
      }
    });
  }

  void _checkUserId() async {
    final res = await RestAPI().checkUserId(iDPenggunaController.text);
    setState(() {
      if (res['success']) {
        _userIdErrorText = null;
      } else {
        _userIdErrorText = res['error'];
      }
    });
  }

  void _validate() {
    setState(() {
      _btnactive = iDPenggunaController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          _userIdErrorText == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

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
                width: mediaQueryWidth,
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
                        const SizedBox(height: 5),
                        OpenSansText.custom(
                          text: 'Masuk',
                          fontSize: 30,
                          warna: MyColors.textWhite(),
                          fontWeight: FontWeight.w700,
                        ),
                        const SizedBox(height: 5),
                        OpenSansText.custom(
                          text: 'Merchant',
                          fontSize: 20,
                          warna: MyColors.textWhite(),
                          fontWeight: FontWeight.w400,
                        ),
                        const SizedBox(height: 30),
                        CostumeTextFormField(
                          errorText: _userIdErrorText,
                          icon: MyIcon.iconUser(size: 20),
                          textformController: iDPenggunaController,
                          hintText: 'michael123',
                          fillColors: MyColors.textWhite(),
                          iconSuffixColor: MyColors.iconGrey(),
                          isPasswordField: false,
                        ),
                        const SizedBox(height: 20),
                        CostumeTextFormField(
                          errorText: _passwordErrorText,
                          icon: MyIcon.iconLock(size: 20),
                          textformController: passwordController,
                          hintText: 'P@ssw0rd',
                          fillColors: MyColors.textWhite(),
                          iconSuffixColor: MyColors.iconGrey(),
                          isPasswordField: true,
                        ),
                        const SizedBox(height: 5),
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ForgotPasswordScreen()),
                              );
                            },
                            child: OpenSansText.custom(
                              text: 'Lupa Kata Sandi?',
                              fontSize: 12,
                              warna: MyColors.textWhite(),
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        CostumeButton(
                          backgroundColorbtn: MyColors.iconGrey(),
                          backgroundTextbtn: MyColors.textBlack(),
                          onTap: _btnactive ? _login : null,
                          buttonText: 'Masuk',
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OpenSansText.custom(
                              text: 'Belum punya akun? ',
                              fontSize: 14,
                              warna: MyColors.textWhite(),
                              fontWeight: FontWeight.w300,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RegisterScreen()),
                                );
                              },
                              child: OpenSansText.custom(
                                text: 'Daftar Akun',
                                fontSize: 14,
                                warna: MyColors.textWhite(),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
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

  void _login() async {
    if (_formmkey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Logging in...'),
        backgroundColor: Colors.green.shade300,
      ));

      final res = await RestAPI().login(
        iDPenggunaController.text,
        passwordController.text,
      );

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (!res['success']) {
        setState(() {
          if (res['errorType'] == 'userId') {
            _userIdErrorText = res['error'];
            _passwordErrorText = null;
          } else if (res['errorType'] == 'password') {
            _userIdErrorText = null;
            _passwordErrorText = res['error'];
          } else {
            _userIdErrorText = null;
            _passwordErrorText = null;
          }
        });

        Fluttertoast.showToast(msg: res['error']);
        return;
      }

      if (res == null) {
        Fluttertoast.showToast(msg: 'Login failed');
        return;
      }

      setState(() {
        _userIdErrorText = null;
        _passwordErrorText = null;
      });

      // Save user data and token to SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      Map<String, dynamic> userData = res['data'];
      String token = userData['token'];
      await prefs.setString('token', token);
      print('Token saved to SharedPreferences: $token');

      String userId = userData['user']['userId'];
      await prefs.setString('userId', userId);
      print('User ID saved to SharedPreferences: $userId');

      int id = userData['user']['id'];
      await prefs.setInt('id', id);
      print('ID saved to SharedPreferences: $id');

      String nama = userData['user']['nama'];
      await prefs.setString('nama', nama);
      print('Name saved to SharedPreferences: $nama');

      String email = userData['user']['email'];
      await prefs.setString('email', email);
      print('Email saved to SharedPreferences: $email');

      String phone = userData['user']['noHp'];
      await prefs.setString('noHp', phone);
      print('Phone saved to SharedPreferences: $phone');

      String role = userData['user']['role'];
      await prefs.setString('role', role);
      print('Role saved to SharedPreferences: $role');

      print('Saved user data to SharedPreferences');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                HomeScreen()), // Replace with your home screen
        (route) => false,
      );
    }
  }
}

// class RegisterScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Register'),
//       ),
//       body: Center(
//         child: Text('Register Screen'),
//       ),
//     );
//   }
// }
