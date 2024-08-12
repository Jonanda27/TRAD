import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';
import 'main.dart';
import 'produk_edit.dart';
import 'package:trad/Screen/HomeScreen/home_screen.dart';


class ProductListing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
          title: Text(
            'Produk Toko',
            style: TextStyle(color: Colors.white), // Set text color to white
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
        ),
        body: ProductList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
          child: Icon(Icons.add),
        ),
        // bottomNavigationBar: MyBottomNavigationBar(
        //   currentIndex: 0, // Ganti dengan index yang sesuai
        //   onTap: (index) {
        //     // Lakukan navigasi atau aksi sesuai dengan index yang dipilih
        //   },
        // ), // Add this line
      ),
    );
  }
}

class Product {
  final int id;
  final String name;
  final int price;
  final int voucher;
  final double rating;
  final int ratingCount;
  final int sold;
  bool isActive;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.voucher,
    required this.rating,
    required this.ratingCount,
    required this.sold,
    this.isActive = false,
  });
}

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<Product> products = [
    Product(
      id: 1,
      name: 'Smoke Chicken ThighPremium by SMOKE.IN',
      price: 35000,
      voucher: 35000,
      rating: 5.0,
      ratingCount: 1234,
      sold: 1234,
      isActive: true,
    ),
    Product(
      id: 2,
      name: 'Smoked Beef RibsPremium by SMOKE.IN',
      price: 45000,
      voucher: 45000,
      rating: 5.0,
      ratingCount: 1500,
      sold: 1500,
      isActive: false,
    ),
  ];

  List<int> selectedProducts = [];
  bool isSelectAllVisible = false;

  void toggleProductSelection(int id) {
    setState(() {
      if (selectedProducts.contains(id)) {
        selectedProducts.remove(id);
      } else {
        selectedProducts.add(id);
      }
    });
  }

  void toggleProductStatus(int id) {
    setState(() {
      products = products.map((product) {
        if (product.id == id) {
          product.isActive = !product.isActive;
        }
        return product;
      }).toList();
    });
  }

  void showDeleteConfirmationOverlay({Product? product, bool isAll = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Produk'),
          content: Text(isAll
              ? 'Anda Yakin ingin Menghapus semua Produk?'
              : 'Anda Yakin ingin Menghapus ${product!.name}?'),
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
                setState(() {
                  if (isAll) {
                    products.removeWhere((product) =>
                        selectedProducts.contains(product.id));
                    selectedProducts.clear();
                  } else {
                    products.remove(product);
                    selectedProducts.remove(product!.id);
                  }
                });
                Navigator.of(context).pop();
                showSuccessOverlay();
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
          title: Text('Hapus Produk Berhasil'),
          content: Column(
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
              child: Text('OK'),
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
        selectedProducts.clear();
      } else {
        selectedProducts = products.map((product) => product.id).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              margin: EdgeInsets.all(8.0),
              child: Row(
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jumlah Produk (${products.length})',
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: toggleSelectAll,
                    child: Text(
                      isSelectAllVisible ? 'Batal' : 'Pilih semua',
                      style: TextStyle(color: const Color.fromRGBO(0, 84, 102, 1)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (isSelectAllVisible)
                                Checkbox(
                                  value: selectedProducts.contains(product.id),
                                  onChanged: (_) => toggleProductSelection(product.id),
                                ),
                              Container(
                                width: 64,
                                height: 64,
                                color: Colors.grey[200],
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('Harga: Rp ${product.price.toString()}'),
                                    Text('Voucher: ${product.voucher.toString()}'),
                                    Text('Rating: ${product.rating.toString()}/5.0 (${product.ratingCount})'),
                                    Text('Terjual: ${product.sold}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomSwitch(
                                isActive: product.isActive,
                                onToggle: () => toggleProductStatus(product.id),
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => EditProductScreen()),
                                      );
                                    },
                                    child: Text(
                                      'Ubah',
                                      style: TextStyle(color: const Color.fromRGBO(0, 84, 102, 1)),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (selectedProducts.length > 1) {
                                        showDeleteConfirmationOverlay(isAll: true);
                                      } else {
                                        showDeleteConfirmationOverlay(product: product);
                                      }
                                    },
                                    child: Text(
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
        if (selectedProducts.isNotEmpty)
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: ElevatedButton(
              onPressed: () {
                if (selectedProducts.length > 1) {
                  showDeleteConfirmationOverlay(isAll: true);
                } else {
                  var product = products.firstWhere(
                      (product) => product.id == selectedProducts.first);
                  showDeleteConfirmationOverlay(product: product);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Hapus'),
            ),
          ),
      ],
    );
  }
}

class CustomSwitch extends StatelessWidget {
  final bool isActive;
  final Function onToggle;

  const CustomSwitch({required this.isActive, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onToggle();
      },
      child: Container(
        width: 72,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isActive ? const Color.fromRGBO(0, 84, 102, 1) : Colors.grey,
        ),
        child: Stack(
          children: [
            Align(
              alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: isActive ? EdgeInsets.only(right: 8) : EdgeInsets.only(left: 8),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: isActive ? EdgeInsets.only(right: 8) : EdgeInsets.only(left: 8),
                child: Text(
                  isActive ? 'Aktif' : 'Non Aktif',
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
