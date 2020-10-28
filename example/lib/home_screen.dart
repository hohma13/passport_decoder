import 'package:flutter/material.dart';
import 'package:passport_decoder/data/passport_data.dart';
import 'package:passport_decoder/passport_decoder.dart';
import 'package:passport_decoder_example/main.dart';
import 'package:passport_decoder_example/passport_details_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String readData = '';
  StateEnum _enum;
  String dateOfBirth = '550501';
  String documentNumber = '724005099';
  String dateOfExpiry = '230410';
  bool isNfcSupported = false;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> readNfcData(BuildContext context) async {
    readData = '';
    isNfcSupported = await PassportDecoder.isNfcSupported;
    print("isNfcSupported: $isNfcSupported");
    if (isNfcSupported) {
      listenData();
    } else {
      _enum = StateEnum.Error;
      readData = 'NFC is not supported or disabled';
      setState(() {});
    }
  }

  void listenData() {
    try {
      PassportDecoder.getPassportData(getMrzData())
          .listen((event) => handleEvents(event))
          .onError((error) => handleError(error));
    } catch (e) {
      print(e);
    }
  }

  void handleError(error) {
    PassportDecoder.dispose();
    _enum = StateEnum.Error;
    readData = error.message.toString();
    setState(() {});
    print('PassportError: $error');
  }

  Map<String, String> getMrzData() {
    return {
      "documentNumber": "$documentNumber",
      "dateOfBirth": "$dateOfBirth",
      "dateOfExpiry": "$dateOfExpiry",
    };
  }

  void handleEvents(Map event) {
    print('PassportEvent: $event');
    if (event.containsValue('start')) {
      _enum = StateEnum.Loading;
    } else if (event.containsValue('end')) {
      _enum = StateEnum.Done;
      PassportDecoder.dispose();
    } else if (event.containsKey('personDetails')) {
      var passportData = PassportData.fromJson(event);
      _enum = StateEnum.Data;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PassportDetailsScreen(passportData: passportData)));
      readData = event.toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_enum == StateEnum.Loading) LinearProgressIndicator(),
              Text(
                getText(),
                textAlign: TextAlign.center,
              ),
              TextFormField(
                decoration:
                    InputDecoration(hintText: documentNumber, helperText: 'Document number'),
                onChanged: (text) => documentNumber = text,
              ),
              TextFormField(
                decoration: InputDecoration(
                    hintText: dateOfBirth, helperText: 'Date of Birth. Format: yyMMdd'),
                onChanged: (text) => dateOfBirth = text,
              ),
              TextFormField(
                decoration: InputDecoration(
                    hintText: dateOfExpiry, helperText: 'Date of Expiry. Format: yyMMdd'),
                onChanged: (text) => dateOfExpiry = text,
              ),
              RaisedButton(
                onPressed: () {
                  readData = '';
                  _enum = StateEnum.Start;
                  setState(() {});
                  return readNfcData(context);
                },
                child: Text('Start'),
              ),
              RaisedButton(
                child: Text('Open NFC Settings'),
                onPressed: () => PassportDecoder.openNFCSettings(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getText() {
    if (_enum == StateEnum.Loading || _enum == StateEnum.Start)
      return _enum.name();
    else if (_enum == StateEnum.Data)
      return '${_enum.name()} $readData';
    else if (_enum == StateEnum.Error)
      return '${_enum.name()} $readData';
    else if (_enum == StateEnum.Done)
      return '${_enum.name()}';
    else
      return "No name";
  }
}
