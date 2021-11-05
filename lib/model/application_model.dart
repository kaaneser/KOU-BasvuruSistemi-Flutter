//@dart=2.9
import 'dart:convert';

import 'package:json_object_lite/json_object_lite.dart';

class ApplicationModel {
  String sId;
  String sRev;
  String studentNum;
  String applicationType;
  List<Documents> documents;
  String status;

  ApplicationModel(
      {this.sId,
      this.sRev,
      this.studentNum,
      this.applicationType,
      this.documents,
      this.status});

  ApplicationModel.fromJson(JsonObjectLite<dynamic> json) {
    sId = json['_id'];
    sRev = json['_rev'];
    studentNum = json['studentNum'];
    applicationType = json['applicationType'];
    if (json['documents'] != null) {
      documents = <Documents>[];
      json['documents'].forEach((v) {
        documents.add(Documents.fromJson(v));
      });
    }
    status = json["status"];
  }

  JsonObjectLite<dynamic> toJsonForAdding() {
    final JsonObjectLite<dynamic> data = new JsonObjectLite<dynamic>();
    data['_id'] = this.sId;
    data['studentNum'] = this.studentNum;
    data['applicationType'] = this.applicationType;
    if (this.documents != null) {
      data['documents'] = this.documents.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    return data;
  }

  JsonObjectLite<dynamic> toJson() {
    final JsonObjectLite<dynamic> data = new JsonObjectLite<dynamic>();
    data['_id'] = this.sId;
    data['_rev'] = this.sRev;
    data['studentNum'] = this.studentNum;
    data['applicationType'] = this.applicationType;
    if (this.documents != null) {
      data['documents'] = this.documents.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    return data;
  }
}

class Documents {
  String documentName;
  String path;

  Documents(
      {this.documentName,
      this.path});

  Documents.fromJson(JsonObjectLite<dynamic> json) {
    documentName = utf8.decode(json['documentName'].toString().codeUnits);
    path = json['path'];
  }

  JsonObjectLite<dynamic> toJson() {
    final JsonObjectLite<dynamic> data = new JsonObjectLite<dynamic>();
    data['documentName'] = this.documentName;
    data['path'] = this.path;
    return data;
  }
}