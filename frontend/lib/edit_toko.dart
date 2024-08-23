import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trad/Model/RestAPI/service_toko.dart';
import 'package:trad/Model/toko_model.dart';
import 'package:trad/list_toko.dart';

class UbahTokoScreen extends StatefulWidget {
  final TokoModel toko;
  final int idToko;

  UbahTokoScreen({required this.toko, required this.idToko});

  @override
  _UbahTokoScreenState createState() => _UbahTokoScreenState();
}

class _UbahTokoScreenState extends State<UbahTokoScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<Map<String, dynamic>> _jamOperasional;
  late TextEditingController _namaTokoController;
  late TextEditingController _alamatTokoController;
  late TextEditingController _nomorTeleponTokoController;
  late TextEditingController _emailTokoController;
  late TextEditingController _deskripsiTokoController;
  List<Uint8List> _fotoProfileToko = [];
  List<Uint8List> _fotoToko = [];
  List<String> _selectedCategories = [];
  String? _selectedProvinsi;
  String? _selectedKota;
  String? _selectedCategory;
  bool _hasCategories = false;

  final List<String> availableCategories = ['Makanan', 'Pakaian', 'Minuman'];
  final List<String> _provinsiOptions = ['Provinsi 1', 'Provinsi 2'];
  final List<String> _kotaOptions = ['Kota 1', 'Kota 2'];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data
    _namaTokoController = TextEditingController(text: widget.toko.namaToko);
    _alamatTokoController = TextEditingController(text: widget.toko.alamatToko);
    _nomorTeleponTokoController =
        TextEditingController(text: widget.toko.nomorTeleponToko);
    _emailTokoController = TextEditingController(text: widget.toko.emailToko);
    _deskripsiTokoController =
        TextEditingController(text: widget.toko.deskripsiToko);
    _selectedProvinsi = widget.toko.provinsiToko;
    _selectedKota = widget.toko.kotaToko;
    _selectedCategories = widget.toko.kategoriToko.values.toList();

    // Initialize operational hours based on existing data
    _jamOperasional = widget.toko.jamOperasional.map((jam) {
      return {
        'hari': jam.hari,
        'jamBuka': jam.jamBuka.substring(0, 5), // Mengambil format "HH:mm"
        'jamTutup': jam.jamTutup.substring(0, 5), // Mengambil format "HH:mm"
        'statusBuka': jam.statusBuka == 1, // Convert to boolean
      };
    }).toList();

    // Load initial profile photo if exists
    if (widget.toko.fotoProfileToko != null) {
      _fotoProfileToko
          .add(Uint8List.fromList(base64Decode(widget.toko.fotoProfileToko!)));
    }

    if (widget.toko.fotoToko.isNotEmpty) {
      for (var foto in widget.toko.fotoToko) {
        _fotoToko.add(Uint8List.fromList(base64Decode(foto)));
      }
    }
  }

  Future<void> _pickImage({bool isProfile = false}) async {
    final picker = ImagePicker();
    final pickedFiles = await picker
        .pickMultiImage(); // Menggunakan pickMultiImage untuk pemilihan banyak gambar

    if (pickedFiles != null) {
      for (var pickedFile in pickedFiles) {
        final imageBytes = await pickedFile
            .readAsBytes(); // Menggunakan readAsBytes karena asinkron

        setState(() {
          if (isProfile) {
            _fotoProfileToko = [
              imageBytes
            ]; // Hanya memperbolehkan satu foto profil
          } else {
            _fotoToko.add(imageBytes); // Menambahkan banyak foto toko
          }
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final tokoService = TokoService(); // Gantilah dengan URL API Anda

        final jamOperasionalFields = <String, String>{};
        for (int i = 0; i < _jamOperasional.length; i++) {
          final jam = _jamOperasional[i];
          jamOperasionalFields['jamOperasional[$i][hari]'] = jam['hari'];
          jamOperasionalFields['jamOperasional[$i][jamBuka]'] = jam['jamBuka'];
          jamOperasionalFields['jamOperasional[$i][jamTutup]'] =
              jam['jamTutup'];
          jamOperasionalFields['jamOperasional[$i][statusBuka]'] =
              jam['statusBuka'] ? '1' : '0';
        }

        // Convert kategori toko ke format integer
        final kategoriTokoFields = _selectedCategories;

        // Convert Uint8List images to XFile for profile photo
        XFile? profilePhoto;
        if (_fotoProfileToko.isNotEmpty) {
          profilePhoto = XFile.fromData(_fotoProfileToko[0]);
        }

        // Convert Uint8List images to XFile for toko photos
        List<XFile>? newTokoPhotos;
        if (_fotoToko.isNotEmpty) {
          newTokoPhotos =
              _fotoToko.map((foto) => XFile.fromData(foto)).toList();
        }

        final response = await tokoService.ubahToko(
          idToko: widget.idToko,
          namaToko: _namaTokoController.text,
          kategoriToko: kategoriTokoFields,
          alamatToko: _alamatTokoController.text,
          provinsiToko: _selectedProvinsi!,
          kotaToko: _selectedKota!,
          nomorTeleponToko: _nomorTeleponTokoController.text,
          emailToko: _emailTokoController.text,
          deskripsiToko: _deskripsiTokoController.text,
          jamOperasional: jamOperasionalFields,
          fotoProfileToko: profilePhoto,
          newFotoToko: newTokoPhotos,
          existingFotoToko:
              widget.toko.fotoToko, // Mengirim existing photos jika ada
        );

        if (response.containsKey('status') && response['status'] == 'success') {
          // Tampilkan popup berhasil
          _showDialog('Success', 'Toko berhasil diubah', true);
        } else {
          // Tampilkan popup error
          _showDialog(
              'Error', response['message'] ?? 'Gagal mengubah toko', false);
        }
      } catch (e) {
        // Tampilkan popup error
        _showDialog('Error', 'Terjadi kesalahan: $e', false);
      }
    }
  }

  void _showDialog(String title, String content, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
              if (isSuccess) {
                // Redirect ke ListTokoScreen jika berhasil
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ListTokoScreen()),
                );
              }
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
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
          'Ubah Toko',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF006064),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: screenHeight / 3.8,
              color: const Color.fromRGBO(240, 244, 243, 1),
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
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                                color: Colors.grey[200],
                              ),
                              child: const Center(child: Text('Tambah Foto')),
                            )
                          else
                            ..._fotoToko.asMap().entries.map((entry) {
                              int idx = entry.key;
                              Uint8List imageBytes = entry.value;
                              return Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                      color: Colors.grey[200],
                                    ),
                                    child: Image.memory(imageBytes,
                                        fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _fotoToko.removeAt(
                                              idx); // Menghapus gambar dari daftar
                                        });
                                      },
                                      child: const Icon(Icons.remove_circle,
                                          color: Colors.red),
                                    ),
                                  ),
                                ],
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
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.memory(
                                      _fotoProfileToko[0],
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  )
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
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _namaTokoController,
                                decoration: const InputDecoration(
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
                                  fontWeight: FontWeight.bold,
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
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        TextFormField(
                          controller: _alamatTokoController,
                          decoration: const InputDecoration(
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Alamat Toko tidak boleh kosong';
                            }
                            return null;
                          },
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
                                    color: Colors.black, fontSize: 16),
                              ),
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
                                    color: Colors.black, fontSize: 16),
                              ),
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
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        TextFormField(
                          controller: _nomorTeleponTokoController,
                          decoration: const InputDecoration(
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nomor Telepon Toko tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email Toko',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        TextFormField(
                          controller: _emailTokoController,
                          decoration: const InputDecoration(
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email Toko tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deskripsi Toko',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        TextFormField(
                          controller: _deskripsiTokoController,
                          decoration: const InputDecoration(
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
                        print(
                            "Status Buka: ${jam['statusBuka']}"); // Untuk debugging
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (index == 0) ...[
                                Row(
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
                                SizedBox(height: 4),
                              ],
                              Row(
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
                                  SizedBox(
                                    width: 62,
                                    height: 28,
                                    child: TextField(
                                      controller: TextEditingController(
                                          text: jam['jamBuka']),
                                      onChanged: (value) =>
                                          jam['jamBuka'] = value,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.datetime,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFFDBE7E4),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFDBE7E4),
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 4),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child:
                                        Icon(Icons.remove, color: Colors.black),
                                  ),
                                  SizedBox(
                                    width: 62,
                                    height: 28,
                                    child: TextField(
                                      controller: TextEditingController(
                                          text: jam['jamTutup']),
                                      onChanged: (value) =>
                                          jam['jamTutup'] = value,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.datetime,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFFDBE7E4),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFDBE7E4),
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 22),
                                  Switch(
                                    value: jam['statusBuka'] ==
                                        true, // Memastikan boolean
                                    onChanged: (value) {
                                      setState(() {
                                        jam['statusBuka'] = value
                                            ? 1
                                            : 0; // Set 1 jika switch aktif, 0 jika tidak
                                      });
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Simpan Perubahan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006064),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
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
}
