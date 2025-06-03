import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:gal/gal.dart';
import 'package:image_filter/services/image_processor.dart';
import 'package:image_filter/helper/filters.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/app_widgets.dart';
import '../providers/image_display_provider.dart';
import '../providers/filter_preview_provider.dart';
import '../providers/image_comparison_provider.dart';
import '../animations/sparkle.dart';
import '../widgets/show_image_widgets.dart';
import 'package:http/http.dart' as http;

class PhotoDisplayScreen extends StatefulWidget {
  const PhotoDisplayScreen({super.key});

  @override
  _PhotoDisplayScreenState createState() => _PhotoDisplayScreenState();
}

class _PhotoDisplayScreenState extends State<PhotoDisplayScreen> 
    with TickerProviderStateMixin {

  late AnimationController _sparkleController;
  late List<Sparkle> _sparkles;
  
  @override
  void initState() {
    super.initState();
    _initializeIsolate();
    _sparkleController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _sparkleController.repeat();
    _sparkles = List.generate(25, (_) => Sparkle.random());
  }
  
  Future<void> _initializeIsolate() async {
    await IsolateImageProcessor.initializeIsolate();
  }
  
  @override
  void dispose() {
    IsolateImageProcessor.disposeIsolate();
    _sparkleController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final route = ModalRoute.of(context);
    if (route != null && route.settings.arguments != null) {
      final file = route.settings.arguments as File;
      
      final imageDisplayProvider = context.read<ImageDisplayProvider>();
      
      if (imageDisplayProvider.imageFile?.path != file.path) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final filterPreviewProvider = context.read<FilterPreviewProvider>();
          final comparisonProvider = context.read<ImageComparisonProvider>();
          
          imageDisplayProvider.setImageFile(file);
          filterPreviewProvider.initializeWithImage(file);
          comparisonProvider.resetSlider();
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppWidgets.errorSnackBar(message)
      );
    }
  }

  void _onSavePressed() async {
    final imageDisplayProvider = context.read<ImageDisplayProvider>();
    
    try {
      imageDisplayProvider.setProcessing(true);
      
      final currentImage = imageDisplayProvider.filterStates[imageDisplayProvider.currentStateIndex].processedImage;
      final currentFilterName = FilterLib.getFilterName(imageDisplayProvider.filterStates[imageDisplayProvider.currentStateIndex].filterIndex);
      
      final imageProvider = currentImage.image;
      final imageStream = imageProvider.resolve(ImageConfiguration.empty);
      final completer = Completer<Uint8List>();
      
      imageStream.addListener(ImageStreamListener((ImageInfo info, bool _) async {
        final byteData = await info.image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          completer.complete(byteData.buffer.asUint8List());
        } else {
          completer.completeError('Görüntü verisi alınamadı');
        }
      }));
      
      final bytes = await completer.future;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = "filtered_image_$timestamp.png";
      
      await Gal.putImageBytes(bytes, name: fileName);
      await _saveThumbnail(bytes, fileName);
      await _saveImageMetadata(fileName, currentFilterName, timestamp);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppWidgets.successSnackBar('Fotoğraf galeriye kaydedildi!')
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showErrorSnackBar('Kaydetme hatası: $e');
    } finally {
      if (mounted) {
        imageDisplayProvider.setProcessing(false);
      }
    }
  }

  Future<void> _saveThumbnail(Uint8List imageBytes, String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final thumbnailDir = Directory('${appDir.path}/thumbnails');
    
    if (!await thumbnailDir.exists()) {
      await thumbnailDir.create(recursive: true);
    }
    
    final thumbnailFile = File('${thumbnailDir.path}/$fileName');
    await thumbnailFile.writeAsBytes(imageBytes);
  }

  Future<void> _saveImageMetadata(String fileName, String filterName, int timestamp) async {
    final appDir = await getApplicationDocumentsDirectory();
    final metadataFile = File('${appDir.path}/saved_images_metadata.txt');
    
    final metadataLine = '$fileName|$filterName|$timestamp\n';
    await metadataFile.writeAsString(metadataLine, mode: FileMode.append);
  }

