//@dart=2.9

import 'dart:convert';

import 'package:yazgel_project/database/database_helper.dart';
import 'package:yazgel_project/model/faculty_model.dart';

class FacultyService {
  final conn = DatabaseHelper().Connection();

  getFaculties() async {
    final query = await conn.getDocument('_design/_all/_view/faculties');
    List data = [];

    query.jsonCouchResponse.forEach((k, v) {
      if (k == 'rows') {
        for (var faculty in v[0]["value"]["faculties"]) {
          final model = Faculties.fromJson(faculty);
          data.add(model);
        }
      }
    });
    return data;
  }
}

Future<int> main(List<String> args) async {
  var facultyData = await FacultyService().getFaculties();
  print(utf8.decode(facultyData[0].departments[2].toString().codeUnits));

  return 0;
}
