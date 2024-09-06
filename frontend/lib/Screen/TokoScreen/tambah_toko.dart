import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_toko.dart';
import 'package:trad/Screen/TokoScreen/list_toko.dart';

class TambahTokoScreen extends StatefulWidget {
  @override
  _TambahTokoScreenState createState() => _TambahTokoScreenState();
}

class _TambahTokoScreenState extends State<TambahTokoScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _jamOperasional = List.generate(7, (index) {
    return {
      'hari': _getDayName(index),
      'jamBuka': '09:00',
      'jamTutup': '21:00',
      'statusBuka': false,
    };
  });
  final TextEditingController _namaTokoController = TextEditingController();
  final TextEditingController _alamatTokoController = TextEditingController();
  final TextEditingController _nomorTeleponTokoController =
      TextEditingController();
  final TextEditingController _emailTokoController = TextEditingController();
  final TextEditingController _deskripsiTokoController =
      TextEditingController();
  List<Uint8List> _fotoProfileToko = [];
  List<Uint8List> _fotoToko = [];
  final List<String> _selectedCategories = [];
  List<String> availableCategories = ['Makanan', 'Pakaian', 'Minuman'];
  String? _selectedProvinsi;
  String? _selectedKota;
  String? _selectedCategory;
  bool _hasCategories = false;
  bool _isSubmitting = false;
  bool _showCategoryError = false;
  Uint8List? _fotoQrToko;

  final List<String> _provinsiOptions = [
    'Provinsi 1',
    'Provinsi 2',
    // Tambahkan opsi provinsi lainnya
  ];

  final List<String> _kotaOptions = [
    'Kota 1',
    'Kota 2',
    // Tambahkan opsi kota lainnya
  ];

