import 'dart:io';
import 'dart:typed_data';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:image_filter/helper/filters.dart';
import 'package:path_provider/path_provider.dart';

// data structure to be sent to isolate 
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

// processing result from isoleate
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

  // initialize isolate
  static Future<void> initializeIsolate() async {
    if (_isIsolateReady) return;
    
    final receivePort = ReceivePort();
    
    _processingIsolate = await Isolate.spawn(
      _imageProcessingIsolate,
      receivePort.sendPort,
    );
    
    // take sendport from isolate
    _isolateSendPort = await receivePort.first as SendPort;
    _isIsolateReady = true;
  }

  // dispose isolate
  static void disposeIsolate() {
    _processingIsolate?.kill();
    _processingIsolate = null;
    _isolateSendPort = null;
    _isIsolateReady = false;
  }

  // main methodfor filter
  static Future<Image?> applyFilter(File imageFile, int filterIndex, {double intensity = 1.0}) async {
    
    // start isolate
    if (!_isIsolateReady) {
      await initializeIsolate();
    }

    // no filter
    if (filterIndex == 0) {
      return Image.file(imageFile);
    }

    // temp output file
    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/filtered_${DateTime.now().millisecondsSinceEpoch}_${filterIndex}_${intensity.toStringAsFixed(1)}.jpg';
    
    final result = await _processImageInIsolate(imageFile.path, outputPath, filterIndex, intensity);
    
    if (result.isSuccess && result.outputPath != null) {
      final outputFile = File(result.outputPath!);
      if (await outputFile.exists()) {
        return Image.file(outputFile);
      }
    }

    // failed
    return null;
    
  }

  // apply filter to memory image
  static Future<Image?> applyFilterToMemoryImage(Image sourceImage, int filterIndex, {double intensity = 1.0}) async {
    
    if (filterIndex == 0) return sourceImage;

    // start isolate
    if (!_isIsolateReady) {
      await initializeIsolate();
    }

    // save temp file to memory image
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

    // temp output file
    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/filtered_${DateTime.now().millisecondsSinceEpoch}_${filterIndex}_${intensity.toStringAsFixed(1)}.jpg';

    final result = await _processImageInIsolate(tempInputFile.path, outputPath, filterIndex, intensity);
    
    // delete temp input file
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

  // send image to isolate
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
    
    // send request to isolate
    _isolateSendPort!.send(request);
    
    // result
    final result = await responsePort.first as ImageProcessingResult;
    responsePort.close();
    
    return result;
  }

  // save Bytes to the temp file
  static Future<File> _saveBytesToTempFile(Uint8List bytes, String prefix) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }

  // save memory image to temp file
  static Future<File> saveMemoryImageToTempFile(Image memoryImage) async {
    if (memoryImage.image is MemoryImage) {
      final memImage = memoryImage.image as MemoryImage;
      return await _saveBytesToTempFile(memImage.bytes, 'temp_filtered');
    }

    throw Exception('Memory image geçici dosyaya kaydedilemedi');
  }

  // get bytes from memory image
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

// main function in isolate
void _imageProcessingIsolate(SendPort mainSendPort) async {
  final receivePort = ReceivePort();
  
  mainSendPort.send(receivePort.sendPort);
  
  // filterLib instance
  final filterLib = FilterLib();
  
  // listen for requests
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

// helper function
Future<ImageProcessingResult> _processImageInIsolateHelper(
  String inputPath,
  String outputPath,
  int filterIndex,
  double intensity,
  FilterLib filterLib,
) async {
  try {
    // input file check
    final inputFile = File(inputPath);
    if (!await inputFile.exists()) {
      return ImageProcessingResult.error('Input file does not exist');
    }

    // apply filter. image file's path is sent
    filterLib.applyFilterByIndex(filterIndex, inputPath, outputPath, intensity: intensity);

    // output file
    final outputFile = File(outputPath);
    if (!await outputFile.exists()) {
      return ImageProcessingResult.error('Filter processing failed - output file not created');
    }

    return ImageProcessingResult.success(outputPath);
    
  } catch (e) {
    return ImageProcessingResult.error('Image processing error: $e');
  }
}