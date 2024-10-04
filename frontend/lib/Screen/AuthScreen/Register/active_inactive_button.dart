import 'package:flutter/material.dart';
import 'package:trad/widget/component/costume_buttonLanjut.dart';
import 'package:trad/Utility/warna.dart';

class ActiveInactiveButton extends StatelessWidget {
  final bool isActive;
  final String buttonText;
  final VoidCallback? onTap;

  const ActiveInactiveButton({
    Key? key,
    required this.isActive,
    required this.buttonText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CostumeButtonLanjut(
      buttonText: buttonText,
      backgroundColorbtn: isActive ? MyColors.greenDarkButton() : MyColors.iconGreyDisable(),
      onTap: isActive ? onTap : null,
      backgroundTextbtn: MyColors.textWhite(),
      inactiveBackgroundColor: MyColors.iconGreyDisable(),
    );
  }
}
