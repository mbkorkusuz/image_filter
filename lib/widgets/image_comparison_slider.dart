import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/image_comparison_provider.dart';

class ImageComparisonSlider extends StatelessWidget {
  final Widget originalImage;
  final Widget filteredImage;

  const ImageComparisonSlider({
    super.key,
    required this.originalImage,
    required this.filteredImage,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Consumer<ImageComparisonProvider>(
          builder: (context, comparisonProvider, child) {
            return GestureDetector(
              onTapDown: (details) {
                comparisonProvider.setSliderActive(true);
                comparisonProvider.updateSliderPosition(details.localPosition.dx, constraints.maxWidth);
              },
              onTapUp: (details) {
                comparisonProvider.setSliderActive(false);
              },
              onTapCancel: () {
                comparisonProvider.setSliderActive(false);
              },
              onPanStart: (details) {
                comparisonProvider.setSliderActive(true);
                comparisonProvider.updateSliderPosition(details.localPosition.dx, constraints.maxWidth);
              },
              onPanUpdate: (details) {
                comparisonProvider.updateSliderPosition(details.localPosition.dx, constraints.maxWidth);
              },
              onPanEnd: (details) {
                comparisonProvider.setSliderActive(false);
              },
              child: Stack(
                children: [
                  // Filtreli görüntü (üst katman)
                  SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: filteredImage,
                  ),
                  
                  // Orijinal görüntü (alt katman)
                  if (comparisonProvider.isSliderActive)
                    ClipRect(
                      clipper: LeftClipper(comparisonProvider.sliderPosition),
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: originalImage,
                      ),
                    ),
                  
                  // slider çizgisi
                  if (comparisonProvider.isSliderActive)
                    Positioned(
                      left: (comparisonProvider.sliderPosition * constraints.maxWidth),
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 0,
                        color: Colors.transparent,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class LeftClipper extends CustomClipper<Rect> {
  final double position;
  
  LeftClipper(this.position);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * position, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return oldClipper is LeftClipper && oldClipper.position != position;
  }
}