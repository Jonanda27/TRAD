import 'package:flutter/material.dart';
import 'package:trad/Model/register_model.dart';
import 'package:trad/Model/RestAPI/service_auth.dart';

class RegisterProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  RegisterModel _registerData = RegisterModel(
    id: 0,
    UserID: '',
    name: '',
    phone: '',
    email: '',
    alamat: '',
    password: '',
    pin: '',
    noReferal: '',
  );

  RegisterModel get registerData => _registerData;

  set registerData(RegisterModel newData) {
    _registerData = newData;
    notifyListeners();
  }

  Future<bool> registerUser() async {
    try {
      await _apiService.registerPenjual(
        userID: _registerData.UserID,
        name: _registerData.name,
        phone: _registerData.phone,
        email: _registerData.email,
        alamat: _registerData.alamat,
        noReferal: _registerData.noReferal,
        password: _registerData.password,
        pin: _registerData.pin,
      );
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<bool> activateReferral(String otp) async {
    try {
      await _apiService.processReferral(
        userID: _registerData.UserID,
        otp: otp,
      );
      return true;
    } catch (e) {
      print('Activation error: $e');
      return false;
    }
  }
}
