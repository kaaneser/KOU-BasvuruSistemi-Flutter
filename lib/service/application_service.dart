//@dart=2.9

import 'dart:convert' show u;

import 'package:balancedtrees/balancedtrees.dart';
import 'package:balancedtrees/bplustree/bplustree.dart';
import 'package:balancedtrees/comparators/comparators.dart';
import 'package:balancedtrees/util/util.dart';
import 'package:json_object_lite/json_object_lite.dart';
import 'package:yazgel_project/database/database_helper.dart';
import 'package:yazgel_project/model/application_model.dart';

class ApplicationService {
  final conn = DatabaseHelper().Connection();

  Future getApplicationsByStudentId(String sId) async {
    final query = await conn
        .getDocument('_design/_all/_view/student-applications?key="201307083"');
    final tree = BPlusTree(capacityOfNode: 4, compare: genUnitSortHelper);

    query.jsonCouchResponse.forEach((k, v) {
      if (k == "rows") {
        for (var application in v) {
          final model = ApplicationModel.fromJson(application["value"]);
          BPlusTreeAlgos.insert(
              bptree: tree,
              keyToBeInserted: application["id"].toString(),
              valueToBeInserted: model);
        }
      }
    });
    return tree;
  }

  Future addApplication(ApplicationModel model) async {
    var json = model.toJsonForAdding();

    await conn.postDocument(json);
  }

  Future getAllApplicationsTree() async {
    final query = await conn.getDocument("_design/_all/_view/applications");
    final tree = BPlusTree(capacityOfNode: 4, compare: genUnitSortHelper);

    query.jsonCouchResponse.forEach((k, v) {
      if (k == "rows") {
        for (var application in v) {
          final model = ApplicationModel.fromJson(application["value"]);
          BPlusTreeAlgos.insert(
              bptree: tree,
              keyToBeInserted: application["key"].toString(),
              valueToBeInserted: model);
        }
      }
    });
    return tree;
  }

  Future updateApplication(ApplicationModel model) async {
    var json = model.toJson();

    print(model.sId);
    await conn.putDocument(model.sId, json);
  }
}

void main(List<String> args) async {
  final connection = DatabaseHelper().Connection();
  var res = await connection.getDocument("_design/_all/_view/applications");
  print(res.jsonCouchResponse);
}
