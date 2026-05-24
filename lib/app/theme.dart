import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PeraXColors {
  static const darkBlue = Color(0xFF040B1F);
  static const electricBlue = Color(0xFF0D47A1);
  static const cyan = Color(0xFF00E5FF);
  static const surfaceBlue = Color(0xFF0A1931);
  static const glassBorder = Color(0x2200E5FF);
}

class PeraXTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: PeraXColors.darkBlue,
      primaryColor: PeraXColors.cyan,
      cardColor: PeraXColors.surfaceBlue,
      dividerColor: PeraXColors.glassBorder,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: PeraXColors.darkBlue,
        elevation: 0,
      ),
      useMaterial3: true,
    );
  }
}
