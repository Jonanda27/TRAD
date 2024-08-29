import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trad/profile.dart';
import 'package:trad/verifikasi_pin.dart';
import 'package:trad/Model/RestAPI/service_bank.dart';

class TambahRekeningBankPage extends StatefulWidget {
  final int userId;
  const TambahRekeningBankPage({Key? key, required this.userId})
      : super(key: key);

  @override
  _TambahRekeningBankPageState createState() => _TambahRekeningBankPageState();
}

class _TambahRekeningBankPageState extends State<TambahRekeningBankPage> {
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  String? _selectedBank;
  final BankService _bankService = BankService();

  final List<String> _banks = [
    'Bank Mandiri',
    'Bank BRI',
    'Bank BCA',
    'Bank BSI',
  ];

  void _saveBankAccount() {
    if (_validateInputs()) {
      final newBankDetails = {
        'namaBank': _selectedBank!,
        'pemilikRekening': _ownerController.text,
        'nomorRekening': _accountNumberController.text,
      };

            Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifikasiPinPage(
            onPinVerified: (String pin) async {
              try {
                await _bankService.addBankAccount(
                    widget.userId, pin, newBankDetails);
                // Show success pop-up
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Dialog Header with Title and Close Button
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Color(
                                  0xFF4D919E), // Teal color for the header (same as error pop-up)
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ubah Data Berhasil',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors
                                        .white, // White text for the title
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close,
                                      color: Colors.white), // White close icon
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(
                                16.0), // Main content padding
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 16),
                                // Success Icon
                                CircleAvatar(
                                  backgroundColor: Colors.green,
                                  radius: 30,
                                  child: Icon(Icons.check,
                                      color: Colors.white, size: 30),
                                ),
                                SizedBox(height: 16),
                                // Success Message
                                Text(
                                  'Data telah berhasil diperbarui',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors
                                          .black), // Same font style as error pop-up
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).then((_) =>
                    Navigator.of(context).popUntil((route) => route.settings.name == ProfileScreen));
              } catch (e) {
                print('Error updating bank account: $e');
                // Show an error message to the user
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Dialog Header with Title and Close Button
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Color(
                                  0xFF4D919E), // Teal color from the header
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ubah Data Gagal',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors
                                        .white, // White text for the title
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close,
                                      color: Colors.white), // White close icon
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(
                                16.0), // Main content padding
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 16),
                                // Error Icon
                                CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 30,
                                  child: Icon(Icons.close,
                                      color: Colors.white, size: 30),
                                ),
                                SizedBox(height: 16),
                                // Error Message
                                Text(
                                  'Data telah gagal diperbarui',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors
                                          .black), // Slightly smaller font
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      );
    }
  }


  bool _validateInputs() {
    return _ownerController.text.isNotEmpty &&
        _accountNumberController.text.isNotEmpty &&
        _selectedBank != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Rekening Bank',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Tambah Info Rekening',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            _buildDropdownFormField('Bank Name', _banks),
            const SizedBox(height: 16.0),
            _buildTextFormField('Account Owner', _ownerController),
            const SizedBox(height: 16.0),
            _buildTextFormField('Account Number', _accountNumberController,
                isNumeric: true),
            const SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                onPressed: _saveBankAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFormField(String label, List<String> items) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (String? newValue) {
        setState(() {
          _selectedBank = newValue;
        });
      },
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: isNumeric
          ? TextInputType.number
          : TextInputType.text, // Specify numeric keyboard if needed
      inputFormatters: isNumeric
          ? <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly, // Allow only digits
            ]
          : null,
    );
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }
}
