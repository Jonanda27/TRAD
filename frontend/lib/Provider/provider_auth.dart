import 'package:flutter/material.dart';
import 'package:trad/Model/register_model.dart';
import 'package:trad/Model/RestAPI/service_auth.dart';

class RegisterProvider extends ChangeNotifier {
  final RegisterService _registerService = RegisterService();
  RegisterModel _registerData = RegisterModel(
    id: 0,
    UserID: '',
    name: '',
    phone: '',
    email: '',
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
    bool success = await _registerService.registerUser(_registerData);
    return success;
  }
}
