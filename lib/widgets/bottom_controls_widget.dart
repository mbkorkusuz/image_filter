import 'package:flutter/material.dart';
import '../themes/app_button_styles.dart';

class BottomControlsWidget extends StatelessWidget {


  const BottomControlsWidget({
    super.key,
    this.onBackPressed,
    this.onNextPressed,
  });
  
  final VoidCallback? onBackPressed;
  final VoidCallback? onNextPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 32),
            onPressed: onBackPressed,
            style: AppButtonStyles.iconButton(),
          ),
          
          IconButton(
            icon: const Icon(Icons.arrow_forward, size: 32),
            onPressed: onNextPressed,
            style: AppButtonStyles.iconButton(),
          ),
        ],
      ),
    );
  }
}