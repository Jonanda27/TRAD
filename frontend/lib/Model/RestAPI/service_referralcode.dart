import 'dart:convert';
import 'package:http/http.dart' as http;

class ReferralService {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // Ganti dengan URL API sebenarnya

  // Mendapatkan semua kode referral
  Future<List<dynamic>> getAllReferralCodes() async {
    final response = await http.get(Uri.parse('$baseUrl/referral'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load referral codes');
    }
  }

  // Membuat referral code baru
  Future<Map<String, dynamic>> createReferralCode(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/referral'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'id': userId,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create referral code: ${json.decode(response.body)['error']}');
    }
  }

  // Mengecek referral code
  Future<Map<String, dynamic>> checkReferralCode(String referralCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/referral/check/$referralCode'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Referral Code not available');
    }
  }

  // Menghapus referral code berdasarkan ID
  Future<void> deleteReferralCode(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/referral/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete referral code');
    }
  }
}
