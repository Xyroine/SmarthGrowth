import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary (Forest Green)
  static const Color primary = Color(0xFF2D6A4F);
  static const Color primaryLight = Color(0xFF52B788);

  // Secondary / Card (Soft Mint/Sage Pastel)
  static const Color secondary = Color(0xFFE8F0EC);

  // Accent (Soft Salmon/Coral — untuk status "Perlu distimulasi")
  static const Color accent = Color(0xFFE9967A);

  // Background
  static const Color bgCream = Color(0xFFFDFBF7);
  static const Color bgWhite = Color(0xFFFFFFFF);

  // Text
  static const Color textDark = Color(0xFF2F3E46);
  static const Color textMuted = Color(0xFF7A8F95);

  // Neutral
  static const Color divider = Color(0xFFE0E0E0);
  static const Color grey = Color(0xFFD9D9D9);
  static const Color navInactive = Color(0xFFA0A0A0);
  static const Color inputBg = Color(0xFFF1F1F1);

  // Category accent colors
  static const Color catKognitif = Color(0xFFFFB347);
  static const Color catBahasa = Color(0xFF52B788);
  static const Color catEmosional = Color(0xFFE9967A);

  // Legacy aliases for backward-compatibility
  static const Color primaryDark = primary;
  static const Color primaryPale = secondary;
  static const Color bgWarm = Color(0xFFFFF9F2);
  static const Color accentYellow = Color(0xFFFFC107);
  static const Color primaryMedium = Color(0xFF40916C);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgCream,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.bgCream,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textDark,
      ),
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        // H1 — 24px SemiBold (Nama Anak / Judul Utama)
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          letterSpacing: 0,
        ),
        // H2 — 18px SemiBold (Judul Seksi / Nama Fitur)
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          letterSpacing: 0,
        ),
        // Title — 16px SemiBold
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        // Body — 14px Regular, Line Height 140%
        bodyLarge: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
          height: 1.4,
        ),
        // Body Small — 12px
        bodyMedium: GoogleFonts.nunito(
          fontSize: 12,
          color: AppColors.textDark,
          height: 1.4,
        ),
        // Sub-caption — 12px Regular, abu-abu #7A8F95
        bodySmall: GoogleFonts.nunito(
          fontSize: 12,
          color: AppColors.textMuted,
          height: 1.4,
        ),
        // Button label
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
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgWhite,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.navInactive,
      ),
    );
  }
}
