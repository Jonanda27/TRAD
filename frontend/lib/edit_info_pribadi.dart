import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trad/Provider/profile_provider.dart';

class EditInfoPribadiPage extends StatefulWidget {
  @override
  _EditInfoPribadiPageState createState() => _EditInfoPribadiPageState();
}

class _EditInfoPribadiPageState extends State<EditInfoPribadiPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime _birthDate = DateTime.now();
  String? _gender; // Changed to nullable

  @override
  void initState() {
    super.initState();
    final profileData = context.read<ProfileProvider>().profileData;
    _emailController.text = profileData['email'] ?? '';
    _phoneController.text = profileData['noHp'] ?? '';
    _birthDate = profileData['tanggalLahir'] != null
        ? DateTime.parse(profileData['tanggalLahir'])
        : DateTime.now();
    _gender = profileData['jenisKelamin'];
    _dateController.text = DateFormat('dd MMMM yyyy').format(_birthDate);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
        _dateController.text = DateFormat('dd MMMM yyyy').format(_birthDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Info Pribadi', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF005466),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Regex for email validation
                  final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType:
                    TextInputType.phone, // Menampilkan keyboard numerik
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  // Regex untuk memvalidasi bahwa nomor telepon hanya berisi angka dan simbol +
                  final regex = RegExp(r'^\+?[0-9]*$');
                  if (!regex.hasMatch(value)) {
                    return 'Only numbers and + symbol are allowed';
                  }
                  if (value.length < 10 || value.length > 15) {
                    return 'Phone number should be between 10-15 digits';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tanggal Lahir',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: DateFormat('dd MMMM yyyy').format(_birthDate),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap masukkan tanggal lahir';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(child: Text('Male'), value: 'L'),
                  DropdownMenuItem(child: Text('Female'), value: 'P'),
                ],
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                child: Text('Simpan'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await context.read<ProfileProvider>().updatePersonalInfo({
                        'email': _emailController.text,
                        'noHp': _phoneController.text,
                        'tanggalLahir':
                            DateFormat('yyyy-MM-dd').format(_birthDate),
                        'jenisKelamin': _gender ?? '',
                      });
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Failed to update personal info')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF005466),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
