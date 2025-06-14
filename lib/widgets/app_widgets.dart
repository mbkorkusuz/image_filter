import 'package:flutter/material.dart';
import 'dart:io';
import '../themes/app_theme.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_button_styles.dart';

class AppWidgets {
  static Widget loading({String? text}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text(text!, style: AppTextStyles.bodySecondary),
        ],
      ),
    );
  }

  // Empty State Widget
  static Widget emptyState({
    required IconData icon,
    required String title,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppTheme.grey400),
          const SizedBox(height: 20),
          Text(title, style: AppTextStyles.heading2.copyWith(color: AppTheme.grey700)),
        ],
      ),
    );
  }

  // Snackbar
  static SnackBar snackBar({
    required String message,
    Color? backgroundColor,
    Duration? duration,
  }) {
    return SnackBar(
      content: Text(message, style: AppTextStyles.snackBar),
      backgroundColor: backgroundColor ?? AppTheme.accentColor,
      duration: duration ?? Duration(seconds: 2),
    );
  }

  // Success Snackbar
  static SnackBar successSnackBar(String message) {
    return snackBar(
      message: message,
      backgroundColor: AppTheme.successColor,
      duration: const Duration(seconds: 2),
    );
  }

  // Error Snackbar
  static SnackBar errorSnackBar(String message) {
    return snackBar(
      message: message,
      backgroundColor: AppTheme.errorColor,
      duration: const Duration(seconds: 4),
    );
  }

  // Header Section
  static Widget headerSection({
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
              Text(title, style: AppTextStyles.heading1),
              const SizedBox(height: 4),
        ],
      ),
    );
  }

  // Filter Grid Item
  static Widget filterGridItem({
    required String thumbnailPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: ClipRRect(
                child: Image.file(File(thumbnailPath), fit: BoxFit.cover),
              ),
            ),
          ],
        ),
    );
  }

  // Intensity Slider
  static Widget intensitySlider({
    required BuildContext context,
    required double value,
    required ValueChanged<double>? onChanged,
    required bool isEnabled,
  }) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: AppTheme.primaryColor,
            inactiveTrackColor: AppTheme.grey400,
            thumbColor: AppTheme.primaryColor,
            overlayColor: AppTheme.primaryColor.withOpacity(0.2),
            tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 3),
            activeTickMarkColor: AppTheme.primaryColor,
            inactiveTickMarkColor: AppTheme.grey400,
          ),
          child: Slider(
            value: value,
            min: 0.2,
            max: 1.0,
            divisions: 4,
            onChanged: isEnabled ? onChanged : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _intensityLabel('1', 0.2, value),
              _intensityLabel('2', 0.4, value),
              _intensityLabel('3', 0.6, value),
              _intensityLabel('4', 0.8, value),
              _intensityLabel('5', 1.0, value),
            ],
          ),
        ),
      ],
    );
  }

  // Helper for intensity labels
  static Widget _intensityLabel(String label, double targetValue, double currentValue) {
    final isSelected = (currentValue - targetValue).abs() < 0.05;
    return Text(label, style: AppTextStyles.intensityTick(isSelected));
  }

  // filter chain single item widget
  static Widget filterChainItem({
    required String filterName,
    required bool isSelected,
    bool isOriginal = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: isOriginal 
        ? AppButtonStyles.filterChainGreenBox(isSelected)
        : AppButtonStyles.filterChainBox(isSelected),
      child: Text(
        filterName,
        style: AppTextStyles.bodySmall.copyWith(
          color: isOriginal 
            ? (isSelected ? AppTheme.successColor : AppTheme.grey700)
            : (isSelected ? AppTheme.primaryColor : AppTheme.grey700),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  // Dialog
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Sil',
    String cancelText = 'İptal',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppTextStyles.heading4),
        content: Text(content, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: AppButtonStyles.textButton,
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: AppButtonStyles.errorButton,
            child: Text(
              confirmText,
              style: AppTextStyles.buttonMedium.copyWith(color: AppTheme.textOnPrimary),
            ),
          ),
        ],
      ),
    );
  }
}