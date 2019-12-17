import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class FlutterExif {

  static const MethodChannel _channel =
      const MethodChannel('flutter_exif');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<List<FlutterExifData>> list ( int starting, int ending, { max = 12 }) async {

    Iterable it = await _channel.invokeMethod('filter',
        <String,dynamic>{ 'starting': starting, 'ending': ending, 'max': max });

    if (it.isEmpty) {
      return List<FlutterExifData>();
    }

    var mapped = it.map( (item) => FlutterExifData(item) );
    return mapped.toList();

  }

  static Future<Uint8List> image ( String id, { width: int, height: int }) async {
    Uint8List result = await _channel.invokeMethod('image',
        <String,dynamic>{ 'id': id, 'width': width, 'height': height });
    return result;
  }

}

class FlutterExifData {
  String identifier;
  int width;
  int height;
  int createdAt;
  double latitude;
  double longitude;
  double altitude;
  FlutterExifData( Map map ) {
    this.identifier = map["identifier"] ?? null;
    this.width = map["width"];
    this.height = map["height"];
    this.createdAt = map["createdAt"] ?? null;
    this.latitude = map["latitude"] as double ?? null;
    this.longitude = map["longitude"] as double ?? null;
    this.altitude = map["altitude"] as double ?? null;
  }
}
