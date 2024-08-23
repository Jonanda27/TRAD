import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_api.dart';
import 'package:trad/Screen/AuthScreen/Login/lupa_password.dart';
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
  String? _errorText;
  bool _btnactive = false;
  bool _isPasswordIncorrect = false;
  final GlobalKey<FormState> _formmkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    iDPenggunaController.addListener(_validate);
    passwordController.addListener(_validate);
  }

  void _validate() {
    setState(() {
      _btnactive = iDPenggunaController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    iDPenggunaController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
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
                          errorText: _errorText,
                          icon: MyIcon.iconUser(size: 20),
                          textformController: iDPenggunaController,
                          hintText: 'ID Pengguna',
                          fillColors: MyColors.textWhite(),
                          iconSuffixColor: MyColors.iconGrey(),
                          isPasswordField: false, // ID field is not a password field
                        ),
                        const SizedBox(height: 20),
                        CostumeTextFormField(
                          errorText: _errorText,
                          icon: MyIcon.iconLock(size: 20),
                          textformController: passwordController,
                          hintText: 'Kata Sandi',
                          fillColors: MyColors.textWhite(),
                          iconSuffixColor: MyColors.iconGrey(),
                          suffixIcon: _isPasswordIncorrect ? Icons.cancel : null,
                          isPasswordField: true, // Password field is a password field
                        ),
                        const SizedBox(height: 5),
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
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

      if (res == null) {
        setState(() {
          _isPasswordIncorrect = true;
          _errorText = 'Invalid username / Password';
        });
        Fluttertoast.showToast(msg: 'Invalid username / Password');
        return;
      }

      setState(() {
        _isPasswordIncorrect = false;
        _errorText = null;
      });

      // Save user data and token to SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      String token = res['token'];
      await prefs.setString('token', token);
      print('Token saved to SharedPreferences: $token');

      String userId = res['user']['userId'];
      await prefs.setString('userId', userId);
      print('User ID saved to SharedPreferences: $userId');

      int id = res['user']['id'];
      await prefs.setInt('id', id);
      print('ID saved to SharedPreferences: $id');

      String nama = res['user']['nama'];
      await prefs.setString('nama', nama);
      print('Name saved to SharedPreferences: $nama');

      String email = res['user']['email'];
      await prefs.setString('email', email);
      print('Email saved to SharedPreferences: $email');

      String phone = res['user']['noHp'];
      await prefs.setString('noHp', phone);
      print('Phone saved to SharedPreferences: $phone');
 
      String role = res['user']['role'];
      await prefs.setString('role', role);
      print('Role saved to SharedPreferences: $role');

      print('Saved user data to SharedPreferences');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
        (route) => false,
      );
    }
  }
}
