import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_toko.dart';
import 'package:trad/list_toko.dart';

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
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('id');

        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('User ID tidak ditemukan. Silakan login kembali.')),
          );
          return;
        }

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
        );

        print('Server response: $result');

        // Check if the result indicates success
        if (result['Toko berhasil ditambahkan'] == true ||
            result['Toko berhasil ditambahkan'] == 'true') {
          print('Toko berhasil ditambahkan, menampilkan dialog sukses...');
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Success'),
                content: Text(result['message'] ?? 'Toko berhasil ditambahkan'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListTokoScreen()),
                      ); // Redirect to ListTokoScreen
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          print('Toko gagal ditambahkan, menampilkan dialog error...');
          // Show error dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Behasil'),
                content: Text(result['message'] ?? 'Gagal menambahkan toko'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListTokoScreen()),
                      ); // Close the dialog
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        print('Terjadi kesalahan: $e');
        // Show error dialog for unexpected exceptions
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Terjadi kesalahan: $e'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
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
    // Get the screen height
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Toko',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: const Color(0xFF006064), // Background color
        iconTheme: const IconThemeData(
            color: Colors.white), // Set back arrow color to white
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Grey Background covering the top half of the screen
            Container(
              height: screenHeight / 4.0, // Covers half of the screen
              color: const Color.fromRGBO(240, 244, 243, 1),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row containing Background Toko text and Unggah button
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
                          onPressed: () => _pickImage(
                              isProfile: false), // Pick image for _fotoToko
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF005466), // Button color
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: const Text(
                            'Unggah',
                            style: TextStyle(color: Colors.white), // Font color
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Placeholder for the selected photo
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

                    // Info Toko text
                    const Text(
                      'Info Toko',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Store Profile Image
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Store Profile Image
                        GestureDetector(
                          onTap: () => _pickImage(isProfile: true),
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey
                                  .shade200, // Background color for the container
                              borderRadius:
                                  BorderRadius.circular(20), // Rounded corners
                            ),
                            child: Stack(
                              alignment: Alignment
                                  .center, // Center the content in the container
                              children: [
                                if (_fotoProfileToko
                                    .isNotEmpty) // If a photo is selected
                                  ..._fotoProfileToko.map((imageBytes) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8.0), // Space between images
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            20), // Match container's border radius
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
                                    size: 50, // Store icon size
                                    color: Colors.grey, // Store icon color
                                  ),
                                Align(
                                  alignment: Alignment
                                      .bottomCenter, // Position camera icon at the bottom
                                  child: Container(
                                    height:
                                        40, // Adjust the size of the icon container
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.teal
                                          .shade800, // Background color for camera icon
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 20, // Camera icon size
                                      color: Colors.white, // Camera icon color
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(
                            width: 16), // Space between image and form fields

                        // Nama Toko and Kategori Toko Button
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nama Toko
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
                                  border:
                                      OutlineInputBorder(), // Tambahkan ini untuk border default
                                ),
                                style: const TextStyle(color: Colors.black),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nama Toko tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(
                                  height: 16), // Space between the two fields

                              // Kategori Toko Button
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
                                      backgroundColor: const Color(
                                          0xFF005466), // Button color
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                    ),
                                    child: Text(
                                      _hasCategories ? '+' : 'Tambah +',
                                      style: const TextStyle(
                                          color: Colors.white), // Font color
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Display selected categories
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
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                            border:
                                OutlineInputBorder(), // Tambahkan ini untuk border default
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
                                  border:
                                      OutlineInputBorder(), // Tambahkan ini untuk border default
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
                                  border:
                                      OutlineInputBorder(), // Tambahkan ini untuk border default
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                            border:
                                OutlineInputBorder(), // Tambahkan ini untuk border default
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
                            border:
                                OutlineInputBorder(), // Tambahkan ini untuk border default
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
                            border:
                                OutlineInputBorder(), // Tambahkan ini untuk border default
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
                    // Add operational hours list
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
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 0.0), // Padding kanan
                                      child: SizedBox(
                                        width: 62,
                                        height: 28,
                                        child: TextField(
                                          controller: TextEditingController(
                                              text: jam['jamBuka']),
                                          onChanged: (value) =>
                                              jam['jamBuka'] = value,
                                          textAlign: TextAlign.center,
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
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Icon(Icons.remove,
                                          color: Colors.black),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 0.0), // Padding kanan
                                      child: SizedBox(
                                        width: 62,
                                        height: 28,
                                        child: TextField(
                                          controller: TextEditingController(
                                              text: jam['jamTutup']),
                                          onChanged: (value) =>
                                              jam['jamTutup'] = value,
                                          textAlign: TextAlign.center,
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
                                    ),
                                    const SizedBox(width: 22),
                                    Switch(
                                      value: jam['statusBuka'],
                                      onChanged: (value) {
                                        setState(() {
                                          jam['statusBuka'] = value;
                                        });
                                      },
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
                      onPressed: _submitForm,
                      child: const Text('Tambah Toko'),
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
