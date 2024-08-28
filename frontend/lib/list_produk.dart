import 'dart:convert'; // Untuk menggunakan base64 decoding

import 'package:flutter/material.dart';
import 'package:trad/Model/RestAPI/service_produk.dart';
import 'package:trad/Model/produk_model.dart';
import 'package:trad/edit_produk.dart';
import 'package:trad/tambah_produk.dart';
import 'bottom_navigation_bar.dart';

class ListProduk extends StatelessWidget {
  final int id; // ID dari tabel toko (idToko)

  const ListProduk({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Produk Toko',
                style: TextStyle(color: Colors.white),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Background color white
                  borderRadius:
                      BorderRadius.circular(6), // Rounded corners with radius 6
                ),
                child: IconButton(
                  icon: const Icon(Icons.add),
                  color:
                      const Color.fromRGBO(36, 75, 89, 1), // Icon color green
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TambahProdukScreen(idToko: id)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        body: ProdukList(id: id),
        bottomNavigationBar: MyBottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            // Perform navigation or actions based on the selected index
          },
          userId: id,
        ),
      ),
    );
  }
}

class ProdukList extends StatefulWidget {
  final int id;

  const ProdukList({Key? key, required this.id}) : super(key: key);

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
    // Gunakan service fetchProdukByTokoId untuk mendapatkan data produk berdasarkan idToko
    futureProdukList = ProdukService().fetchProdukByTokoId(widget.id);
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          titlePadding: EdgeInsets.zero, // Remove default padding
          title: Container(
            color: Color(0xFF337F8F), // Background color for the title
            padding: EdgeInsets.all(16.0), // Add padding to the title
            child: Center(
              child: Text(
                'Hapus Produk',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Text color for the title
                ),
              ),
            ),
          ),
          content: Text(
            isAll
                ? 'Anda yakin ingin menghapus semua produk?'
                : 'Anda yakin ingin menghapus ${produk!.namaProduk}?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF005466),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF005466),
                    backgroundColor: Colors.white, // Text color
                    side: BorderSide(color: Color(0xFF005466)), // Border color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  ),
                  child: Text('Tidak'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFFEF4444), // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  ),
                  child: Text('Ya'),
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
                      }
                      showSuccessOverlay();
                      // Refresh the product list after deletion
                      setState(() {
                        futureProdukList =
                            ProdukService().fetchProdukByTokoId(widget.id);
                      });
                    } catch (e) {
                      showErrorOverlay(e.toString());
                    }
                  },
                ),
              ],
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          titlePadding: EdgeInsets.zero, // Remove default padding
          title: Container(
            color: Color(0xFF337F8F), // Background color for the title
            padding: EdgeInsets.all(16.0), // Add padding to the title
            child: Center(
              child: Text(
                'Hapus Produk Berhasil',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Text color for the title
                ),
                textAlign: TextAlign.center, // Ensure text is centered
              ),
            ),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Produk berhasil dihapus',
                style: TextStyle(
                  color: Color(0xFF005466), // Text color for the content
                ),
              ),
            ],
          ),
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

  ImageProvider<Object> _getImageProvider(String? fotoProduk) {
    if (fotoProduk == null || fotoProduk.isEmpty) {
      return AssetImage(
          'assets/img/default_image.png'); // Provide a default image
    } else if (fotoProduk.startsWith('/9j/')) {
      return MemoryImage(base64Decode(fotoProduk));
    } else {
      return NetworkImage(fotoProduk);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Produk>>(
      key: UniqueKey(),
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
                          color: Colors
                              .white, // Set the background color of the card to white
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8), // You can adjust the radius as needed
                            side: BorderSide(
                              color: Color(0xFFDEE2E9), // Set the outline color
                              width: 1.0, // Set the width of the outline
                            ),
                          ),
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
                                      width: 88,
                                      height: 88,
                                      color: Colors.grey[200],
                                      child: produk.fotoProduk.isNotEmpty
                                          ? Image(
                                              image: _getImageProvider(
                                                  produk.fotoProduk[0]),
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(Icons.image_not_supported),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            produk.namaProduk,
                                            style: const TextStyle(
                                              color: Color.fromRGBO(
                                                  31, 41, 55, 1.0),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Harga: Rp ${(produk.harga).toString()}',
                                                  style: const TextStyle(
                                                    color: Color(0xFF000313),
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Text(
                                                  'Voucher: ${produk.voucher ?? 'No voucher'}',
                                                  style: const TextStyle(
                                                    color: Color(0xFF000313),
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Rating: ${(produk.rating).toString()}/5.0 (${produk.rating})',
                                                  style: const TextStyle(
                                                    color: Color(0xFF000313),
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Text(
                                                  'Terjual: ${produk.terjual}',
                                                  style: const TextStyle(
                                                    color: Color(0xFF000313),
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 95.0), // Add left padding here
                                      child: CustomSwitch(
                                        isActive: produk.statusProduk,
                                        onToggle: (newStatus) {
                                          // Perbarui status produk di sini sesuai dengan newStatus
                                          setState(() {
                                            produk.statusProduk = newStatus;
                                          });
                                          // Optionally, send the new status to the server
                                          // toggleProdukStatus(produk.id);
                                        },
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditProdukScreen(
                                                  produk:
                                                      produk, // Mengirimkan data produk yang akan diedit
                                                ),
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                const Color(0xFF005466),
                                            backgroundColor: Colors.white,
                                            side: const BorderSide(
                                                color: Color(
                                                    0xFF005466)), // Text color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      6), // Set the radius to 6
                                            ),
                                          ),
                                          child: const Text(
                                            'Ubah',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
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
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                const Color(0xFFEF4444),
                                            backgroundColor: Colors.white,
                                            side: const BorderSide(
                                              color: Color(0xFFEF4444),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      6), // Set the radius to 6
                                            ),
                                          ),
                                          child: const Text(
                                            'Hapus',
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

class CustomSwitch extends StatefulWidget {
  final bool isActive;
  final ValueChanged<bool> onToggle;

  CustomSwitch({required this.isActive, required this.onToggle});

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  late bool isActive;

  @override
  void initState() {
    super.initState();
    isActive = widget.isActive;
  }

  void _toggleSwitch() {
    setState(() {
      isActive = !isActive;
    });
    widget.onToggle(isActive);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleSwitch,
      child: Container(
        width: 60,
        height: 30,
        decoration: BoxDecoration(
          color: isActive ? Color(0xFF005466) : Colors.grey[300],
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
