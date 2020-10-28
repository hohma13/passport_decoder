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
            children: [
              TextFormField(
                initialValue: passportData.personalDetails.givenNames,
                decoration: InputDecoration(helperText: 'Given Name'),
              ),
              TextFormField(
                initialValue: passportData.personalDetails.surname,
                decoration: InputDecoration(helperText: 'Surname'),
              ),
              TextFormField(
                initialValue: passportData.personalDetails.gender,
                decoration: InputDecoration(helperText: 'Gender'),
              ),
              TextFormField(
                initialValue: passportData.personalDetails.dateOfBirth,
                decoration: InputDecoration(helperText: 'Date of Birth'),
              ),
              TextFormField(
                initialValue: passportData.personalDetails.dateOfExpiry,
                decoration: InputDecoration(helperText: 'Date of Expiry'),
              ),
              TextFormField(
                initialValue: passportData.personalDetails.documentNumber,
                decoration: InputDecoration(helperText: 'Document number'),
              ),
              TextFormField(
                initialValue: passportData.personalDetails.documentCode,
                decoration: InputDecoration(helperText: 'Document code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
