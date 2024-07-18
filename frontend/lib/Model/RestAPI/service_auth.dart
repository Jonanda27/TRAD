import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // Ganti dengan URL base dari backend Laravel Anda

  Future<void> registerRegular({
    required String userID,
    required String name,
    required String phone,
    required String email,
    required String noReferal,
    required String password,
    required String pin,
  }) async {
    try {
      var url = Uri.parse('$baseUrl/register-regular');
      var response = await http.post(url, body: {
        'userID': userID,
        'name': name,
        'phone': phone,
        'email': email,
        'noReferal': noReferal,
        'password': password,
        'pin': pin,
      });

      if (response.statusCode == 200) {
        // Registration successful
        print('Registration successful');
        print(response.body);
        return jsonDecode(response.body); // Misalnya, Anda bisa mengembalikan JSON response
      } else {
        // Registration failed
        print('Registration failed');
        print(response.body);
        throw Exception('Failed to register user');
      }
    } catch (e) {
      print('Error during registration: $e');
      throw Exception('Failed to register user: $e');
    }
  }

  Future<void> processReferral({
    required String userID,
    required String otp,
  }) async {
    try {
      var url = Uri.parse('$baseUrl/activate');
      var response = await http.post(url, body: {
        'userID': userID,
        'otp': otp,
      });

      if (response.statusCode == 200) {
        // Activation successful
        print('Activation successful');
        print(response.body);
        return jsonDecode(response.body); // Misalnya, Anda bisa mengembalikan JSON response
      } else {
        // Activation failed
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
