import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:trad/Model/RestAPI/service_toko.dart';
import 'package:trad/Model/toko_model.dart';
import 'package:trad/Screen/TokoScreen/list_toko.dart';

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
  List<String> _fotoToko = [];
  List<XFile> _newFotoToko = [];
  List<String> _deletedFotoToko = [];
  List<String> _selectedCategories = [];
  String? _selectedProvinsi;
  String? _selectedKota;
  String? _selectedCategory;
  bool _hasCategories = false;
  XFile? _newFotoProfileToko;
  String? _existingFotoProfileToko;
  XFile? _newFotoQrToko;
  String? _existingQrProfileToko;
  bool _isSubmitting = false;
  bool _showCategoryError = false;

  final List<String> availableCategories = ['Makanan', 'Pakaian', 'Minuman'];
  List<Map<String, dynamic>> _provinsiOptions = [];
  List<Map<String, dynamic>> _kotaOptions = [];

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
    _existingFotoProfileToko = widget.toko.fotoProfileToko;
    _existingQrProfileToko = widget.toko.fotoQrToko;

    // Initialize operational hours based on existing data
    _jamOperasional = widget.toko.jamOperasional.map((jam) {
      return {
        'hari': jam.hari,
        'jamBuka': jam.jamBuka.substring(0, 5),
        'jamTutup': jam.jamTutup.substring(0, 5),
        'statusBuka': jam.statusBuka,
      };
    }).toList();

    // Load initial profile photo if exists
    if (widget.toko.fotoProfileToko.isNotEmpty) {
      _fotoProfileToko
          .add(Uint8List.fromList(base64Decode(widget.toko.fotoProfileToko!)));
    }

    if (widget.toko.fotoToko.isNotEmpty) {
      _fotoToko = List.from(widget.toko.fotoToko);
    }

    _fetchProvinces();
  }

  Future<void> _pickImage({bool isProfile = false, bool isQr = false}) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _newFotoProfileToko = pickedFile;
          _existingFotoProfileToko = null;
        } else if (isQr) {
          _newFotoQrToko = pickedFile;
          _existingQrProfileToko = null;
        } else {
          _newFotoToko.add(pickedFile);
        }
      });
    }
  }

  Future<void> _fetchProvinces() async {
    try {
      List<Map<String, dynamic>> provinces = await getProvinces();
      setState(() {
        _provinsiOptions = provinces;
      });

      if (_selectedProvinsi != null) {
        _fetchCities(_selectedProvinsi!);
      }
    } catch (e) {
      print('Failed to fetch provinces: $e');
    }
  }

  Future<void> _fetchCities(String provinceId) async {
    try {
      List<Map<String, dynamic>> cities = await getCities(provinceId);
      setState(() {
        _kotaOptions = cities;
      });
    } catch (e) {
      print('Failed to fetch cities: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getProvinces() async {
    final apiKey = '285e8f140067b2160860aba58549345d';
    final response = await http.get(
      Uri.parse('https://api.rajaongkir.com/starter/province'),
      headers: {
        'key': apiKey,
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
    final apiKey = '285e8f140067b2160860aba58549345d';
    final response = await http.get(
      Uri.parse('https://api.rajaongkir.com/starter/city?province=$provinceId'),
      headers: {
        'key': apiKey,
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

  Widget _buildImageContainer(String base64Image,
      {required VoidCallback onDelete}) {
    Uint8List bytes = base64Decode(base64Image);
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            color: Colors.grey[200],
          ),
          child: Image.memory(bytes, fit: BoxFit.cover),
        ),
        Positioned(
          right: 0,
          child: GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.remove_circle, color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildNewImageContainer(XFile image,
      {required VoidCallback onDelete}) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            color: Colors.grey[200],
          ),
          child: FutureBuilder<Uint8List>(
            future: image.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {
                return kIsWeb
                    ? Image.memory(snapshot.data!, fit: BoxFit.cover)
                    : Image.file(File(image.path), fit: BoxFit.cover);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        Positioned(
          right: 0,
          child: GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.remove_circle, color: Colors.red),
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    String? categoryError = _validateCategory();
    String? provinceError = _validateProvince(_selectedProvinsi);
    String? cityError = _validateCity(_selectedKota);

    if (_formKey.currentState?.validate() ??
        false &&
            categoryError == null &&
            provinceError == null &&
            cityError == null) {
      setState(() {
        _isSubmitting = true;
        _showCategoryError = false;
      });

      try {
        final tokoService = TokoService();

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

        final response = await tokoService.ubahToko(
          idToko: widget.idToko,
          namaToko: _namaTokoController.text,
          kategoriToko: _selectedCategories,
          alamatToko: _alamatTokoController.text,
          provinsiToko: _selectedProvinsi!,
          kotaToko: _selectedKota!,
          nomorTeleponToko: _nomorTeleponTokoController.text,
          emailToko: _emailTokoController.text,
          deskripsiToko: _deskripsiTokoController.text,
          jamOperasional: jamOperasionalFields,
          newFotoProfileToko: _newFotoProfileToko,
          existingFotoProfileToko: _existingFotoProfileToko,
          newFotoQrToko: _newFotoQrToko,
          existingFotoQrToko: _existingQrProfileToko,
          newFotoToko: _newFotoToko.isNotEmpty ? _newFotoToko : null,
          existingFotoToko: _fotoToko
              .where((foto) => !_deletedFotoToko.contains(foto))
              .toList(),
        );

        if (response.containsKey('status') && response['status'] == 'success') {
          _showDialog('Success', 'Toko berhasil diubah', true);
        } else {
          _showDialog(
              'Error', response['message'] ?? 'Gagal mengubah toko', false);
        }
      } catch (e) {
        _showDialog('Error', 'Terjadi kesalahan: $e', false);
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    } else {
      setState(() {
        _showCategoryError = categoryError != null;
      });
    }
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email Toko tidak boleh kosong';
    }
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validateCategory() {
    if (_selectedCategories.isEmpty) {
      return 'Kategori toko harus dipilih';
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

  void _showDialog(String title, String content, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF337F8F),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6.0),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 90.0),
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  if (isSuccess) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => ListTokoScreen()),
                    );
                  }
                },
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 20.0), // Added left padding
              child: Center(
                child: Text(
                  content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF005466),
                  ),
                ),
              ),
            ),
          ],
        ),
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
        title: const Text('Ubah Toko', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF006064),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Background Toko',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    ElevatedButton(
                      onPressed: () => _pickImage(isProfile: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005466),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: const Text('Unggah',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (_fotoToko.isNotEmpty)
                        ..._fotoToko
                            .map((foto) =>
                                _buildImageContainer(foto, onDelete: () {
                                  setState(() {
                                    _deletedFotoToko.add(foto);
                                    _fotoToko.remove(foto);
                                  });
                                }))
                            .toList(),
                      if (_newFotoToko.isNotEmpty)
                        ..._newFotoToko
                            .map((foto) =>
                                _buildNewImageContainer(foto, onDelete: () {
                                  setState(() {
                                    _newFotoToko.remove(foto);
                                  });
                                }))
                            .toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Info Toko',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
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
                            if (_newFotoProfileToko != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: kIsWeb
                                    ? Image.network(_newFotoProfileToko!.path,
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover)
                                    : Image.file(
                                        File(_newFotoProfileToko!.path),
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover),
                              )
                            else if (_existingFotoProfileToko != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.memory(
                                    base64Decode(_existingFotoProfileToko!),
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover),
                              )
                            else
                              const Icon(Icons.storefront,
                                  size: 50, color: Colors.grey),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade800,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    size: 20, color: Colors.white),
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
                          const Text('Nama Toko',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _namaTokoController,
                            decoration: const InputDecoration(
                              hintText: 'Contoh: Toko Buku A',
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
                                return 'Nama Toko tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text('Kategori Toko',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: _hasCategories
                                    ? null
                                    : _showCategoryDropdown,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF005466),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        6), // Tambahkan radius 6 di sini
                                  ),
                                ),
                                child: Text(_hasCategories ? '+' : 'Tambah +',
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                              if (_showCategoryError)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
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
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Alamat Toko',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                    TextFormField(
                      controller: _alamatTokoController,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Jl. Merdeka No. 123',
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
                          const Text('Provinsi Toko',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16)),
                          DropdownButtonFormField<String>(
                            value: _selectedProvinsi,
                            items: _provinsiOptions.map((provinsi) {
                              return DropdownMenuItem<String>(
                                value: provinsi['id'],
                                child: Text(provinsi['nama']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedProvinsi = value;
                                _selectedKota = null;
                                if (value != null) {
                                  _fetchCities(value);
                                }
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Pilih Provinsi',
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
                            validator: _validateProvince,
                            isExpanded:
                                true, // Allow dropdown to take full width
                            menuMaxHeight: 200, // Limit dropdown height
                            alignment: Alignment
                                .bottomLeft, // Align the dropdown to open downward
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kota Toko',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16)),
                          DropdownButtonFormField<String>(
                            value: _selectedKota,
                            items: _kotaOptions.map((kota) {
                              return DropdownMenuItem<String>(
                                value: kota['id'],
                                child: Text(kota['nama']),
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
                                    color: Color.fromRGBO(209, 213, 219, 1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(209, 213, 219, 1)),
                              ),
                              border: OutlineInputBorder(),
                            ),
                            validator: _validateCity,
                            isExpanded: true,
                            menuMaxHeight: 200,
                            alignment: Alignment
                                .bottomLeft, // Align the dropdown to open downward
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
                    const Text('Nomor Telepon Toko',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
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
                    const Text('Email Toko',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
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
                    const Text('Deskripsi Toko',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                    TextFormField(
                      controller: _deskripsiTokoController,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Toko buku lengkap dan murah',
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
                const Text('Foto QR Toko',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickImage(isQr: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005466),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              6), // Radius 6 ditambahkan di sini
                        ),
                      ),
                      child: const Text(
                        'Unggah QR Toko',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (_newFotoQrToko != null)
                      _buildNewImageContainer(_newFotoQrToko!, onDelete: () {
                        setState(() {
                          _newFotoQrToko = null;
                        });
                      })
                    else if (_existingQrProfileToko != null)
                      _buildImageContainer(_existingQrProfileToko!,
                          onDelete: () {
                        setState(() {
                          _existingQrProfileToko = null;
                        });
                      }),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Jam Operasional',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _jamOperasional.length,
                  itemBuilder: (context, index) {
                    final jam = _jamOperasional[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 60.0),
                                    child: Text('Buka',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 60.0),
                                    child: Text('Tutup',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(jam['hari'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ),
                              SizedBox(
                                width: 62,
                                height: 28,
                                child: TextField(
                                  controller: TextEditingController(
                                      text: jam['jamBuka']),
                                  onChanged: (value) => jam['jamBuka'] = value,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.datetime,
                                  decoration: InputDecoration(
                                    hintText: '09:00',
                                    filled: true,
                                    fillColor: const Color(0xFFDBE7E4),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6.0),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFDBE7E4)),
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(Icons.remove, color: Colors.black),
                              ),
                              SizedBox(
                                width: 62,
                                height: 28,
                                child: TextField(
                                  controller: TextEditingController(
                                      text: jam['jamTutup']),
                                  onChanged: (value) => jam['jamTutup'] = value,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.datetime,
                                  decoration: InputDecoration(
                                    hintText: '21:00',
                                    filled: true,
                                    fillColor: const Color(0xFFDBE7E4),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6.0),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFDBE7E4)),
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 4),
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
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor:
                        _isSubmitting ? Colors.grey : const Color(0xFF005466),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
