import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // We only need a dark theme for the Luminous Terminal
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.surface,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      // Typography: Space Grotesk for Headlines, Manrope for Body
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
          color: AppColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.spaceGrotesk(
          color: AppColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          color: AppColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          color: AppColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: GoogleFonts.manrope(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.manrope(color: AppColors.onSurface),
        bodyMedium: GoogleFonts.manrope(color: AppColors.onSurfaceVariant),
        labelSmall: GoogleFonts.manrope(
          color: AppColors.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
