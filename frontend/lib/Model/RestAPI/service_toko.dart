import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/toko_model.dart';

class TokoService {
  final String baseUrl =
      'http://127.0.0.1:8000/api'; // Ganti dengan URL API Anda

  Future<List<TokoModel>> fetchStores() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

    if (userId == null) {
      throw Exception('User ID tidak ditemukan');
    }

    final response = await http.get(Uri.parse('$baseUrl/getListToko/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<TokoModel> tokoList =
          body.map((json) => TokoModel.fromJson(json)).toList();
      return tokoList;
    } else {
      throw Exception('Gagal mengambil data toko');
    }
  }

  Future<Map<String, dynamic>> tambahToko({
    required int userId,
    required String namaToko,
    required String kategoriToko,
    required String alamatToko,
    required String provinsiToko,
    required String kotaToko,
    required String nomorTeleponToko,
    required String emailToko,
    String? deskripsiToko,
    required Map<String, String>
        jamOperasional, // Changed to Map<String, String>
    List<Uint8List>? fotoProfileToko,
    List<Uint8List>? fotoToko,
  }) async {
    final Uri url = Uri.parse('$baseUrl/tambahToko');

    final request = http.MultipartRequest('POST', url);

    // Tambahkan fields yang bukan file
    request.fields['userId'] = userId.toString();
    request.fields['namaToko'] = namaToko;
    request.fields['kategoriToko'] = kategoriToko;
    request.fields['alamatToko'] = alamatToko;
    request.fields['provinsiToko'] = provinsiToko;
    request.fields['kotaToko'] = kotaToko;
    request.fields['nomorTeleponToko'] = nomorTeleponToko;
    request.fields['emailToko'] = emailToko;
    request.fields['deskripsiToko'] = deskripsiToko ?? '';

    // Tambahkan field untuk jam operasional
    request.fields.addAll(jamOperasional);

    // Tambahkan foto profil jika ada
    if (fotoProfileToko != null && fotoProfileToko.isNotEmpty) {
      final photo = fotoProfileToko[0]; // Mengambil foto profil pertama
      request.files.add(http.MultipartFile.fromBytes(
        'fotoProfileToko',
        photo,
        filename: 'fotoProfileToko.jpg',
      ));
    }

    // Tambahkan foto toko jika ada
    if (fotoToko != null && fotoToko.isNotEmpty) {
      for (var foto in fotoToko) {
        request.files.add(http.MultipartFile.fromBytes(
          'fotoToko[]',
          foto,
          filename: 'fotoToko.jpg',
        ));
      }
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> result = jsonDecode(responseBody);

      if (response.statusCode == 201) {
        return {'message': result['message']};
      } else {
        return {
          'error': result['error'] ?? 'Terjadi kesalahan saat menambahkan toko'
        };
      }
    } catch (e) {
      return {'error': 'Terjadi kesalahan: $e'};
    }
  }

  Future<void> hapusToko(int tokoId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final uri = Uri.parse('$baseUrl/hapusToko/$tokoId');
      final response = await http.delete(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        print('Toko berhasil dihapus');
      } else {
        print('Gagal menghapus toko: ${response.body}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }
}
