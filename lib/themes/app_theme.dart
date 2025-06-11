import 'package:flutter/material.dart';

class AppTheme {
  
  // Ana renkler
  static const Color primaryColor = Colors.black;
  static const Color accentColor = Color.fromARGB(255, 185, 126, 37);
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color.fromARGB(255, 198, 53, 43);
  static const Color successColor = Color.fromARGB(255, 50, 144, 53);
  
  // Gri tonları
  static final Color grey100 = Colors.grey[100]!;
  static final Color grey400 = Colors.grey[400]!;
  static final Color grey700 = Colors.grey[700]!;
  
  // Text Colors
  static const Color textPrimary = Colors.black;
  static final Color textSecondary = Colors.grey[600]!;
  static final Color textTertiary = Colors.grey[500]!;
  static const Color textOnPrimary = Colors.white;
  
  // Font Family
  static const String fontFamily = 'Helvetica';  

  // Main Theme Data
  static ThemeData get themeData {
    return ThemeData(
      scaffoldBackgroundColor: backgroundColor,
      textTheme: Typography.blackCupertino.copyWith(
        bodyLarge: TextStyle(fontFamily: fontFamily),
        bodyMedium: TextStyle(fontFamily: fontFamily),
        titleLarge: TextStyle(fontFamily: fontFamily),
        titleMedium: TextStyle(fontFamily: fontFamily),
        headlineLarge: TextStyle(fontFamily: fontFamily),
        headlineMedium: TextStyle(fontFamily: fontFamily),
      ),
      primarySwatch: Colors.blue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
    );
  }
}