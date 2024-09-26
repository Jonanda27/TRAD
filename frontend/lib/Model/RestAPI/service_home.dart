import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeService {
  static const String apiUrl = 'http://127.0.0.1:8000/api';

  Future<Map<String, dynamic>> fetchHomeData(int userId) async {
    final response = await http.get(Uri.parse('$apiUrl/home/$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load home data');
    }
  }

  Future<Map<String, dynamic>> gantiRole(int userId) async {
    final response = await http.post(Uri.parse('$apiUrl/gantiRole/$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to switch role: ${response.body}');
    }
  }
}

