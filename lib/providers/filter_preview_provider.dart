import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_filter/helper/filters.dart';
import 'package:image_filter/services/image_processor.dart';

// filter preview and cache managament

class FilterPreviewProvider extends ChangeNotifier {
  final Map<int, Image?> _previewCache = {};
  final Set<int> _loadingPreviews = {};

  Map<int, Image?> get previewCache => _previewCache;
  Set<int> get loadingPreviews => _loadingPreviews;

  void clearCache() {
    _previewCache.clear();
    _loadingPreviews.clear();
    notifyListeners();
  }

  void initializeWithImage(File imageFile) {
    _previewCache.clear();
    _loadingPreviews.clear();
    _previewCache[0] = Image.file(imageFile);
  }

  Future<void> generatePreviews(File imageFile) async {
    _previewCache[0] = Image.file(imageFile);
    notifyListeners();

    for (int i = 1; i <= FilterLib.totalFilters; i++) {
      generatePreviewForFilter(i, imageFile);
    }
  }

  Future<void> generatePreviewForFilter(int filterIndex, File imageFile) async {
    if (_previewCache.containsKey(filterIndex) || _loadingPreviews.contains(filterIndex)) {
      return;
    }

    _loadingPreviews.add(filterIndex);
    notifyListeners();

    try {
      final filteredImage = await IsolateImageProcessor.applyFilter(
        imageFile, 
        filterIndex, 
        intensity: 0.6
      );
      
      if (filteredImage != null) {
        _previewCache[filterIndex] = filteredImage;
        _loadingPreviews.remove(filterIndex);
        notifyListeners();
      }
    } catch (e) {
      _loadingPreviews.remove(filterIndex);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _previewCache.clear();
    _loadingPreviews.clear();
    super.dispose();
  }
}