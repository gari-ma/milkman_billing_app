import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData globalAppTheme() {
    return ThemeData(
        appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xff191919),
            titleTextStyle: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
        fontFamily: GoogleFonts.poppins().fontFamily);
  }
}
