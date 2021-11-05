import 'package:balancedtrees/bplustree/bplustree.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yazgel_project/service/application_service.dart';
import 'package:yazgel_project/service/category_service.dart';
import 'package:yazgel_project/views/cap.dart';
import 'package:yazgel_project/views/custom_page_route.dart';
import 'package:yazgel_project/views/dgs.dart';
import 'package:yazgel_project/views/intibak.dart';
import 'package:yazgel_project/views/yatay_gecis.dart';
import 'package:yazgel_project/views/yaz_okulu.dart';

class Home extends StatefulWidget {
  Home({Key? key, this.student}) : super(key: key);

  final student;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final applicationData = ["Yaz Okulu", "Yatay Geçiş", "ÇAP", "İntibak", "DGS"];
  String studentNumNoId = "";
  late BPlusTree<Comparable<dynamic>> applicationTree;
  late BPlusTree<Comparable<dynamic>> categoryTree;
  bool isLoaded = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    studentNumNoId = widget.student.sId.split("-")[1];
    getApplicationsTree(studentNumNoId);
  }

  getApplicationsTree(String id) async {
    applicationTree = await ApplicationService().getAllApplicationsTree();
    categoryTree = await CategoryService().getAllCategoriesTree();
    setState(() {
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoaded == false
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            key: _scaffoldKey,
            drawer: Drawer(
                child: Column(
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF317254),
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.elliptical(200, 15)),
                  ),
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 120,
                          height: 50,
                          margin: const EdgeInsets.only(
                            top: 30,
                            bottom: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: NetworkImage(widget.student.photoUrl),
                                fit: BoxFit.contain),
                          ),
                        ),
                        Text(
                          widget.student.nameSurname,
                          style: const TextStyle(
                              fontSize: 22, color: Color(0xffe6eaed)),
                        ),
                        Text(
                          widget.student.mail,
                          style: const TextStyle(
                              fontSize: 17, color: Color(0xffe6eaed)),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Okul No: $studentNumNoId',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Üniversite: ${widget.student.universityInfo.universityName}',
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Bölüm: ${widget.student.universityInfo.department}',
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Sınıf: ${widget.student.universityInfo.grade}.Sınıf',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text("ÇIKIŞ YAP", style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff149a43)
                    )),
                  ),
                )
              ],
            )),
            body: Column(children: [
              Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF317254),
                      borderRadius: BorderRadius.vertical(
                          bottom: Radius.elliptical(200, 30)),
                    ),
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () {
                                  _scaffoldKey.currentState!.openDrawer();
                                },
                                icon: const Icon(Icons.view_headline,
                                    color: Color(0xffe6eaed))),
                            const Text(
                              "KOCAELİ ÜNİVERSİTESİ",
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  color: Color(0xffe6eaed)),
                            ),
                            const CircleAvatar(
                              backgroundColor: Color(0xFF4e7966),
                              backgroundImage:
                                  AssetImage('lib/assets/koulogo.png'),
                              minRadius: 20,
                              maxRadius: 25,
                            )
                          ],
                        ),
                      ],
                    ),
                  )),
              Expanded(
                  flex: 3,
                  child: Container(
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 5,
                              itemBuilder: (BuildContext context, int i) {
                                return GestureDetector(
                                  onTap: () {
                                    if (applicationData[i] == "Yatay Geçiş") {
                                      Navigator.push(
                                          context,
                                          CustomPageRoute(
                                              child: yatayGecis(
                                                  student: widget.student,
                                                  appTree: applicationTree)));
                                    } else if (applicationData[i] ==
                                        "Yaz Okulu") {
                                      Navigator.push(
                                          context,
                                          CustomPageRoute(
                                              child: yazOkulu(
                                                  student: widget.student,
                                                  appTree: applicationTree)));
                                    } else if (applicationData[i] == "DGS") {
                                      Navigator.push(
                                          context,
                                          CustomPageRoute(
                                              child: dgs(
                                                  student: widget.student,
                                                  appTree: applicationTree)));
                                    } else if (applicationData[i] == "ÇAP") {
                                      Navigator.push(
                                          context,
                                          CustomPageRoute(
                                              child: cap(
                                                  student: widget.student,
                                                  appTree: applicationTree)));
                                    } else if (applicationData[i] ==
                                        "İntibak") {
                                      Navigator.push(
                                          context,
                                          CustomPageRoute(
                                              child: intibak(
                                                  student: widget.student,
                                                  appTree: applicationTree)));
                                    }
                                  },
                                  child: Container(
                                    width: 150,
                                    padding: const EdgeInsets.only(
                                      top: 15,
                                      bottom: 30,
                                      left: 3,
                                    ),
                                    child: Center(
                                      child: Card(
                                        elevation: 7,
                                        color: Color(0xff566074),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        child: Container(
                                          height: 200,
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Text(
                                                      '${applicationData[i]}',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20,
                                                          color: Colors.white),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    Container(
                                                      width: 130,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xffe6eaed),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                blurRadius: 2,
                                                                offset: Offset(
                                                                    0, 2),
                                                                color: Colors
                                                                    .black26)
                                                          ]),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                              width: 40,
                                                              height: 40,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .black38,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20)),
                                                              child: Icon(
                                                                  Icons
                                                                      .arrow_forward_ios_rounded,
                                                                  color: Color(
                                                                      0xffe6eaed))),
                                                          SizedBox(width: 5),
                                                          Center(
                                                              child: Text(
                                                                  "Başvuru Yap",
                                                                  style: TextStyle(
                                                                      color: Color(
                                                                          0xff26262b),
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500))),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ]),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(left: 20, bottom: 5),
                            child: Text("Başvurularım:",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xff26262b)))),
                        Expanded(
                          child: Container(
                            padding:
                                EdgeInsets.only(top: 1, left: 10, right: 10),
                            child: ListView.separated(
                              separatorBuilder: (context, index) =>
                                  Divider(height: 3),
                              itemCount: applicationTree.size,
                              itemBuilder: (BuildContext context, int i) {
                                var applicationData =
                                    BPlusTreeAlgos.searchForKey(
                                            bptree: applicationTree,
                                            searchKey:
                                                "app-" + (i + 1).toString())
                                        .getValue();
                                var categoryData = BPlusTreeAlgos.searchForKey(
                                        bptree: categoryTree,
                                        searchKey: applicationData
                                            .applicationType
                                            .toString())
                                    .getValue();
                                final Color statusColor;
                                applicationData.status == "Kabul Edildi"
                                    ? statusColor = Colors.green
                                    : applicationData.status == "Reddedildi"
                                        ? statusColor = Colors.red
                                        : statusColor = Colors.orangeAccent;
                                return applicationData.studentNum !=
                                        studentNumNoId
                                    ? Container()
                                    : Card(
                                        elevation: 5,
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Container(
                                            padding: const EdgeInsets.only(
                                              left: 15,
                                              right: 15,
                                            ),
                                            height: 80,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  height: 50,
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      child: Image.network(
                                                          widget
                                                              .student.photoUrl,
                                                          fit: BoxFit.fill)),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Text(
                                                      widget
                                                          .student.nameSurname,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                    Text(
                                                      categoryData.categoryName,
                                                      style: TextStyle(
                                                          letterSpacing: 1,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color:
                                                              Colors.black54),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    applicationData.status ==
                                                            "Kabul Edildi"
                                                        ? Icon(Icons.check,
                                                            color: Colors.green)
                                                        : applicationData
                                                                    .status ==
                                                                "Reddedildi"
                                                            ? Icon(Icons.clear,
                                                                color:
                                                                    Colors.red)
                                                            : Icon(
                                                                Icons
                                                                    .alarm_rounded,
                                                                color: Colors
                                                                    .orangeAccent),
                                                    Text(
                                                      applicationData.status,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: statusColor),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            )));
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  )),
            ]),
          );
  }
}
