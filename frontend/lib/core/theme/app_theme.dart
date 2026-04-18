import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? AppColors.surface : Colors.white,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        surface: isDark ? AppColors.surface : Colors.white,
        error: AppColors.error,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceContainer : Colors.grey[50],
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return IconThemeData(
            color: isDark ? AppColors.onSurfaceVariant : Colors.grey[600],
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? AppColors.primary
              : (isDark ? AppColors.onSurfaceVariant : Colors.grey[600]);
          return GoogleFonts.manrope(
            color: color,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            fontSize: 12,
          );
        }),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
          color: isDark ? AppColors.onSurface : Colors.black,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          color: isDark ? AppColors.onSurface : Colors.black,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          color: isDark ? AppColors.onSurface : Colors.black,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: GoogleFonts.manrope(
          color: isDark ? AppColors.onSurface : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.manrope(
          color: isDark ? AppColors.onSurface : Colors.black87,
        ),
        bodyMedium: GoogleFonts.manrope(
          color: isDark ? AppColors.onSurfaceVariant : Colors.grey[700],
        ),
        labelSmall: GoogleFonts.manrope(
          color: isDark ? AppColors.onSurfaceVariant : Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
