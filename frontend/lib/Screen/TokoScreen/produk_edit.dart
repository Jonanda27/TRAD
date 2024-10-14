import 'package:flutter/material.dart';
import 'package:trad/Screen/TokoScreen/produk_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EditProductScreen(),
    );
  }
}

class EditProductScreen extends StatefulWidget {
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  double _profitShareValue = 10;
  TextEditingController _productNameController = TextEditingController(text: 'Smoked IN Ayam Betukok');
  TextEditingController _priceController = TextEditingController(text: '50000');
  TextEditingController _voucherValueController = TextEditingController(text: '175wwwgsjBpq');
  TextEditingController _productCodeController = TextEditingController(text: '000001');
  TextEditingController _descriptionController = TextEditingController(text: 'Smoked IN Ayam Betukok enak banget');

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Process the form data
      print('Form submitted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 84, 102, 1),
        title: Text(
          'Edit Produk',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProductListing()),
            );
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildImagePlaceholder(),
                    _buildImagePlaceholder(),
                    _buildImagePlaceholder(),
                  ],
                ),
                SizedBox(height: 20),
                _buildTextField('Nama Produk', _productNameController, TextInputType.text),
                SizedBox(height: 15),
                _buildTextField('Harga', _priceController, TextInputType.number),
                SizedBox(height: 15),
                _buildProfitShareSlider(),
                SizedBox(height: 15),
                _buildTextField('Nilai Voucher', _voucherValueController, TextInputType.text),
                SizedBox(height: 15),
                _buildTextField('Kode Produk (Opsional)', _productCodeController, TextInputType.text),
                SizedBox(height: 15),
                _buildCategoryTags(),
                SizedBox(height: 15),
                _buildHashtagTags(),
                SizedBox(height: 15),
                _buildDescriptionField(),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF006064),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: _submitForm,
                  child: Text(
                    'Masukkan ke daftar produk',
                    style: TextStyle(color: Colors.white), // Set text color to white
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 100,
      height: 100,
      color: Color(0xFFE0E0E0),
      child: Center(
        child: Text(
          '+',
          style: TextStyle(fontSize: 24, color: Color(0xFF757575)),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType inputType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black)),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildProfitShareSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bagi Hasil', style: TextStyle(color: Colors.black)),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _profitShareValue,
                min: 0,
                max: 100,
                onChanged: (value) {
                  setState(() {
                    _profitShareValue = value;
                  });
                },
              ),
            ),
            Text('${_profitShareValue.toInt()}%'),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kategori Produk', style: TextStyle(color: Colors.black)),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            _buildTag('Makanan'),
            _buildTag('Minuman'),
            _buildTag('+ Kategori'),
          ],
        ),
      ],
    );
  }

  Widget _buildHashtagTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hashtag', style: TextStyle(color: Colors.black)),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            _buildTag('#Ayam'),
            _buildTag('+ Hashtag'),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Chip(
      label: Text(text),
      backgroundColor: Color(0xFFE0E0E0),
      deleteIcon: text.startsWith('+') ? null : Icon(Icons.close, size: 16),
      onDeleted: text.startsWith('+') ? null : () {
        // Handle delete tag
      },
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Deskripsi', style: TextStyle(color: Colors.black)),
        SizedBox(height: 5),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
        ),
      ],
    );
  }
}
