import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary
  static const Color primaryDark = Color(0xFF18583D);
  static const Color primary = Color(0xFF6BAF92);
  static const Color primaryMedium = Color(0xFF327458);
  static const Color primaryLight = Color(0xFF8ECFB3);
  static const Color primarySoft = Color(0xFF8AC7AD);
  static const Color primaryPale = Color(0xFFD4F8E9);
  static const Color primaryPaleBg = Color(0xFFF8FFFC);
  static const Color chipGreen = Color(0xFF8DD5B7);

  // Background
  static const Color bgCream = Color(0xFFFDF6EE);
  static const Color bgWarm = Color(0xFFFFF0DC);
  static const Color bgWhite = Color(0xFFFFFFFF);

  // Text
  static const Color textDark = Color(0xFF3D3530);
  static const Color textMuted = Color(0xFF8C7B72);
  static const Color textBlack = Color(0xFF000000);

  // Accent
  static const Color accentYellow = Color(0xFFFFC107);
  static const Color accentYellowLight = Color(0x38FFC107);

  // Other
  static const Color inputBg = Color(0xFFF1F1F1);
  static const Color divider = Color(0xFFC0C0C0);
  static const Color grey = Color(0xFFD9D9D9);
  static const Color shadow = Color(0x4018583D);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.bgCream,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryDark,
        secondary: AppColors.primary,
        surface: AppColors.bgCream,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textDark,
      ),
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        displayMedium: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        titleLarge: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 14,
          color: AppColors.textDark,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 12,
          color: AppColors.textDark,
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 10,
          color: AppColors.textDark,
        ),
        labelLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          minimumSize: const Size(double.infinity, 45),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.textMuted),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.textMuted),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        hintStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: AppColors.textMuted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgCream,
        elevation: 0,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.primaryDark,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
      ),
    );
  }
}
