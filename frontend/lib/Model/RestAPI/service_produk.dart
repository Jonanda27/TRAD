import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:trad/Model/produk_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProdukService {
  final String baseUrl = 'http://127.0.0.1:8000/api'; // Ganti dengan URL API Anda

  Future<Map<String, dynamic>> tambahProduk({
    required String? idToko,
    required XFile? fotoProduk,
    required String namaProduk,
    required double harga,
    required double bagiHasil,
    double? voucher,
    required String kodeProduk,
    required List<String> hashtag,
    required String deskripsiProduk,
    required List<int> kategori,
  }) async {
    final uri = Uri.parse('$baseUrl/tambahProduk');
    var request = http.MultipartRequest('POST', uri);

    request.fields['idToko'] = "1";
    request.fields['namaProduk'] = namaProduk;
    request.fields['harga'] = harga.toString();
    request.fields['bagiHasil'] = bagiHasil.toString();
    request.fields['voucher'] = voucher?.toString() ?? '';
    request.fields['kodeProduk'] = kodeProduk;
    // request.fields['hashtag'] = jsonEncode(hashtag);  // Mengirim hashtag sebagai JSON array
    request.fields['deskripsiProduk'] = deskripsiProduk;
    // request.fields['kategori'] = jsonEncode(kategori); // Mengirim kategori sebagai JSON array

    if (fotoProduk != null) {
      var fileBytes = await fotoProduk.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'fotoProduk[]',
        fileBytes,
        filename: fotoProduk.name,
      ));
    }

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    return jsonDecode(responseData);

    // print('Response Status: ${response.statusCode}');
    // print('Response Body: ${responseBody}');
    // print('Response json: ${responseJson}');

    // if (response.statusCode == 201) {
    //   return responseJson;
    // } else {
    //   throw Exception('Failed to add product: ${responseJson['message']}');
    // }
  }

  Future<List<Produk>> fetchProdukList() async {
    final response = await http.get(Uri.parse('$baseUrl/indeksProduk'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Produk.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<Produk>> fetchProdukUser(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/produkUser/$id'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Produk.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user products');
    }
  }

  Future<void> hapusProduk(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/hapusProduk/$id'),
      headers: {
        'Content-Type': 'application/json',
        // Tambahkan headers jika diperlukan, misalnya token autentikasi
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        // Produk berhasil dihapus
      } else {
        throw Exception('Gagal menghapus produk: ${data['message']}');
      }
    } else {
      throw Exception('Gagal menghapus produk');
    }
  }
}


