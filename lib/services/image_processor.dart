import 'dart:io';
import 'dart:typed_data';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:image_filter/helper/filters.dart';
import 'package:path_provider/path_provider.dart';

// Isolate'e gönderilecek veri yapısı - intensity eklendi
class ImageProcessingRequest {
  final String inputPath;
  final String outputPath;
  final int filterIndex;
  final double intensity;
  final SendPort responsePort;
  
  ImageProcessingRequest({
    required this.inputPath,
    required this.outputPath,
    required this.filterIndex,
    required this.intensity,
    required this.responsePort,
  });
}

// Isolate'den dönecek sonuç yapısı
class ImageProcessingResult {
  final String? outputPath;
  final String? error;
  final bool isSuccess;
  
  ImageProcessingResult.success(this.outputPath) 
    : error = null, isSuccess = true;
    
  ImageProcessingResult.error(this.error) 
    : outputPath = null, isSuccess = false;
}

class IsolateImageProcessor {
  static Isolate? _processingIsolate;
  static SendPort? _isolateSendPort;
  static bool _isIsolateReady = false;

  // Isolate'i başlat
  static Future<void> initializeIsolate() async {
    if (_isIsolateReady) return;
    
    final receivePort = ReceivePort();
    
    _processingIsolate = await Isolate.spawn(
      _imageProcessingIsolate,
      receivePort.sendPort,
    );
    
    // Isolate'den SendPort'u al
    _isolateSendPort = await receivePort.first as SendPort;
    _isIsolateReady = true;
  }

  // Isolate'i temizle
  static void disposeIsolate() {
    _processingIsolate?.kill();
    _processingIsolate = null;
    _isolateSendPort = null;
    _isIsolateReady = false;
  }

  // Ana filtre uygulama metodu - intensity parametresi eklendi
  static Future<Image?> applyFilter(File imageFile, int filterIndex, {double intensity = 1.0}) async {
    try {
      // Isolate hazır değilse başlat
      if (!_isIsolateReady) {
        await initializeIsolate();
      }

      // Orijinal görüntü seçildiyse filtreleme yapma
      if (filterIndex == 0) {
        return Image.file(imageFile);
      }

      // Geçici output dosyası oluştur
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/filtered_${DateTime.now().millisecondsSinceEpoch}_${filterIndex}_${intensity.toStringAsFixed(1)}.jpg';
      
      final result = await _processImageInIsolate(imageFile.path, outputPath, filterIndex, intensity);
      
      if (result.isSuccess && result.outputPath != null) {
        final outputFile = File(result.outputPath!);
        if (await outputFile.exists()) {
          return Image.file(outputFile);
        }
      }
      return null;
      
    } catch (e) {
      return null;
    }
  }

  // Memory Image'a filtre uygulama - intensity parametresi eklendi
  static Future<Image?> applyFilterToMemoryImage(Image sourceImage, int filterIndex, {double intensity = 1.0}) async {
    
    if (filterIndex == 0) return sourceImage;

    // Isolate hazır değilse başlat
    if (!_isIsolateReady) {
      await initializeIsolate();
    }

    // Memory image'ı geçici dosyaya kaydet
    File? tempInputFile;
    
    if (sourceImage.image is MemoryImage) {
      final memImage = sourceImage.image as MemoryImage;
      tempInputFile = await _saveBytesToTempFile(memImage.bytes, 'temp_input');
    } else if (sourceImage.image is FileImage) {
      tempInputFile = (sourceImage.image as FileImage).file;
    }

    if (tempInputFile == null || !await tempInputFile.exists()) {
      return null;
    }

    // Geçici output dosyası oluştur
    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/filtered_${DateTime.now().millisecondsSinceEpoch}_${filterIndex}_${intensity.toStringAsFixed(1)}.jpg';

    final result = await _processImageInIsolate(tempInputFile.path, outputPath, filterIndex, intensity);
    
    // Eğer geçici input dosyası oluşturduysak sil
    if (sourceImage.image is MemoryImage) {
      await tempInputFile.delete();
    }
    
    if (result.isSuccess && result.outputPath != null) {
      final outputFile = File(result.outputPath!);
      if (await outputFile.exists()) {
        return Image.file(outputFile);
      }
    }
    return null;

  }

