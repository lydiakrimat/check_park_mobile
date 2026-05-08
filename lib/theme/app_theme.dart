import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_colors_scheme.dart';

class AppTheme {
  AppTheme._();

  // ── Thème clair ─────────────────────────────────────────────────────────────

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        extensions: const [AppColorsScheme.light],
        textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
          bodyColor: AppColors.text,
          displayColor: AppColors.text,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: GoogleFonts.plusJakartaSans(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(color: AppColors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.green, width: 1.5),
          ),
          hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
        ),
        cardTheme: CardThemeData(
          color: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: const Color(0x140F2F5A),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 1,
        ),
      );

  // ── Thème sombre ────────────────────────────────────────────────────────────

  static const _darkSurface   = Color(0xFF1A2035);
  static const _darkBg        = Color(0xFF0F1117);
  static const _darkText      = Color(0xFFE8EDF5);
  static const _darkMuted     = Color(0xFF8899B4);
  static const _darkBorder    = Color(0xFF2A3850);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          surface: _darkSurface,
          onSurface: _darkText,
        ),
        scaffoldBackgroundColor: _darkBg,
        extensions: const [AppColorsScheme.dark],
        textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
          bodyColor: _darkText,
          displayColor: _darkText,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _darkSurface,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _darkBorder, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.green, width: 1.5),
          ),
          hintStyle: const TextStyle(color: _darkMuted, fontSize: 14),
        ),
        cardTheme: CardThemeData(
          color: _darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: _darkBorder,
          thickness: 1,
          space: 1,
        ),
      );

  // ── Styles de texte partagés ────────────────────────────────────────────────

  static TextStyle pageTitle(BuildContext ctx) =>
      GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: ctx.colors.text,
      );

  static TextStyle sectionLabel(BuildContext ctx) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: ctx.colors.muted,
        letterSpacing: 1.2,
      );

  static TextStyle kpiValue(BuildContext ctx) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        color: ctx.colors.text,
      );
}
