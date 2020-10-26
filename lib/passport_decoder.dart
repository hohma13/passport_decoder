import 'dart:async';

import 'package:flutter/services.dart';

class PassportDecoder {
  static const MethodChannel _channel = const MethodChannel('passport_decoder');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