Future<void> sendToPythonApi(File imageFile) async {
  final imageDisplayProvider = context.read<ImageDisplayProvider>();
  
  try {
    imageDisplayProvider.setAIProcessing(true);
    
    // Şu anda pipeline'da görünen görüntüyü al
    final currentImage = imageDisplayProvider.displayedImage ?? 
                        imageDisplayProvider.filterStates[imageDisplayProvider.currentStateIndex].processedImage;
    
    // Görüntüyü geçici dosyaya kaydet
    File imageToSend;
    
    if (currentImage.image is FileImage) {
      // Eğer FileImage ise direkt dosyayı kullan
      imageToSend = (currentImage.image as FileImage).file;
    } else if (currentImage.image is MemoryImage) {
      // MemoryImage ise geçici dosyaya kaydet
      final memImage = currentImage.image as MemoryImage;
      final tempDir = await getTemporaryDirectory();
      imageToSend = File('${tempDir.path}/current_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await imageToSend.writeAsBytes(memImage.bytes);
    } else {
      // Fallback olarak orijinal dosyayı kullan
      imageToSend = imageFile;
    }
    
    final uri = Uri.parse('http://10.0.2.2:5000/process');
    final request = http.MultipartRequest('POST', uri);
    
    // Şu anki pipeline görüntüsünü gönder
    request.files.add(
      await http.MultipartFile.fromPath('image', imageToSend.path)
    );
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      // İşlenmiş görüntüyü al
      final processedImageBytes = response.bodyBytes;
      
      // Geçici dosya oluştur
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/ai_processed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(processedImageBytes);
      
      // İşlenmiş görüntüyü pipeline'a ekle
      final processedImage = Image.file(tempFile);
      
      // Yeni FilterState oluştur ve pipeline'a ekle
      final newState = FilterState(
        filterIndex: 99, // AI işlemi için özel index
        filterName: 'AI İyileştirme',
        processedImage: processedImage,
        timestamp: DateTime.now(),
      );
      
      imageDisplayProvider.addFilterState(newState);
    } else {
      throw Exception('API hatası: ${response.statusCode}');
    }
    
    // Geçici dosyayı temizle (sadece MemoryImage için oluşturduysak)
    if (currentImage.image is MemoryImage && imageToSend.path != imageFile.path) {
      await imageToSend.delete();
    }
    
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppWidgets.errorSnackBar('AI işleme başarısız: $e')
      );
    }
  } finally {
    imageDisplayProvider.setAIProcessing(false);
  }
}

  void _onCancelPressed() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageDisplayProvider>(
      builder: (context, imageDisplayProvider, child) {
        if (imageDisplayProvider.imageFile == null) {
          return Scaffold(
            body: AppWidgets.loading(text: 'Görüntü yükleniyor...'),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header Section
                PhotoDisplayHeader(
                  onCancel: _onCancelPressed,
                  onAIProcess: () => sendToPythonApi(imageDisplayProvider.imageFile!),
                  onSave: imageDisplayProvider.filterStates.length > 1 ? _onSavePressed : null,
                  onReset: imageDisplayProvider.filterStates.length > 1 ? () => imageDisplayProvider.resetToOriginal() : null,
                ),
                
                // Filter Chain Section
                const FilterChainSection(),
                
                // Image Display Section
                PhotoDisplayImage(
                  sparkles: _sparkles,
                  sparkleAnimation: _sparkleController,
                ),
                
                // Intensity Slider Section
                const IntensitySliderSection(),
                
                // Filter Preview Section
                const FilterPreviewSection(),
                
                // Bottom Navigation Section
                const BottomNavigationSection(),
              ],
            ),
          ),
        );
      },
    );
  }
}