//@dart=2.9

import 'package:balancedtrees/balancedtrees.dart';
import 'package:balancedtrees/comparators/comparators.dart';
import 'package:yazgel_project/database/database_helper.dart';
import 'package:yazgel_project/model/category_model.dart';

class CategoryService {
  final conn = DatabaseHelper().Connection();

  Future getAllCategoriesTree() async {
    final query = await conn.getDocument('_design/_all/_view/categories');
    final tree = BPlusTree(capacityOfNode: 4, compare: genUnitSortHelper);

    query.jsonCouchResponse.forEach((k, v) {
      if (k == "rows") {
        for (var category in v) {
          final model = CategoryModel.fromJson(category["value"]);
          BPlusTreeAlgos.insert(
          bptree: tree,
          keyToBeInserted: category["key"].toString(),
          valueToBeInserted: model);
        }
      }
    });
    return tree;
  }
}
