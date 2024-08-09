import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trad/Model/toko_model.dart'; // Your model file

class TokoService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  TokoService();

  Future<List<TokoModel>> fetchStores() async {
    final response = await http.get(Uri.parse('$baseUrl/getListToko'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<TokoModel> stores = data.map((json) => TokoModel.fromJson(json)).toList();
      return stores;
    } else {
      throw Exception('Failed to load stores');
    }
  }

  Future<TokoModel> fetchStoreById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/stores/$id'));

    if (response.statusCode == 200) {
      return TokoModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load store');
    }
  }
}
