# flutter_exif

[![pub package](https://img.shields.io/pub/v/flutter_exif.svg)](https://pub.dartlang.org/packages/flutter_exif)

A Flutter plugin for accessing to all metadata from your photos. Supports iOS and Android.

## Getting Started

In Android, you need to add the **READ_EXTERNAL_STORAGE** permission in your AndroidManifest.xml.

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

In iOS, you need to add the key **NSPhotoLibraryUsageDescription** in your Info.plist file.

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photos in your gallery for this demo</string>
````

## Usage

### Import package

To use this plugin you must add `flutter_exif` as a [dependency in your `pubspec.yaml` file](https://flutter.io/platform-plugins/).

```yaml
dependencies:
    flutter_exif: ^1.0.0
```

### Example

```dart
import 'package:flutter_exif/flutter_exif.dart';
````

Listing images from your gallery filtered by an initial date and an end date. NOTE: By now, only the images with GPS data in their metadata is returned.

```dart
int startingAt = 1574679600;
int endingAt = 1575370800;
List<FlutterExifData> list = await FlutterExif.list( startingAt, endingAt );
```

Retrieve the image data for a FlutterExifData object:

```dart
FlutterExifData item = ...;
Uint8List data = await FlutterExif.image( item.identifier );
````

### Models

#### FlutterExifData

```dart
class FlutterExifData {
    String identifier;
    int width;
    int height;
    int createdAt;
    double latitude;
    double longitude;
    double altitude;                        // Only in iOS
}
```

## Credits

This plugin has been created and developed by [Daniel Martínez](mailto:dmartinez@danielmartinez.info).

Any suggestions and contributions are welcomed.
Thanks for using this plugin!
