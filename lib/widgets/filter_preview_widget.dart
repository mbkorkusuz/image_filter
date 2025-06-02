import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_filter/helper/filters.dart';
import '../themes/app_theme.dart';
import '../themes/app_text_styles.dart';
import '../providers/filter_preview_provider.dart';

class FilterPreviewWidget extends StatefulWidget {
  final File imageFile;
  final int selectedIndex;
  final Function(int) onFilterSelected;

  const FilterPreviewWidget({
    super.key,
    required this.imageFile,
    required this.selectedIndex,
    required this.onFilterSelected,
  });

  @override
  _FilterPreviewWidgetState createState() => _FilterPreviewWidgetState();
}

class _FilterPreviewWidgetState extends State<FilterPreviewWidget> {
  @override
  void initState() {
    super.initState();
    // Build tamamlandıktan sonra çalıştır
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FilterPreviewProvider>();
      provider.initializeWithImage(widget.imageFile);
      provider.generatePreviews(widget.imageFile);
    });
  }

  @override
  void didUpdateWidget(FilterPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageFile.path != widget.imageFile.path) {
      // Build tamamlandıktan sonra çalıştır
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<FilterPreviewProvider>();
        provider.initializeWithImage(widget.imageFile);
        provider.generatePreviews(widget.imageFile);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: SingleChildScrollView( 
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Consumer<FilterPreviewProvider>(
          builder: (context, filterPreviewProvider, child) {
            return Row(
              children: List.generate(13, (index) {
                final isSelected = widget.selectedIndex == index;
                final label = FilterLib.getFilterName(index);
                final isLoading = filterPreviewProvider.loadingPreviews.contains(index);
                final hasPreview = filterPreviewProvider.previewCache.containsKey(index);

                return GestureDetector(
                  onTap: () => widget.onFilterSelected(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Text(
                          label,
                          style: isSelected 
                            ? AppTextStyles.filterNameSelected 
                            : AppTextStyles.filterName,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryColor.withOpacity(0.9) : AppTheme.grey400,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildPreviewContent(index, isLoading, hasPreview, filterPreviewProvider),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPreviewContent(int index, bool isLoading, bool hasPreview, FilterPreviewProvider filterPreviewProvider) {
    if (isLoading) {
      return Container(
        color: AppTheme.grey100,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
        ),
      );
    }
    
    if (hasPreview && filterPreviewProvider.previewCache[index] != null) {
      return Image(
        image: filterPreviewProvider.previewCache[index]!.image,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return Container(
      color: AppTheme.grey100,
      child: Stack(
        children: [
          Image.file(
            widget.imageFile,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          if (index != 0)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.blue.withOpacity(0.3),
              child: Center(
                child: Text(
                  FilterLib.getFilterName(index),
                  style: AppTextStyles.bodyXSmall.copyWith(
                    color: AppTheme.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}