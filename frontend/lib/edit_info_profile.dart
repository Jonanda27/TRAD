import 'package:flutter/material.dart';

class EditInfoProfilePage extends StatefulWidget {
  @override
  _EditInfoProfilePageState createState() => _EditInfoProfilePageState();
}

class _EditInfoProfilePageState extends State<EditInfoProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String _name = 'Michael Desmond Limanto';
  String _userID = 'macdeli';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Info Profil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF005466),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap masukkan nama';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                initialValue: _userID,
                decoration: InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap masukkan User ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  _userID = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Simpan perubahan dan kembali ke halaman sebelumnya
                    Navigator.pop(context);
                  }
                },
                child: Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF005466), // background
                  foregroundColor: Colors.white, // foreground
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

