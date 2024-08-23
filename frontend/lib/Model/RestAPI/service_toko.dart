import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/toko_model.dart';
import 'package:http_parser/http_parser.dart';

class TokoService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

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
    required Map<String, String> kategoriToko, // Updated to Map<String, String>
    required String alamatToko,
    required String? provinsiToko,
    required String? kotaToko,
    required String nomorTeleponToko,
    required String emailToko,
    String? deskripsiToko,
    required Map<String, String> jamOperasional,
    List<Uint8List>? fotoProfileToko,
    List<Uint8List>? fotoToko,
  }) async {
    final Uri url = Uri.parse('$baseUrl/tambahToko');

    final request = http.MultipartRequest('POST', url);

    // Add non-file fields
    request.fields['userId'] = userId.toString();
    request.fields['namaToko'] = namaToko;
    request.fields['alamatToko'] = alamatToko;
    request.fields['provinsiToko'] = provinsiToko!;
    request.fields['kotaToko'] = kotaToko!;
    request.fields['nomorTeleponToko'] = nomorTeleponToko;
    request.fields['emailToko'] = emailToko;
    request.fields['deskripsiToko'] = deskripsiToko ?? '';

    // Add category fields in the desired format
    kategoriToko.forEach((key, value) {
      request.fields[key] = value;
    });

    // Add operational hours
    request.fields.addAll(jamOperasional);

    // Add profile photo if available
    if (fotoProfileToko != null && fotoProfileToko.isNotEmpty) {
      request.files.add(http.MultipartFile.fromBytes(
        'fotoProfileToko',
        fotoProfileToko[0],
        filename: 'fotoProfileToko.jpg',
      ));
    }

    // Add store photos if available
    if (fotoToko != null && fotoToko.isNotEmpty) {
      for (var i = 0; i < fotoToko.length; i++) {
        request.files.add(http.MultipartFile.fromBytes(
          'fotoToko[]',
          fotoToko[i],
          filename: 'fotoToko_$i.jpg',
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

  Future<Map<String, dynamic>> ubahToko({
    required int idToko,
    required String namaToko,
    required List<String> kategoriToko,
    required String alamatToko,
    required String provinsiToko,
    required String kotaToko,
    required String nomorTeleponToko,
    required String emailToko,
    String? deskripsiToko,
    required Map<String, String> jamOperasional,
    XFile? fotoProfileToko,
    List<XFile>? newFotoToko,
    List<String>? existingFotoToko,
  }) async {
    final url = Uri.parse('$baseUrl/ubahToko/$idToko');
    final request = http.MultipartRequest('POST', url);

    request.headers['Content-Type'] = 'application/json';
    request.fields['namaToko'] = namaToko;
    request.fields['alamatToko'] = alamatToko;
    request.fields['provinsiToko'] = provinsiToko;
    request.fields['kotaToko'] = kotaToko;
    request.fields['nomorTeleponToko'] = nomorTeleponToko;
    request.fields['emailToko'] = emailToko;
    request.fields['_method'] = 'PUT';
    if (deskripsiToko != null) request.fields['deskripsiToko'] = deskripsiToko;
    for (int i = 0; i < kategoriToko.length; i++) {
      request.fields['kategoriToko[$i]'] = kategoriToko[i].toString();
    }
    request.fields.addAll(jamOperasional);

    // Mengirim foto profil toko yang baru
    if (fotoProfileToko != null) {
      if (kIsWeb) {
        var bytes = await fotoProfileToko.readAsBytes();
        var file = http.MultipartFile.fromBytes(
          'fotoProfileToko',
          bytes,
          filename: fotoProfileToko.name,
        );
        request.files.add(file);
      } else {
        var file = await http.MultipartFile.fromPath(
          'fotoProfileToko',
          fotoProfileToko.path,
        );
        request.files.add(file);
      }
    }

    // Mengirim foto toko yang sudah ada
    if (existingFotoToko != null) {
      for (int i = 0; i < existingFotoToko.length; i++) {
        request.fields['existingFotoToko[$i]'] = existingFotoToko[i];
      }
    }

    // Mengirim foto toko baru
    if (newFotoToko != null) {
      for (int i = 0; i < newFotoToko.length; i++) {
        if (kIsWeb) {
          var bytes = await newFotoToko[i].readAsBytes();
          var file = http.MultipartFile.fromBytes(
            'newFotoToko[$i]',
            bytes,
            filename: newFotoToko[i].name,
          );
          request.files.add(file);
        } else {
          var file = await http.MultipartFile.fromPath(
            'newFotoToko[$i]',
            newFotoToko[i].path,
          );
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
        throw Exception('Failed to update toko: ${responseJson['message']}');
      }
    } catch (e) {
      throw Exception('Failed to update toko: $e');
    }
  }
}
