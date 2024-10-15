import 'dart:io' as io; // Menggunakan alias 'io' untuk File
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trad/Model/RestAPI/service_produk.dart';
import 'package:trad/Model/produk_model.dart'; // Pastikan untuk mengimpor model Produk
import 'package:trad/Screen/TokoScreen/list_produk.dart';
import 'dart:convert';
import 'dart:typed_data';

Widget _buildBase64ImageContainer(String base64String,
    {required VoidCallback onDelete}) {
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
  bool _isSubmitting = false;
  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'id_ID');
  List<String> _deletedFotos =
      []; // Tambahkan ini untuk melacak foto yang dihapus
  List<XFile> _newFotos = [];
  String? _productNameError;
  String? _priceError;
  String? _categoryError;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data produk
    _productNameController =
        TextEditingController(text: widget.produk.namaProduk);
    _priceController = TextEditingController(
      text: _currencyFormat.format(widget.produk.harga).replaceAll(',', '.'),
    );

    _voucherValueController =
        TextEditingController(text: (widget.produk.voucher ?? 0.0).toString());
    _productCodeController =
        TextEditingController(text: widget.produk.kodeProduk);
    _descriptionController =
        TextEditingController(text: widget.produk.deskripsiProduk);
    _hashtagController = TextEditingController();
    _percentageController = TextEditingController(
        text: (widget.produk.bagiHasil / widget.produk.harga * 100).toString());
    _currencyController =
        TextEditingController(text: widget.produk.bagiHasil.toString());
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

  void _validateFields() {
    setState(() {
      _productNameError = _productNameController.text.isEmpty
          ? 'Nama produk harus diisi.'
          : null;

      double priceValue = double.tryParse(
              _priceController.text.replaceAll('.', '').replaceAll(',', '')) ??
          0.0;
      _priceError =
          priceValue <= 0 ? 'Harga harus diisi dengan angka yang valid.' : null;

      _categoryError =
          _selectedCategories.isEmpty ? 'Kategori harus dipilih.' : null;
    });
  }

  Future<void> _submitForm() async {
    _validateFields();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true; // Atur status pengiriman menjadi true
      });

      try {
        double percentageValue =
            double.tryParse(_percentageController.text) ?? 0.0;
        // Menghapus pemisah ribuan untuk parsing harga dengan benar
        double currencyValue = double.tryParse(_priceController.text
                .replaceAll('.', '')
                .replaceAll(',', '')) ??
            0.0;
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
          harga: currencyValue,
          bagiHasil: hargaBgHasil,
          voucher: double.tryParse(_voucherValueController.text),
          kodeProduk: _productCodeController.text,
          hashtag: _hashtags,
          deskripsiProduk: _descriptionController.text,
          kategori: _selectedCategories,
        );

        if (response != null && response['status'] == 'success') {
          // Tampilkan dialog sukses
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
                      padding: const EdgeInsets.only(
                          left: 20.0), // Menambahkan padding kiri
                      child: Center(
                        child: Text(
                          'Edit Produk Berhasil',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                ListProduk(id: widget.produk.idToko),
                          ),
                        );
                      },
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Produk berhasil diperbarui',
                    style: TextStyle(
                      color: Color(0xFF005466),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Gagal'),
              content:
                  const Text('Gagal memperbarui produk. Silakan coba lagi.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        // showDialog(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     title: const Text('Error'),
        //     content: Text('Terjadi kesalahan: $e'),
        //     actions: [
        //       TextButton(
        //         onPressed: () {
        //           Navigator.of(context).pop();
        //         },
        //         child: const Text('OK'),
        //       ),
        //     ],
        //   ),
        // );
      } finally {
        setState(() {
          _isSubmitting = false; // Kembalikan status pengiriman menjadi false
        });
      }
    }
  }

  void _updatePercentageAndVoucherFromCurrency() {
    final currencyValue = double.tryParse(_currencyController.text
            .replaceAll('.', '')
            .replaceAll(',', '.')) ??
        0.0;
    final priceValue =
        double.tryParse(_priceController.text.replaceAll('.', '')) ?? 0.0;

    if (priceValue > 0) {
      final percentageValue = (currencyValue / priceValue) * 100;
      final voucherValue = 2 * currencyValue;

      setState(() {
        // Format persentase dengan dua digit di belakang koma dan ganti titik dengan koma
        _percentageController.text =
            percentageValue.toStringAsFixed(2).replaceAll('.', ',');
        _voucherValueController.text = _currencyFormat.format(voucherValue);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageUploadButton(),
                    const SizedBox(height: 8),
                    _buildTextField(
                      'Nama Produk',
                      _productNameController,
                      TextInputType.text,
                      'Contoh: Buku Cerita',
                      onChanged: (value) {
                        _validateFields(); // Call validation here
                      },
                      errorText: _productNameError, // Show error message
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      'Harga',
                      _priceController,
                      TextInputType.number,
                      'Contoh: 40000',
                      onChanged: (value) {
                        _priceController.value = TextEditingValue(
                          text: _formatCurrencyInput(value),
                          selection: TextSelection.collapsed(
                              offset: _formatCurrencyInput(value).length),
                        );
                        _validateFields(); // Call validation here
                        _updateValues();
                      },
                      errorText: _priceError, // Show error message
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildTextField(
                            'Bagi Hasil (%)',
                            _percentageController,
                            TextInputType.text,
                            'Contoh: 20,50', // Terima input dengan dua angka desimal
                            onChanged: (value) {
                              // Mengganti koma menjadi titik untuk parsing desimal
                              final parsedValue =
                                  double.tryParse(value.replaceAll(',', '.')) ??
                                      0.0;

                              // Batasi nilai maksimal ke 50%
                              if (parsedValue > 50) {
                                setState(() {
                                  _percentageController.text = '50,00';
                                  _percentageController.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                        offset:
                                            _percentageController.text.length),
                                  );
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Bagi Hasil tidak boleh lebih dari 50%')),
                                );
                              } else {
                                setState(() {
                                  _percentageController.value =
                                      TextEditingValue(
                                    text: value,
                                    selection: TextSelection.fromPosition(
                                        TextPosition(offset: value.length)),
                                  );
                                });
                              }

                              _updateValues(); // Perbarui nilai lainnya
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(
                                  r'[0-9,]')), // Mengizinkan angka dan koma
                            ],
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
                            'Contoh: 8000',
                            backgroundColor: Color.fromARGB(255, 255, 255, 255),
                            onChanged: (value) {
                              // Ambil nilai harga
                              final priceValue = double.tryParse(
                                      _priceController.text
                                          .replaceAll('.', '')) ??
                                  0.0;

                              // Hitung setengah nilai harga
                              final halfPriceValue = priceValue / 2;

                              // Parse input currency
                              final currencyValue =
                                  double.tryParse(value.replaceAll('.', '')) ??
                                      0.0;

                              if (currencyValue > halfPriceValue) {
                                // Set to half of price and notify user
                                setState(() {
                                  _currencyController.text =
                                      _currencyFormat.format(halfPriceValue);
                                  _currencyController.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                        offset:
                                            _currencyController.text.length),
                                  );
                                });

                                // Optionally show a Snackbar to notify the user
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Nilai currency tidak boleh lebih dari setengah harga')),
                                );
                              } else {
                                // Update currency controller value
                                setState(() {
                                  _currencyController.value = TextEditingValue(
                                    text: _formatCurrencyInput(value),
                                    selection: TextSelection.collapsed(
                                      offset:
                                          _formatCurrencyInput(value).length,
                                    ),
                                  );
                                });
                              }

                              _updatePercentageAndVoucherFromCurrency();
                            },
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
                      'Contoh: BC-0001',
                      isOptional: true, // Tambahkan ini
                    ),
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
        ],
      ),
    );
  }

  void _updateCurrencyAndPercentageFromVoucher() {
    final voucherValue = double.tryParse(_voucherValueController.text
            .replaceAll('.', '')
            .replaceAll(',', '.')) ??
        0.0;
    final priceValue =
        double.tryParse(_priceController.text.replaceAll('.', '')) ?? 0.0;

    if (voucherValue > 0) {
      final currencyValue = voucherValue / 2;
      final percentageValue =
          priceValue > 0 ? (currencyValue / priceValue) * 100 : 0;

      setState(() {
        _currencyController.text = _currencyFormat.format(currencyValue);
        _percentageController.text =
            percentageValue.toStringAsFixed(2).replaceAll('.', ',');
      });
    }
  }

  String _formatCurrencyInput(String input) {
    String cleanInput = input.replaceAll(
        RegExp(r'[^0-9]'), ''); // Menghapus semua karakter non-digit
    double value = double.tryParse(cleanInput) ?? 0;
    return _currencyFormat.format(value);
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
                backgroundColor: const Color(0xFF005466),
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
                    _deletedFotos.add(
                        base64); // Tambahkan foto yang dihapus ke _deletedFotos
                    widget.produk.fotoProduk.removeAt(index);
                  });
                });
              }),
              // Menampilkan gambar baru yang dipilih
              ..._newFotos
                  .map((image) => _buildImageContainer(image, onDelete: () {
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    TextInputType inputType,
    String hintText, {
    Color backgroundColor = Colors.white,
    bool isReadOnly = false,
    void Function(String)? onChanged,
    bool isOptional = false,
    String? errorText, // Tampilkan pesan error
    List<TextInputFormatter>? inputFormatters, // Tambahkan inputFormatters
  }) {
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
            inputFormatters: inputFormatters, // Pasang inputFormatters di sini
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              errorText: errorText, // Tampilkan pesan error
            ),
            onChanged: onChanged,
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
                color: Color.fromARGB(255, 255, 255, 255),
                child: TextFormField(
                  controller: _voucherValueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Contoh: 16000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  onChanged: (value) {
                    // Parse the input to validate against price
                    final voucherValue =
                        double.tryParse(value.replaceAll('.', '')) ?? 0.0;

                    // Ambil nilai dari _priceController
                    final priceValue = double.tryParse(
                            _priceController.text.replaceAll('.', '')) ??
                        0.0;

                    if (voucherValue > priceValue) {
                      // Set to priceValue and notify user
                      setState(() {
                        _voucherValueController.text =
                            _currencyFormat.format(priceValue);
                        _voucherValueController.selection =
                            TextSelection.fromPosition(
                          TextPosition(
                              offset: _voucherValueController.text.length),
                        );
                      });

                      // Optionally show a Snackbar to notify the user
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Nilai Voucher tidak boleh lebih dari harga')),
                      );
                    } else {
                      // Format input di _voucherValueController sebagai nilai ribuan
                      _voucherValueController.value = TextEditingValue(
                        text: _formatCurrencyInput(value),
                        selection: TextSelection.collapsed(
                            offset: _formatCurrencyInput(value).length),
                      );
                    }

                    // Perbarui nilai _currencyController dan _percentageController
                    _updateCurrencyAndPercentageFromVoucher();
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
                    _validateFields(); // Call validation to clear the error
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
                        _validateFields();
                      });
                    },
                    backgroundColor: Colors.white,
                    labelStyle: const TextStyle(color: Colors.black),
                  );
                }).toList(),
              ),
              if (_categoryError != null) // Show category error message
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _categoryError!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
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
              iconSize: 30.0, 
            ),
          ),
        ),
      ],
    );
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
                inputFormatters: [HashtagInputFormatter()],
                decoration: InputDecoration(
                  hintText: 'Contoh: #Buku',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF004D5E),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: IconButton(
                  onPressed: _addHashtag,
                  icon: const Icon(Icons.add),
                  color: Colors.white,
                  iconSize: 30.0, // Tambahkan ukuran ikon
                ),
              ),
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

  void _addHashtag() {
    final hashtag = _hashtagController.text.trim();
    if (hashtag.isNotEmpty && !_hashtags.contains(hashtag)) {
      setState(() {
        _hashtags.add(hashtag);
        _hashtagController.clear();
      });
    }
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
            hintText:
                'Contoh: Buku cerita anak bergambar yang mendidik dan menyenangkan.',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
        ),
      ],
    );
  }

  void _updateValues() {
    // Mengganti koma dengan titik untuk menghitung desimal
    final percentageValue =
        double.tryParse(_percentageController.text.replaceAll(',', '.')) ?? 0.0;
    final currencyValue =
        double.tryParse(_priceController.text.replaceAll('.', '')) ?? 0.0;

    final voucherValue = 2 * ((percentageValue / 100) * currencyValue);
    final calculatedCurrencyValue = (percentageValue / 100) * currencyValue;

    setState(() {
      // Formatkan hasil dengan dua angka di belakang koma
      _currencyController.text =
          _currencyFormat.format(calculatedCurrencyValue);
      _voucherValueController.text = _currencyFormat.format(voucherValue);
    });
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isSubmitting ? Colors.grey : const Color(0xFF006064),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: const Text(
          'Simpan',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class HashtagInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final String newText =
        newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    // Tambahkan "#" di depan, kecuali jika string kosong.
    final formattedText = newText.isNotEmpty ? '#$newText' : '';

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
