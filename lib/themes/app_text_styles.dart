import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppTextStyles {
  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );
  
  static const TextStyle heading4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppTheme.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppTheme.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );
  
  static const TextStyle bodyXSmall = TextStyle(
    fontSize: 10,
    color: AppTheme.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );
  
  // Secondary Text
  static TextStyle bodySecondary = TextStyle(
    fontSize: 16,
    color: AppTheme.textSecondary,
    fontFamily: AppTheme.fontFamily,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: AppTheme.fontFamily,
  );
  
  // Filter Related
  static const TextStyle filterName = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppTheme.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );
  
  static const TextStyle filterNameSelected = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppTheme.primaryColor,
    fontFamily: AppTheme.fontFamily,
  );
  
  static TextStyle intensityTick(bool isSelected) => TextStyle(
    fontSize: 10,
    color: isSelected ? AppTheme.primaryColor : AppTheme.grey400,
    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
    fontFamily: AppTheme.fontFamily,
  );
  
  // Snackbar Text
  static const TextStyle snackBar = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontWeight: FontWeight.w500,
  );
}