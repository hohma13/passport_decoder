import 'package:flutter/material.dart';
import 'package:passport_decoder_example/home_screen.dart';

enum StateEnum { Start, Loading, Done, Data, Error }

extension SteteEnumExt on StateEnum {
  String name() {
    switch (this) {
      case StateEnum.Start:
        return 'Please hold your phone on top of document';
      case StateEnum.Loading:
        return 'Reading';
      case StateEnum.Done:
        return 'Done';
      case StateEnum.Data:
        return 'Data: ';
      case StateEnum.Error:
        return 'Error: ';
      default:
        return 'No name';
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {'/': (context) => HomeScreen()},
    );
  }
}
