import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String baseUrl = 'http://192.168.18.219:8000/api'; // Replace with your actual API base URL

  // Fetch profile data either from SharedPreferences or from the API
  static Future<Map<String, dynamic>> fetchProfileData(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final profileDataString = prefs.getString('profile_data_$id');

    if (profileDataString != null) {
      return json.decode(profileDataString);
    } else {
      final response = await http.get(Uri.parse('$baseUrl/profil/$id'));
      if (response.statusCode == 200) {
        final profileData = json.decode(response.body);
        await _saveProfileData(id, profileData);
        return profileData;
      } else {
        throw Exception('Failed to load profile data');
      }
    }
  }

  // Update profile data (e.g., name, email, etc.)
  static Future<Map<String, dynamic>> updateProfile(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ubahProfil/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update personal information (e.g., phone number, date of birth)
  static Future<Map<String, dynamic>> updatePersonalInfo(int? id, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ubahPribadi/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update profile picture
  static Future<void> updateProfilePicture(int id, String imagePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/ubahFotoProfil/$id'));
      request.files.add(await http.MultipartFile.fromPath('fotoProfil', imagePath));

      var response = await request.send();

      if (response.statusCode != 200) {
        final errorData = json.decode(await response.stream.bytesToString());
        throw Exception(errorData['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Save profile data in SharedPreferences
  static Future<void> _saveProfileData(int id, Map<String, dynamic> profileData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_data_$id', json.encode(profileData));
  }

// Logout and clear SharedPreferences
static Future<void> logout() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token'); // Retrieve the token

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add the token in the header
      },
    );

    if (response.statusCode == 200) {
      // Clearing specific keys instead of all (optional)
      await prefs.remove('token');
      await prefs.remove('userId');
      // Add any other keys you want to remove
    } else {
      throw Exception('Failed to log out. Status: ${response.statusCode}, Body: ${response.body}');
    }
  } catch (e) {
    // Logging error
    print('Logout error: $e');
    // Optionally, you could add retry logic here if logout fails
    rethrow;
  }
}


// Change password
static Future<bool> changePassword(String newPassword) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId'); // Fetch user ID from SharedPreferences

  if (userId == null) {
    throw Exception('User ID not found');
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/ubahKataSandi'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'userId': userId,
        'password': newPassword,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to change password. Status: ${response.statusCode}, Body: ${response.body}');
    }
  } catch (e) {
    print('Error changing password: $e');
    rethrow;
  }
}
  // Update PIN
  static Future<bool> updatePin(String userId, String currentPin, String newPin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/updatePin'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'userId': userId,
          'current_pin': currentPin,
          'new_pin': newPin,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to update PIN');
      }
    } catch (e) {
      rethrow;
    }
  }
}
