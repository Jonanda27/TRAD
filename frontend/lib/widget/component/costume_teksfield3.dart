import 'package:flutter/material.dart';
import 'package:trad/Utility/warna.dart';

class CostumeTextFormFieldWithoutBorderPrefix2 extends StatelessWidget {
  final TextEditingController textformController;
  final String? errorText;
  final Color fillColors;
  final Color? iconSuffixColor;
  final String? hintText;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;

  const CostumeTextFormFieldWithoutBorderPrefix2({
    super.key,
    required this.textformController,
    this.errorText,
    this.hintText,
    required this.fillColors,
    this.iconSuffixColor,
    this.validator,
    this.focusNode, 
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          cursorColor: MyColors.iconGrey(),
          textAlign: TextAlign.start,
          controller: textformController,
          focusNode: focusNode,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColors,
            hintText: hintText,
            errorText: errorText,
            suffixIcon: (errorText != null && errorText!.isNotEmpty)
                ? Icon(
                    Icons.cancel,
                    color: Colors.red,
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
          validator: validator,
          onChanged: onChanged,
        ),
        if (errorText != null && errorText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              errorText!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}