Future<void> _pickImage({bool isProfile = false, bool isQr = false}) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Memilih satu gambar saja

  if (pickedFile != null) {
    final imageBytes = await pickedFile.readAsBytes();

    setState(() {
      if (isProfile) {
        _fotoProfileToko = [imageBytes];
      } else if (isQr) {
        _fotoQrToko = imageBytes; // Pastikan gambar QR toko disimpan dengan benar
      } else {
        _fotoToko.add(imageBytes);
      }
    });
  }
}

  void _removeQrPhoto() {
    setState(() {
      _fotoQrToko = null;
    });
  }

   Future<void> _submitForm() async {
    // Validasi untuk kategori, provinsi, dan kota
    String? categoryError = _validateCategory(); // Validasi kategori
    String? provinceError = _validateProvince(_selectedProvinsi); // Validasi provinsi
    String? cityError = _validateCity(_selectedKota); // Validasi kota

    // Jika semua validasi form berhasil dan tidak ada kesalahan pada kategori, provinsi, dan kota
    if (_formKey.currentState?.validate() ??
        false &&
            categoryError == null &&
            provinceError == null &&
            cityError == null) {
      setState(() {
        _isSubmitting = true; // Mulai proses submit
        _showCategoryError = false; // Tidak ada kesalahan pada kategori
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('id');

        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('User ID tidak ditemukan. Silakan login kembali.')),
          );
          setState(() {
            _isSubmitting = false; // Selesai proses submit
          });
          return;
        }

        final jamOperasionalFields = <String, String>{};
        for (int i = 0; i < _jamOperasional.length; i++) {
          final jam = _jamOperasional[i];
          jamOperasionalFields['jamOperasional[$i][hari]'] = jam['hari'];
          jamOperasionalFields['jamOperasional[$i][jamBuka]'] = jam['jamBuka'];
          jamOperasionalFields['jamOperasional[$i][jamTutup]'] = jam['jamTutup'];
          jamOperasionalFields['jamOperasional[$i][statusBuka]'] = jam['statusBuka'] ? '1' : '0';
        }

        final kategoriTokoFields = <String, String>{};
        for (int i = 0; i < _selectedCategories.length; i++) {
          kategoriTokoFields['kategoriToko[$i]'] = _selectedCategories[i];
        }

        final tokoService = TokoService();
        final result = await tokoService.tambahToko(
          userId: userId,
          namaToko: _namaTokoController.text,
          kategoriToko: kategoriTokoFields,
          alamatToko: _alamatTokoController.text,
          provinsiToko: _selectedProvinsi,
          kotaToko: _selectedKota,
          nomorTeleponToko: _nomorTeleponTokoController.text,
          emailToko: _emailTokoController.text,
          deskripsiToko: _deskripsiTokoController.text,
          jamOperasional: jamOperasionalFields,
          fotoProfileToko: _fotoProfileToko,
          fotoToko: _fotoToko,
          fotoQrToko: _fotoQrToko, // Sertakan foto QR Toko
        );

        // Mengecek status dan menampilkan dialog yang sesuai
        if (result.containsKey('status') && result['status'] == 'success') {
          _showDialog('Success',
              result['message'] ?? 'Toko berhasil ditambahkan', true);
        } else {
          _showDialog(
              'Success', result['message'] ?? 'Gagal menambahkan toko', true);
        }
      } catch (e) {
        _showDialog('Error', 'Terjadi kesalahan: $e', false);
      } finally {
        setState(() {
          _isSubmitting = false; // Selesai proses submit
        });
      }
    } else {
      // Jika ada validasi yang gagal, atur state untuk menampilkan kesalahan kategori
      setState(() {
        _showCategoryError = categoryError != null; // Tampilkan kesalahan jika kategori kosong
      });
    }
  }

  void _showDialog(String title, String content, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF337F8F),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (isSuccess) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ListTokoScreen()),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    content,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Redirect to ListTokoScreen after 2 seconds
    if (isSuccess) {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ListTokoScreen()),
        );
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email Toko tidak boleh kosong';
    }
    String pattern = r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor Telepon Toko tidak boleh kosong';
    }
    if (!RegExp(r'^08[0-9]{8,}$').hasMatch(value)) {
      return 'Nomor telepon harus dimulai dengan "08" dan minimal 10 digit';
    }
    return null;
  }

  String? _validateCategory() {
    if (_selectedCategories.isEmpty) {
      return '';
    }
    return null;
  }

  String? _validateProvince(String? value) {
    if (value == null || value.isEmpty) {
      return 'Provinsi toko harus dipilih';
    }
    return null;
  }

  String? _validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kota toko harus dipilih';
    }
    return null;
  }

  void _showCategoryDropdown() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Kategori'),
          content: DropdownButtonFormField<String>(
            value: _selectedCategory,
            items: availableCategories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                if (value != null && !_selectedCategories.contains(value)) {
                  _selectedCategories.add(value);
                }
                _selectedCategory = null;
              });
              Navigator.of(context).pop();
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        );
      },
    );
  }

  void _removeCategory(String category) {
    setState(() {
      _selectedCategories.remove(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Toko',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF006064),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: screenHeight / 3.9,
              color: Color.fromARGB(255, 240, 244, 243),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Background Toko',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _pickImage(isProfile: false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005466),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: const Text(
                            'Unggah',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_fotoToko.isEmpty)
                            Container(
                              width: 100,
                              height: 100,
                            )
                          else
                            ..._fotoToko.map((imageBytes) {
                              return Container(
                                width: 100,
                                height: 100,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                  color: Colors.grey[200],
                                ),
                                child:
                                    Image.memory(imageBytes, fit: BoxFit.cover),
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Info Toko',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => _pickImage(isProfile: true),
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (_fotoProfileToko.isNotEmpty)
                                  ..._fotoProfileToko.map((imageBytes) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.memory(
                                          imageBytes,
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  }).toList()
                                else
                                  const Icon(
                                    Icons.storefront,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade800,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nama Toko',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _namaTokoController,
                                decoration: const InputDecoration(
                                  hintText: 'Contoh: Toko Buku A',
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromRGBO(209, 213, 219, 1)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromRGBO(209, 213, 219, 1)),
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                style: const TextStyle(color: Colors.black),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nama Toko tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Kategori Toko',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: _hasCategories
                                        ? null
                                        : _showCategoryDropdown,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF005466),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                    ),
                                    child: Text(
                                      _hasCategories ? '+' : 'Tambah +',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  if (_showCategoryError) // Tampilkan ikon kesalahan jika tombol simpan ditekan dan kategori kosong
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Icon(
                                        Icons.error_outline,
                                        color: Colors
                                            .red, // Warna ikon merah untuk kesalahan
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: _selectedCategories.map((category) {
                                  return Chip(
                                    label: Text(category),
                                    deleteIcon: const Icon(Icons.delete),
                                    onDeleted: () => _removeCategory(category),
                                  );
                                }).toList(),
                              ),
                              if (_selectedCategories
                                  .isEmpty) // Tampilkan pesan kesalahan jika tidak ada kategori yang dipilih
                                const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alamat Toko',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _alamatTokoController,
                            decoration: InputDecoration(
                              hintText: 'Contoh: Jl. Merdeka No. 123',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD1D5DB),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD1D5DB),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            maxLines: 4,
                            style: const TextStyle(color: Colors.black),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Alamat Toko tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Provinsi Toko',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _selectedProvinsi,
                                items: _provinsiOptions.map((provinsi) {
                                  return DropdownMenuItem<String>(
                                    value: provinsi,
                                    child: Text(provinsi),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedProvinsi = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Pilih Provinsi',
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromRGBO(209, 213, 219, 1)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromRGBO(209, 213, 219, 1)),
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                validator:
                                    _validateProvince, // Validasi untuk provinsi
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kota Toko',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _selectedKota,
                                items: _kotaOptions.map((kota) {
                                  return DropdownMenuItem<String>(
                                    value: kota,
                                    child: Text(kota),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedKota = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Pilih Kota',
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromRGBO(209, 213, 219, 1)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromRGBO(209, 213, 219, 1)),
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateCity, // Validasi untuk kota
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nomor Telepon Toko',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nomorTeleponTokoController,
                          decoration: const InputDecoration(
                            hintText: 'Contoh: 081234567890',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(209, 213, 219, 1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(209, 213, 219, 1)),
                            ),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(color: Colors.black),
                          validator: _validatePhoneNumber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email Toko',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailTokoController,
                          decoration: const InputDecoration(
                            hintText: 'Contoh: tokobukua@gmail.com',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(209, 213, 219, 1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(209, 213, 219, 1)),
                            ),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(color: Colors.black),
                          validator: _validateEmail,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deskripsi Toko',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _deskripsiTokoController,
                            decoration: InputDecoration(
                              hintText: 'Contoh: Toko buku lengkap dan murah',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD1D5DB),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD1D5DB),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            maxLines: 4,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                      const SizedBox(height: 16),
                    const Text(
                      'Foto QR Toko',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _pickImage(isQr: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005466),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: const Text(
                            'Unggah QR Toko',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (_fotoQrToko != null)
                          Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Image.memory(_fotoQrToko!, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _removeQrPhoto,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Jam Operasional',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _jamOperasional.length,
                      itemBuilder: (context, index) {
                        final jam = _jamOperasional[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (jam['hari'] == 'Senin') ...[
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 60.0),
                                          child: Text(
                                            'Buka',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 60.0),
                                          child: Text(
                                            'Tutup',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        jam['hari'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    // Pilihan waktu untuk jam buka
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 0.0),
                                      child: InkWell(
                                        onTap: () async {
                                          TimeOfDay? pickedTime =
                                              await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay(
                                              hour: int.parse(
                                                  jam['jamBuka'].split(":")[0]),
                                              minute: int.parse(
                                                  jam['jamBuka'].split(":")[1]),
                                            ),
                                          );
                                          if (pickedTime != null) {
                                            setState(() {
                                              jam['jamBuka'] =
                                                  "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: 62,
                                          height: 28,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDBE7E4),
                                            borderRadius:
                                                BorderRadius.circular(6.0),
                                          ),
                                          child: Text(
                                            jam['jamBuka'],
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Icon(Icons.remove,
                                          color: Colors.black),
                                    ),
                                    // Pilihan waktu untuk jam tutup
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 0.0),
                                      child: InkWell(
                                        onTap: () async {
                                          TimeOfDay? pickedTime =
                                              await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay(
                                              hour: int.parse(jam['jamTutup']
                                                  .split(":")[0]),
                                              minute: int.parse(jam['jamTutup']
                                                  .split(":")[1]),
                                            ),
                                          );
                                          if (pickedTime != null) {
                                            setState(() {
                                              jam['jamTutup'] =
                                                  "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: 62,
                                          height: 28,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDBE7E4),
                                            borderRadius:
                                                BorderRadius.circular(6.0),
                                          ),
                                          child: Text(
                                            jam['jamTutup'],
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 22),
                                    Switch(
                                      value: jam['statusBuka'],
                                      onChanged: (value) {
                                        setState(() {
                                          jam['statusBuka'] = value;
                                        });
                                      },
                                      activeColor: Colors.green,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : _submitForm, // Disable tombol jika sedang submit
                      child: const Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSubmitting
                            ? Colors
                                .grey // Warna abu-abu saat tombol di-disable
                            : Color.fromRGBO(
                                36, 75, 89, 1), // Warna tombol normal
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _getDayName(int index) {
    switch (index) {
      case 0:
        return 'Senin';
      case 1:
        return 'Selasa';
      case 2:
        return 'Rabu';
      case 3:
        return 'Kamis';
      case 4:
        return 'Jumat';
      case 5:
        return 'Sabtu';
      case 6:
        return 'Minggu';
      default:
        return '';
    }
  }
}
