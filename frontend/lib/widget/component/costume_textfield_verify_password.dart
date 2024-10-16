import 'package:flutter/material.dart';
import 'package:trad/Utility/warna.dart';

class CostumeTextfieldVerifyPassword extends StatefulWidget {
  final TextEditingController textformController;
  final bool showCancelIcon;
  final bool isFieldValid;
  final Color fillColors;
  final Color iconSuffixColor;
  final Color? suffixIconColor;
  final String? hintText;
  final IconData? suffixIcon;
  final bool isPasswordField;
  final bool alwaysShowSuffix;
  final Function(String)? onChanged;
  final Function()? onCancelIconPressed;
  final bool isDirty; // Flag to control if the user has started typing

  const CostumeTextfieldVerifyPassword({
    super.key,
    required this.textformController,
    this.showCancelIcon = false,
    this.isFieldValid = true,
    this.hintText,
    required this.fillColors,
    required this.iconSuffixColor,
    this.suffixIconColor,
    this.suffixIcon,
    this.isPasswordField = false,
    this.alwaysShowSuffix = false,
    this.onChanged,
    this.onCancelIconPressed,
    this.isDirty = false, // Added flag to check if the field has been touched
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.showCancelIcon)
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
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: widget.isDirty
                    ? (widget.isFieldValid ? Colors.grey : Colors.red)
                    : Colors.grey, // Neutral color if not dirty
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: widget.isDirty
                    ? (widget.isFieldValid ? MyColors.iconGrey() : Colors.red)
                    : MyColors.iconGrey(), // Neutral color if not dirty
                width: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
