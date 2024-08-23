import 'dart:convert';
import 'package:http/http.dart' as http;

class PasswordService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<bool> sendOtp(String userId, String noHp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'noHp': noHp,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final Map<String, dynamic> responseJson = json.decode(response.body);
      throw Exception(responseJson['error']);
    }
  }

  Future<bool> verifyOtp(String noHp, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'noHp': noHp,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final Map<String, dynamic> responseJson = json.decode(response.body);
      throw Exception(responseJson['error']);
    }
  }

  Future<bool> resetPassword({
    required String userId,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resetPassword'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final Map<String, dynamic> responseJson = json.decode(response.body);
      throw Exception(responseJson['error']);
    }
  }
}