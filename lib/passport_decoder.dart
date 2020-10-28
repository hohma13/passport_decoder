import 'dart:async';

import 'package:flutter/services.dart';

class PassportDecoder {
  static const MethodChannel _channel = const MethodChannel('passport_decoder');
  static const EventChannel _eventChannel = const EventChannel('passport_decoder_events');
  static Stream<Map<String, dynamic>> _passportStream;

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static void _createPassportStream() {
    _passportStream = _eventChannel.receiveBroadcastStream().map((event) {
      print('');
      // Map<String, dynamic> eventValue = (event as Map).map((key, value) => MapEntry(key, value));
      if (event is Map)
        return event.map((key, value) => MapEntry(key, value));
      else
        return Map<String, String>();
    });
  }

  static Future<bool> get isNfcSupported async {
    final supported = await _channel.invokeMethod("readNfcSupported");
    assert(supported is bool);
    return supported as bool;
  }

  /// Example mrz:
  /// {
  ///   "documentNumber":"AB1234567",
  ///   "dateOfBirth":"yyMMdd",
  ///   "dateOfExpiry":"yyMMdd",
  /// }

  static Stream<Map<String, dynamic>> getPassportData(Map<String, String> mrz) {
    if (_passportStream == null) {
      _createPassportStream();
    }
    StreamController<Map<String, dynamic>> controller = StreamController();
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
      throw e;
    }

    return controller.stream;
  }

  static Future<bool> dispose() async {
    bool isOk = await _channel.invokeMethod('dispose');
    return isOk;
  }
}
