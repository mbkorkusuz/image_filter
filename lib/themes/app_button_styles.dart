import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'app_text_styles.dart';

class AppButtonStyles {
  // Error Button
  static ButtonStyle errorButton = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.errorColor,
    foregroundColor: AppTheme.textOnPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: AppTextStyles.buttonMedium,
  );

  // Icon Button Styles
  static ButtonStyle iconButton({Color? color}) => IconButton.styleFrom(
    foregroundColor: color ?? AppTheme.primaryColor,
  );

  // Text Button
  static ButtonStyle textButton = TextButton.styleFrom(
    foregroundColor: AppTheme.grey700,
    padding: const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
    textStyle: AppTextStyles.bodyMedium,
  );

  // Filter Chain Button
  static BoxDecoration filterChainBox(bool isSelected) => BoxDecoration(
    color: isSelected 
      ? AppTheme.primaryColor.withOpacity(0.3) 
      : AppTheme.grey100.withOpacity(0.1),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: isSelected 
        ? AppTheme.primaryColor.withOpacity(0.7) 
        : AppTheme.grey400.withOpacity(0.3),
    ),
  );

  // Filter Chain Green Button (for Original)
  static BoxDecoration filterChainGreenBox(bool isSelected) => BoxDecoration(
    color: isSelected 
      ? AppTheme.successColor.withOpacity(0.2) 
      : AppTheme.grey100.withOpacity(0.1),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: isSelected 
        ? AppTheme.successColor.withOpacity(0.5) 
        : AppTheme.grey400.withOpacity(0.3),
    ),
  );
}