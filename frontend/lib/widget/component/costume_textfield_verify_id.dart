import 'package:flutter/material.dart';
import 'package:trad/Utility/warna.dart';

class CostumeTextfieldVerifyId extends StatefulWidget {
  final TextEditingController textformController;
  final bool showCancelIcon; // Flag to control when to show the cancel icon
  final bool isFieldValid; // Flag to determine if the field is valid
  final Color fillColors;
  final Color iconSuffixColor;
  final Color? suffixIconColor; // Color for cancel icon
  final String? hintText;
  final IconData? suffixIcon; // Icon for the suffix (e.g., Icons.cancel)
  final bool isPasswordField;
  final bool alwaysShowSuffix;
  final Function(String)? onChanged;
  final Function()? onCancelIconPressed; // Callback when cancel icon is pressed

  const CostumeTextfieldVerifyId({
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
  _CostumeTextfieldVerifyIdState createState() => _CostumeTextfieldVerifyIdState();
}

class _CostumeTextfieldVerifyIdState extends State<CostumeTextfieldVerifyId> {
  bool _obscureText = true;
  bool _isFieldTouched = false; // Track whether the user has interacted with the field

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          cursorColor: MyColors.iconGrey(),
          textAlign: TextAlign.start,
          controller: widget.textformController,
          obscureText: widget.isPasswordField ? _obscureText : false,
          onChanged: (value) {
            // When user starts typing, mark the field as touched
            if (!_isFieldTouched) {
              setState(() {
                _isFieldTouched = true;
              });
            }
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.fillColors,
            hintText: widget.hintText,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show cancel icon only when the user interacts with the field and it's invalid
                if (widget.showCancelIcon && _isFieldTouched && !widget.isFieldValid)
                  IconButton(
                    icon: Icon(
                      widget.suffixIcon ?? Icons.cancel,
                      color: widget.suffixIconColor ?? Colors.red,
                    ),
                    onPressed: widget.onCancelIconPressed,
                  ),
                if (widget.isPasswordField)
                  IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: MyColors.iconGrey(),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
              ],
            ),
            // Border behavior
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                // Only show red when the field has been touched and is invalid
                color: _isFieldTouched && !widget.isFieldValid ? Colors.red : Colors.grey,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: _isFieldTouched && !widget.isFieldValid ? Colors.red : MyColors.iconGrey(),
                width: 1.0,
              ),
            ),
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
