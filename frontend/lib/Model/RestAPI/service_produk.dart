import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:trad/Model/produk_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProdukService {
  final String baseUrl =
      'http://127.0.0.1:8000/api'; // Ganti dengan URL API Anda

  Future<Map<String, dynamic>> tambahProduk({
    required String? idToko,
    required List<XFile> fotoProduk,
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

    request.fields['idToko'] = idToko.toString();
    request.fields['namaProduk'] = namaProduk;
    request.fields['harga'] = harga.toString();
    request.fields['bagiHasil'] = bagiHasil.toString();
    request.fields['voucher'] = voucher?.toString() ?? '';
    request.fields['kodeProduk'] = kodeProduk;
    request.fields['deskripsiProduk'] = deskripsiProduk;

    // Menambahkan hashtag dengan indeks
    for (int i = 0; i < hashtag.length; i++) {
      request.fields['hashtag[$i]'] = hashtag[i];
    }

    // Menambahkan kategori dengan indeks
    for (int i = 0; i < kategori.length; i++) {
      request.fields['kategori[$i]'] = kategori[i].toString();
    }

    // Handle multiple images
    for (var image in fotoProduk) {
      var fileBytes = await image.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'fotoProduk[]',
        fileBytes,
        filename: image.name,
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
    required String idToko,
    required String namaProduk,
    required double harga,
    double? bagiHasil,
    double? voucher,
    String? kodeProduk,
    List<String>? hashtag,
    String? deskripsiProduk,
    required List<int> kategori,
    List<XFile>? newFotoProduk,
    List<String>? existingFotoProduk,
  }) async {
    final url = Uri.parse('$baseUrl/ubahProduk/$idProduk');
    final request = http.MultipartRequest('POST', url);

    request.headers['Content-Type'] = 'application/json';
    request.fields['idToko'] = idToko.toString();
    request.fields['namaProduk'] = namaProduk;
    request.fields['harga'] = harga.toString();
    request.fields['_method'] = 'PUT';
    if (bagiHasil != null) request.fields['bagiHasil'] = bagiHasil.toString();
    if (voucher != null) request.fields['voucher'] = voucher.toString();
    if (kodeProduk != null) request.fields['kodeProduk'] = kodeProduk;
    if (hashtag != null) {
      for (int i = 0; i < hashtag.length; i++) {
        request.fields['hashtag[$i]'] = hashtag[i];
      }
    }
    if (deskripsiProduk != null)
      request.fields['deskripsiProduk'] = deskripsiProduk;
    for (int i = 0; i < kategori.length; i++) {
      request.fields['kategori[$i]'] = kategori[i].toString();
    }

    // Mengirim foto produk yang sudah ada
    if (existingFotoProduk != null) {
      for (int i = 0; i < existingFotoProduk.length; i++) {
        request.fields['existingFotoProduk[$i]'] = existingFotoProduk[i];
      }
    }

    // Mengirim foto produk baru
    if (newFotoProduk != null) {
      for (int i = 0; i < newFotoProduk.length; i++) {
        if (kIsWeb) {
          // Handling for web
          var bytes = await newFotoProduk[i].readAsBytes();
          var file = http.MultipartFile.fromBytes(
            'newFotoProduk[$i]',
            bytes,
            filename: newFotoProduk[i].name,
          );
          request.files.add(file);
        } else {
          // Handling for mobile
          var file = await http.MultipartFile.fromPath(
              'newFotoProduk[$i]', newFotoProduk[i].path);
          request.files.add(file);
        }
      }
    }

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final responseJson = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return responseJson;
      } else {
        throw Exception('Failed to update product: ${responseJson['message']}');
      }
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
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

  Future<List<Produk>> fetchProdukByTokoId(int idToko) async {
    final response =
        await http.get(Uri.parse('$baseUrl/indeksProdukToko/$idToko'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Produk> produkList =
          data.map((item) => Produk.fromJson(item)).toList();
      return produkList;
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Map<String, dynamic>> ubahStatusProduk({
    required int produkId,
    required bool status,
  }) async {
    final url = Uri.parse('$baseUrl/produk/ubahStatus');
    final headers = {'Content-Type': 'application/json'};

    // Mempersiapkan body request
    final body = json.encode({
      'produk_id': produkId,
      'status': status,
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('Response status: ${response.statusCode}');
      print(
          'Response body: ${response.body}'); // Debugging untuk melihat isi respons

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to change product status: ${response.body}');
      }
    } catch (e) {
      print('Error while changing product status: $e');
      throw Exception('Failed to change product status: $e');
    }
  }

  Future<List<Produk>> cariFilterProdukPerToko({
  required int idToko,
  String? namaProduk,
  List<String>? kategori,
  int? rating,
}) async {
  final uri = Uri.parse('$baseUrl/toko/$idToko/cariFilterProduk');

  // Mempersiapkan query parameters untuk filter
  Map<String, dynamic> queryParams = {};

  if (namaProduk != null) {
    queryParams['namaProduk'] = namaProduk;
  }
  if (kategori != null && kategori.isNotEmpty) {
    queryParams['kategori[]'] = kategori.join(','); // Gabungkan kategori jadi string
  }
  if (rating != null) {
    queryParams['rating'] = rating.toString();
  }

  final uriWithParams = uri.replace(queryParameters: queryParams);

  try {
    final response = await http.get(uriWithParams);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Produk.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load filtered products');
    }
  } catch (e) {
    throw Exception('Error fetching filtered products: $e');
  }
}

   
}
