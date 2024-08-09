import 'package:flutter/material.dart';
import 'package:trad/Model/RestAPI/service_produk.dart';
import 'package:trad/Model/produk_model.dart';
import 'package:trad/Screen/HomeScreen/home_screen.dart';
import 'package:trad/tambah_produk.dart';
import 'bottom_navigation_bar.dart';

class ListProduk extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
          title: const Text(
            'Produk Toko',
            style: TextStyle(color: Colors.white), // Set text color to white
          ),
        ),
        body: ProdukList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TambahProdukScreen()),
            );
          },
          backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: MyBottomNavigationBar(
          currentIndex: 0, // Change to the appropriate index
          onTap: (index) {
            // Perform navigation or actions based on the selected index
          },
        ),
      ),
    );
  }
}

class ProdukList extends StatefulWidget {
  @override
  _ProdukListState createState() => _ProdukListState();
}

class _ProdukListState extends State<ProdukList> {
  late Future<List<Produk>> futureProdukList;
  List<int> selectedProduk = [];
  bool isSelectAllVisible = false;

  @override
  void initState() {
    super.initState();
    futureProdukList = ProdukService().fetchProdukList();
  }

  void toggleProdukSelection(int id) {
    setState(() {
      if (selectedProduk.contains(id)) {
        selectedProduk.remove(id);
      } else {
        selectedProduk.add(id);
      }
    });
  }

  void toggleProdukStatus(int id) {
    setState(() {
      // This should ideally update the status on the server as well
    });
  }

  void showDeleteConfirmationOverlay({Produk? produk, bool isAll = false}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text(isAll
            ? 'Anda Yakin ingin Menghapus semua Produk?'
            : 'Anda Yakin ingin Menghapus ${produk!.name}?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Hapus'),
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                if (isAll) {
                  for (var id in selectedProduk) {
                    await ProdukService().hapusProduk(id);
                  }
                  selectedProduk.clear();
                } else {
                  await ProdukService().hapusProduk(produk!.id);
                  setState(() {
                    futureProdukList = ProdukService().fetchProdukList();
                  });
                }
                showSuccessOverlay();
              } catch (e) {
                showErrorOverlay(e.toString());
              }
            },
          ),
        ],
      );
    },
  );
}

void showErrorOverlay(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Hapus Produk Gagal'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

  void showSuccessOverlay() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Produk Berhasil'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              SizedBox(height: 16),
              Text('Produk berhasil Dihapus'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void toggleSelectAll() {
    setState(() {
      isSelectAllVisible = !isSelectAllVisible;
      if (!isSelectAllVisible) {
        selectedProduk.clear();
      } else {
        // Ideally, fetch the product IDs from the server
        // Here we simulate by clearing and adding all IDs
        selectedProduk = []; // Replace this with actual IDs if necessary
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Produk>>(
      future: futureProdukList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No products available'));
        } else {
          final produkList = snapshot.data!;
          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    margin: const EdgeInsets.all(8.0),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Cari produk di toko',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Icon(Icons.more_vert, color: Colors.grey),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jumlah Produk (${produkList.length})',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: toggleSelectAll,
                          child: Text(
                            isSelectAllVisible ? 'Batal' : 'Pilih semua',
                            style: const TextStyle(
                                color: Color.fromRGBO(0, 84, 102, 1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: produkList.length,
                      itemBuilder: (context, index) {
                        final produk = produkList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (isSelectAllVisible)
                                      Checkbox(
                                        value:
                                            selectedProduk.contains(produk.id),
                                        onChanged: (_) =>
                                            toggleProdukSelection(produk.id),
                                      ),
                                    Container(
                                      width: 64,
                                      height: 64,
                                      color: Colors.grey[200],
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              produk.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                                'Harga: Rp ${(produk.harga).toString()}'),
                                            Text(
                                                'Voucher: ${produk.voucher ?? 'No voucher'}'),
                                            Text(
                                                'Rating: ${(produk.rating).toString()}/5.0 (${produk.rating})'),
                                            Text('Terjual: ${produk.terjual}'),
                                          ]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomSwitch(
                                      isActive: produk.statusProduk,
                                      onToggle: () =>
                                          toggleProdukStatus(produk.id),
                                    ),
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TambahProdukScreen()),
                                            );
                                          },
                                          child: const Text(
                                            'Ubah',
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    0, 84, 102, 1)),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            if (selectedProduk.length > 1) {
                                              showDeleteConfirmationOverlay(
                                                  isAll: true);
                                            } else {
                                              showDeleteConfirmationOverlay(
                                                  produk: produk);
                                            }
                                          },
                                          child: const Text(
                                            'Hapus',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (selectedProduk.isNotEmpty)
                Positioned(
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedProduk.length > 1) {
                        showDeleteConfirmationOverlay(isAll: true);
                      } else {
                        var produk = produkList.firstWhere(
                            (produk) => produk.id == selectedProduk.first);
                        showDeleteConfirmationOverlay(produk: produk);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Hapus'),
                  ),
                ),
            ],
          );
        }
      },
    );
  }
}

class CustomSwitch extends StatelessWidget {
  final bool isActive;
  final VoidCallback onToggle;

  CustomSwitch({required this.isActive, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 60,
        height: 30,
        decoration: BoxDecoration(
          color: isActive ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment:
                  isActive ? Alignment.centerRight : Alignment.centerLeft,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