  // Isolate'e işlem gönder ve sonuç bekle - intensity parametresi eklendi
  static Future<ImageProcessingResult> _processImageInIsolate(
    String inputPath, 
    String outputPath,
    int filterIndex,
    double intensity
  ) async {
    if (_isolateSendPort == null) {
      return ImageProcessingResult.error('Isolate not ready');
    }

    final responsePort = ReceivePort();
    
    final request = ImageProcessingRequest(
      inputPath: inputPath,
      outputPath: outputPath,
      filterIndex: filterIndex,
      intensity: intensity,
      responsePort: responsePort.sendPort,
    );
    
    // İsteği isolate'e gönder
    _isolateSendPort!.send(request);
    
    // Sonucu bekle
    final result = await responsePort.first as ImageProcessingResult;
    responsePort.close();
    
    return result;
  }

  // Bytes'ı geçici dosyaya kaydetme yardımcı fonksiyonu
  static Future<File> _saveBytesToTempFile(Uint8List bytes, String prefix) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }

  // Memory Image'ı geçici dosyaya kaydetme fonksiyonu (mevcut API uyumluluğu için)
  static Future<File> saveMemoryImageToTempFile(Image memoryImage) async {
    if (memoryImage.image is MemoryImage) {
      final memImage = memoryImage.image as MemoryImage;
      return await _saveBytesToTempFile(memImage.bytes, 'temp_filtered');
    }

    throw Exception('Memory image geçici dosyaya kaydedilemedi');
  }

  // Memory Image'dan bytes alma (mevcut API uyumluluğu için)
  static Future<Uint8List?> getImageBytes(Image image) async {
    if (image.image is MemoryImage) {
      final memImage = image.image as MemoryImage;
      return memImage.bytes;
    } else if (image.image is FileImage) {
      final fileImage = image.image as FileImage;
      return await fileImage.file.readAsBytes();
    }
    return null;
  }
}

// Isolate'de çalışacak ana fonksiyon
void _imageProcessingIsolate(SendPort mainSendPort) async {
  final receivePort = ReceivePort();
  
  // Ana thread'e SendPort'u gönder
  mainSendPort.send(receivePort.sendPort);
  
  // FilterLib instance'ını isolate içinde oluştur
  final filterLib = FilterLib();
  
  // İstekleri dinle
  await for (final message in receivePort) {
    if (message is ImageProcessingRequest) {
      try {
        final result = await _processImageInIsolateHelper(
          message.inputPath,
          message.outputPath,
          message.filterIndex,
          message.intensity,
          filterLib,
        );
        message.responsePort.send(result);
      } catch (e) {
        message.responsePort.send(
          ImageProcessingResult.error('Processing error: $e')
        );
      }
    }
  }
}

// Isolate içinde image processing işlemini yapan yardımcı fonksiyon - intensity eklendi
Future<ImageProcessingResult> _processImageInIsolateHelper(
  String inputPath,
  String outputPath,
  int filterIndex,
  double intensity,
  FilterLib filterLib,
) async {
  try {
    // Input dosyasının var olduğundan emin ol
    final inputFile = File(inputPath);
    if (!await inputFile.exists()) {
      return ImageProcessingResult.error('Input file does not exist');
    }

    // Filtreyi path-based olarak intensity ile uygula
    filterLib.applyFilterByIndex(filterIndex, inputPath, outputPath, intensity: intensity);

    // Output dosyasının oluşturulduğundan emin ol
    final outputFile = File(outputPath);
    if (!await outputFile.exists()) {
      return ImageProcessingResult.error('Filter processing failed - output file not created');
    }

    return ImageProcessingResult.success(outputPath);
    
  } catch (e) {
    return ImageProcessingResult.error('Image processing error: $e');
  }
}