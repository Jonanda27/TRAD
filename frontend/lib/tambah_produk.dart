import 'dart:io' as io; // Menggunakan alias 'io' untuk File
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_produk.dart';

class TambahProdukScreen extends StatefulWidget {
  const TambahProdukScreen({super.key});

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

  XFile? _selectedImage;
  final List<int> _selectedCategories = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<String?> _getIdToko() async {
    final prefs = await SharedPreferences.getInstance();
    // print(prefs);
    return prefs.getString('nama');
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final idToko = await _getIdToko() ?? '1';

        double percentageValue =
            double.tryParse(_percentageController.text) ?? 0.0;
        double currencyValue = double.tryParse(_priceController.text) ?? 0.0;
        double hargaBgHasil = (percentageValue / 100) * currencyValue;

        print(hargaBgHasil);

        var response = await ProdukService().tambahProduk(
          idToko: idToko,
          fotoProduk: _selectedImage,
          namaProduk: _productNameController.text,
          harga: double.parse(_priceController.text),
          bagiHasil: hargaBgHasil,
          voucher: double.tryParse(_voucherValueController.text),
          kodeProduk: _productCodeController.text,
          hashtag: _hashtags,
          deskripsiProduk: _descriptionController.text,
          kategori: _selectedCategories,
        );
        print('Product added successfully: $response');
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
            const SizedBox(
                width: 134), // Adjust the width to your desired spacing
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006064),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(6.0), // Set border radius to 6
                ),
              ),
              child: const Text('Unggah',
                  style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
            ),
          ],
        ),

        const SizedBox(height: 10),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            color: Colors.grey[200],
          ),
          child: _selectedImage != null
              ? kIsWeb
                  ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                  : Image.file(io.File(_selectedImage!.path), fit: BoxFit.cover)
              : const Center(child: Text('')),
        ),
        const SizedBox(height: 10), // Jarak antara gambar dan nama produk
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
            items: [1, 2, 3, 4].map((int category) {
              return DropdownMenuItem<int>(
                value: category,
                child: Text(
                    category.toString()), // Displaying the integer as a string
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kategori',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                children: _selectedCategories.map((categoryId) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8, bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      categoryId
                          .toString(), // Displaying the integer as a string
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF004D5E),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: IconButton(
              onPressed: _showCategoryDialog,
              icon: const Icon(Icons.add),
              color: Colors.white,
            ),
          ),
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
          'Tagar/Hastag',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(6.0),
                ),
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
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF004D5E),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: IconButton(
                onPressed: _addHashtag,
                icon: const Icon(Icons.add),
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: _hashtags.map((hashtag) {
            return Chip(
              label: Text(hashtag),
              deleteIcon: const Icon(Icons.close),
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
