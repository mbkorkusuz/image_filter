import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../themes/app_theme.dart';
import '../themes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/home_provider.dart';


// This is the home screen that displays previously filtered images and lets user add one to the collection.
class PhotoPickerScreen extends StatefulWidget {
  const PhotoPickerScreen({super.key});

  @override
  State<PhotoPickerScreen> createState() => _PhotoPickerScreenState();
}

class _PhotoPickerScreenState extends State<PhotoPickerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadSavedImages();
    });
  }

  Future<void> _selectImage(BuildContext context) async {
    final homeProvider = context.read<HomeProvider>();
    final imageFile = await homeProvider.selectImage();
    
    if (imageFile != null) {
      await Navigator.pushNamed(
        context,
        '/display',
        arguments: imageFile,
      );
    }
  }

  Future<void> _deleteImage(GallerySavedImage image) async {
    
    await context.read<HomeProvider>().deleteImage(image);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppWidgets.successSnackBar('Fotoğraf silindi')
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Consumer<HomeProvider>(
                builder: (context, homeProvider, child) {
                  if (homeProvider.isLoading) {
                    return AppWidgets.loading(text: 'Koleksiyonlar yükleniyor...');
                  }
                  
                  if (homeProvider.savedImages.isEmpty) {
                    return _buildEmptyView();
                  }
                  
                  return _buildCollectionsView(homeProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Consumer<HomeProvider>(
          builder: (context, homeProvider, child) {
            return AppWidgets.headerSection(
              title: 'Koleksiyonlar',
            );
          },
        ),
        const SizedBox(height: 20),
        IconButton(
            onPressed: () => _selectImage(context), 
            icon: const Icon(Icons.add, size: 32, color: Colors.black,),
        )
      ],
    );
  }

  Widget _buildEmptyView() {
    return AppWidgets.emptyState(
      icon: Icons.collections_rounded,
      title: 'Henüz Koleksiyon Yok',
    );
  }

  Widget _buildCollectionsView(HomeProvider homeProvider) {
    final groupedImages = homeProvider.groupImagesByDate();
    
    return RefreshIndicator(
      onRefresh: () => homeProvider.loadSavedImages(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: groupedImages.length,
        itemBuilder: (context, index) {
          final dateGroup = groupedImages.keys.toList()[index];
          final images = groupedImages[dateGroup]!;
          
          return _buildDateSection(dateGroup, images);
        },
      ),
    );
  }

  Widget _buildDateSection(String dateGroup, List<GallerySavedImage> images) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(dateGroup, style: AppTextStyles.heading3),
        ),
        _buildImageGrid(images),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildImageGrid(List<GallerySavedImage> images) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.5,
        mainAxisSpacing: 2.5,
        childAspectRatio: 1.0,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return _buildImageTile(image);
      },
    );
  }

  Widget _buildImageTile(GallerySavedImage image) {
    return AppWidgets.filterGridItem(
      thumbnailPath: image.thumbnailPath!,
      onTap: () => _showImagePreview(image),
    );
  }

  void _showImagePreview(GallerySavedImage image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.file(File(image.thumbnailPath!), fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 16),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteDialog(image);
                      }, 
                      icon: const Icon(Icons.delete, size: 24),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 0,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: AppTheme.textOnPrimary, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(GallerySavedImage image) {
    AppWidgets.showConfirmDialog(
      context: context,
      title: 'Fotoğrafı Sil',
      content: 'Seçili fotoğrafı silmek istediğinizden emin misiniz',
    ).then((confirmed) {
      if (confirmed == true) {
        _deleteImage(image);
      }
    });
  }
}