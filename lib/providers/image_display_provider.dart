import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_filter/services/image_processor.dart';
import 'package:image_filter/helper/filters.dart';

class FilterState {
  final int filterIndex;
  final String filterName;
  final Image processedImage;
  final DateTime timestamp;

  FilterState({
    required this.filterIndex,
    required this.filterName,
    required this.processedImage,
    required this.timestamp,
  });
}

class ImageDisplayProvider extends ChangeNotifier {
  int _selectedFilterIndex = 0;
  double _filterIntensity = 0.6;
  Image? _displayedImage;
  File? _imageFile;
  bool _isProcessing = false;
  bool _isAIin = false;
  
  List<FilterState> _filterStates = [];
  int _currentStateIndex = 0;

  // Getters
  int get selectedFilterIndex => _selectedFilterIndex;
  double get filterIntensity => _filterIntensity;
  Image? get displayedImage => _displayedImage;
  File? get imageFile => _imageFile;
  bool get isProcessing => _isProcessing;
  bool get isAIin => _isAIin;
  List<FilterState> get filterStates => _filterStates;
  int get currentStateIndex => _currentStateIndex;

  void setImageFile(File file) {
    // Yeni fotoğraf geldiğinde tüm state'i sıfırla
    _imageFile = file;
    _displayedImage = Image.file(file);
    _selectedFilterIndex = 0;
    _filterIntensity = 0.6;
    _isProcessing = false;
    _isAIin = false;
    _currentStateIndex = 0;
    
    // Filter states'i sıfırla ve sadece orijinal ekle
    _filterStates.clear();
    _filterStates.add(FilterState(
      filterIndex: 0,
      filterName: 'Orijinal',
      processedImage: Image.file(file),
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  Future<void> onFilterSelected(int index) async {
    if (_isProcessing || _imageFile == null) return;
    
    if (index == 0) {
      resetToOriginal();
      return;
    }

    _selectedFilterIndex = index;
    _filterIntensity = 0.6;
    _isProcessing = true;
    notifyListeners();

    final currentState = _filterStates[_currentStateIndex];
    Image baseImage = currentState.processedImage;
    
    final filteredImage = await IsolateImageProcessor.applyFilterToMemoryImage(
      baseImage, 
      index, 
      intensity: _filterIntensity
    );
    
    if (filteredImage != null) {
      final newState = FilterState(
        filterIndex: index,
        filterName: FilterLib.getFilterName(index),
        processedImage: filteredImage,
        timestamp: DateTime.now(),
      );
      
      if (_currentStateIndex < _filterStates.length - 1) {
        _filterStates = _filterStates.sublist(0, _currentStateIndex + 1);
      }
      
      _filterStates.add(newState);
      _currentStateIndex = _filterStates.length - 1;
      _displayedImage = filteredImage;
    }

    _isProcessing = false;
    notifyListeners();
  }

void addFilterState(FilterState newState) {
  // Eğer şu anda son state'de değilsek, sonrasını kes
  if (_currentStateIndex < _filterStates.length - 1) {
    _filterStates = _filterStates.sublist(0, _currentStateIndex + 1);
  }
  
  // Yeni state'i ekle
  _filterStates.add(newState);
  _currentStateIndex = _filterStates.length - 1;
  _displayedImage = newState.processedImage;
  _selectedFilterIndex = newState.filterIndex;
  notifyListeners();
}


  Future<void> onIntensityChanged(double newIntensity) async {
    if (_selectedFilterIndex == 0 || _isProcessing) return;
    
    _filterIntensity = newIntensity;
    _isProcessing = true;
    notifyListeners();

    Image baseImage;
    if (_filterStates.length == 2) {
      baseImage = _filterStates[0].processedImage;
    } else {
      baseImage = _filterStates[_currentStateIndex - 1].processedImage;
    }
    
    final filteredImage = await IsolateImageProcessor.applyFilterToMemoryImage(
      baseImage, 
      _selectedFilterIndex, 
      intensity: _filterIntensity
    );
    
    if (filteredImage != null) {
      final updatedState = FilterState(
        filterIndex: _selectedFilterIndex,
        filterName: FilterLib.getFilterName(_selectedFilterIndex),
        processedImage: filteredImage,
        timestamp: DateTime.now(),
      );
      
      _filterStates[_currentStateIndex] = updatedState;
      _displayedImage = filteredImage;
    }
    
    _isProcessing = false;
    notifyListeners();
  }

  void resetToOriginal() {
    _filterStates = [_filterStates[0]];
    _currentStateIndex = 0;
    _selectedFilterIndex = 0;
    _displayedImage = _filterStates[0].processedImage;
    notifyListeners();
  }

  void goToState(int index) {
    if (index >= 0 && index < _filterStates.length) {
      _currentStateIndex = index;
      _displayedImage = _filterStates[index].processedImage;
      _selectedFilterIndex = _filterStates[index].filterIndex;
      notifyListeners();
    }
  }

  void goToPreviousState() {
    if (_currentStateIndex > 0) {
      goToState(_currentStateIndex - 1);
    }
  }

  void goToNextState() {
    if (_currentStateIndex < _filterStates.length - 1) {
      goToState(_currentStateIndex + 1);
    }
  }

  void setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void setAIProcessing(bool processing) {
    _isAIin = processing;
    notifyListeners();
  }
}