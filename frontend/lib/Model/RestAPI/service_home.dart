import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeService {
  static const String apiUrl = 'http://192.168.18.219:8000/api/home';

  Future<Map<String, dynamic>> fetchHomeData(int userId) async {
    final response = await http.get(Uri.parse('$apiUrl/$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load home data');
    }
  }
}

