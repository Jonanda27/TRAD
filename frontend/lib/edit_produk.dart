import 'dart:io' as io; // Menggunakan alias 'io' untuk File
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_produk.dart';
import 'package:trad/Model/produk_model.dart'; // Pastikan untuk mengimpor model Produk
import 'dart:convert';
import 'dart:typed_data';

Widget _buildBase64ImageContainer(String base64String, {required VoidCallback onDelete}) {
  Uint8List bytes = base64Decode(base64String);
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
        top: 2,
        right: 2,
        child: InkWell(
          onTap: onDelete,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 14),
          ),
        ),
      ),
    ],
  );
}

class EditProdukScreen extends StatefulWidget {
  final Produk produk;

  const EditProdukScreen({Key? key, required this.produk}) : super(key: key);

  @override
  _EditProdukScreenState createState() => _EditProdukScreenState();
}

class _EditProdukScreenState extends State<EditProdukScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _productNameController;
  late TextEditingController _priceController;
  late TextEditingController _voucherValueController;
  late TextEditingController _productCodeController;
  late TextEditingController _descriptionController;
  late TextEditingController _hashtagController;
  late TextEditingController _percentageController;
  late TextEditingController _currencyController;
  late List<String> _hashtags;
  List<XFile> _selectedImages = [];
  late List<int> _selectedCategories;
  final Map<String, String> _categories = {
  'Makanan': '1',
  'Minuman': '2',
  'Beku': '3',
  // Tambahkan kategori lain di sini
};

  List<String> _deletedFotos = []; // Tambahkan ini untuk melacak foto yang dihapus
  List<XFile> _newFotos = []; 


  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data produk
    _productNameController = TextEditingController(text: widget.produk.namaProduk);
    _priceController = TextEditingController(text: widget.produk.harga.toString());
    _voucherValueController = TextEditingController(text: (widget.produk.voucher ?? 0.0).toString());
    _productCodeController = TextEditingController(text: widget.produk.kodeProduk);
    _descriptionController = TextEditingController(text: widget.produk.deskripsiProduk);
    _hashtagController = TextEditingController();
    _percentageController = TextEditingController(text: (widget.produk.bagiHasil / widget.produk.harga * 100).toString());
    _currencyController = TextEditingController(text: widget.produk.bagiHasil.toString());
    _hashtags = List.from(widget.produk.hashtag);
    _selectedCategories = List.from(widget.produk.kategori);

    // If you need to load the image from network or local file, do it here
  }

  Future<void> _pickImage() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _newFotos.addAll(images);
      });
    }
  }

  Future<String?> _getIdToko() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nama');
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        double percentageValue = double.tryParse(_percentageController.text) ?? 0.0;
        double currencyValue = double.tryParse(_priceController.text) ?? 0.0;
        double hargaBgHasil = (percentageValue / 100) * currencyValue;

        List<String> existingFotoProduk = widget.produk.fotoProduk
            .where((foto) => !_deletedFotos.contains(foto))
            .toList();

        var response = await ProdukService().ubahProduk(
          idProduk: widget.produk.id,
          idToko: widget.produk.idToko.toString(),
          existingFotoProduk: existingFotoProduk,
          newFotoProduk: _newFotos,
          namaProduk: _productNameController.text,
          harga: double.parse(_priceController.text),
          bagiHasil: hargaBgHasil,
          voucher: double.tryParse(_voucherValueController.text),
          kodeProduk: _productCodeController.text,
          hashtag: _hashtags,
          deskripsiProduk: _descriptionController.text,
          kategori: _selectedCategories,
        );
        print('Product updated successfully: $response');
        // Tambahkan navigasi kembali atau pesan sukses di sini
      } catch (e) {
        print('Failed to update product: $e');
        // Tambahkan pesan error atau dialog di sini
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
          'Edit Produk',
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
                  onChanged: (value) => _updateValues(),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildTextField(
                        'Bagi Hasil',
                        _percentageController,
                        TextInputType.number,
                        '',
                        onChanged: (value) => _updateValues(),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text(
                        '% / Rp.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
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
            onPressed: _pickImage,
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
            ...widget.produk.fotoProduk.asMap().entries.map((entry) {
                int index = entry.key;
                String base64 = entry.value;
                return _buildBase64ImageContainer(base64, onDelete: () {
                  setState(() {
                    _deletedFotos.add(base64); // Tambahkan foto yang dihapus ke _deletedFotos
                    widget.produk.fotoProduk.removeAt(index);
                  });
                });
              }),
              // Menampilkan gambar baru yang dipilih
              ..._newFotos.map((image) => _buildImageContainer(image, onDelete: () {
                setState(() {
                  _newFotos.remove(image);
                });
              })),
          ],
        ),
      ),
    ],
  );
}


Widget _buildImageContainer(XFile image, {required VoidCallback onDelete}) {
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
        child: kIsWeb
            ? Image.network(image.path, fit: BoxFit.cover)
            : Image.file(io.File(image.path), fit: BoxFit.cover),
      ),
      Positioned(
        top: 2,
        right: 2,
        child: InkWell(
          onTap: onDelete,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 14),
          ),
        ),
      ),
    ],
  );
}

Widget _buildNetworkImageContainer(String url) {
  return Container(
    width: 100,
    height: 100,
    margin: const EdgeInsets.only(right: 10),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey, width: 1),
      color: Colors.grey[200],
    ),
    child: Image.network(url, fit: BoxFit.cover),
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
  int? selectedCategoryId;
  String? selectedCategoryName;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Pilih Kategori'),
        content: DropdownButtonFormField<int>(
          value: selectedCategoryId,
          items: _categories.entries.map((entry) {
            return DropdownMenuItem<int>(
              value: int.parse(entry.value),
              child: Text(entry.key),
            );
          }).toList(),
          onChanged: (int? newValue) {
            setState(() {
              selectedCategoryId = newValue;
              selectedCategoryName = _categories.keys.firstWhere(
                (key) => _categories[key] == newValue.toString(),
                orElse: () => 'Unknown',
              );
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
              if (selectedCategoryId != null &&
                  !_selectedCategories.contains(selectedCategoryId)) {
                setState(() {
                  _selectedCategories.add(selectedCategoryId!);
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
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              children: _selectedCategories.map((kategoriId) {
                String categoryName = _categories.keys.firstWhere(
                  (key) => _categories[key] == kategoriId.toString(),
                  orElse: () => 'Unknown',
                );
                return Chip(
                  label: Text(categoryName),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      _selectedCategories.remove(kategoriId);
                    });
                  },
                  backgroundColor: Colors.white,
                  labelStyle: const TextStyle(color: Colors.black),
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Tolong isi Deskripsi Produk';
          }
          return null;
        },
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