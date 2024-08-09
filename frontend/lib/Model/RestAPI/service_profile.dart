import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileService {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // Replace with your actual API base URL

  static Future<Map<String, dynamic>> fetchProfileData(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/profil/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  static Future<void> updateProfile(int id, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ubahProfil/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }

  static Future<void> updatePersonalInfo(int id, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ubahPribadi/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update personal info');
    }
  }

  static Future<void> updateProfilePicture(int id, String imagePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/ubahFotoProfil/$id'));
    request.files.add(await http.MultipartFile.fromPath('fotoProfil', imagePath));

    var response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile picture');
    }
  }
}