import 'package:flutter/material.dart';

class ImageComparisonProvider extends ChangeNotifier {
  double _sliderPosition = 0.5;
  bool _isSliderActive = false;

  double get sliderPosition => _sliderPosition;
  bool get isSliderActive => _isSliderActive;

  void setSliderPosition(double position) {
    _sliderPosition = position.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setSliderActive(bool active) {
    _isSliderActive = active;
    notifyListeners();
  }

  void resetSlider() {
    _sliderPosition = 0.5;
    _isSliderActive = false;
    // notifyListeners() çağırmıyoruz çünkü build sırasında çağrılabilir
  }

  void updateSliderPosition(double position, double maxWidth) {
    _sliderPosition = (position / maxWidth).clamp(0.0, 1.0);
    notifyListeners();
  }
}