class PassportData {
  FeatureStatus featureStatus;
  List<Null> fingerprints;
  PersonDetails personDetails;
  SodFile sodFile;
  VerificationStatus verificationStatus;

  PassportData(
      {this.featureStatus,
      this.fingerprints,
      this.personDetails,
      this.sodFile,
      this.verificationStatus});

  PassportData.fromJson(Map<dynamic, dynamic> json) {
    featureStatus =
        json['featureStatus'] != null ? new FeatureStatus.fromJson(json['featureStatus']) : null;
    if (json['fingerprints'] != null) {
      fingerprints = new List<Null>();
      json['fingerprints'].forEach((v) {
        // fingerprints.add(new Null.fromJson(v));
      });
    }
    personDetails =
        json['personDetails'] != null ? new PersonDetails.fromJson(json['personDetails']) : null;
    sodFile = json['sodFile'] != null ? new SodFile.fromJson(json['sodFile']) : null;
    verificationStatus = json['verificationStatus'] != null
        ? new VerificationStatus.fromJson(json['verificationStatus'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.featureStatus != null) {
      data['featureStatus'] = this.featureStatus.toJson();
    }
    if (this.fingerprints != null) {
      // data['fingerprints'] = this.fingerprints.map((v) => v.toJson()).toList();
    }
    if (this.personDetails != null) {
      data['personDetails'] = this.personDetails.toJson();
    }
    if (this.sodFile != null) {
      data['sodFile'] = this.sodFile.toJson();
    }
    if (this.verificationStatus != null) {
      data['verificationStatus'] = this.verificationStatus.toJson();
    }
    return data;
  }
}

class FeatureStatus {
  String hasAA;
  String hasBAC;
  String hasCA;
  String hasEAC;
  String hasSAC;

  FeatureStatus({this.hasAA, this.hasBAC, this.hasCA, this.hasEAC, this.hasSAC});

  FeatureStatus.fromJson(Map<String, dynamic> json) {
    hasAA = json['hasAA'];
    hasBAC = json['hasBAC'];
    hasCA = json['hasCA'];
    hasEAC = json['hasEAC'];
    hasSAC = json['hasSAC'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hasAA'] = this.hasAA;
    data['hasBAC'] = this.hasBAC;
    data['hasCA'] = this.hasCA;
    data['hasEAC'] = this.hasEAC;
    data['hasSAC'] = this.hasSAC;
    return data;
  }
}

class PersonDetails {
  String dateOfBirth;
  String dateOfExpiry;
  String documentCode;
  String documentNumber;
  String gender;
  String issuingState;
  String nationality;
  String optionalData1;
  String primaryIdentifier;
  String secondaryIdentifier;

  PersonDetails(
      {this.dateOfBirth,
      this.dateOfExpiry,
      this.documentCode,
      this.documentNumber,
      this.gender,
      this.issuingState,
      this.nationality,
      this.optionalData1,
      this.primaryIdentifier,
      this.secondaryIdentifier});

  PersonDetails.fromJson(Map<String, dynamic> json) {
    dateOfBirth = json['dateOfBirth'];
    dateOfExpiry = json['dateOfExpiry'];
    documentCode = json['documentCode'];
    documentNumber = json['documentNumber'];
    gender = json['gender'];
    issuingState = json['issuingState'];
    nationality = json['nationality'];
    optionalData1 = json['optionalData1'];
    primaryIdentifier = json['primaryIdentifier'];
    secondaryIdentifier = json['secondaryIdentifier'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dateOfBirth'] = this.dateOfBirth;
    data['dateOfExpiry'] = this.dateOfExpiry;
    data['documentCode'] = this.documentCode;
    data['documentNumber'] = this.documentNumber;
    data['gender'] = this.gender;
    data['issuingState'] = this.issuingState;
    data['nationality'] = this.nationality;
    data['optionalData1'] = this.optionalData1;
    data['primaryIdentifier'] = this.primaryIdentifier;
    data['secondaryIdentifier'] = this.secondaryIdentifier;
    return data;
  }
}

class SodFile {
  int length;
  int tag;

