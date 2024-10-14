import 'package:flutter/material.dart';
import 'package:trad/Utility/warna.dart';

class CostumeTextfieldVerifyPassword extends StatefulWidget {
  final TextEditingController textformController;
  final bool showCancelIcon; // Flag to control when to show the cancel icon
  final bool isFieldValid; // New flag to determine if the field is valid
  final Color fillColors;
  final Color iconSuffixColor;
  final Color? suffixIconColor; // Color for cancel icon
  final String? hintText;
  final IconData? suffixIcon; // Icon for the suffix (e.g., Icons.cancel)
  final bool isPasswordField;
  final bool alwaysShowSuffix;
  final Function(String)? onChanged;
  final Function()? onCancelIconPressed; // Callback when cancel icon is pressed

  const CostumeTextfieldVerifyPassword({
    super.key,
    required this.textformController,
    this.showCancelIcon = false, // Controls the visibility of the cancel icon
    this.isFieldValid = true, // Controls border color based on validity
    this.hintText,
    required this.fillColors,
    required this.iconSuffixColor,
    this.suffixIconColor, // Optional color for the cancel icon
    this.suffixIcon,
    this.isPasswordField = false,
    this.alwaysShowSuffix = false,
    this.onChanged,
    this.onCancelIconPressed, // Handle when the cancel icon is clicked
  });

  @override
  _CostumeTextfieldVerifyPasswordState createState() => _CostumeTextfieldVerifyPasswordState();
}

class _CostumeTextfieldVerifyPasswordState extends State<CostumeTextfieldVerifyPassword> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          cursorColor: MyColors.iconGrey(),
          textAlign: TextAlign.start,
          controller: widget.textformController,
          obscureText: widget.isPasswordField ? _obscureText : false,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.fillColors,
            hintText: widget.hintText,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showCancelIcon)
                  IconButton(
                    icon: Icon(
                      widget.suffixIcon ?? Icons.cancel, // Show cancel icon
                      color: widget.suffixIconColor ?? Colors.red, // Color for cancel icon
                    ),
                    onPressed: widget.onCancelIconPressed, // Handle cancel icon press if needed
                  ),
                if (widget.isPasswordField)
                  IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: MyColors.iconGrey(), // Visibility icon stays grey
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
              ],
            ),
            // No prefix icon by default
            prefixIcon: null, 
            // Red border when invalid even if the field is not focused
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: widget.isFieldValid ? Colors.grey : Colors.red, // Always red when invalid
                width: 1.0,
              ),
            ),
            // Red border when the field is focused and invalid
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: widget.isFieldValid ? MyColors.iconGrey() : Colors.red, // Always red when invalid
                width: 1.0,
              ),
            ),
            // Optional error border for further customization (not necessary if enabled/focused is handled)
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: Colors.red,
                width: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
