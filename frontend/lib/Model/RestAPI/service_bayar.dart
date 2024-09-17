import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<Map<String, dynamic>> getPembeliTransaksi(int id) async {
    final String url = '$baseUrl/transaksi/pembeli/$id';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Jika berhasil, kembalikan data dalam bentuk JSON
        return jsonDecode(response.body);
      } else {
        // Jika ada kesalahan, kembalikan pesan error
        return {'error': 'Gagal mendapatkan data. Kode status: ${response.statusCode}'};
      }
    } catch (e) {
      // Jika terjadi kesalahan saat permintaan
      return {'error': 'Terjadi kesalahan: $e'};
    }
  }

   Future<Map<String, dynamic>> transaksiBayar(String noNota, int idPembeli) async {
    final String url = '$baseUrl/transaksi-bayar';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'noNota': noNota, 'idPembeli': idPembeli}),
      );

      if (response.statusCode == 200) {
        // If successful, return the data as JSON
        return jsonDecode(response.body);
      } else {
        // If there is an error, return an error message
        return {'error': 'Gagal melakukan transaksi. Kode status: ${response.statusCode}'};
      }
    } catch (e) {
      // If there is an error during the request
      return {'error': 'Terjadi kesalahan: $e'};
    }
  }

   Future<Map<String, dynamic>> transaksiBayarSelanjutnya(
      String noNota, int idPembeli, String pin, bool useVoucher) async {
    final String url = '$baseUrl/transaksi-bayar-selanjutnya';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'noNota': noNota,
          'idPembeli': idPembeli,
          'pin': pin,
          'useVoucher': useVoucher
        }),
      );

      if (response.statusCode == 200) {
        // If successful, return the data as JSON
        return jsonDecode(response.body);
      } else {
        // If there is an error, return an error message
        return {'error': 'Gagal melakukan transaksi selanjutnya. Kode status: ${response.statusCode}'};
      }
    } catch (e) {
      // If there is an error during the request
      return {'error': 'Terjadi kesalahan: $e'};
    }
  }
}
