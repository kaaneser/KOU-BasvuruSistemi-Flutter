//@dart=2.9

import 'dart:convert';

import 'package:balancedtrees/bplustree/bplustree.dart';
import 'package:balancedtrees/comparators/comparators.dart';
import 'package:yazgel_project/database/database_helper.dart';
import 'package:yazgel_project/model/student_model.dart';

class StudentService {
  final conn = DatabaseHelper().Connection();

  Future getAllStudentsTree() async {
    final query = await conn.getDocument('_design/_all/_view/students');
    final tree = BPlusTree(capacityOfNode: 4, compare: genUnitSortHelper);

    query.jsonCouchResponse.forEach((k, v) {
      if (k == "rows") {
        for (var student in v) {
          final model = StudentModel.fromJson(student["value"]);
          BPlusTreeAlgos.insert(
          bptree: tree,
          keyToBeInserted: student["key"].toString(),
          valueToBeInserted: model);
        }
      }
    });
    return tree;
  }

  Future getAllStudents() async {
    String baseUrl = 'kou-database/_design/_all/_view/students';
    List students = [];

    await conn.get(baseUrl).then((value) {
      for (var student in value.json["rows"]) {
        final model = StudentModel.fromJson(student["value"]);
        students.add(model);
      }
    });
    return students;
  }

  checkAdminAuth(String id, String pass) {
    id = 'stu-$id';
    print("id:"+id);
    print("pass:"+pass);
    if (id.toString() == 'stu-admin' && pass.toString() == 'admin123')
      return true;
    else return false;
  }

  Future getStudent(String id) async {
    var res = await conn.getDocument('stu-$id');
    
    final model = StudentModel.fromJson(res.jsonCouchResponse);
    return model;
  }

  Future addStudent(StudentModel model) async {
    var json = model.toJson();

    var res = await conn.postDocument(json);
    return res;
  }
}