
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:trad/Model/produk_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProdukService {
  final String baseUrl =
      'http://127.0.0.1:8000/api'; // Ganti dengan URL API Anda

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


  print('namaProduk: $namaProduk');
  print('harga: $harga');
  print('bagiHasil: $bagiHasil');
  print('voucher: ${voucher?.toString() ?? 'null'}');
  print('kodeProduk: $kodeProduk');
  print('deskripsiProduk: $deskripsiProduk');
  print('hashtag: ${jsonEncode(hashtag)}');
  print('kategori: ${jsonEncode(kategori)}');


    request.fields['idToko'] = "1";
    request.fields['namaProduk'] = namaProduk;
    request.fields['harga'] = harga.toString();
    request.fields['bagiHasil'] = bagiHasil.toString();
    request.fields['voucher'] = voucher?.toString() ?? '';
    request.fields['kodeProduk'] = kodeProduk;
    request.fields['deskripsiProduk'] = deskripsiProduk;
     // Mengirimkan data hashtag sebagai beberapa field dengan nama 'hashtag[]'
  for (var tag in hashtag) {
    request.fields.addAll({'hashtag[]': tag});
  }

  // Mengirimkan data kategori sebagai beberapa field dengan nama 'kategori[]'
  for (var cat in kategori) {
    request.fields.addAll({'kategori[]': cat.toString()});
  }

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
    print(jsonDecode(responseData));
    return jsonDecode(responseData);
  }

  Future<Produk> getProductById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/produk/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Produk.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load product');
    }
  }

  Future<Map<String, dynamic>> ubahProduk({
    required int idProduk,
    required String? idToko,
    XFile? fotoProduk,
    required String namaProduk,
    required double harga,
    required double bagiHasil,
    double? voucher,
    required String kodeProduk,
    required List<String> hashtag,
    required String deskripsiProduk,
    required List<int> kategori,
  }) async {
    final uri = Uri.parse('$baseUrl/ubahProduk/$idProduk');
    var request = http.MultipartRequest('PUT', uri);

    request.fields['idToko'] = idToko ?? '';
    request.fields['namaProduk'] = namaProduk;
    request.fields['harga'] = harga.toString();
    request.fields['bagiHasil'] = bagiHasil.toString();
    request.fields['voucher'] = voucher?.toString() ?? '';
    request.fields['kodeProduk'] = kodeProduk;
    request.fields['deskripsiProduk'] = deskripsiProduk;
    request.fields['kategori'] =
        jsonEncode(kategori); // Sending kategori as JSON array
    request.fields['hashtag'] =
        jsonEncode(hashtag); // Send hashtags as JSON array

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
