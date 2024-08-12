import 'package:flutter/material.dart';

class TambahToko extends StatefulWidget {
  @override
  _TambahTokoState createState() => _TambahTokoState();
}

class _TambahTokoState extends State<TambahToko> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Set back arrow color to white
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Tambah Toko',
          style: TextStyle(color: Colors.white), // Set title text color to white
        ),
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1), // Customize the color to match the image
        iconTheme: const IconThemeData(color: Colors.white), // Set back arrow color to white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Background Toko',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Text('Unggah',
                          style: TextStyle(color: Colors.black54)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Info Toko',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 80,
                  width: 80,
                  color: Colors.grey[200],
                  child: Icon(Icons.store, size: 40, color: Colors.teal[700]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Nama Toko',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Kategori'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(
                              36, 75, 89, 1), // Customize the button color
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
