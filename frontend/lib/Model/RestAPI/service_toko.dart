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

  // Profile Toko service to fetch store profile details
  Future<Map<String, dynamic>> profileToko(int idToko) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/profileToko/$idToko'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('Response data: $responseData'); // Log the response
        return responseData;
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in profileToko: $e'); // Log any errors
      rethrow;
    }
  }

  Future<Map<String, dynamic>> tambahToko({
    required int userId,
    required String namaToko,
    required Map<String, String> kategoriToko,
    required String alamatToko,
    required String? provinsiToko,
    required String? kotaToko,
    required String nomorTeleponToko,
    required String emailToko,
    String? deskripsiToko,
    required Map<String, String> jamOperasional,
    List<Uint8List>? fotoProfileToko,
    List<Uint8List>? fotoToko,
    Uint8List? fotoQrToko, // Pastikan parameter untuk fotoQrToko ada di sini
  }) async {
    final Uri url = Uri.parse('$baseUrl/tambahToko');

    final request = http.MultipartRequest('POST', url);

    request.fields['userId'] = userId.toString();
    request.fields['namaToko'] = namaToko;
    request.fields['alamatToko'] = alamatToko;
    request.fields['provinsiToko'] = provinsiToko!;
    request.fields['kotaToko'] = kotaToko!;
    request.fields['nomorTeleponToko'] = nomorTeleponToko;
    request.fields['emailToko'] = emailToko;
    request.fields['deskripsiToko'] = deskripsiToko ?? '';

    kategoriToko.forEach((key, value) {
      request.fields[key] = value;
    });

    request.fields.addAll(jamOperasional);

    if (fotoProfileToko != null && fotoProfileToko.isNotEmpty) {
      request.files.add(http.MultipartFile.fromBytes(
        'fotoProfileToko',
        fotoProfileToko[0],
        filename: 'fotoProfileToko.jpg',
      ));
    }

    if (fotoQrToko != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'fotoQrToko',
        fotoQrToko, // Sertakan foto QR Toko di sini
        filename: 'fotoQrToko.jpg',
      ));
    }

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
        return {'status': 'success', 'message': result['message']};
      } else {
        return {
          'status': 'error',
          'error': result['error'] ?? 'Terjadi kesalahan saat menambahkan toko'
        };
      }
    } catch (e) {
      return {'status': 'error', 'error': 'Terjadi kesalahan: $e'};
    }
  }