  SodFile({this.length, this.tag});

  SodFile.fromJson(Map<String, dynamic> json) {
    length = json['length'];
    tag = json['tag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['length'] = this.length;
    data['tag'] = this.tag;
    return data;
  }
}

class VerificationStatus {
  String aa;
  String aaReason;
  String bac;
  String bacReason;
  List<CertificateChain> certificateChain;
  String cs;
  String csReason;
  String ds;
  String dsReason;
  String eac;
  HashResults hashResults;
  String ht;
  String htReason;
  List<TriedBACEntries> triedBACEntries;

  VerificationStatus(
      {this.aa,
      this.aaReason,
      this.bac,
      this.bacReason,
      this.certificateChain,
      this.cs,
      this.csReason,
      this.ds,
      this.dsReason,
      this.eac,
      this.hashResults,
      this.ht,
      this.htReason,
      this.triedBACEntries});

  VerificationStatus.fromJson(Map<String, dynamic> json) {
    aa = json['aa'];
    aaReason = json['aaReason'];
    bac = json['bac'];
    bacReason = json['bacReason'];
    if (json['certificateChain'] != null) {
      certificateChain = new List<CertificateChain>();
      json['certificateChain'].forEach((v) {
        certificateChain.add(new CertificateChain.fromJson(v));
      });
    }
    cs = json['cs'];
    csReason = json['csReason'];
    ds = json['ds'];
    dsReason = json['dsReason'];
    eac = json['eac'];
    hashResults =
        json['hashResults'] != null ? new HashResults.fromJson(json['hashResults']) : null;
    ht = json['ht'];
    htReason = json['htReason'];
    if (json['triedBACEntries'] != null) {
      triedBACEntries = new List<TriedBACEntries>();
      json['triedBACEntries'].forEach((v) {
        triedBACEntries.add(new TriedBACEntries.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['aa'] = this.aa;
    data['aaReason'] = this.aaReason;
    data['bac'] = this.bac;
    data['bacReason'] = this.bacReason;
    if (this.certificateChain != null) {
      data['certificateChain'] = this.certificateChain.map((v) => v.toJson()).toList();
    }
    data['cs'] = this.cs;
    data['csReason'] = this.csReason;
    data['ds'] = this.ds;
    data['dsReason'] = this.dsReason;
    data['eac'] = this.eac;
    if (this.hashResults != null) {
      data['hashResults'] = this.hashResults.toJson();
    }
    data['ht'] = this.ht;
    data['htReason'] = this.htReason;
    if (this.triedBACEntries != null) {
      data['triedBACEntries'] = this.triedBACEntries.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CertificateChain {
  String name;

  CertificateChain();

  CertificateChain.fromJson(Map<String, dynamic> json) {
    name = '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return data;
  }
}

class HashResults {
  One eleven;
  One twelve;

  HashResults({this.eleven, this.twelve});

  HashResults.fromJson(Map<String, dynamic> json) {
    eleven = json['1'] != null ? new One.fromJson(json['1']) : null;
    twelve = json['2'] != null ? new One.fromJson(json['2']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.eleven != null) {
      data['1'] = this.eleven.toJson();
    }
    if (this.twelve != null) {
      data['2'] = this.twelve.toJson();
    }
    return data;
  }
}

class One {
  List<int> storedHash;

  One({this.storedHash});

  One.fromJson(Map<String, dynamic> json) {
    storedHash = json['storedHash'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['storedHash'] = this.storedHash;
    return data;
  }
}

class TriedBACEntries {
  String dateOfBirth;
  String dateOfExpiry;
  String documentNumber;

  TriedBACEntries({this.dateOfBirth, this.dateOfExpiry, this.documentNumber});

  TriedBACEntries.fromJson(Map<String, dynamic> json) {
    dateOfBirth = json['dateOfBirth'];
    dateOfExpiry = json['dateOfExpiry'];
    documentNumber = json['documentNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dateOfBirth'] = this.dateOfBirth;
    data['dateOfExpiry'] = this.dateOfExpiry;
    data['documentNumber'] = this.documentNumber;
    return data;
  }
}
