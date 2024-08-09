import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OpenSansText {
  static custom({
    required text,
    required double fontSize,
    required Color warna,
    required FontWeight fontWeight,
  }) {
    return Text(
      text,
      style: GoogleFonts.openSans(
        color: warna,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
