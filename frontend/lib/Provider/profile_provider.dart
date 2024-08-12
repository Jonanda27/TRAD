// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:trad/Model/RestAPI/service_profile.dart';

// class ProfileProvider with ChangeNotifier {
//   Map<String, dynamic> _profileData = {};
//   bool _isLoading = false;

//   Map<String, dynamic> get profileData => _profileData;
//   bool get isLoading => _isLoading;

//   Future<void> fetchProfileData() async {
//     _isLoading = true;
//     notifyListeners();

//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final id = prefs.getInt('id');
//     if (id != null) {
//       try {
//         final data = await ProfileService.fetchProfileData(id);
//         _profileData = data;
//         await _updateSharedPreferences();
//       } catch (e) {
//         print('Error fetching profile data: $e');
//       }
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<void> updateProfile(Map<String, dynamic> updatedData) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final id = prefs.getInt('id');
//     if (id != null) {
//       try {
//         final response = await ProfileService.updateProfile(id, updatedData);
//         if (response != null) {
//           _profileData.addAll(updatedData);
//           notifyListeners();
//           // Update SharedPreferences
//           await _updateSharedPreferences();
//         }
//       } catch (e) {
//         print('Error updating profile: $e');
//       }
//     }
//   }

//   Future<void> _updateSharedPreferences() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('name', _profileData['name'] ?? '');
//     await prefs.setString('userId', _profileData['userId'] ?? '');
//     await prefs.setString('email', _profileData['email'] ?? '');
//     await prefs.setString('noHp', _profileData['noHp'] ?? '');
//     await prefs.setString('tanggalLahir', _profileData['tanggalLahir'] ?? '');
//     await prefs.setString('jenisKelamin', _profileData['jenisKelamin'] ?? '');
//     await prefs.setString('fotoProfil', _profileData['fotoProfil'] ?? '');
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_profile.dart';

class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic> _profileData = {};
  bool _isLoading = true;

  Map<String, dynamic> get profileData => _profileData;
  bool get isLoading => _isLoading;

  Future<void> fetchProfileData() async {
    _isLoading = true;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    if (id != null) {
      try {
        final data = await ProfileService.fetchProfileData(id);
        _profileData = data;
      } catch (e) {
        print('Error fetching profile data: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> updatedData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    if (id != null) {
      try {
        await ProfileService.updateProfile(id, updatedData);
        _profileData.addAll(updatedData);
        notifyListeners();
      } catch (e) {
        print('Error updating profile: $e');
        throw e;
      }
    }
  }

  Future<void> updatePersonalInfo(Map<String, dynamic> updatedData) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final id = prefs.getInt('id');
  if (id != null) {
    try {
      final updatedProfileData = await ProfileService.updatePersonalInfo(id, updatedData);
      _profileData.addAll(updatedProfileData['data']);
      notifyListeners();
    } catch (e) {
      print('Error updating personal info: $e');
      throw e;
    }
  }
}
}