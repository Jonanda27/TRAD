import 'package:flutter/material.dart';
import 'package:trad/Utility/warna.dart';

class CostumeTextFormFieldTemp extends StatefulWidget {
  final TextEditingController textformController;
  final bool showCancelIcon;
  final bool isFieldValid;
  final Color fillColors;
  final Color iconSuffixColor;
  final Color? suffixIconColor;
  final String? hintText;
  final String? errorText; // New parameter for error text
  final IconData? suffixIcon;
  final bool isPasswordField;
  final bool alwaysShowSuffix;
  final Function(String)? onChanged;
  final Function()? onCancelIconPressed;

  const CostumeTextFormFieldTemp({
    super.key,
    required this.textformController,
    this.showCancelIcon = false,
    this.isFieldValid = true,
    this.hintText,
    this.errorText, // Added errorText parameter
    required this.fillColors,
    required this.iconSuffixColor,
    this.suffixIconColor,
    this.suffixIcon,
    this.isPasswordField = false,
    this.alwaysShowSuffix = false,
    this.onChanged,
    this.onCancelIconPressed,
  });

  @override
  _CostumeTextFormFieldTempState createState() => _CostumeTextFormFieldTempState();
}

class _CostumeTextFormFieldTempState extends State<CostumeTextFormFieldTemp> {
  bool _obscureText = true;
  bool _isFieldTouched = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          cursorColor: MyColors.iconGrey(),
          textAlign: TextAlign.start,
          controller: widget.textformController,
          obscureText: widget.isPasswordField ? _obscureText : false,
          onChanged: (value) {
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
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
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
        if (widget.errorText != null && _isFieldTouched && !widget.isFieldValid)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 12.0),
            child: Text(
              widget.errorText!,
              style: TextStyle(color: Colors.red, fontSize: 12.0),
            ),
          ),
      ],
    );
  }
}
