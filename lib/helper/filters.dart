import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef FilterFuncC = Void Function(
  Pointer<Utf8>, Pointer<Utf8>, Float,
);


typedef FilterFuncDart = void Function(
  Pointer<Utf8>, Pointer<Utf8>, double,
);

class FilterLib {
  late DynamicLibrary _lib;

  late FilterFuncDart applyFilter1;
  late FilterFuncDart applyFilter2;
  late FilterFuncDart applyFilter3;
  late FilterFuncDart applyFilter4;
  late FilterFuncDart applyFilter5;
  late FilterFuncDart applyFilter6;
  late FilterFuncDart applyFilter7;
  late FilterFuncDart applyFilter8;
  late FilterFuncDart applyFilter9;
  late FilterFuncDart applyFilter10;
  late FilterFuncDart applyFilter11;
  late FilterFuncDart applyFilter12;

  

  FilterLib() {
    // platforma göre .so veya .dylib seçimi
    if (Platform.isAndroid) {
      _lib = DynamicLibrary.open('libfilters.so');
    } else if (Platform.isIOS) {
      _lib = DynamicLibrary.process(); 
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    applyFilter1 = _lib
        .lookup<NativeFunction<FilterFuncC>>('apply_filter1')
        .asFunction();

    applyFilter2 = _lib
        .lookup<NativeFunction<FilterFuncC>>('apply_filter2')
        .asFunction();

    applyFilter3 = _lib
        .lookup<NativeFunction<FilterFuncC>>('apply_filter3')
        .asFunction();

    applyFilter4 = _lib
        .lookup<NativeFunction<FilterFuncC>>('apply_filter4')
        .asFunction();

    applyFilter5 = _lib
        .lookup<NativeFunction<FilterFuncC>>('apply_filter5')
        .asFunction();

    applyFilter6 = _lib
        .lookup<NativeFunction<FilterFuncC>>('apply_filter6')
        .asFunction();

    applyFilter7 = _lib
        .lookup<NativeFunction<FilterFuncC>>('apply_filter7')
        .asFunction();

    applyFilter8 = _lib
        .lookup<NativeFunction<FilterFuncC>>('apply_filter8')
        .asFunction();

    applyFilter9 = _lib
        .lookup<NativeFunction<FilterFuncC>>('apply_filter9')
        .asFunction();

    applyFilter10 = _lib
        .lookup<NativeFunction<FilterFuncC>>('apply_filter10')
        .asFunction();

    applyFilter11 = _lib
        .lookup<NativeFunction<FilterFuncC>>('apply_filter11')
        .asFunction();

    applyFilter12 = _lib
        .lookup<NativeFunction<FilterFuncC>>('apply_filter12')
        .asFunction();
  }

  
  void applyFilterByIndex(int index, String inputPath, String outputPath, {double intensity = 1.0}) {
    final inputPathPtr = inputPath.toNativeUtf8();
    final outputPathPtr = outputPath.toNativeUtf8();
    
    
    switch (index) {
      case 1:
        applyFilter1(inputPathPtr, outputPathPtr, intensity);
        break;
      case 2:
        applyFilter2(inputPathPtr, outputPathPtr, intensity);
        break;
      case 3:
        applyFilter3(inputPathPtr, outputPathPtr, intensity);
        break;
      case 4:
        applyFilter4(inputPathPtr, outputPathPtr, intensity);
        break;
      case 5:
        applyFilter5(inputPathPtr, outputPathPtr, intensity);
        break;
      case 6:
        applyFilter6(inputPathPtr, outputPathPtr, intensity);
        break;
      case 7:
        applyFilter7(inputPathPtr, outputPathPtr, intensity);
        break;
      case 8:
        applyFilter8(inputPathPtr, outputPathPtr, intensity);
        break;
      case 9:
        applyFilter9(inputPathPtr, outputPathPtr, intensity);
        break;
      case 10:
        applyFilter10(inputPathPtr, outputPathPtr, intensity);
        break;
      case 11:
        applyFilter11(inputPathPtr, outputPathPtr, intensity);
        break;
      case 12:
        applyFilter12(inputPathPtr, outputPathPtr, intensity);
        break;
    }
    
    malloc.free(inputPathPtr);
    malloc.free(outputPathPtr);
    
  }

  
  static String getFilterName(int index) {
    switch (index) {
      case 0: return 'Orijinal';
      case 1: return 'Sepia';
      case 2: return 'Sıcak';
      case 3: return 'Soğuk';
      case 4: return 'Eskiz';
      case 5: return 'Kontrast';
      case 6: return 'Solgun';
      case 7: return 'S&B';
      case 8: return 'Vintage';
      case 9: return 'Bulanık';
      case 10: return 'Kenar';
      case 11: return 'Kabartma';
      case 12: return 'Negatif';
      default: return '';
    }
  }

  
  static String getIntensityLabel(double intensity) {
    if (intensity <= 0.2) return '1';
    if (intensity <= 0.4) return '2';
    if (intensity <= 0.6) return '3';
    if (intensity <= 0.8) return '4';
    return '5';
  }

  static int get totalFilters => 12;
}