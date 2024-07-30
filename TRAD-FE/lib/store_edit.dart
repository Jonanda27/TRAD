import 'package:flutter/material.dart';
import 'package:trad/store_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Toko',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: EditStoreScreen(),
    );
  }
}

class EditStoreScreen extends StatefulWidget {
  @override
  _EditStoreScreenState createState() => _EditStoreScreenState();
}

class _EditStoreScreenState extends State<EditStoreScreen> {
  bool showCategoryOverlay = false;
  String selectedCategory = "Makanan";
  Map<String, Map<String, dynamic>> operatingHours = {
    'Senin': {'open': '08:00', 'close': '18:00', 'isOpen': true},
    'Selasa': {'open': '08:00', 'close': '18:00', 'isOpen': true},
    'Rabu': {'open': '08:00', 'close': '18:00', 'isOpen': true},
    'Kamis': {'open': '08:00', 'close': '18:00', 'isOpen': true},
    'Jumat': {'open': '08:00', 'close': '18:00', 'isOpen': true},
    'Sabtu': {'open': '08:00', 'close': '18:00', 'isOpen': true},
    'Minggu': {'open': '08:00', 'close': '18:00', 'isOpen': false},
  };

  TextEditingController _namaTokoController = TextEditingController();

  Future<void> _selectTime(
      BuildContext context, String day, String type) async {
    final TimeOfDay initialTime = TimeOfDay(
      hour: int.parse(operatingHours[day]![type].split(':')[0]),
      minute: int.parse(operatingHours[day]![type].split(':')[1]),
    );
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        operatingHours[day]![type] =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void handleCategorySelect(String category) {
    setState(() {
      selectedCategory = category;
      showCategoryOverlay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 84, 102, 1), // teal-700
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StoreListPage()),
            );
          },
        ),
        title: Text(
          'Edit Toko',
          style: TextStyle(color: Colors.white), // Change text color to white
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              Text('Foto Background Toko',
                  style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 8.0),
              Row(
                children: List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              Icon(Icons.camera_alt, color: Colors.grey[400]),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Icon(Icons.close,
                              color: Colors.grey[500], size: 16),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text('4/5',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                padding: EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text('Gambar Profil Toko',
                            style: TextStyle(color: Colors.grey[600])),
                        SizedBox(height: 8.0),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text('IN',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200]),
                          child: Text('Unggah Gambar',
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nama Toko',
                              style: TextStyle(color: Colors.grey[600])),
                          TextField(
                            controller: _namaTokoController,
                            decoration: InputDecoration(
                              hintText: 'Masukkan Nama Toko',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 16.0),
                            ),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16.0),
                          Text('Kategori Toko',
                              style: TextStyle(color: Colors.grey[600])),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    setState(() => showCategoryOverlay = true),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange[100]),
                                child: Text('Ubah',
                                    style:
                                        TextStyle(color: Colors.orange[500])),
                              ),
                              Text(selectedCategory,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Text('Alamat Toko',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              buildAddressField(
                  'Pilih Provinsi, Kota, Kecamatan, Kode Pos',
                  const Color.fromRGBO(88, 137, 140, 1),
                  Color.fromARGB(255, 255, 255, 255) ?? Colors.teal),
              buildAddressField(
                  'Nama Jalan, Gedung, No. Rumah',
                  const Color.fromRGBO(223, 242, 241, 1),
                  const Color.fromRGBO(104, 139, 141, 1) ?? Colors.grey),
              buildAddressField(
                  'Detail Lainnya (Cth: Block / Unit No., Patokan, dll.)',
                  const Color.fromRGBO(223, 242, 241, 1),
                  const Color.fromRGBO(104, 139, 141, 1) ?? Colors.grey),
              buildLabeledField('Nomor Telepon', 'Nomer Telepon Toko',
                  Color.fromRGBO(104, 139, 141, 1)),
              buildLabeledField('E-mail Toko (Optional)',
                  'E-mail Toko (Optional)', Color.fromRGBO(104, 139, 141, 1)),
              buildLabeledField(
                  'Deskripsi', 'Deskripsi', Color.fromRGBO(104, 139, 141, 1),
                  isTextArea: true),
              SizedBox(height: 16.0),
              Text('Jam Operasional',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 8.0),
              ...operatingHours.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 80, child: Text(entry.key)),
                        if (entry.key != 'Minggu') ...[
                          InkWell(
                            onTap: () =>
                                _selectTime(context, entry.key, 'open'),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(entry.value['open']),
                            ),
                          ),
                          Text('-'),
                          InkWell(
                            onTap: () =>
                                _selectTime(context, entry.key, 'close'),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(entry.value['close']),
                            ),
                          ),
                        ] else
                          Text('Toko Tutup',
                              style: TextStyle(color: Colors.grey)),
                        Row(
                          children: [
                            Switch(
                              value: entry.value['isOpen'],
                              onChanged: (bool value) {
                                setState(() {
                                  operatingHours[entry.key]!['isOpen'] = value;
                                });
                              },
                              activeColor: Color.fromRGBO(60, 109, 114, 0),
                            ),
                            Text('Buka'),
                          ],
                        ),
                      ],
                    ),
                  )),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {},
                style:
                    ElevatedButton.styleFrom(backgroundColor: Color(0xF0F0F0)),
                child: Text('Simpan Perubahan',
                    style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1))),
              ),
            ],
          ),
          if (showCategoryOverlay)
            CategoryOverlay(
              onClose: () => setState(() => showCategoryOverlay = false),
              onSelect: handleCategorySelect,
            ),
        ],
      ),
    );
  }

  Widget buildAddressField(
      String placeholder, Color backgroundColor, Color placeholderColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: backgroundColor,
          hintText: placeholder,
          hintStyle: TextStyle(color: placeholderColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget buildLabeledField(String label, String placeholder, Color color,
      {bool isTextArea = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Color(0xFF000000))),
          SizedBox(height: 4.0),
          TextField(
            maxLines: isTextArea ? 5 : 1,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromRGBO(223, 242, 241, 1),
              hintText: placeholder,
              hintStyle:
                  TextStyle(color: const Color.fromRGBO(104, 139, 141, 1)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final Function(String) onSelect;

  CategoryOverlay({required this.onClose, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pilih Kategori Toko Kamu',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 8.0),
              ListTile(
                title: Text('Tempat Makanan dan Minuman'),
                onTap: () => onSelect('Makanan'),
              ),
              ListTile(
                title: Text('Tempat Market'),
                onTap: () => onSelect('Market'),
              ),
              ListTile(
                title: Text('Tempat Jasa'),
                onTap: () => onSelect('Jasa'),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: Text('Tutup', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
