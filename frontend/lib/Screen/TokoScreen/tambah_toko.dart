import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
  String? _selectedProvinsiName;
  String? _selectedKotaName;

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

  String? _emailError;
  String? _phoneError;
  String? _categoryError;
  String? _provinceError;
  String? _cityError;
  String? _namaError;
  String? _deskripsiError;

  List<Map<String, dynamic>> _provinsiOptions = [];
  List<Map<String, dynamic>> _kotaOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchProvinces(); // Fetch provinces when the screen is initialized
  }

  Future<void> _fetchProvinces() async {
    try {
      List<Map<String, dynamic>> provinces = await getProvinces();
      setState(() {
        _provinsiOptions = provinces;
      });
    } catch (e) {
      print('Failed to fetch provinces: $e');
    }
  }

  Future<void> _fetchCities(String provinceId) async {
    try {
      List<Map<String, dynamic>> cities = await getCities(provinceId);
      setState(() {
        _kotaOptions = cities;
        _selectedKota = null; // Reset selected city when province changes
      });
    } catch (e) {
      print('Failed to fetch cities: $e');
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

  Future<void> _pickImage({bool isProfile = false, bool isQr = false}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();

      setState(() {
        if (isProfile) {
          _fotoProfileToko = [imageBytes];
        } else if (isQr) {
          _fotoQrToko = imageBytes;
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
    // Memeriksa setiap input untuk memastikan tidak ada yang kosong atau tidak valid
    _validateNama(_namaTokoController.text);
    _validateDeskripsi(_alamatTokoController.text);
    _validateEmail(_emailTokoController.text);
    _validatePhoneNumber(_nomorTeleponTokoController.text);
    _validateCategory();
    _validateProvince(_selectedProvinsi);
    _validateCity(_selectedKota);

    // Jika ada error, hentikan proses submit
    if (_namaError != null ||
        _deskripsiError != null ||
        _emailError != null ||
        _phoneError != null ||
        _categoryError != null ||
        _provinceError != null ||
        _cityError != null) {
      return; // Ada kesalahan, tidak dapat melanjutkan proses submit
    }

    setState(() {
      _isSubmitting =
          true; // Tampilkan indikator bahwa proses submit sedang berlangsung
    });

    try {
      // Mengambil userId dari SharedPreferences untuk otentikasi pengguna
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID tidak ditemukan. Silakan login kembali.'),
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Memastikan foto profil toko diisi, jika tidak menggunakan gambar default
      if (_fotoProfileToko.isEmpty) {
        final ByteData bytes = await rootBundle.load('img/default_image.png');
        final Uint8List defaultImage = bytes.buffer.asUint8List();
        _fotoProfileToko = [defaultImage];
      }

      // Memastikan foto QR toko diisi, jika tidak menggunakan gambar default
      if (_fotoQrToko == null) {
        final ByteData bytes = await rootBundle.load('img/default_image.png');
        _fotoQrToko = bytes.buffer.asUint8List();
      }

      // Mempersiapkan data jam operasional untuk dikirim
      final jamOperasionalFields = <String, String>{};
      for (int i = 0; i < _jamOperasional.length; i++) {
        final jam = _jamOperasional[i];
        jamOperasionalFields['jamOperasional[$i][hari]'] = jam['hari'];
        jamOperasionalFields['jamOperasional[$i][jamBuka]'] = jam['jamBuka'];
        jamOperasionalFields['jamOperasional[$i][jamTutup]'] = jam['jamTutup'];
        jamOperasionalFields['jamOperasional[$i][statusBuka]'] =
            jam['statusBuka'] ? '1' : '0';
      }

      // Mempersiapkan data kategori toko untuk dikirim
      final kategoriTokoFields = <String, String>{};
      for (int i = 0; i < _selectedCategories.length; i++) {
        kategoriTokoFields['kategoriToko[$i]'] = _selectedCategories[i];
      }

      // Membuat instance dari TokoService untuk melakukan request
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
        fotoQrToko: _fotoQrToko,
      );

      // Memeriksa hasil dari request dan memberikan umpan balik ke pengguna
      if (result.containsKey('status') && result['status'] == 'success') {
        _showDialog(
            'Success', result['message'] ?? 'Toko berhasil ditambahkan', true);
      } else {
        _showDialog(
            'Error', result['message'] ?? 'Gagal menambahkan toko', false);
      }
    } catch (e) {
      _showDialog('Error', 'Terjadi kesalahan: $e', false);
    } finally {
      setState(() {
        _isSubmitting = false; // Sembunyikan indikator proses submit
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
                    isSuccess ? Icons.check_circle : Icons.error,
                    color: isSuccess ? Colors.green : Colors.red,
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
  }

  void _validateEmail(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        _emailError = 'Email Toko tidak boleh kosong';
      } else {
        String pattern = r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+$';
        RegExp regex = RegExp(pattern);
        _emailError =
            !regex.hasMatch(value) ? 'Format email tidak valid' : null;
      }
    });
  }

  void _validatePhoneNumber(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        _phoneError = 'Nomor Telepon Toko tidak boleh kosong';
      } else if (!RegExp(r'^08[0-9]{8,}$').hasMatch(value)) {
        _phoneError =
            'Nomor telepon harus dimulai dengan "08" dan minimal 10 digit';
      } else {
        _phoneError = null;
      }
    });
  }

  void _validateCategory() {
    setState(() {
      _categoryError =
          _selectedCategories.isEmpty ? 'Kategori toko harus dipilih' : null;
    });
  }

  void _validateProvince(String? value) {
    setState(() {
      _provinceError =
          value == null || value.isEmpty ? 'Provinsi toko harus dipilih' : null;
    });
  }

  void _validateCity(String? value) {
    setState(() {
      _cityError =
          value == null || value.isEmpty ? 'Kota toko harus dipilih' : null;
    });
  }

  void _validateNama(String? value) {
    setState(() {
      _namaError = value == null || value.isEmpty
          ? 'Nama Toko tidak boleh kosong'
          : null;
    });
  }

  void _validateDeskripsi(String? value) {
    setState(() {
      _deskripsiError = value == null || value.isEmpty
          ? 'Deskripsi Toko tidak boleh kosong'
          : null;
    });
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
                                decoration: InputDecoration(
                                  hintText: 'Contoh: Toko Buku A',
                                  errorText: _namaError,
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
                                onChanged: (value) {
                                  _validateNama(value);
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
                              if (_selectedCategories.isEmpty)
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
                              errorText: _deskripsiError,
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
                            onChanged: (value) {
                              _validateDeskripsi(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Flexible(
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
                                    value: provinsi['id'],
                                    child: Text(provinsi['nama']),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedProvinsi = value;
                                    _selectedKota =
                                        null; // Reset kota saat provinsi berubah
                                    if (value != null) {
                                      _validateProvince(
                                          value); // Memanggil validasi ketika provinsi dipilih
                                      _fetchCities(value);
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Pilih Provinsi',
                                  errorText:
                                      _provinceError, // Tampilkan pesan error berdasarkan validasi
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
                                validator: (value) {
                                  _validateProvince(value);
                                  return _provinceError;
                                },
                                isExpanded:
                                    true, // Allow dropdown to take full width
                                menuMaxHeight: 200, // Limit dropdown height
                                alignment: Alignment
                                    .bottomLeft, // Align the dropdown to open downward
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
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
                                isExpanded: true,
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
                                    _selectedKotaName = _kotaOptions.firstWhere(
                                        (kota) => kota['id'] == value)['nama'];
                                    _validateCity(
                                        value); // Memanggil validasi untuk kota ketika diubah
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Pilih Kota',
                                  errorText:
                                      _cityError, // Menggunakan variabel kesalahan validasi kota
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(209, 213, 219, 1),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(209, 213, 219, 1),
                                    ),
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  _validateCity(
                                      value); // Validasi kota ketika form difokuskan ulang
                                  return _cityError;
                                },
                                menuMaxHeight:
                                    200, // Batasi tinggi dropdown dan aktifkan scrolling
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
                          decoration: InputDecoration(
                            hintText: 'Contoh: 081234567890',
                            errorText: _phoneError,
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
                          onChanged: (value) {
                            _validatePhoneNumber(
                                _nomorTeleponTokoController.text);
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
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailTokoController,
                          decoration: InputDecoration(
                            hintText: 'Contoh: tokobukua@gmail.com',
                            errorText: _emailError,
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
                          onChanged: (value) {
                            _validateEmail(_emailTokoController.text);
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
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
                                child: Image.memory(_fotoQrToko!,
                                    fit: BoxFit.cover),
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
                      onPressed: _isSubmitting ? null : _submitForm,
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
                            ? Colors.grey
                            : Color.fromRGBO(36, 75, 89, 1),
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
