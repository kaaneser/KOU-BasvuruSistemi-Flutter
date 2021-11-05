//@dart=2.9
import 'package:balancedtrees/bplustree/bplustree.dart';
import 'package:balancedtrees/comparators/comparators.dart';
import 'package:balancedtrees/util/util.dart';
import 'package:wilt/wilt.dart';


class DatabaseHelper {
  dynamic Connection() {
    final db = Wilt(
     "koubsserver.live",
      port: 5984,
      useSSL: false
    );
    db.login("admin", "123321k");
    db.db = 'kou-database';

    return db;
  }
}