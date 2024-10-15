import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trad/Utility/warna.dart';

class CostumeTextfieldVerifyPassword2 extends StatefulWidget {
  final TextEditingController textformController;
  final Widget icon;
  final String? errorText;
  final Color fillColors;
  final Color? iconSuffixColor;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged; // Callback for real-time validation

  const CostumeTextfieldVerifyPassword2({
    super.key,
    required this.textformController,
    required this.icon,
    this.errorText,
    this.hintText,
    required this.fillColors,
    this.iconSuffixColor,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  _CostumeTextfieldVerifyPassword2State createState() => _CostumeTextfieldVerifyPassword2State();
}

class _CostumeTextfieldVerifyPassword2State extends State<CostumeTextfieldVerifyPassword2> {
  bool _obscureText = true; // Manage visibility of password field

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          cursorColor: MyColors.iconGrey(),
          textAlign: TextAlign.start,
          controller: widget.textformController,
          obscureText: _obscureText, // Set based on the visibility toggle
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged, // Trigger validation when text changes
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.fillColors,
            hintText: widget.hintText,
            errorText: widget.errorText,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cancel icon if errorText is not null
                if (widget.errorText != null)
                  Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                // Show/Hide password icon
                IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: MyColors.iconGrey(), // Visibility icon stays grey
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText; // Toggle password visibility
                    });
                  },
                ),
              ],
            ),
            suffixIconColor: widget.iconSuffixColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ],
    );
  }
}
