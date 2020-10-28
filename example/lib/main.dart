import 'package:flutter/material.dart';
import 'package:passport_decoder_example/home_screen.dart';

enum StateEnum { Loading, Done, Error }

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
