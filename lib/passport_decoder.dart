import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

class PassportDecoder {
  static const MethodChannel _channel = const MethodChannel('passport_decoder');
  static const EventChannel _eventChannel = const EventChannel('passport_decoder_events');
  static Stream<dynamic> _passportStream;

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static void _createPassportStream() {
    _passportStream = _eventChannel.receiveBroadcastStream().map((event) {
      print('');
      var json;
      if (event is String) {
        json = jsonDecode(event);
        print(json.toString());
      }
      if (json is Map)
        return json.map((key, value) => MapEntry(key, value));
      else
        return Map<String, String>();
    });
  }

  static Future<bool> get isNfcSupported async {
    bool supported;
    if (Platform.isAndroid) {
      supported = await _channel.invokeMethod("readNfcSupported");
    } else if (Platform.isIOS) {
      supported = true;
    } else {
      supported = false;
    }
    assert(supported is bool);
    return supported;
  }

  ///Android only
  static Future<bool> openNFCSettings() async {
    if (Platform.isAndroid) {
      final isOpened = await _channel.invokeMethod('openNFCSettings');
      assert(isOpened is bool);
      return isOpened as bool;
    } else {
      return false;
    }
  }

  /// Example mrz:
  /// {
  ///   "documentNumber":"AB1234567",
  ///   "dateOfBirth":"yyMMdd",
  ///   "dateOfExpiry":"yyMMdd",
  /// }

  static Stream<Map<dynamic, dynamic>> getPassportData(Map<String, String> mrz) {
    if (_passportStream == null) {
      _createPassportStream();
    } else {
      throw Exception('Already start');
    }
    StreamController<Map<dynamic, dynamic>> controller = StreamController();
    final stream = _passportStream;
    final subscription = stream.listen(
      (message) {
        controller.add(message);
      },
      onError: (error) {
        controller.addError(error);
        controller.close();
      },
      onDone: () {
        _passportStream = null;
        return controller.close();
      },
    );
    controller.onCancel = () {
      subscription.cancel();
    };
    try {
      _channel.invokeMethod('getPassportData', mrz);
    } catch (e) {
      controller.addError(e);
    }

    return controller.stream;
  }

  static Future<bool> dispose() async {
    _passportStream = null;
    bool isOk = await _channel.invokeMethod('dispose');
    return isOk;
  }
}