Future<List<TokoModel>> cariToko({
  required int userId,
  String? namaToko,
  String? kategori,
  String? alamatToko,
  String? provinsiToko,
  String? kotaToko,
  String? jamOperasional,
  String? deskripsiToko,
}) async {
  try {
    final Uri url = Uri.parse('$baseUrl/cariTokoPenjual/$userId');

    final Map<String, String> params = {};

    if (namaToko != null && namaToko.isNotEmpty) {
      params['namaToko'] = namaToko;
    }
    if (kategori != null && kategori.isNotEmpty) {
      params['kategori'] = kategori;
    }
    if (alamatToko != null && alamatToko.isNotEmpty) {
      params['alamatToko'] = alamatToko;
    }
    if (provinsiToko != null && provinsiToko.isNotEmpty) {
      params['provinsiToko'] = provinsiToko;
    }
    if (kotaToko != null && kotaToko.isNotEmpty) {
      params['kotaToko'] = kotaToko;
    }
    if (jamOperasional != null && jamOperasional.isNotEmpty) {
      params['jamOperasional'] = jamOperasional;
    }
    if (deskripsiToko != null && deskripsiToko.isNotEmpty) {
      params['deskripsiToko'] = deskripsiToko;
    }

    final response = await http.post(url, body: params);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Extract 'data' or main list from the response
      List<dynamic> storesJson = responseData['data'] ?? responseData['items'] ?? responseData['results'] ?? [];

      List<TokoModel> tokoList = storesJson.map((json) => TokoModel.fromJson(json)).toList();

      return tokoList;
    } else {
      throw Exception('Failed to search stores: ${response.statusCode}');
    }
  } catch (e) {
    print('Error in cariToko: $e');
    throw Exception('Failed to search stores: $e');
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

  Future<List<Map<String, dynamic>>> getProvinces() async {
    final apiKey =
        'fb48784ac7bbce1f44e397c0849472f5'; // Ganti dengan API Key Anda dari RajaOngkir
    final response = await http.get(
      Uri.parse('https://api.rajaongkir.com/starter/province'),
      headers: {
        'key': apiKey, // Sertakan API Key di header permintaan
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['rajaongkir']['status']['code'] == 200) {
        List provinces = data['rajaongkir']['results'];
        return provinces
            .map((province) =>
                {'id': province['province_id'], 'nama': province['province']})
            .toList();
      } else {
        throw Exception(
            'Failed to load provinces: ${data['rajaongkir']['status']['description']}');
      }
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  Future<List<Map<String, dynamic>>> getCities(String provinceId) async {
    final apiKey =
        'fb48784ac7bbce1f44e397c0849472f5'; // Ganti dengan API Key Anda dari RajaOngkir
    final response = await http.get(
      Uri.parse('https://api.rajaongkir.com/starter/city?province=$provinceId'),
      headers: {
        'key': apiKey, // Sertakan API Key di header permintaan
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['rajaongkir']['status']['code'] == 200) {
        List cities = data['rajaongkir']['results'];
        return cities
            .map((city) => {'id': city['city_id'], 'nama': city['city_name']})
            .toList();
      } else {
        throw Exception(
            'Failed to load cities: ${data['rajaongkir']['status']['description']}');
      }
    } else {
      throw Exception('Failed to load cities');
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
    XFile? newFotoProfileToko,
    String? existingFotoProfileToko,
    XFile? newFotoQrToko,
    String? existingFotoQrToko,
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
      request.fields['kategoriToko[$i]'] = kategoriToko[i];
    }

    request.fields.addAll(jamOperasional);

    if (newFotoProfileToko != null) {
      if (kIsWeb) {
        var bytes = await newFotoProfileToko.readAsBytes();
        var file = http.MultipartFile.fromBytes(
          'fotoProfileToko',
          bytes,
          filename: newFotoProfileToko.name,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(file);
      } else {
        var file = await http.MultipartFile.fromPath(
          'fotoProfileToko',
          newFotoProfileToko.path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(file);
      }
    } else if (existingFotoProfileToko != null) {
      request.fields['fotoProfileToko'] = existingFotoProfileToko;
    }

     if (newFotoQrToko != null) {
   if (kIsWeb) {
     var bytes = await newFotoQrToko.readAsBytes();
     var file = http.MultipartFile.fromBytes(
       'fotoQrToko', // Ganti dengan nama parameter yang benar
       bytes,
       filename: newFotoQrToko.name,
       contentType: MediaType('image', 'jpeg'),
     );
     request.files.add(file);
   } else {
     var file = await http.MultipartFile.fromPath(
       'fotoQrToko', // Ganti dengan nama parameter yang benar
       newFotoQrToko.path,
       contentType: MediaType('image', 'jpeg'),
     );
     request.files.add(file);
   }
 } else if (existingFotoQrToko != null) {
   request.fields['fotoQrToko'] = existingFotoQrToko;
 }


    if (newFotoToko != null) {
      for (int i = 0; i < newFotoToko.length; i++) {
        if (kIsWeb) {
          var bytes = await newFotoToko[i].readAsBytes();
          var file = http.MultipartFile.fromBytes(
            'newFotoToko[$i]',
            bytes,
            filename: newFotoToko[i].name,
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(file);
        } else {
          var file = await http.MultipartFile.fromPath(
            'newFotoToko[$i]',
            newFotoToko[i].path,
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(file);
        }
      }
    }

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      print(jsonDecode(responseData));
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
