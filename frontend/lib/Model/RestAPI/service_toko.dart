import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/toko_model.dart';

class TokoService {
  final String baseUrl = 'http://127.0.0.1:8000/api'; // Ganti dengan URL API Anda

  Future<List<TokoModel>> fetchStores() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

    if (userId == null) {
      throw Exception('User ID tidak ditemukan');
    }

    final response = await http.get(Uri.parse('$baseUrl/getListToko/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<TokoModel> tokoList = body.map((json) => TokoModel.fromJson(json)).toList();
      return tokoList;
    } else {
      throw Exception('Gagal mengambil data toko');
    }
  }
}
