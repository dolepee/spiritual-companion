import 'package:flutter/material.dart';

class AppColors {
  static const Color emerald = Color(0xFF185E4B);
  static const Color emeraldSoft = Color(0xFF2F7A63);
  static const Color moss = Color(0xFF7D8F5B);
  static const Color cream = Color(0xFFF7F1E6);
  static const Color sand = Color(0xFFE9DFC9);
  static const Color ink = Color(0xFF1D312B);
  static const Color slate = Color(0xFF5E6C66);
  static const Color gold = Color(0xFFC49A52);
  static const Color rose = Color(0xFFD47862);
  static const Color white = Colors.white;
}

class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.emerald,
      onPrimary: AppColors.white,
      secondary: AppColors.gold,
      onSecondary: AppColors.ink,
      error: AppColors.rose,
      onError: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.ink,
      primaryContainer: Color(0xFFDDE9DF),
      onPrimaryContainer: AppColors.ink,
      secondaryContainer: Color(0xFFF5E8CA),
      onSecondaryContainer: AppColors.ink,
      tertiary: AppColors.moss,
      onTertiary: AppColors.white,
      tertiaryContainer: Color(0xFFE3E8D7),
      onTertiaryContainer: AppColors.ink,
      outline: Color(0xFFCED4C8),
      outlineVariant: Color(0xFFE7E1D5),
      shadow: Color(0x1A1D312B),
      scrim: Color(0x401D312B),
      inverseSurface: AppColors.ink,
      onInverseSurface: AppColors.white,
      inversePrimary: Color(0xFFB6D3C5),
      surfaceTint: AppColors.emerald,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cream,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displaySmall: base.textTheme.displaySmall?.copyWith(
          fontFamily: 'Amiri',
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          letterSpacing: -0.4,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontFamily: 'Amiri',
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          letterSpacing: -0.3,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontFamily: 'Amiri',
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontFamily: 'Amiri',
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: AppColors.ink,
          height: 1.45,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: AppColors.ink,
          height: 1.5,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          color: AppColors.slate,
          height: 1.45,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white.withOpacity(0.92),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: Color(0xFFF0E7D7)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          side: const BorderSide(color: Color(0xFFD5CCBC)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.white,
        selectedColor: colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE4DAC7)),
        ),
        labelStyle: base.textTheme.bodySmall?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE7DED0),
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD8D0C2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD8D0C2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.emerald, width: 1.4),
        ),
        labelStyle: const TextStyle(color: AppColors.slate),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white.withOpacity(0.96),
        indicatorColor: const Color(0xFFE5EEE8),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.emerald
                : AppColors.slate,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.emerald
                : AppColors.slate,
          ),
        ),
        height: 72,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }
}
