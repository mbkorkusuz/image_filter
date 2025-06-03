# Image Filter App

This repository contain a modern mobile application that allows users to apply various filters to images. The core filter operations are implemented in **C++ using the OpenCV library**.

The app is built with **Flutter**, and the C++ filters are integrated via **Dart FFI**, providing seamless cross-platform performance without relying on platform channels.

---

## DEMO

[![Watch the demo](https://img.youtube.com/vi/mdfHy1uaFq0/0.jpg)](https://www.youtube.com/watch?v=mdfHy1uaFq0)

## Requirements

- Flutter SDK (3.x or later)
- Android SDK, NDK & CMake (for Android builds)
- Xcode + CocoaPods (for iOS builds)
- OpenCV Android SDK
- OpenCV iOS Framework

## Features

- Select and preview images from the gallery
- Apply filters in real time
- High-performance C++ image processing engine
- Direct integration using Dart FFI (no platform channels)
- Supports both Android and iOS

---

## Technologies Used

- **Flutter** 
- **Dart FFI** – for calling native C++ functions
- **C++** – filter implementation
- **OpenCV** – computer vision and image processing library

---

## Installation

### 1. Clone the repository

```bash
git clone git@github.com:mbkorkusuz/image_filter.git
cd image_filter
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Run

#### Android

```bash
flutter run
```

#### IOS

```bash
cd ios
pod install
cd ..
flutter run

```

#### Last Notes

- Make sure you have the corresponding opencv libraries in your project.

    - For android copy the opencv library folder into source folder.
    - For ios copy the opencv2.framework folder to ios folder. And add the opencv2.framework to your Xcode project.

- Notice that AI process is actually simulation behavior to show the user. And for it is to be run correctly run the python script "edge_api.py" in the source folder
