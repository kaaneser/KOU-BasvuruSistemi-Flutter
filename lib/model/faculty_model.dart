//@dart=2.9

import 'dart:convert';

import 'package:json_object_lite/json_object_lite.dart';

class FacultyModel {
  String sId;
  String sRev;
  List<Faculties> faculties;

  FacultyModel({this.sId, this.sRev, this.faculties});

  FacultyModel.fromJson(JsonObjectLite<dynamic> json) {
    sId = json['_id'];
    sRev = json['_rev'];
    if (json['faculties'] != null) {
      faculties = <Faculties>[];
      json['faculties'].forEach((v) {
        faculties.add(new Faculties.fromJson(v));
      });
    }
  }

  JsonObjectLite<dynamic> toJson() {
    final JsonObjectLite<dynamic> data = new JsonObjectLite<dynamic>();
    data['_id'] = this.sId;
    data['_rev'] = this.sRev;
    if (this.faculties != null) {
      data['faculties'] = this.faculties.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Faculties {
  String faculty;
  List<String> departments;

  Faculties({this.faculty, this.departments});

  Faculties.fromJson(JsonObjectLite<dynamic> json) {
    faculty = utf8.decode(json['faculty'].toString().codeUnits);
    departments = json['departments'].cast<String>();
  }

  JsonObjectLite<dynamic> toJson() {
    final JsonObjectLite<dynamic> data = new JsonObjectLite<dynamic>();
    data['faculty'] = this.faculty;
    data['departments'] = this.departments;
    return data;
  }
}