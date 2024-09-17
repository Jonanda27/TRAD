import 'dart:convert';
import 'package:http/http.dart' as http;

class RestAPI {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<Map<String, dynamic>> login(String userId, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'userId': userId,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else if (response.statusCode == 404) {
        return {'success': false, 'error': 'User tidak ditemukan', 'errorType': 'userId'};
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': 'Password salah', 'errorType': 'password'};
      } else {
        return {'success': false, 'error': 'Terjadi kesalahan', 'errorType': 'general'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Terjadi kesalahan jaringan', 'errorType': 'network'};
    }
  }

  Future<Map<String, dynamic>> checkUserId(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cekUserId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'User Id Benar!'};
      } else if (response.statusCode == 400) {
        final responseBody = jsonDecode(response.body);
        if (responseBody.containsKey('errors')) {
          return {'success': false, 'error': 'Input tidak valid', 'errorType': 'validation'};
        } else {
          return {'success': false, 'error': 'User Id tidak ditemukan', 'errorType': 'notFound'};
        }
      } else {
        return {'success': false, 'error': 'Terjadi kesalahan', 'errorType': 'general'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Terjadi kesalahan jaringan', 'errorType': 'network'};
    }
  }


  Future<Map<String, dynamic>?> registerUser(
    String userId, 
    String name, 
    String phone, 
    String email, 
    String noReferal, 
    String password, 
    String pin, 
    String role
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register-$role'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userID': userId,
        'name': name,
        'phone': phone,
        'email': email,
        'noReferal': noReferal,
        'password': password,
        'pin': pin,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}