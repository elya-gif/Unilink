import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Akademik palet: üniversite renklerinden ilham
class AppColors {
  static const burgundy = Color(0xFF7A1F2B); // ana renk: butonlar, vurgular
  static const navy = Color(0xFF1F2A44);     // başlıklar, ikinci renk
  static const cream = Color(0xFFFBF7F0);    // sayfa arka planı
  static const success = Color(0xFF2E7D32);  // yeşil: başarı mesajları
  static const error = Color(0xFFC62828);    // kırmızı: hatalar
}

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.burgundy,
      primary: AppColors.burgundy,
      secondary: AppColors.navy,
      surface: AppColors.cream,
      error: AppColors.error,
    );

    final radius = BorderRadius.circular(12);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: GoogleFonts.manropeTextTheme().apply(
        bodyColor: AppColors.navy,
        displayColor: AppColors.navy,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: AppColors.navy.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.burgundy, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.navy),
      ),
      chipTheme: ChipThemeData(
        selectedColor: AppColors.burgundy.withValues(alpha: 0.15),
        side: BorderSide(color: AppColors.navy.withValues(alpha: 0.15)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
      ),
    );
  }
}
