import 'package:flutter/material.dart';
import 'package:trad/edit_profile.dart';
import 'package:trad/main.dart';

class EditInfoProfile extends StatefulWidget {
  final String title;
  final String initialValue;
  final void Function(String) onSave;

  EditInfoProfile({
    required this.title,
    required this.initialValue,
    required this.onSave,
  });

  @override
  _EditInfoProfileState createState() => _EditInfoProfileState();
}

class _EditInfoProfileState extends State<EditInfoProfile> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Color(0xFF005466),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: widget.title),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onSave(_controller.text);
                Navigator.pop(context);
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
