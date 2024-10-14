import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trad/Screen/BayarScreen/verifikasi_bayar.dart';
import 'package:trad/Screen/ProfileScreen/profile.dart';
import 'package:trad/utility/text_opensans.dart';
import 'package:trad/utility/warna.dart';
// import 'package:trad/Screen/ProfileScreen/verifikasi_pin.dart';
import 'package:trad/Model/RestAPI/service_bank.dart';

class EditRekeningBankPage extends StatefulWidget {
  final int userId;

  const EditRekeningBankPage({Key? key, required this.userId})
      : super(key: key);

  @override
  _EditRekeningBankPageState createState() => _EditRekeningBankPageState();
}

class _EditRekeningBankPageState extends State<EditRekeningBankPage> {
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final BankService _bankService = BankService();

  final List<String> _banks = [
    'Bank Mandiri',
    'Bank BRI',
    'Bank BCA',
    'Bank BSI',
  ];

  Map<String, dynamic>? _currentBankDetails;
  String _selectedBank = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentBankDetails();
  }

  Future<void> _fetchCurrentBankDetails() async {
    try {
      final bankDetails = await _bankService.getBankAccount(widget.userId);
      setState(() {
        _currentBankDetails = bankDetails;
        _selectedBank = bankDetails['namaBank'] ?? '';
        _ownerController.text = bankDetails['pemilikRekening'] ?? '';
        _accountNumberController.text = bankDetails['nomorRekening'] ?? '';
      });
    } catch (e) {
      print('Error fetching bank details: $e');
      // Consider showing an error message to the user
    }
  }

  void _saveBankAccount() {
    if (_validateInputs()) {
      final newBankDetails = {
        'namaBank': _selectedBank,
        'pemilikRekening': _ownerController.text,
        'nomorRekening': _accountNumberController.text,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifikasiPinPage(
            onPinVerified: (String pin) async {
              try {
                await _bankService.updateBankAccount(
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
                ).then((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                });
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
        _selectedBank.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        title: const Text(
          'Edit Info Rekening Bank',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 40,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Akun Bank Sekarang',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10.0),
                  _buildCurrentBankDetails(),
                  const Divider(height: 30.0, thickness: 1.0),
                  const Text(
                    'Akun Bank Baru',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10.0),
                  _buildDropdownFormField('Nama Bank', _selectedBank, _banks),
                  const SizedBox(height: 16.0),
                  _buildTextFormField('Nama Pemilik', _ownerController),
                  const SizedBox(height: 16.0),
                  _buildTextFormField(
                      'Nomoer Rekening', _accountNumberController,
                      isNumeric: true),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveBankAccount,
                      child: OpenSansText.custom(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        warna: MyColors.textWhite(),
                        text: "Lanjut",
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6), // <-- Radius
                        ),
                        side: BorderSide(
                          width: 1,
                          color: MyColors.greenDarkButton(),
                        ),
                        backgroundColor: MyColors.greenDarkButton(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentBankDetails() {
    if (_currentBankDetails == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildReadOnlyTextField('Bank Name', _currentBankDetails!['namaBank']),
        _buildReadOnlyTextField(
            'Account Owner', _currentBankDetails!['pemilikRekening']),
        _buildReadOnlyTextField(
            'Account Number', _currentBankDetails!['nomorRekening']),
      ],
    );
  }

  Widget _buildReadOnlyTextField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        initialValue: value,
        decoration: const InputDecoration(
          // labelText: label,
          border: OutlineInputBorder(),
        ),
        readOnly: true,
      ),
    );
  }

  Widget _buildDropdownFormField(
      String label, String value, List<String> items) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      decoration: InputDecoration(
        hintText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (String? newValue) {
        setState(() {
          _selectedBank = newValue ?? '';
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
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      inputFormatters:
          isNumeric ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: InputDecoration(
        hintText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }
}
