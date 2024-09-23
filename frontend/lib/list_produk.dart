import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:trad/Model/RestAPI/service_produk.dart';
import 'package:trad/Model/produk_model.dart';
import 'package:trad/edit_produk.dart';
import 'package:trad/tambah_produk.dart';
import 'bottom_navigation_bar.dart';

class ListProduk extends StatelessWidget {
  final int id;

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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add),
                  color: const Color.fromRGBO(36, 75, 89, 1),
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
          onTap: (index) {},
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
  String searchQuery = ''; // Variabel untuk menyimpan kata kunci pencarian
  TextEditingController _searchController =
      TextEditingController(); // Controller untuk TextField pencarian
  Timer? _debounce; // Declare debounce timer

  List<String> selectedCategories = [];
  List<int> selectedRatings = [];

  @override
  void initState() {
    super.initState();
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

  Future<void> toggleProdukStatus(int id, bool newStatus) async {
    try {
      final result = await ProdukService().ubahStatusProduk(
        produkId: id,
        status: newStatus,
      );

      if (result['success']) {
        setState(() {
          futureProdukList = ProdukService().fetchProdukByTokoId(widget.id);
        });
      } else {
        showErrorOverlay(result['message']);
      }
    } catch (e) {
      showErrorOverlay(e.toString());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Cancel the debounce timer on dispose
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // If there's an active debounce timer, cancel it
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Set a new debounce timer
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        searchQuery = query; // Update the search query
      });

      // Fetch products based on the query
      if (query.isEmpty) {
        // If the query is empty, fetch all products
        futureProdukList = ProdukService().fetchProdukByTokoId(widget.id);
      } else {
        // Else, call the search function
        cariProduk(query);
      }
    });
  }

  Future<void> cariProduk(String query) async {
    try {
      // Call the service to search products based on the query
      List<Produk> produkList = await ProdukService().cariFilterProdukPerToko(
        idToko: widget.id,
        namaProduk:
            query.isEmpty ? null : query, // If query is empty, send null
      );

      setState(() {
        futureProdukList = Future.value(produkList); // Set the search results
      });
    } catch (e) {
      showErrorOverlay(e.toString());
    }
  }

  void toggleSelectAll() {
    setState(() {
      isSelectAllVisible = !isSelectAllVisible;
      if (!isSelectAllVisible) {
        selectedProduk.clear();
      }
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
          titlePadding: EdgeInsets.zero,
          title: Container(
            color: Color(0xFF337F8F),
            padding: EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Center(
                  child: const Text(
                    'Hapus Produk',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Text.rich(
            TextSpan(
              text: isAll
                  ? 'Anda yakin ingin menghapus semua produk?'
                  : 'Anda yakin ingin menghapus ',
              style: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              children: [
                if (!isAll)
                  TextSpan(
                    text: '${produk!.namaProduk}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                const TextSpan(
                  text: '?',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 108,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color(0xFF005466),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Color(0xFF005466)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                    ),
                    child: Text('Tidak'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 108,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
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
                        setState(() {
                          futureProdukList =
                              ProdukService().fetchProdukByTokoId(widget.id);
                        });
                      } catch (e) {
                        showErrorOverlay(e.toString());
                      }
                    },
                  ),
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
          titlePadding: EdgeInsets.zero,
          title: Container(
            color: const Color(0xFF337F8F),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: Text(
                    'Hapus Produk Berhasil',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Tambahkan ikon X di sebelah kanan
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); // Tutup dialog saat ikon X ditekan
                  },
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Produk berhasil dihapus',
                style: TextStyle(
                  color: Color(0xFF005466),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ImageProvider<Object> _getImageProvider(String? fotoProduk) {
    if (fotoProduk == null || fotoProduk.isEmpty) {
      return AssetImage('assets/img/default_image.png');
    } else if (fotoProduk.startsWith('/9j/')) {
      return MemoryImage(base64Decode(fotoProduk));
    } else {
      return NetworkImage(fotoProduk);
    }
  }

   void _showFilterOptions() {
  // List of categories for filtering, only including "Makanan", "Minuman", and "Beku"
  List<String> categories = ["Makanan", "Minuman", "Beku"];
  
  List<int> ratings = [5, 4, 3, 2, 1]; // Showing ratings from 5-star to 1-star

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // This allows the modal to take up more space
    builder: (context) {
      // Declare variables to hold selected categories and ratings
      List<String> selectedCategories = [];
      List<int> selectedRatings = [];

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter modalSetState) {
          return FractionallySizedBox(
            heightFactor: 0.8, // Set the height to 80% of the screen height
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: const Color(0xFFDBE7E4), // Background color #DBE7E4
                elevation: 0, // Remove shadow below AppBar
                centerTitle: false, // Title starts from the left
                automaticallyImplyLeading: false, // Prevent adding the back button or arrow
                title: const Text(
                  'Filter',
                  style: TextStyle(
                    color: Colors.black, // Set text color to black
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wrap the scrollable content in SingleChildScrollView
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            // Kategori Section
                            const Text(
                              'Kategori',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF005466), // Customize the color
                              ),
                            ),
                            const Divider(), // Moved Divider below 'Kategori'
                            const SizedBox(height: 10),
                            Column(
                              children: categories.map((category) {
                                return CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 14, // Adjust font size
                                    ),
                                  ),
                                  value: selectedCategories.contains(category),
                                  onChanged: (bool? value) {
                                    modalSetState(() {
                                      if (value == true) {
                                        selectedCategories.add(category);
                                      } else {
                                        selectedCategories.remove(category);
                                      }
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.leading, // Align checkbox to the left
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),

                            // Rating Section
                            const Text(
                              'Rating',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF005466), // Customize the color
                              ),
                            ),
                            const Divider(), // Divider added below 'Rating'
                            const SizedBox(height: 10),
                            Column(
                              children: ratings.map((rating) {
                                return CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber),
                                      Text(
                                        ' ($rating/5)',
                                        style: const TextStyle(
                                          fontSize: 14, // Adjust font size
                                        ),
                                      ),
                                    ],
                                  ),
                                  value: selectedRatings.contains(rating),
                                  onChanged: (bool? value) {
                                    modalSetState(() {
                                      if (value == true) {
                                        selectedRatings.add(rating);
                                      } else {
                                        selectedRatings.remove(rating);
                                      }
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.leading, // Align checkbox to the left
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF005466),
                            side: const BorderSide(color: Color(0xFF005466)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () {
                            // Clear selected filters
                            modalSetState(() {
                              selectedCategories.clear();
                              selectedRatings.clear();
                            });
                          },
                          child: const Text('Reset'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005466),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () {
                            // Apply filter logic here with the selected filters
                            setState(() {
                              // Save selected filters globally when Apply is pressed
                            });
                            cariProdukFiltered(
                                selectedCategories, selectedRatings);
                            Navigator.pop(context);
                          },
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  Future<void> cariProdukFiltered(
      List<String> selectedCategories, List<int> selectedRatings) async {
    try {
      // Call the service to filter products based on selected categories and ratings
      List<Produk> produkList = await ProdukService().cariFilterProdukPerToko(
        idToko: widget.id,
        kategori: selectedCategories.isNotEmpty ? selectedCategories : null,
        rating: selectedRatings.isNotEmpty ? selectedRatings.first : null,
      );

      setState(() {
        futureProdukList = Future.value(produkList); // Set the filtered results
      });
    } catch (e) {
      showErrorOverlay(e.toString());
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
          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.white,
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: const InputDecoration(
                              hintText: 'Cari produk di toko',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.filter_list, color: Colors.grey),
                          onPressed: () {
                            _showFilterOptions();
                          },
                        ),
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
                          'Jumlah Produk (0)',
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
                  Center(child: Text('Tidak ada produk'))
                ],
              ),
            ],
          );
        } else {
          final produkList = snapshot.data!;
          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.white,
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: const InputDecoration(
                              hintText: 'Cari produk di toko',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.filter_list, color: Colors.grey),
                          onPressed: () {
                            _showFilterOptions();
                          },
                        ),
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
                        final isActive = produk.statusProduk ==
                            'aktif'; // Status produk saat ini

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          color: isActive
                              ? Colors.white
                              : Colors.grey[
                                  200], // Warna background berbeda saat di-disable
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Color(0xFFDEE2E9),
                              width: 1.0,
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
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6.0),
                                      child: Container(
                                        width: 88,
                                        height: 88,
                                        color: Colors.grey[200],
                                        child: produk.fotoProduk.isNotEmpty
                                            ? Image(
                                                image: _getImageProvider(
                                                    produk.fotoProduk[0]),
                                                fit: BoxFit.cover,
                                              )
                                            : const Icon(
                                                Icons.image_not_supported),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            produk.namaProduk,
                                            style: TextStyle(
                                              color: isActive
                                                  ? Color.fromRGBO(
                                                      31, 41, 55, 1.0)
                                                  : Colors
                                                      .grey, // Gaya teks berubah jika di-disable
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
                                                  style: TextStyle(
                                                    color: isActive
                                                        ? Color(0xFF000313)
                                                        : Colors
                                                            .grey, // Gaya teks berubah jika di-disable
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Text(
                                                  'Voucher: ${produk.voucher ?? 'No voucher'}',
                                                  style: TextStyle(
                                                    color: isActive
                                                        ? Color(0xFF000313)
                                                        : Colors
                                                            .grey, // Gaya teks berubah jika di-disable
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
                                                  style: TextStyle(
                                                    color: isActive
                                                        ? Color(0xFF000313)
                                                        : Colors
                                                            .grey, // Gaya teks berubah jika di-disable
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Text(
                                                  'Terjual: ${produk.terjual}',
                                                  style: TextStyle(
                                                    color: isActive
                                                        ? Color(0xFF000313)
                                                        : Colors
                                                            .grey, // Gaya teks berubah jika di-disable
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
                                      padding:
                                          const EdgeInsets.only(left: 95.0),
                                      child: CustomSwitch(
                                        produk: produk,
                                        onToggle: (newStatus) {
                                          toggleProdukStatus(
                                              produk.id, newStatus);
                                        },
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: isActive
                                              ? () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditProdukScreen(
                                                              produk: produk),
                                                    ),
                                                  );
                                                }
                                              : null, // Nonaktifkan tombol jika produk tidak aktif
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                const Color(0xFF005466),
                                            backgroundColor: Colors.white,
                                            side: const BorderSide(
                                                color: Color(0xFF005466)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text('Ubah'),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton(
                                          onPressed: isActive
                                              ? () {
                                                  if (selectedProduk.length >
                                                      1) {
                                                    showDeleteConfirmationOverlay(
                                                        isAll: true);
                                                  } else {
                                                    showDeleteConfirmationOverlay(
                                                        produk: produk);
                                                  }
                                                }
                                              : null, // Nonaktifkan tombol jika produk tidak aktif
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                const Color(0xFFEF4444),
                                            backgroundColor: Colors.white,
                                            side: const BorderSide(
                                                color: Color(0xFFEF4444)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text('Hapus'),
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
  final Produk produk;
  final ValueChanged<bool> onToggle;

  CustomSwitch({required this.produk, required this.onToggle});

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  late bool isActive;

  @override
  void initState() {
    super.initState();
    // Konversi status string dari produk menjadi boolean
    isActive = widget.produk.statusProduk == 'aktif';
  }

  void _toggleSwitch() async {
    setState(() {
      isActive = !isActive; // Toggle status
    });

    try {
      // Panggil API dengan mengirimkan status sebagai boolean
      final result = await ProdukService().ubahStatusProduk(
        produkId: widget.produk.id,
        status: isActive,
      );

      if (result['success']) {
        // Jika berhasil, update status di frontend
        setState(() {
          widget.produk.statusProduk = isActive ? 'aktif' : 'nonaktif';
        });
        widget.onToggle(isActive);
      } else {
        setState(() {
          isActive = !isActive; // Kembalikan status sebelumnya jika gagal
        });
        _showErrorOverlay(result['message']);
      }
    } catch (e) {
      setState(() {
        isActive = !isActive; // Kembalikan status sebelumnya jika ada error
      });
      print('Error while toggling the status: $e');
      _showErrorOverlay(e.toString());
    }
  }

  void _showErrorOverlay(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Gagal Mengubah Status Produk'),
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
