import 'package:flutter/material.dart';
import 'package:trad/Utility/warna.dart';

class CostumeCheckBox extends StatelessWidget {
  final Color unSelectedColor, checkedColor, activedColor;
  final bool isChecked;
  final Function(bool?) onTap;
  const CostumeCheckBox(
      {super.key,
      required this.unSelectedColor,
      required this.checkedColor,
      required this.activedColor,
      required this.isChecked,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: unSelectedColor,
      ),
      child: Checkbox(
        checkColor: checkedColor,
        activeColor: activedColor,
        value: isChecked,
        onChanged: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: BorderSide(
          // ======> CHANGE THE BORDER COLOR HERE <======
          color: MyColors.textWhite(),
          // Give your checkbox border a custom width
          width: 1.5,
        ),
      ),
    );
  }
}
