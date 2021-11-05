import 'package:animations/animations.dart';
import 'package:balancedtrees/bplustree/bplustree.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yazgel_project/views/application_detail.dart';
import 'package:yazgel_project/service/application_service.dart';
import 'package:yazgel_project/service/category_service.dart';
import 'package:yazgel_project/service/student_service.dart';

class AdminMenu extends StatefulWidget {
  const AdminMenu({Key? key}) : super(key: key);

  @override
  _AdminMenuState createState() => _AdminMenuState();
}

class _AdminMenuState extends State<AdminMenu> {
  bool isAppStatusFiltered = false;
  bool isAppTypeFiltered = false;
  String currentFilteredAppStatus = "";
  String currentFilteredAppType = "";
  List<String> applicationStatus = [
    "Gelen Başvurular",
    "Kabul Edilen Başvurular",
    "Reddedilen Başvurular"
  ];
  List<Color> applicationTypesColor = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.grey,
    Colors.amber
  ];
  List<String> applicationTypes = [
    "Yaz Okulu",
    "Yatay Geçiş",
    "DGS",
    "ÇAP",
    "İntibak"
  ];
  List<IconData> statusIcons = [Icons.alarm, Icons.check, Icons.clear];
  List<String> statusNames = ["Beklemede", "Kabul Edildi", "Reddedildi"];
  late BPlusTree<Comparable<dynamic>> applicationTree;
  late BPlusTree<Comparable<dynamic>> categoryTree;
  late BPlusTree<Comparable<dynamic>> studentTree;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    createTree();
  }

  createTree() async {
    applicationTree = await ApplicationService().getAllApplicationsTree();
    categoryTree = await CategoryService().getAllCategoriesTree();
    studentTree = await StudentService().getAllStudentsTree();
    setState(() {
      isLoaded = true;
    });
  }

  getData(int i) {
    var application = BPlusTreeAlgos.searchForKey(
            bptree: applicationTree, searchKey: "app-" + (i + 1).toString())
        .getValue();
    var category = BPlusTreeAlgos.searchForKey(
            bptree: categoryTree,
            searchKey: application.applicationType.toString())
        .getValue();
    var student = BPlusTreeAlgos.searchForKey(
            bptree: studentTree, searchKey: "stu-" + application.studentNum)
        .getValue();
    return [application, category, student];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoaded
          ? Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 250, left: 10, right: 10),
                  color: Theme.of(context).backgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 35, bottom: 3),
                    child: ListView.builder(
                      itemCount: applicationTree.size,
                      itemBuilder: (BuildContext context, int i) =>
                          OpenContainer(
                        transitionDuration: const Duration(milliseconds: 800),
                        openColor: Colors.transparent,
                        closedColor: Colors.transparent,
                        closedElevation: 0,
                        openElevation: 0,
                        openShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide.none),
                        closedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide.none),
                        closedBuilder: (context, VoidCallback openContainer) {
                          List data = getData(i);

                          if (currentFilteredAppType == data[1].categoryName) {
                            if (currentFilteredAppStatus ==
                                "Gelen Başvurular") {
                              if (data[0].status == 'Beklemede') {
                                return applicationCard(
                                    data[0], data[1], data[2]);
                              } else
                                return Container();
                            } else if (currentFilteredAppStatus ==
                                'Kabul Edilen Başvurular') {
                              if (data[0].status == 'Kabul Edildi')
                                return applicationCard(
                                    data[0], data[1], data[2]);
                              else
                                return Container();
                            } else if (currentFilteredAppStatus ==
                                'Reddedilen Başvurular') {
                              if (data[0].status == 'Reddedildi')
                                return applicationCard(
                                    data[0], data[1], data[2]);
                              else
                                return Container();
                            } else
                              return applicationCard(data[0], data[1], data[2]);
                          } else if (currentFilteredAppType == '') {
                            if (currentFilteredAppStatus ==
                                "Gelen Başvurular") {
                              if (data[0].status == 'Beklemede') {
                                return applicationCard(
                                    data[0], data[1], data[2]);
                              } else
                                return Container();
                            } else if (currentFilteredAppStatus ==
                                'Kabul Edilen Başvurular') {
                              if (data[0].status == 'Kabul Edildi')
                                return applicationCard(
                                    data[0], data[1], data[2]);
                              else
                                return Container();
                            } else if (currentFilteredAppStatus ==
                                'Reddedilen Başvurular') {
                              if (data[0].status == 'Reddedildi')
                                return applicationCard(
                                    data[0], data[1], data[2]);
                              else
                                return Container();
                            } else
                              return applicationCard(data[0], data[1], data[2]);
                          } else
                            return Container();
                        },
                        openBuilder: (context, object) {
                          List data = getData(i);
                          return ApplicationDetail(
                              application: data[0],
                              category: data[1],
                              student: data[2]);
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                      color: Color(0xff317254),
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.elliptical(200, 30)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          offset: Offset(8, 8),
                          blurRadius: 10,
                        ),
                      ]),
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              alignment: Alignment.centerLeft,
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                          title: const Text("Genel Bilgiler"),
                                          content: Text(
                                            "Toplam yaprak düğüm sayısı: ${applicationTree.size}\nAğaç derinliği: ${BPlusTreeAlgos.getHeight(applicationTree) + 1}\nZaman karmaşıklığı: O(log${applicationTree.size})",
                                          ),
                                        ));
                              },
                              icon: const Icon(Icons.info_rounded, color: Color(0xffe6eaed)),
                              iconSize: 45,
                            ),
                            IconButton(
                              alignment: Alignment.centerRight,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.logout_rounded, color: Color(0xffe6eaed)),
                              iconSize: 30,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 25,
                          padding: const EdgeInsetsDirectional.only(
                              start: 8, end: 8),
                          child: Center(
                            child: ListView.separated(
                              itemCount: applicationStatus.length,
                              itemBuilder: (BuildContext context, int i) =>
                                  TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.grey,
                                ),
                                onPressed: () {
                                  if (isAppStatusFiltered == false) {
                                    if (currentFilteredAppStatus !=
                                        applicationStatus[i]) {
                                      setState(() {
                                        currentFilteredAppStatus =
                                            applicationStatus[i];
                                      });
                                    } else {
                                      setState(() {
                                        currentFilteredAppStatus = "";
                                      });
                                    }
                                  }
                                },
                                child: Text(
                                  applicationStatus[i],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: applicationStatus[i] ==
                                              currentFilteredAppStatus
                                          ? Color(0xffe6eaed)
                                          : Colors.black87),
                                ),
                              ),
                              separatorBuilder: (context, i) =>
                                  const VerticalDivider(
                                thickness: 2,
                                color: Colors.black45,
                                indent: 10,
                                endIndent: 10,
                              ),
                              scrollDirection: Axis.horizontal,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(8, 20, 8, 40),
                          child: ListView.separated(
                            itemCount: 5,
                            itemBuilder: (BuildContext context, int i) =>
                                GestureDetector(
                              onTap: () {
                                if (isAppTypeFiltered == false) {
                                  if (currentFilteredAppType !=
                                      applicationTypes[i]) {
                                    setState(() {
                                      currentFilteredAppType =
                                          applicationTypes[i];
                                    });
                                  } else {
                                    setState(() {
                                      currentFilteredAppType = "";
                                    });
                                  }
                                }
                              },
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                    color: currentFilteredAppType ==
                                            applicationTypes[i]
                                        ? Colors.white54
                                        : Colors.white30,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Center(
                                    child: Text(
                                  applicationTypes[i],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                              ),
                            ),
                            scrollDirection: Axis.horizontal,
                            separatorBuilder: (context, i) =>
                                const VerticalDivider(
                                    width: 15, color: Colors.transparent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Card applicationCard(var application, var category, var student) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Container(
        padding:
            const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    image: DecorationImage(
                        image: NetworkImage(
                          student.photoUrl,
                        ),
                        fit: BoxFit.cover),
                  ),
                  height: 80,
                  width: 80,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              application.studentNum,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              student.nameSurname,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category.categoryName,
                                style: const TextStyle(
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  application.status == "Beklemede"
                                      ? const Icon(Icons.alarm_rounded,
                                          color: Colors.orangeAccent)
                                      : application.status == "Kabul Edildi"
                                          ? const Icon(Icons.check,
                                              color: Colors.green)
                                          : const Icon(Icons.clear,
                                              color: Colors.red),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  application.status == "Beklemede"
                                      ? Text(
                                          application.status,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orangeAccent,
                                          ),
                                        )
                                      : application.status == "Kabul Edildi"
                                          ? Text(
                                              application.status,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            )
                                          : Text(
                                              application.status,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                            ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}