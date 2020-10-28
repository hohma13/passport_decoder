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
                initialValue: passportData.personDetails.primaryIdentifier,
                decoration: InputDecoration(helperText: 'Given Name'),
              ),
              TextFormField(
                initialValue: passportData.personDetails.secondaryIdentifier,
                decoration: InputDecoration(helperText: 'Surname'),
              ),
              TextFormField(
                initialValue: passportData.personDetails.gender,
                decoration: InputDecoration(helperText: 'Gender'),
              ),
              TextFormField(
                initialValue: passportData.personDetails.dateOfBirth,
                decoration: InputDecoration(helperText: 'Date of Birth'),
              ),
              TextFormField(
                initialValue: passportData.personDetails.dateOfExpiry,
                decoration: InputDecoration(helperText: 'Date of Expiry'),
              ),
              TextFormField(
                initialValue: passportData.personDetails.documentNumber,
                decoration: InputDecoration(helperText: 'Document number'),
              ),
              TextFormField(
                initialValue: passportData.personDetails.documentCode,
                decoration: InputDecoration(helperText: 'Document code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
