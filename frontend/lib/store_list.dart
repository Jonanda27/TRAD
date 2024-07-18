import 'package:flutter/material.dart';
import 'package:trad/Screen/HomeScreen/home_screen.dart';
import 'main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Toko',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Josefin Sans',
      ),
      home: StoreListPage(),
    );
  }
}

class StoreListPage extends StatefulWidget {
  @override
  _StoreListPageState createState() => _StoreListPageState();
}

class _StoreListPageState extends State<StoreListPage> {
  bool _isSelecting = false;
  List<bool> _selected = List.generate(3, (_) => false);

  void _showDeleteConfirmation(BuildContext context, String storeName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Apakah Anda Yakin ingin Menghapus Toko $storeName?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Hapus'),
              onPressed: () {
                // Handle delete action here
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(36, 75, 89, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        title: Center(
          child: Text(
            'Daftar Toko',
            style: TextStyle(color: Colors.white, fontFamily: 'Josefin Sans'),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.store_mall_directory, color: Colors.white),
            onPressed: () {
              // Handle add button press
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.lightBlue[100],
                hintText: 'Cari Toko',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Jumlah Toko : 3'),
                TextButton(
                  child: Text(_isSelecting ? 'Kembali' : 'Pilih Sekaligus'),
                  onPressed: () {
                    setState(() {
                      _isSelecting = !_isSelecting;
                      _selected = List.generate(3, (_) => false);
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          if (_isSelecting)
                            Checkbox(
                              value: _selected[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  _selected[index] = value!;
                                });
                              },
                            ),
                          Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('SMOKE.IN BANDUNG'),
                                  Text('Dibuat : 11 Juli 2022'),
                                  Text('No. Telepon : 081234456778'),
                                  Text('Alamat : Jalan Papanggungan no 32'),
                                  Text('Lokasi : Bandung, Jawa Barat, Indonesia'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: PopupMenuButton<String>(
                          onSelected: (String result) {
                            if (result == 'Edit') {
                              // Handle edit action
                            } else if (result == 'Hapus') {
                              _showDeleteConfirmation(context, 'SMOKE.IN BANDUNG');
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'Edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'Hapus',
                              child: Text('Hapus'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isSelecting && _selected.contains(true)
          ? Container(
              color: Colors.red,
              child: TextButton(
                child: Text(
                  'Hapus',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _showDeleteConfirmation(context, 'terpilih');
                },
              ),
            )
          : null,
    );
  }
}