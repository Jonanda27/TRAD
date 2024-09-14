import 'dart:convert';
import 'package:http/http.dart' as http;

class BankService {
  // Define the base URL here
  final String baseUrl = 'http://192.168.18.219:8000/api';

  // Constructor
  BankService();

  Future<Map<String, dynamic>> addBankAccount(int userId, String pin, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tambahBank'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'pin': pin,
        ...data,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add bank account: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateBankAccount(int userId, String pin, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/ubahBank/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'pin': pin,
        ...data,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update bank account: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getBankAccount(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/bank/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'][0];
    } else {
      throw Exception('Failed to retrieve bank account: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getLayananPoin(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/layananPoin/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to retrieve layanan poin: ${response.body}');
    }
  }
}
