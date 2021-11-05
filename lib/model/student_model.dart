//@dart=2.9
import 'dart:convert';

import 'package:json_object_lite/json_object_lite.dart';

class StudentModel {
  String sId;
  //String sRev;
  String nameSurname;
  String mail;
  String telNum;
  String identityCard;
  Address address;
  String dateBirth;
  UniversityInfo universityInfo;
  String photoUrl;

  StudentModel(
      {this.sId,
      //this.sRev,
      this.nameSurname,
      this.mail,
      this.telNum,
      this.identityCard,
      this.address,
      this.dateBirth,
      this.universityInfo,
      this.photoUrl});

  StudentModel.fromJson(JsonObjectLite<dynamic> json) {
    sId = json['_id'];
    //sRev = json['_rev'];
    nameSurname = utf8.decode(json['nameSurname'].toString().codeUnits);
    mail = json['mail'];
    telNum = json['telNum'];
    identityCard = json['identityCard'];
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
    dateBirth = json['dateBirth'];
    universityInfo = json['universityInfo'] != null
        ? new UniversityInfo.fromJson(json['universityInfo'])
        : null;
    photoUrl = json['photoUrl'];
  }

  JsonObjectLite<dynamic> toJson() {
    final JsonObjectLite<dynamic> data = new JsonObjectLite<dynamic>();
    data['_id'] = this.sId;
    //data['_rev'] = this.sRev;
    data['nameSurname'] = this.nameSurname;
    data['mail'] = this.mail;
    data['telNum'] = this.telNum;
    data['identityCard'] = this.identityCard;
    if (this.address != null) {
      data['address'] = this.address.toJson();
    }
    data['dateBirth'] = this.dateBirth;
    if (this.universityInfo != null) {
      data['universityInfo'] = this.universityInfo.toJson();
    }
    data['photoUrl'] = this.photoUrl;
    return data;
  }
}

class Address {
  String home;
  String job;

  Address({this.home, this.job});

  Address.fromJson(JsonObjectLite<dynamic> json) {
    home = json['home'];
    job = json['job'];
  }

  JsonObjectLite<dynamic> toJson() {
    final JsonObjectLite<dynamic> data = new JsonObjectLite<dynamic>();
    data['home'] = this.home;
    data['job'] = this.job;
    return data;
  }
}

class UniversityInfo {
  String universityName;
  String facility;
  String department;
  int grade;

  UniversityInfo(
      {this.universityName, this.facility, this.department, this.grade});

  UniversityInfo.fromJson(JsonObjectLite<dynamic> json) {
    universityName = utf8.decode(json['universityName'].toString().codeUnits);
    facility = utf8.decode(json['facility'].toString().codeUnits);
    department = utf8.decode(json['department'].toString().codeUnits);
    grade = json['grade'];
  }

  JsonObjectLite<dynamic> toJson() {
    final JsonObjectLite<dynamic> data = new JsonObjectLite<dynamic>();
    data['universityName'] = this.universityName;
    data['facility'] = this.facility;
    data['department'] = this.department;
    data['grade'] = this.grade;
    return data;
  }
}
