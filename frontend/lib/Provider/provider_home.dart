// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trad/Model/home_model.dart';

class ApiService {
  static const String baseUrl = 'http://yourapiurl.com/api';

  Future<HomeData> getHomeData(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/home/$userId'));

    if (response.statusCode == 200) {
      return HomeData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load home data');
    }
  }
}
