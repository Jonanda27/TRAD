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

  XFile? _selectedImage;
  final List<int> _selectedCategoryIds = [];
  final List<String> _selectedCategories = [];

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

      List<String> hashtags = _hashtagController.text.split(' ').toList();
      
      var response = await ProdukService().tambahProduk(
        idToko: idToko,
        fotoProduk: _selectedImage,
        namaProduk: _productNameController.text,
        harga: double.parse(_priceController.text),
        bagiHasil: _profitShareValue,
        voucher: double.tryParse(_voucherValueController.text),
        kodeProduk: _productCodeController.text,
        hashtag: hashtags,
        deskripsiProduk: _descriptionController.text,
        kategori: _selectedCategoryIds,
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
                _buildTextField('Harga', _priceController, TextInputType.number,
                    'Masukkan harga produk'),
                const SizedBox(height: 15),
                _buildProfitShareFields(),
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
            const SizedBox(width: 134), // Adjust the width to your desired spacing
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006064),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(6.0), // Set border radius to 6
                ),
              ),
              child: const Text('Unggah', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
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
      {Color backgroundColor = Colors.white}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          color: backgroundColor,
          child: TextFormField(
            controller: controller,
            keyboardType: inputType,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(6.0), // Set corner radius to 6
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Tolong isi $label';
              }
              return null;
            },
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
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Masukkan nilai voucher',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(6.0), // Set corner radius to 6
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
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
    final _percentageController = TextEditingController();
    final _currencyController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bagi Hasil',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 1, // Adjust the flex to make this field smaller
              child: TextFormField(
                controller: _percentageController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center, // Center the hint text
                decoration: InputDecoration(
                  hintText: '0',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(6.0), // Set corner radius to 6
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                onChanged: (value) {
                  setState(() {
                    _profitShareValue = double.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
            const SizedBox(width: 5),
            const Text('% / Rp.',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Expanded(
              flex: 3, // Adjust the flex to make this field larger
              child: TextFormField(
                controller: _currencyController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center, // Center the hint text
                decoration: InputDecoration(
                  hintText: '0',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(6.0), // Set corner radius to 6
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                onChanged: (value) {
                  // Optionally handle currency input changes here
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

   Widget _buildCategoryButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kategori',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        const SizedBox(height: 0),
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8.0, // Space between categories
                runSpacing: 4.0, // Space between rows
                children: _selectedCategories.map((category) {
                  return Chip(
                    label: Text(category),
                    onDeleted: () {
                      setState(() {
                        _selectedCategories.remove(category);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: _showCategoryDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006064),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0), // Set border radius to 6
                ),
              ),
              child: const Icon(Icons.add, color: Color.fromARGB(255, 255, 255, 255)),
            ),
          ],
        ),
      ],
    );
  }

  void _showCategoryDialog() {
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Kategori'),
          content: DropdownButtonFormField<String>(
            value: selectedCategory,
            items: ['Makanan', 'Minuman', 'Pakaian', 'Elektronik']
                .map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
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


  Widget _buildHashtagField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tagar/Hashtag',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _hashtagController,
                decoration: InputDecoration(
                  hintText: '#tagproduk',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(6.0), // Set corner radius to 6
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                // Handle hashtag addition
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006064),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(6.0), // Set border radius to 6
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
        ),
      ],
    );
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
