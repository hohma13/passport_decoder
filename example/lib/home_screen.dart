import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState(BuildContext context) async {
    bool isNfcSupported = await PassportDecoder.isNfcSupported;
    print("isNfcSupported: $isNfcSupported");
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      PassportDecoder.getPassportData({
        "documentNumber": "$documentNumber",
        "dateOfBirth": "$dateOfBirth",
        "dateOfExpiry": "$dateOfExpiry",
      }).listen((event) {
        print('PassportEvent: $event');
        if (event.containsValue('start')) {
          _enum = StateEnum.Loading;
          readData = 'Reading NFC';
        } else if (event.containsValue('end')) {
          _enum = StateEnum.Done;
          readData = readData + '\n' + 'Done';
        } else if (event.containsKey('personalDetails')) {
          var a = PassportData(
              personalDetails: PersonalDetails.fromMap(Map.from(event['personalDetails'])));
          _enum = StateEnum.Done;
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PassportDetailsScreen(passportData: a)));
          readData = event.toString();
        }
        setState(() {});
      }).onError((error) {
        print('PassportError: $error');
      });
    } on PlatformException {
      readData = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_enum == StateEnum.Loading) CircularProgressIndicator(),
            Text(
              'Running on: $readData\n',
              textAlign: TextAlign.center,
            ),
            TextFormField(
              decoration: InputDecoration(hintText: documentNumber, helperText: 'Document number'),
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
                _enum = StateEnum.Loading;
                setState(() {});
                return initPlatformState(context);
              },
              child: Text('Start'),
            )
          ],
        ),
      ),
    );
  }
}
