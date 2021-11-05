//@dart=2.9
import 'dart:convert';

import 'package:balancedtrees/balancedtrees.dart';
import 'package:balancedtrees/comparators/comparators.dart';
import 'package:json_object_lite/json_object_lite.dart';

class CategoryModel {
  String sId;
  String sRev;
  String categoryName;
  final categoryTree = BPlusTree(
    capacityOfNode: 4,
    compare: genUnitSortHelper
  );

  CategoryModel({this.sId, this.sRev, this.categoryName});

  CategoryModel.fromJson(JsonObjectLite<dynamic> json) {
    sId = json['_id'];
    sRev = json['_rev'];
    categoryName = utf8.decode(json['categoryName'].toString().codeUnits);
  }

  JsonObjectLite<dynamic> toJson() {
    final JsonObjectLite<dynamic> data = new JsonObjectLite<dynamic>();
    data['_id'] = this.sId;
    data['categoryName'] = this.categoryName;
    return data;
  }
}
