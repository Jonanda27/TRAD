import 'dart:io' as io; // Menggunakan alias 'io' untuk File
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_produk.dart';
import 'package:trad/list_produk.dart';

class TambahProdukScreen extends StatefulWidget {
  final int idToko; // Add this line to accept idToko

  const TambahProdukScreen({super.key, required this.idToko}); // Add required idToko

  @override
  _TambahProdukScreenState createState() => _TambahProdukScreenState();
}

class _TambahProdukScreenState extends State<TambahProdukScreen> {
  final _formKey = GlobalKey<FormState>();
  double _profitShareValue = 0;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _voucherValueController = TextEditingController();
  final TextEditingController _productCodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hashtagController = TextEditingController();
  // final TextEditingController _percentageController = TextEditingController();
  // final TextEditingController _currencyController = TextEditingController();
  final _percentageController = TextEditingController();
  final _currencyController = TextEditingController();
  final List<String> _hashtags = [];

  List<XFile> _selectedImages = [];
  final List<int> _selectedCategories = [];
  final List<Map<String, dynamic>> _availableCategories = [
  {'id': 1, 'name': 'Makanan'},
  {'id': 2, 'name': 'Minuman'},
  {'id': 3, 'name': 'Beku'},
];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
  final List<XFile>? images = await _picker.pickMultiImage();
  if (images != null && images.isNotEmpty) {
    setState(() {
      _selectedImages.addAll(images);
    });
  }
}

  Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    try {
      double percentageValue = double.tryParse(_percentageController.text) ?? 0.0;
      double currencyValue = double.tryParse(_priceController.text) ?? 0.0;
      double hargaBgHasil = (percentageValue / 100) * currencyValue;

      var response = await ProdukService().tambahProduk(
        idToko: widget.idToko.toString(),
        fotoProduk: _selectedImages,
        namaProduk: _productNameController.text,
        harga: double.parse(_priceController.text),
        bagiHasil: hargaBgHasil,
        voucher: double.tryParse(_voucherValueController.text),
        kodeProduk: _productCodeController.text,
        hashtag: _hashtags,
        deskripsiProduk: _descriptionController.text,
        kategori: _selectedCategories,
      );

      // Jika produk berhasil ditambahkan
      if (response != null) {  // Cek kondisi ini tergantung pada respons API Anda
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Berhasil'),
            content: const Text('Produk berhasil ditambahkan.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ListProduk(id: widget.idToko),
                    ),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Failed to add product: $e');
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
        title: const Text(
          'Tambah Produk',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageUploadButton(),
                _buildTextField('Nama Produk', _productNameController,
                    TextInputType.text, 'Masukkan nama produk'),
                const SizedBox(height: 15),
                _buildTextField(
                  'Harga', _priceController,
                  TextInputType.number, 'Masukkan harga produk',
                  onChanged: (value) => _updateValues(), // Tambahkan ini
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Center the content within the row
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildTextField(
                        'Bagi Hasil',
                        _percentageController,
                        TextInputType.number,
                        '',
                        onChanged: (value) => _updateValues(), // Tambahkan ini
                      ),
                    ),
                    const SizedBox(
                      width: 15, // Spacing between the fields and the text
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 20.0), // Adjust the top padding as needed
                      child: Text(
                        '% / Rp.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(
                        width:
                            15), // Spacing between the text and the next field
                    Expanded(
                      flex: 1,
                      child: _buildTextField(
                        '',
                        _currencyController,
                        TextInputType.number,
                        '',
                        backgroundColor: const Color(0xFFE8E8E8),
                        isReadOnly: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildVoucherField(),
                const SizedBox(height: 15),
                _buildTextField(
                    'Kode Produk (Opsional)',
                    _productCodeController,
                    TextInputType.text,
                    'Masukkan kode produk'),
                const SizedBox(height: 15),
                _buildCategoryButton(),
                const SizedBox(height: 15),
                _buildHashtagField(),
                const SizedBox(height: 15),
                _buildDescriptionField(),
                const SizedBox(height: 20),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadButton() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Text('Foto Produk',
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
          const Spacer(),
          ElevatedButton(
            onPressed: _pickImages,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006064),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
            ),
            child: const Text('Unggah',
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
          ),
        ],
      ),
      const SizedBox(height: 10),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_selectedImages.isEmpty)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                ),
              )
            else
              ..._selectedImages.map((image) {
                return Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    color: Colors.grey[200],
                  ),
                  child: kIsWeb
                      ? Image.network(image.path, fit: BoxFit.cover)
                      : Image.file(io.File(image.path), fit: BoxFit.cover),
                );
              }).toList(),
          ],
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}

  Widget _buildTextField(String label, TextEditingController controller,
      TextInputType inputType, String hintText,
      {Color backgroundColor = Colors.white,
      bool isReadOnly = false,
      void Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          color: backgroundColor,
          child: TextFormField(
            controller: controller,
            keyboardType: inputType,
            readOnly: isReadOnly,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            validator: (value) {
              if (!isReadOnly && (value == null || value.isEmpty)) {
                return 'Tolong isi $label';
              }
              return null;
            },
            onChanged: onChanged, // Tambahkan ini
          ),
        ),
      ],
    );
  }

  Widget _buildVoucherField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Nilai Voucher',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                color: const Color(0xFFE8E8E8),
                child: TextFormField(
                  controller: _voucherValueController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan nilai voucher',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(6.0), // Set corner radius to 6
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  readOnly: true, // Prevent user input
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tolong isi Nilai Voucher';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfitShareFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bagi Hasil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 1, // Menyesuaikan ukuran field persentase
              child: TextFormField(
                controller: _percentageController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '0%',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                // onChanged: (value) {
                //   setState(() {
                //     _profitShareValue = double.tryParse(value) ?? 0;
                //   });
                // },
              ),
            ),
            const SizedBox(
                width: 10), // Spasi antara field persentase dan field mata uang
            Expanded(
              flex: 1, // Menyesuaikan ukuran field persentase
              child: TextFormField(
                controller: _currencyController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '0%',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                // onChanged: (value) {
                //   setState(() {
                //     _profitShareValue = double.tryParse(value) ?? 0;
                //   });
                // },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCategoryDialog() {
  int? selectedCategory;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Pilih Kategori'),
        content: DropdownButtonFormField<int>(
          value: selectedCategory,
          items: _availableCategories.map((category) {
            return DropdownMenuItem<int>(
              value: category['id'],
              child: Text(category['name']),
            );
          }).toList(),
          onChanged: (int? newValue) {
            setState(() {
              selectedCategory = newValue;
            });
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Tambah'),
            onPressed: () {
              if (selectedCategory != null &&
                  !_selectedCategories.contains(selectedCategory)) {
                setState(() {
                  _selectedCategories.add(selectedCategory!);
                });
              }
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}

Widget _buildCategoryButton() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Text(
            'Kategori',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _showCategoryDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF004D5E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _selectedCategories.map((categoryId) {
          final category = _availableCategories
              .firstWhere((category) => category['id'] == categoryId);
          return Chip(
            label: Text(category['name']),
            onDeleted: () {
              setState(() {
                _selectedCategories.remove(categoryId);
              });
            },
          );
        }).toList(),
      ),
    ],
  );
}

  void _addHashtag() {
    final hashtag = _hashtagController.text.trim();
    if (hashtag.isNotEmpty && !_hashtags.contains(hashtag)) {
      setState(() {
        _hashtags.add(hashtag);
        _hashtagController.clear();
      });
    }
  }

  Widget _buildHashtagField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Tagar/Hashtag',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _hashtagController,
              decoration: InputDecoration(
                hintText: '#tagproduk',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _addHashtag,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF004D5E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _hashtags.map((hashtag) {
          return Chip(
            label: Text(hashtag),
            onDeleted: () {
              setState(() {
                _hashtags.remove(hashtag);
              });
            },
          );
        }).toList(),
      ),
    ],
  );
}

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Deskripsi Produk',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Masukkan deskripsi produk',
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(6.0), // Set corner radius to 6
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
        ),
      ],
    );
  }

  void _updateValues() {
    final percentageValue = double.tryParse(_percentageController.text) ?? 0.0;
    final currencyValue = double.tryParse(_priceController.text) ?? 0.0;

    final voucherValue = 2 *
        ((percentageValue / 100) * currencyValue); // Contoh perhitungan voucher
    final calculatedCurrencyValue = (percentageValue / 100) * currencyValue;

    setState(() {
      _currencyController.text = calculatedCurrencyValue.toStringAsFixed(2);
      _voucherValueController.text = voucherValue.toStringAsFixed(2);
    });
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF006064),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text(
          'Simpan',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
