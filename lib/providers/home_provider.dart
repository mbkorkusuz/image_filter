import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class GallerySavedImage {
  final String id;
  final String name;
  final DateTime date;
  final String filterApplied;
  final String? thumbnailPath;

  GallerySavedImage({
    required this.id,
    required this.name,
    required this.date,
    required this.filterApplied,
    this.thumbnailPath,
  });
}

class HomeProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  List<GallerySavedImage> _savedImages = [];
  bool _isLoading = true;

  List<GallerySavedImage> get savedImages => _savedImages;
  bool get isLoading => _isLoading;

  Future<void> loadSavedImages() async {
    _isLoading = true;
    notifyListeners();
    
    final appDir = await getApplicationDocumentsDirectory();
    final thumbnailDir = Directory('${appDir.path}/thumbnails');
    
    List<GallerySavedImage> loadedImages = [];
    
    if (await thumbnailDir.exists()) 
    {
      final files = thumbnailDir.listSync()
          .where((entity) => entity is File && 
                  (entity.path.endsWith('.png') || entity.path.endsWith('.jpg')))
          .cast<File>()
          .toList();
      
      final metadataFile = File('${appDir.path}/saved_images_metadata.txt');
      Map<String, String> filterMap = {};
      
      if (await metadataFile.exists()) 
      {
        final content = await metadataFile.readAsString();
        final lines = content.split('\n').where((line) => line.isNotEmpty);
        
        for (String line in lines) 
        {
          final parts = line.split('|');
          if (parts.length >= 2) 
          {
            filterMap[parts[0]] = parts[1];
          }
        }
      }
      
      for (File file in files) 
      {
        final fileName = file.path.split('/').last;
        final stat = await file.stat();
        final filterName = filterMap[fileName] ?? 'Bilinmeyen';
        
        loadedImages.add(GallerySavedImage(
          id: fileName,
          name: fileName,
          date: stat.modified,
          filterApplied: filterName,
          thumbnailPath: file.path,
        ));
      }
    }
    
    loadedImages.sort((a, b) => b.date.compareTo(a.date));
    
    _savedImages = loadedImages;
    _isLoading = false;
    notifyListeners();
  }

  Future<File?> selectImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      return File(picked.path);
    }
    return null;
  }

  Map<String, List<GallerySavedImage>> groupImagesByDate() {
    Map<String, List<GallerySavedImage>> grouped = {};
    
    for (var image in _savedImages) {
      String dateKey = _getDateGroupKey(image.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(image);
    }
    
    return grouped;
  }

  String _getDateGroupKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final imageDate = DateTime(date.year, date.month, date.day);
    
    if (imageDate == today) {
      return 'Bugün';
    } else if (imageDate == yesterday) {
      return 'Dün';
    } else if (now.difference(date).inDays < 7) {
      return 'Bu Hafta';
    } else if (now.difference(date).inDays < 30) {
      return 'Bu Ay';
    } else {
      return '${date.year}';
    }
  }

  Future<void> deleteImage(GallerySavedImage image) async {
   
    if (image.thumbnailPath != null) {
      final file = File(image.thumbnailPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
    
    final appDir = await getApplicationDocumentsDirectory();
    final metadataFile = File('${appDir.path}/saved_images_metadata.txt');
    
    if (await metadataFile.exists()) {
      final content = await metadataFile.readAsString();
      final lines = content.split('\n');
      final newLines = lines.where((line) => !line.startsWith(image.name)).toList();
      await metadataFile.writeAsString(newLines.join('\n'));
    }
    
    loadSavedImages();
    
  }
}