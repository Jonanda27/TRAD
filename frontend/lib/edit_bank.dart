// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:trad/verifikasi_pin.dart';

class EditRekeningBankPage extends StatefulWidget {
  const EditRekeningBankPage({super.key});

  @override
  // ignore: duplicate_ignore
  // ignore: library_private_types_in_public_api
  _EditRekeningBankPageState createState() => _EditRekeningBankPageState();
}

class _EditRekeningBankPageState extends State<EditRekeningBankPage> {
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();

  // Simulated initial bank account data
  String _initialBankName = 'Bank ABC';
  String _initialOwnerName = 'John Doe';
  String _initialAccountNumber = '1234567890';

  @override
  void initState() {
    super.initState();
    // Set initial values for text controllers
    _bankController.text = _initialBankName;
    _ownerController.text = _initialOwnerName;
    _accountNumberController.text = _initialAccountNumber;
  }

  void _editBankAccount() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBankPage(
          initialBankName: _initialBankName,
          initialOwnerName: _initialOwnerName,
          initialAccountNumber: _initialAccountNumber,
          onSave: (String bankName, String ownerName, String accountNumber) {
            setState(() {
              _initialBankName = bankName;
              _initialOwnerName = ownerName;
              _initialAccountNumber = accountNumber;
              _bankController.text = bankName;
              _ownerController.text = ownerName;
              _accountNumberController.text = accountNumber;
            });
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _initialBankName = result['bankName'];
        _initialOwnerName = result['ownerName'];
        _initialAccountNumber = result['accountNumber'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Info Rekening Bank',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1), // Warna RGB (0, 84, 102)
        actions: const [
          // Add any actions you need in the app bar here
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                const Text(
                  'Info Rekening',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editBankAccount,
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            _buildViewMode(),
          ],
        ),
      ),
    );
  }

  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildTextFormField('Bank Name', _bankController),
        _buildTextFormField('Account Owner', _ownerController),
        _buildTextFormField('Account Number', _accountNumberController),
      ],
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      enabled: false, // Tidak bisa di-edit di halaman ini
    );
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _bankController.dispose();
    _ownerController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }
}

class EditBankPage extends StatefulWidget {
  final String initialBankName;
  final String initialOwnerName;
  final String initialAccountNumber;
  final Function(String, String, String) onSave;

  const EditBankPage({super.key, 
    required this.initialBankName,
    required this.initialOwnerName,
    required this.initialAccountNumber,
    required this.onSave,
  });

  @override
  _EditBankPageState createState() => _EditBankPageState();
}

class _EditBankPageState extends State<EditBankPage> {
  late TextEditingController _ownerController;
  late TextEditingController _accountNumberController;
  late String _selectedBank;

  final List<String> _banks = [
    'Bank ABC',
    'Bank BCA',
    'Bank Mandiri',
    'Bank BRI',
    'Bank BNI',
    'Bank Danamon',
    'Bank CIMB Niaga',
    'Bank BTN',
    // Tambahkan bank lainnya sesuai kebutuhan
  ];

  @override
  void initState() {
    super.initState();
    _selectedBank = widget.initialBankName;
    _ownerController = TextEditingController(text: widget.initialOwnerName);
    _accountNumberController = TextEditingController(text: widget.initialAccountNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Bank',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(0, 84, 102, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildDropdownFormField('Bank Name', _selectedBank, _banks),
              const SizedBox(height: 16.0),
              _buildTextFormField('Account Owner', _ownerController),
              const SizedBox(height: 16.0),
              _buildTextFormField('Account Number', _accountNumberController),
              const SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSave(
                      _selectedBank,
                      _ownerController.text,
                      _accountNumberController.text,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerifikasiPinPage(
                          onPinVerified: (String pin) {
                            Navigator.of(context).pop({
                              'bankName': _selectedBank,
                              'ownerName': _ownerController.text,
                              'accountNumber': _accountNumberController.text,
                            });
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 84, 102, 1), // background
                    foregroundColor: Colors.white, // foreground
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFormField(String label, String value, List<String> items) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (String? newValue) {
        setState(() {
          _selectedBank = newValue!;
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

  Widget _buildTextFormField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
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
