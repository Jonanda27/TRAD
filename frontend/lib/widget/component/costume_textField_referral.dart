import 'package:flutter/material.dart';
import 'package:trad/Utility/warna.dart';

class CostumeTextFormFieldWithVerification extends StatefulWidget {
  final TextEditingController textformController;
  final Widget icon;
  final String? errorText;
  final Color fillColors;
  final Color iconSuffixColor;
  final String? hintText;
  final IconData? suffixIcon;
  final bool isPasswordField;
  final bool alwaysShowSuffix;
  final bool showCancelIcon;
  final bool isFieldValid;
  final Function(String)? onChanged;
  final Function()? onCancelIconPressed;

  const CostumeTextFormFieldWithVerification({
    super.key,
    required this.textformController,
    required this.icon,
    this.errorText,
    this.hintText,
    required this.fillColors,
    required this.iconSuffixColor,
    this.suffixIcon,
    this.isPasswordField = false,
    this.alwaysShowSuffix = false,
    this.onChanged,
    this.showCancelIcon = false, // show cancel icon feature
    this.isFieldValid = true, // Real-time validation
    this.onCancelIconPressed,
  });

  @override
  _CostumeTextFormFieldWithVerificationState createState() => _CostumeTextFormFieldWithVerificationState();
}

class _CostumeTextFormFieldWithVerificationState extends State<CostumeTextFormFieldWithVerification> {
  bool _obscureText = true;
  bool _isFieldTouched = false;

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
            // Set field as touched when the user starts typing
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
            errorText: widget.errorText,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show cancel icon if field is invalid and touched
                if (widget.showCancelIcon && _isFieldTouched && !widget.isFieldValid)
                  IconButton(
                    icon: Icon(
                      widget.suffixIcon ?? Icons.cancel,
                      color: Colors.red,
                    ),
                    onPressed: widget.onCancelIconPressed,
                  ),
                if (widget.isPasswordField)
                  IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: widget.iconSuffixColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
              ],
            ),
            // Set border color based on the field's validity and whether it's been touched
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
            prefixIcon: SizedBox(
              width: 50,
              height: 32,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  widget.icon,
                  Container(
                    width: 1,
                    color: MyColors.iconGrey(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
