import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'app_text_styles.dart';

class AppButtonStyles {
  // Primary Button
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    foregroundColor: AppTheme.textOnPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    textStyle: AppTextStyles.buttonLarge,
  );

  // Secondary Button
  static ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.grey100,
    foregroundColor: AppTheme.textPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    textStyle: AppTextStyles.buttonLarge,
  );

  // Large Button (Full width)
  static ButtonStyle largeButton = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    foregroundColor: AppTheme.textOnPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
    minimumSize: const Size(double.infinity, 50),
    textStyle: AppTextStyles.buttonLarge,
  );

  // Success Button
  static ButtonStyle successButton = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.successColor,
    foregroundColor: AppTheme.textOnPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: AppTextStyles.buttonMedium,
  );

  // Error Button
  static ButtonStyle errorButton = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.errorColor,
    foregroundColor: AppTheme.textOnPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: AppTextStyles.buttonMedium,
  );

  // Round Button
  static ButtonStyle roundButton = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    foregroundColor: AppTheme.textOnPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 12,
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

  // Navigation Button
  static ButtonStyle navigationButton(bool isEnabled) => ElevatedButton.styleFrom(
    backgroundColor: isEnabled ? AppTheme.primaryColor : AppTheme.grey400,
    foregroundColor: isEnabled ? AppTheme.textOnPrimary : AppTheme.grey700,
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    textStyle: AppTextStyles.buttonMedium,
  );

  // Filter Chain Button
  static BoxDecoration filterChainButton(bool isSelected) => BoxDecoration(
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
  static BoxDecoration filterChainGreenButton(bool isSelected) => BoxDecoration(
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