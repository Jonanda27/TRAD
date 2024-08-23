import 'dart:convert';
import 'package:http/http.dart' as http;

class RestAPI {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<Map<String, dynamic>?> login(String userId, String password) async {
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
      return jsonDecode(response.body);
    } else {
      return null;
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