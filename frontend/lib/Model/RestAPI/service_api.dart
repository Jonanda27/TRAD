import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': 'User tidak ditemukan', 'errorType': 'userId'};
      } else if (response.statusCode == 402) {
        return {'success': false, 'error': 'Akun belum diaktivasi', 'errorType': 'userId'};
      } else if (response.statusCode == 403) {
        return {'success': false, 'error': 'Password salah', 'errorType': 'password'};
      } 
      else {
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
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register-buyer'),
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
  Future<Map<String, dynamic>> getCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('id');

    if (token == null || userId == null) {
      return {'success': false, 'error': 'No token or user ID found'};
    }

    final response = await http.get(
      Uri.parse('${baseUrl}/user/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'error': 'Failed to fetch user data'};
    }
  }
}