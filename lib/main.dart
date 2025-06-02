import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home.dart';
import 'screens/show_image.dart';
import 'providers/home_provider.dart';
import 'providers/image_display_provider.dart';
import 'providers/filter_preview_provider.dart';
import 'providers/image_comparison_provider.dart';
void main() => runApp(ImageFilterApp());

class ImageFilterApp extends StatelessWidget {
  const ImageFilterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ImageDisplayProvider()),
        ChangeNotifierProvider(create: (_) => FilterPreviewProvider()),
        ChangeNotifierProvider(create: (_) => ImageComparisonProvider()),
      ],
      child: MaterialApp(
        title: 'Image Filter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          textTheme: Typography.blackCupertino,
        ),
        initialRoute: '/',
        routes: 
        {
          '/': (context) => PhotoPickerScreen(),
          '/display': (context) => PhotoDisplayScreen(),
        },
      ),
    );
  }
}