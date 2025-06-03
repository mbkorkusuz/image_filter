import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_filter/widgets/filter_preview_widget.dart';
import 'package:image_filter/widgets/image_comparison_slider.dart';
import '../themes/app_theme.dart';
import '../themes/app_button_styles.dart';
import '../themes/app_widgets.dart';
import '../providers/image_display_provider.dart';
import '../animations/sparkle.dart';

class PhotoDisplayHeader extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onAIProcess;
  final VoidCallback? onSave;
  final VoidCallback? onReset;

  const PhotoDisplayHeader({
    super.key,
    required this.onCancel,
    required this.onAIProcess,
    this.onSave,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageDisplayProvider>(
      builder: (context, imageDisplayProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16, 
            vertical: 8,
          ),
          child: Stack(
            children: [
              // cancel button
              Positioned(
                left: 0,
                child: IconButton(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close, size: 24),
                  color: AppTheme.grey700,
                  tooltip: "Vazgeç",
                ),
              ),
              
              // AI button
              Center(
                child: IconButton(
                  onPressed: onAIProcess,
                  icon: const Icon(Icons.auto_awesome, size: 24),
                  style: AppButtonStyles.iconButton(color: Colors.purple),
                  tooltip: 'İyileştir',
                ),
              ),
              
              // up right
              Positioned(
                right: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // save button
                    IconButton(
                      onPressed: imageDisplayProvider.filterStates.length > 1 ? onSave : null,
                      icon: const Icon(Icons.check, size: 24),
                      style: AppButtonStyles.iconButton(
                        color: imageDisplayProvider.filterStates.length > 1 ? AppTheme.successColor : AppTheme.grey400
                      ),
                      tooltip: 'Kaydet',
                    ),
                    const SizedBox(width: 8),
                    // reset button
                    IconButton(
                      onPressed: imageDisplayProvider.filterStates.length > 1 ? onReset : null,
                      icon: const Icon(Icons.refresh, size: 20),
                      style: AppButtonStyles.iconButton(
                        color: imageDisplayProvider.filterStates.length > 1 ? AppTheme.errorColor : AppTheme.grey400
                      ),
                      tooltip: 'Sıfırla',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FilterChainSection extends StatelessWidget {
  const FilterChainSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageDisplayProvider>(
      builder: (context, imageDisplayProvider, child) {
        return Container(
          height: 50, 
          padding: const EdgeInsets.symmetric(
            horizontal: 16, 
            vertical: 4,
          ),
          child: imageDisplayProvider.filterStates.length <= 1
            ? const SizedBox() 
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    AppWidgets.filterChainItem(
                      filterName: 'Orijinal',
                      isSelected: imageDisplayProvider.currentStateIndex == 0,
                      isOriginal: true,
                    ),
                    ...imageDisplayProvider.filterStates.skip(1).toList().asMap().entries.map((entry) {
                      final stateIndex = entry.key + 1;
                      final state = entry.value;
                      final isCurrentState = imageDisplayProvider.currentStateIndex == stateIndex;
                      
                      return Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: AppTheme.grey700,
                            ),
                          ),
                          AppWidgets.filterChainItem(
                            filterName: state.filterName,
                            isSelected: isCurrentState,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
        );
      },
    );
  }
}

class PhotoDisplayImage extends StatelessWidget {
  final List<Sparkle> sparkles;
  final Animation<double> sparkleAnimation;

  const PhotoDisplayImage({
    super.key,
    required this.sparkles,
    required this.sparkleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageDisplayProvider>(
      builder: (context, imageDisplayProvider, child) {
        return Expanded(
          child: Center(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildImageContent(imageDisplayProvider),
                ),
                if (imageDisplayProvider.isProcessing)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                
                if (imageDisplayProvider.isAIin)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: sparkleAnimation,
                      builder: (_, __) {
                        return CustomPaint(
                          painter: SparklePainter(sparkles, sparkleAnimation.value),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageContent(ImageDisplayProvider imageDisplayProvider) {
    if (imageDisplayProvider.filterStates.length > 1 && imageDisplayProvider.displayedImage != null) {
      final originalImage = imageDisplayProvider.filterStates[0].processedImage;
      
      return ClipRRect(
        child: imageDisplayProvider.isAIin ? ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: imageDisplayProvider.displayedImage ?? const SizedBox(),
        )
        : ImageComparisonSlider(
          originalImage: Container(child: originalImage),
          filteredImage: Container(child: imageDisplayProvider.displayedImage!),
        ),
      );
    }
    
    return ClipRRect(
      child: imageDisplayProvider.isAIin
      ? ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: imageDisplayProvider.displayedImage ?? const SizedBox(),
        )
      : imageDisplayProvider.displayedImage ?? const SizedBox(),
    );
  }
}

class IntensitySliderSection extends StatelessWidget {
  const IntensitySliderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageDisplayProvider>(
      builder: (context, imageDisplayProvider, child) {
        return Container(
          height: 80, // Sabit yükseklik
          padding: const EdgeInsets.symmetric(
            horizontal: 20, 
            vertical: 12
          ),
          child: imageDisplayProvider.selectedFilterIndex == 0 
            ? const SizedBox() // Boş alan ama yükseklik aynı
            : AppWidgets.intensitySlider(
                context: context,
                value: imageDisplayProvider.filterIntensity,
                onChanged: imageDisplayProvider.isProcessing ? null : (value) => imageDisplayProvider.onIntensityChanged(value),
                isEnabled: !imageDisplayProvider.isProcessing,
              ),
        );
      },
    );
  }
}

class FilterPreviewSection extends StatelessWidget {
  const FilterPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageDisplayProvider>(
      builder: (context, imageDisplayProvider, child) {
        return FilterPreviewWidget(
          imageFile: imageDisplayProvider.imageFile!,
          selectedIndex: imageDisplayProvider.selectedFilterIndex,
          onFilterSelected: (index) => imageDisplayProvider.onFilterSelected(index),
        );
      },
    );
  }
}

class BottomNavigationSection extends StatelessWidget {
  const BottomNavigationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageDisplayProvider>(
      builder: (context, imageDisplayProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16, 
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: imageDisplayProvider.currentStateIndex > 0 ? () => imageDisplayProvider.goToPreviousState() : null,
                icon: const Icon(Icons.arrow_back_ios),
                color: imageDisplayProvider.currentStateIndex > 0 ? AppTheme.textPrimary : AppTheme.grey400,
                tooltip: "Geri",
              ),
              
              IconButton(
                onPressed: imageDisplayProvider.currentStateIndex < imageDisplayProvider.filterStates.length - 1 ? () => imageDisplayProvider.goToNextState() : null,
                icon: const Icon(Icons.arrow_forward_ios),
                color: imageDisplayProvider.currentStateIndex < imageDisplayProvider.filterStates.length - 1 ? AppTheme.textPrimary : AppTheme.grey400,
                tooltip: "İleri",
              ),
            ],
          ),
        );
      },
    );
  }
}