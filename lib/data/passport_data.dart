class PassportData {
  PersonalDetails personalDetails;

  PassportData({this.personalDetails});
}

class PersonalDetails {
  String givenNames;
  String surname;
  String gender;
  String nationality;
  String dateOfBirth;
  String dateOfExpiry;
  String documentNumber;
  String documentCode;

  PersonalDetails(
      {this.givenNames,
      this.surname,
      this.gender,
      this.nationality,
      this.dateOfBirth,
      this.dateOfExpiry,
      this.documentNumber,
      this.documentCode});

  factory PersonalDetails.fromMap(Map<String, dynamic> data) => PersonalDetails(
        givenNames: data['givenNames'],
        surname: data['surname'],
        gender: data['gender'],
        nationality: data['nationality'],
        dateOfBirth: data['dateOfBirth'],
        dateOfExpiry: data['dateOfExpiry'],
        documentNumber: data['documentNumber'],
        documentCode: data['documentCode'],
      );
}
