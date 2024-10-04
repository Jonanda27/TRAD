import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // Ganti dengan URL base dari backend Laravel Anda

  Future<void> registerPenjual({
    required String userID,
    required String name,
    required String phone,
    required String email,
    required String alamat,
    required String noReferal,
    required String password,
    required String pin,
  }) async {
    try {
      var url = Uri.parse('$baseUrl/register-seller');
      var data = {
        'userId': userID,
        'nama': name,
        'noHp': '+62$phone',
        'email': email,
        'alamat': alamat,
        'noReferal': noReferal,
        'password': password,
        'pin': pin,
      };
      String jsonData = jsonEncode(data);
      print('data : $data');
      print('jsonData : $jsonData');

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registration successful
        print('Registration successful');
        print(response.body);
        return jsonDecode(response.body); // Misalnya, Anda bisa mengembalikan JSON response
      } else {
        // Registration failed
        print('Registration failed class');
        print(response.body);
        throw Exception('Failed to register user');
      }
    } catch (e) {
      print('Error during registration: $e');
      throw Exception('Failed to register user: $e');
    }
  }

Future<Map<String, dynamic>>otpLupaSandi({required String userID, required String otp}) async {
  try {
    print('The data $userID $otp');
    var url = Uri.parse('$baseUrl/otpLupaSandi');
    var data = {
      'userId': userID,
      'otp': otp, 
    };
    
    String jsonData = jsonEncode(data);

    print('jsonData: $jsonData');
    var response = await http.post(url, headers: {
      'Content-Type': 'application/json',
    }, body: jsonData);
    print('response: $response');
    var status;
    status = response.statusCode;
    print('status: $status');
    if (status == 200 || response.statusCode == 201) {
      print('dah masok');
      var responseBody = jsonDecode(response.body);
      print('Change password successful');
      print(responseBody);

      // Return the response body
      return responseBody;
    } else {
      print('Change password failed');
      print(response.body);
      throw Exception('Failed to change password');
    }
  } catch (e) {
    print('Error during Change password: $e');
    throw Exception('Failed to change password: $e');
  }
}



    Future<void> registerPembeli({
    required String userID,
    required String name,
    required String phone,
    required String email,
    required String alamat,
    required String noReferal,
    required String password,
    required String pin,
  }) async {
    try {
      var url = Uri.parse('$baseUrl/register-buyer');
      var data = {
        'userId': userID,
        'nama': name,
        'noHp': '+62$phone',
        'email': email,
        'alamat': alamat,
        'noReferal': noReferal,
        'password': password,
        'pin': pin,
      };
      String jsonData = jsonEncode(data);
      print('data : $data');
      print('jsonData : $jsonData');

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registration successful
        print('Registration successful');
        print(response.body);
        return jsonDecode(response.body); // Misalnya, Anda bisa mengembalikan JSON response
      } else {
        // Registration failed
        print('Registration failed class');
        print(response.body);
        throw Exception('Failed to register user');
      }
    } catch (e) {
      print('Error during registration: $e');
      throw Exception('Failed to register user: $e');
    }
  }

Future<Map<String, dynamic>> processReferral({required String userID, required String otp}) async {
  try {
    var url = Uri.parse('$baseUrl/activate');
    var data = {
      'userId': userID,
      'otp': otp,
    };
    String jsonData = jsonEncode(data);
    var response = await http.post(url, headers: {
      'Content-Type': 'application/json',
    }, body: jsonData);

    if (response.statusCode == 200 || response.statusCode == 201) {
      var responseBody = jsonDecode(response.body);
      print('Activation successful');
      print(responseBody);

      // Return the response body
      return responseBody;
    } else {
      print('Activation failed');
      print(response.body);
      throw Exception('Failed to activate referral');
    }
  } catch (e) {
    print('Error during activation: $e');
    throw Exception('Failed to activate referral: $e');
  }
}
}
