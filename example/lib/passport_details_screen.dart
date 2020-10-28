import 'package:flutter/material.dart';
import 'package:passport_decoder/data/passport_data.dart';

class PassportDetailsScreen extends StatelessWidget {
  final PassportData passportData;

  const PassportDetailsScreen({Key key, this.passportData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Passport details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Information',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              SizedBox(
                height: 8.0,
              ),
              if (passportData.personDetails != null)
                Text('${passportData.personDetails.toString()}'),
              if (passportData.additionalPersonDetails != null)
                Text('${passportData.additionalPersonDetails.toString()}'),
            ],
          ),
        ),
      ),
    );
  }
}
