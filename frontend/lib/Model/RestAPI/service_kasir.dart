import 'dart:convert';
import 'package:http/http.dart' as http;

class ServiceKasir {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<Map<String, dynamic>> getTransaksiByToko(String idToko) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transaksi/toko/$idToko'),
      );

      if (response.statusCode == 200) {
        // Success: Parse the JSON data
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        // Not found or empty transactions
        return jsonDecode(response.body);
      } else {
        // Handle other status codes
        return {
          'error': 'Failed to fetch data. Status Code: ${response.statusCode}'
        };
      }
    } catch (e) {
      // Handle exceptions
      return {'error': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> getRiwayatTransaksi(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/daftarTransaksiPerUser/$userId'),
      );

      if (response.statusCode == 200) {
        // Parse the response if successful
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        // Handle not found response
        return {'error': 'Transaksi tidak ditemukan untuk user ini'};
      } else {
        // Handle other error codes
        return {
          'error': 'Gagal mengambil riwayat transaksi. Kode Status: ${response.statusCode}'
        };
      }
    } catch (e) {
      // Handle network or other errors
      return {'error': 'Terjadi kesalahan: $e'};
    }
  }

   Future<Map<String, dynamic>> listProdukToko(
    String idToko, // Parameter pertama
    List<Map<String, dynamic>> barang, // Parameter kedua
    double biayaTambahanTunai, // Parameter ketiga
    double biayaTambahanVoucher // Parameter keempat
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/listProdukToko'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'idToko': idToko,
          'barang': barang,
          'biayaTambahanTunai': biayaTambahanTunai,
          'biayaTambahanVoucher': biayaTambahanVoucher,
        }),
      );

      if (response.statusCode == 201) {
        // Success: Parse the JSON data
        return jsonDecode(response.body);
      } else {
        // Handle other status codes
        return {
          'error': 'Failed to process transaction. Status Code: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

    Future<Map<String, dynamic>> getDetailNotaBayarListProduk(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/detailNotaBayarListProduk/$id'),
      );

      if (response.statusCode == 200) {
        // Jika berhasil, parse JSON data
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        // Jika transaksi tidak ditemukan
        return {'error': 'Transaksi tidak ditemukan'};
      } else {
        // Tangani status kode lain
        return {
          'error': 'Gagal mengambil data. Status Kode: ${response.statusCode}'
        };
      }
    } catch (e) {
      // Tangani exception
      return {'error': 'Terjadi kesalahan: $e'};
    }
  }

   Future<Map<String, dynamic>> transaksiApprove(String noNota) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transaksi-approve'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'noNota': noNota,
        }),
      );

      if (response.statusCode == 200) {
        // Jika sukses, parse JSON data
        return jsonDecode(response.body);
      } else {
        // Tangani status kode lain
        return {
          'error': 'Failed to approve transaction. Status Code: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

  // Service untuk menolak transaksi
  Future<Map<String, dynamic>> transaksiReject(String noNota) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transaksi-reject'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'noNota': noNota,
        }),
      );

      if (response.statusCode == 200) {
        // Jika sukses, parse JSON data
        return jsonDecode(response.body);
      } else {
        // Tangani status kode lain
        return {
          'error': 'Failed to reject transaction. Status Code: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

   Future<Map<String, dynamic>> listBayarInstan(
    String idToko,
    double bagiHasilPersenan,
    double bagiHasil,
    double totalBelanjaTunai,
    double totalBelanjaVoucher,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/listBayarInstan'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'idToko': idToko,
          'bagiHasilPersenan': bagiHasilPersenan,
          'bagiHasil': bagiHasil,
          'totalBelanjaTunai': totalBelanjaTunai,
          'totalBelanjaVoucher': totalBelanjaVoucher,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'error': 'Failed to process instant payment. Status Code: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

  // Metode untuk mendapatkan detail nota bayar instan
  Future<Map<String, dynamic>> getDetailNotaBayarInstan(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/detailNotaBayarInstan/$id'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return jsonDecode(response.body);
      } else {
        return {
          'error': 'Failed to fetch data. Status Code: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }
}
