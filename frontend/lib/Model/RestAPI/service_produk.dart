import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:trad/Model/produk_model.dart';

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
  required String hashtag,
  required String deskripsiProduk,
  required List<int> kategori,
}) async {
  final uri = Uri.parse('$baseUrl/tambahProduk');
  final request = http.MultipartRequest('POST', uri)
    ..fields['idToko'] = idToko.toString()
    ..fields['namaProduk'] = namaProduk
    ..fields['harga'] = harga.toString()
    ..fields['bagiHasil'] = bagiHasil.toString()
    ..fields['voucher'] = voucher?.toString() ?? ''
    ..fields['kodeProduk'] = kodeProduk
    ..fields['hashtag'] = hashtag
    ..fields['deskripsiProduk'] = deskripsiProduk;

  // Send categories as separate fields
  for (int i = 0; i < kategori.length; i++) {
    request.fields['kategori[$i]'] = kategori[i].toString();
  }

  if (fotoProduk != null) {
    final image = await http.MultipartFile.fromPath('fotoProduk[]', fotoProduk.path);
    request.files.add(image);
  }

  final response = await request.send();

  final responseBody = await response.stream.bytesToString();
  final responseJson = json.decode(responseBody);

  if (response.statusCode == 201) {
    return responseJson;
  } else {
    throw Exception('Failed to add product: ${responseJson['message']}');
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
