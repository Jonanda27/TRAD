import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(); // Close VerifikasiPinPage
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(); // Close TambahRekeningBankPage
              } catch (e) {
                // Handle error
                print('Error adding bank account: $e');
                // Show error message to user
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
