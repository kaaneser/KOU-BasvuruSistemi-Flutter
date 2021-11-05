import 'dart:convert';
import 'dart:io';
import 'package:balancedtrees/bplustree/bplustree.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yazgel_project/model/application_model.dart';
import 'package:yazgel_project/model/faculty_model.dart';
import 'package:yazgel_project/service/application_service.dart';
import 'package:yazgel_project/service/faculty_service.dart';
import 'package:yazgel_project/views/progress.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/services.dart';

List<int> appType = [];
Map pdfFields = {};
List<int> currentStudyBounds = [];
List<int> futureStudyBounds = [];
List<Map<String, dynamic>> files = [];
final FirebaseStorage _storage = FirebaseStorage.instance;

class yatayGecis extends StatefulWidget {
  const yatayGecis({Key? key, this.student, this.appTree}) : super(key: key);

  final student;
  final appTree;

  @override
  _yatayGecisState createState() => _yatayGecisState();
}

class TProgress extends StatelessWidget {
  TProgress({required this.hintText, this.prefix, required this.input});
  final String hintText;
  final Widget? prefix;
  final String input;
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
          color: Color(0xffE6EAED),
          borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        onChanged: (text) {
          pdfFields[input] = text;
        },
        decoration: InputDecoration(
            prefixIcon: prefix,
            hintText: hintText,
            hintStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800]),
            border: OutlineInputBorder(borderSide: BorderSide.none)),
      ),
    );
  }
}

class fileUpload extends StatefulWidget {
  const fileUpload({Key? key, this.input}) : super(key: key);
  final input;
  
  @override
  _fileUploadState createState() => _fileUploadState();
}

class _fileUploadState extends State<fileUpload> {
  String fileType = 'Hepsi';
  var fileTypeList = ['Pdf', 'Doc', 'Image', 'Hepsi'];
  FilePickerResult? result;
  PlatformFile? file;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Belge Türü:  ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton(
                  value: fileType,
                  items: fileTypeList.map((String type) {
                    return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type,
                          style: TextStyle(fontSize: 19),
                        ));
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      fileType = value!;
                      file = null;
                    });
                  },
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(0xff317254), // background, // foreground
            ),
            onPressed: () async {
              pickFiles(fileType, widget.input);
            },
            child: Text('BELGE SEÇİNİZ', style: TextStyle(color: Colors.white)),
          ),
          if (file != null) fileDetails(file!),
          if (file != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(0xff317254), // background, // foreground
              ),
              onPressed: () async {
                viewFile(file!);
              },
              child: Text('SEÇİLMİŞ BELGEYİ GÖR'),
            )
        ],
      ),
    );
  }

  Widget fileDetails(PlatformFile file) {
    final kb = file.size / 1024;
    final mb = kb / 1024;
    final size = (mb >= 1)
        ? '${mb.toStringAsFixed(2)} MB'
        : '${kb.toStringAsFixed(2)} KB';
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dosya İsmi: ${file.name}'),
          Text('Dosya Boyutu: $size'),
        ],
      ),
    );
  }

  void pickFiles(String? filetype, String input) async {
    switch (filetype) {
      case 'Pdf':
        result = await FilePicker.platform
            .pickFiles(type: FileType.custom, allowedExtensions: [
          'pdf',
        ]);
        if (result == null) return;
        file = result!.files.first;
        final filePath = file!.path;
        final fileName = file!.name;
        final File fileForFirebase = File(filePath!);
        files.add({"fileName": input, "file": fileForFirebase});
        setState(() {});
        break;
      case 'Doc':
        result = await FilePicker.platform.pickFiles(
            type: FileType.custom, allowedExtensions: ['doc', 'docx']);
        if (result == null) return;
        file = result!.files.first;
        final filePath = file!.path;
        final fileName = file!.name;
        final File fileForFirebase = File(filePath!);
        files.add({"fileName": input, "file": fileForFirebase});
        setState(() {});
        break;
      case 'Image':
        result = await FilePicker.platform.pickFiles(type: FileType.image);
        if (result == null) return;
        file = result!.files.first;
        final filePath = file!.path;
        final fileName = file!.name;
        final File fileForFirebase = File(filePath!);
        files.add({"fileName": input, "file": fileForFirebase});
        setState(() {});
        break;
      case 'Hepsi':
        result = await FilePicker.platform.pickFiles();
        if (result == null) return;
        file = result!.files.first;
        final filePath = file!.path;
        final fileName = file!.name;
        final File fileForFirebase = File(filePath!);
        files.add({"fileName": input, "file": fileForFirebase});
        setState(() {});
        break;
    }
  }

  // Seçilmiş belgeyi gör
  void viewFile(PlatformFile file) {
    OpenFile.open(file.path);
  }
}

Future uploadFirebase(String path, Map<String, dynamic> file) async {
  if (file != null) {
    if (file["file"].absolute.existsSync()) {
      var res = await _storage
          .ref()
          .child("$path/${file['fileName']}")
          .putFile(file["file"]);
      var uploadedFile = await res.ref.getDownloadURL();
      return uploadedFile;
    }
  }
}

class Page1 extends StatefulWidget {
  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        children: [
          GestureDetector(
              child: Container(
                  width: 310,
                  height: 65,
                  decoration: BoxDecoration(
                    color: _index == 1 ? Color(0xff317254) : Color(0xffE6EAED),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                    border: Border.all(
                      color: Colors.green,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'KURUMİÇİ YATAY GEÇİŞ BAŞVURUSU',
                          style: TextStyle(
                            color:
                                _index == 1 ? Colors.white : Colors.grey[800],
                            fontWeight: _index == 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                      )
                    ],
                  )),
              onTap: () {
                appType = [279, 90];
                setState(() {
                  _index = 1;
                });
              }), // KURUMİÇİ YATAY GEÇİŞ BAŞVURUSU
          SizedBox(height: 10),
          GestureDetector(
              child: Container(
                  width: 310,
                  height: 65,
                  decoration: BoxDecoration(
                    color: _index == 2 ? Color(0xff317254) : Color(0xffE6EAED),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                    border: Border.all(
                      color: Colors.green,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'KURUMLARARASI YATAY GEÇİŞ BAŞVURUSU',
                          style: TextStyle(
                            color:
                                _index == 2 ? Colors.white : Colors.grey[800],
                            fontWeight: _index == 2
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                      )
                    ],
                  )),
              onTap: () {
                appType = [485, 90];
                setState(() {
                  _index = 2;
                });
              }), // KURUMLARARASI YATAY GEÇİŞ BAŞVURUSU
          SizedBox(height: 10),
          GestureDetector(
              child: Container(
                  width: 310,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _index == 3 ? Color(0xff317254) : Color(0xffE6EAED),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                    border: Border.all(
                      color: Colors.green,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'MER. YER. PUANIYLA YATAY GEÇİŞ BAŞVURUSU',
                          style: TextStyle(
                            color:
                                _index == 3 ? Colors.white : Colors.grey[800],
                            fontWeight: _index == 3
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                      )
                    ],
                  )),
              onTap: () {
                appType = [279, 113];
                setState(() {
                  _index = 3;
                });
              }), // MER. YER. PUANIYLA YATAY GEÇİŞ BAŞVURUSU
          SizedBox(height: 10),
          GestureDetector(
              child: Container(
                  width: 310,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _index == 4 ? Color(0xff317254) : Color(0xffE6EAED),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                    border: Border.all(
                      color: Colors.green,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'YURT DIŞI YATAY GEÇİŞ BAŞVURUSU',
                          style: TextStyle(
                            color:
                                _index == 4 ? Colors.white : Colors.grey[800],
                            fontWeight: _index == 4
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                      )
                    ],
                  )),
              onTap: () {
                appType = [485, 113];
                setState(() {
                  _index = 4;
                });
              }), // YURT DIŞI YATAY GEÇİŞ BAŞVURUSU
        ],
      ),
    );
  }
}

class Page2 extends StatefulWidget {
  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  int _index2 = 0;
  late List facultyData = [];
  List data = [];

  @override
  void initState() {
    super.initState();
    getFacultyData();
  }

  getFacultyData() async {
    facultyData = await FacultyService().getFaculties();
    for (var faculty in facultyData) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                      child: Container(
                          // width: 145,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _index2 == 1
                                ? Color(0xff317254)
                                : Color(0xffE6EAED),
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            border: Border.all(
                              color: Colors.green,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'I.ÖĞRETİM',
                                style: TextStyle(
                                  color: _index2 == 1
                                      ? Colors.white
                                      : Colors.grey[900],
                                  fontWeight: _index2 == 1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 15,
                                ),
                              )
                            ],
                          )),
                      onTap: () {
                        currentStudyBounds = [222, 337];
                        setState(() {
                          _index2 = 1;
                        });
                      }),
                ), // I.ÖĞRETİM
                SizedBox(width: 5),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                      child: Container(
                          // width: 145,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _index2 == 2
                                ? Color(0xff317254)
                                : Color(0xffE6EAED),
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'II.ÖĞRETİM',
                                style: TextStyle(
                                  color: _index2 == 2
                                      ? Colors.white
                                      : Colors.grey[900],
                                  fontWeight: _index2 == 2
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 15,
                                ),
                              )
                            ],
                          )),
                      onTap: () {
                        currentStudyBounds = [327, 337];
                        setState(() {
                          _index2 = 2;
                        });
                      }),
                ), // II.ÖĞRETİM
              ]),
          // SizedBox(
          //   height: 10,
          // ),
          // TProgress(
          //   hintText: "SINIF/ YARIYIL",
          // ),
          SizedBox(
            height: 10,
          ),
          TProgress(
              hintText: "DİSİPLİN CEZASI ALIP ALMADIĞI", input: "disiplin"),
        ],
      ),
    );
  }
}

class Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          TProgress(
              hintText: "AKADEMİK BAŞARI NOT ORTALAMASI", input: 'notortalama'),
          SizedBox(
            height: 10,
          ),
          TProgress(hintText: "ÖĞRENCİ NUMARASI(KOÜ)", input: "öğrencino"),
          SizedBox(
            height: 10,
          ),
          TProgress(
              hintText: "YÖK KURUMUNA YERLEŞTİRİLDİĞİ YIL",
              input: "yerleştirmeyıl"),
          SizedBox(
            height: 10,
          ),
          TProgress(
            hintText: "YERLEŞTİRMEDEKİ PUAN TÜRÜ VE PUANI",
            input: "yerleştirmepuantür",
          ),
          SizedBox(
            height: 10,
          ),
          TProgress(
              hintText: "Z.HAZIRLIK YABANCI DİL PUANI VE SINAV TÜRÜ",
              input: 'yabancıdilpuan'),
        ],
      ),
    );
  }
}

class Page4 extends StatefulWidget {
  @override
  _Page4State createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  String? facultyVal, departmentVal;
  int _index3 = 0;
  List faculties = [];
  List departments = ["", "", "", "", ""];

  @override
  void initState() {
    super.initState();
    getFacultyData();
  }

  getFacultyData() async {
    var facultyData = await FacultyService().getFaculties();
    for (var faculty in facultyData) {
      faculties.add(faculty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
                color: Color(0xffE6EAED),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green)),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                    isExpanded: true,
                    value: facultyVal,
                    items: [
                      DropdownMenuItem(
                          child: Text(faculties[0].faculty),
                          value: faculties[0].faculty),
                      DropdownMenuItem(
                          child: Text(faculties[1].faculty),
                          value: faculties[1].faculty),
                      DropdownMenuItem(
                          child: Text(faculties[2].faculty),
                          value: faculties[2].faculty),
                      DropdownMenuItem(
                          child: Text(faculties[3].faculty),
                          value: faculties[3].faculty),
                      DropdownMenuItem(
                          child: Text(faculties[4].faculty),
                          value: faculties[4].faculty),
                    ],
                    hint: Text(
                      "FAKÜLTE / YÜKSEKOKUL / MYO ADI",
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    onChanged: (text) {
                      print(text);
                      pdfFields["selectedFaculty"] = text;
                      setState(() {
                        facultyVal = text;

                        for (var faculty in faculties) {
                          if (text == faculty.faculty)
                            departments = faculty.departments;
                        }
                      });
                    })),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
                color: Color(0xffE6EAED),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green)),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                    isExpanded: true,
                    value: departmentVal,
                    items: [
                      DropdownMenuItem(
                          child: Text(
                              utf8.decode(departments[0].toString().codeUnits)),
                          value:
                              utf8.decode(departments[0].toString().codeUnits)),
                      DropdownMenuItem(
                          child: Text(
                              utf8.decode(departments[1].toString().codeUnits)),
                          value:
                              utf8.decode(departments[1].toString().codeUnits)),
                      DropdownMenuItem(
                          child: Text(
                              utf8.decode(departments[2].toString().codeUnits)),
                          value:
                              utf8.decode(departments[2].toString().codeUnits)),
                      DropdownMenuItem(
                          child: Text(
                              utf8.decode(departments[3].toString().codeUnits)),
                          value:
                              utf8.decode(departments[3].toString().codeUnits)),
                      DropdownMenuItem(
                          child: Text(
                              utf8.decode(departments[4].toString().codeUnits)),
                          value:
                              utf8.decode(departments[4].toString().codeUnits)),
                    ],
                    hint: Text(
                      "BÖLÜM / PROGRAM ADI",
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    onChanged: (text) {
                      pdfFields["selectedDepartment"] = text;
                      setState(() {
                        departmentVal = text;
                      });
                    })),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                      child: Container(
                          // width: 145,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _index3 == 1
                                ? Color(0xff317254)
                                : Color(0xffE6EAED),
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            border: Border.all(
                              color: Colors.green,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'I.ÖĞRETİM',
                                style: TextStyle(
                                  color: _index3 == 1
                                      ? Colors.white
                                      : Colors.grey[900],
                                  fontWeight: _index3 == 1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 15,
                                ),
                              )
                            ],
                          )),
                      onTap: () {
                        setState(() {
                          _index3 = 1;
                        });
                      }),
                ), // I.ÖĞRETİM
                SizedBox(width: 5),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                      child: Container(
                          // width: 145,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _index3 == 2
                                ? Color(0xff317254)
                                : Color(0xffE6EAED),
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'II.ÖĞRETİM',
                                style: TextStyle(
                                  color: _index3 == 2
                                      ? Colors.white
                                      : Colors.grey[900],
                                  fontWeight: _index3 == 2
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 15,
                                ),
                              )
                            ],
                          )),
                      onTap: () {
                        setState(() {
                          _index3 = 2;
                        });
                      }),
                ), // II.ÖĞRETİM
              ]),
          SizedBox(
            height: 10,
          ),
          TProgress(
              hintText: "YERLEŞTİRME YAPILDIĞI PUAN TÜRÜ VE PUANI",
              input: 'puantürü'),
        ],
      ),
    );
  }
}

class Page5 extends StatefulWidget {
  const Page5({Key? key}) : super(key: key);
  @override
  _Page5State createState() => _Page5State();
}

class _Page5State extends State<Page5> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [fileUpload(input: "Öğrenci Belgesi",)],
      ),
    );
  }
}

class Page6 extends StatefulWidget {
  const Page6({Key? key}) : super(key: key);
  @override
  _Page6State createState() => _Page6State();
}

class _Page6State extends State<Page6> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [fileUpload(input: "ÖSYM Sınav Belgesi")],
      ),
    );
  }
}

class Page7 extends StatefulWidget {
  const Page7({Key? key}) : super(key: key);
  @override
  _Page7State createState() => _Page7State();
}

class _Page7State extends State<Page7> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [fileUpload(input: "ÖSYM Yerleştirme Belgesi")],
      ),
    );
  }
}

class Page8 extends StatefulWidget {
  const Page8({Key? key}) : super(key: key);
  @override
  _Page8State createState() => _Page8State();
}

class _Page8State extends State<Page8> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [fileUpload(input: "Transkript")],
      ),
    );
  }
}

class Page9 extends StatefulWidget {
  const Page9({Key? key}) : super(key: key);
  @override
  _Page9State createState() => _Page9State();
}

class _Page9State extends State<Page9> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [fileUpload(input: "Disiplin Belgesi")],
      ),
    );
  }
}

class Page10 extends StatefulWidget {
  const Page10({Key? key}) : super(key: key);
  @override
  _Page10State createState() => _Page10State();
}

class _Page10State extends State<Page10> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [fileUpload(input: "Ders İçerikleri")],
      ),
    );
  }
}

class Page11 extends StatefulWidget {
  const Page11({Key? key}) : super(key: key);
  @override
  _Page11State createState() => _Page11State();
}

class _Page11State extends State<Page11> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [fileUpload(input: "Yabancı Dil Belgesi",)],
      ),
    );
  }
}

class Page12 extends StatefulWidget {
  const Page12({Key? key}) : super(key: key);
  @override
  _Page12State createState() => _Page12State();
}

class _Page12State extends State<Page12> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [fileUpload(input: "%10 Belgesi")],
      ),
    );
  }
}

class Page13 extends StatefulWidget {
  const Page13({Key? key, this.student, this.appTree}) : super(key: key);

  final student;
  final appTree;
  @override
  _Page13State createState() => _Page13State();
}

class _Page13State extends State<Page13> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          fileUpload(input: "Yurtdışı Sonuç Belgesi"),
          Divider(
            height: 10,
            thickness: 2,
            indent: 10,
            endIndent: 10,
            color: Colors.grey,
          ),
          Text("Başvuru Belgesi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff4e7966)
                    ),
                      onPressed: () async {
                        await pdfGenerate(widget.student);
                      },
                      child: Text("PDF OLUŞTUR",
                          style: TextStyle(color: Colors.white))),
                ),
                SizedBox(width: 5),
                Expanded(flex: 3, child: fileUpload(input: "Başvuru Belgesi"))
              ]),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              primary: Color(0xff566074)
            ),
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (context) => const CupertinoAlertDialog(
                          content: Center(child: CircularProgressIndicator()),
                        ));
                final model = ApplicationModel();
                List<Documents> docs = [];
                int genNum = widget.appTree.size + 1;
                model.sId = "app-$genNum";
                model.applicationType = "kat-2";
                model.status = "Beklemede";
                model.studentNum = widget.student.sId.split("-")[1];

                for (var file in files) {
                  var urlPath = await uploadFirebase("app-$genNum", file);
                  final document = Documents();
                  document.documentName = file["fileName"];
                  document.path = urlPath;
                  docs.add(document);
                }
                model.documents = docs;

                await ApplicationService()
                    .addApplication(model)
                    .whenComplete(() {
                  showDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                            title: Text("Başvurunuz Oluşturuldu!"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Tamam"))
                            ],
                          ));
                });
                BPlusTreeAlgos.insert(
                    bptree: widget.appTree,
                    keyToBeInserted: model.sId.toString(),
                    valueToBeInserted: model);
              },
              icon: Icon(Icons.check, color: Colors.white),
              label: Text("BAŞVURUYU ONAYLA",
                  style: TextStyle(color: Colors.white))),
          SizedBox(height: 80),
        ],
      ),
    );
  }
}

Future<List<int>> _readDocData(String name) async {
  final ByteData data = await rootBundle.load('lib/assets/pdf/$name');
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

insertDataToPdf(PdfPage page, String data, List<int> bounds, String path) {
  page.graphics.drawString(data,
      PdfTrueTypeFont(File('$path/Roboto-Black.ttf').readAsBytesSync(), 10),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds:
          Rect.fromLTWH(bounds[0].toDouble(), bounds[1].toDouble(), 200, 20));
}

pdfGenerate(dynamic student) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  print(appDocPath);
  final PdfDocument document =
      PdfDocument(inputBytes: await _readDocData('yataygecis.pdf'));
  final PdfPage page = document.pages[0];
  insertDataToPdf(page, 'X', appType, appDocPath);
  insertDataToPdf(page, student.nameSurname, [150, 160], appDocPath);
  insertDataToPdf(page, student.identityCard, [150, 180], appDocPath);
  List<String> date = student.dateBirth.split("/");
  insertDataToPdf(page, date[0], [365, 180], appDocPath);
  insertDataToPdf(page, date[1], [390, 180], appDocPath);
  insertDataToPdf(page, date[2], [410, 180], appDocPath);
  insertDataToPdf(page, student.mail, [150, 195], appDocPath);
  insertDataToPdf(page, student.telNum, [150, 215], appDocPath);
  insertDataToPdf(page, student.address.home, [150, 235], appDocPath);
  insertDataToPdf(
      page, student.universityInfo.universityName, [330, 283], appDocPath);
  insertDataToPdf(
      page, student.universityInfo.facility, [330, 300], appDocPath);
  insertDataToPdf(
      page, student.universityInfo.department, [330, 320], appDocPath);
  insertDataToPdf(page, 'X', currentStudyBounds, appDocPath);
  insertDataToPdf(
      page, student.universityInfo.grade.toString(), [430, 340], appDocPath);
  insertDataToPdf(page, pdfFields["disiplin"], [330, 360], appDocPath);
  insertDataToPdf(page, pdfFields["notortalama"], [330, 380], appDocPath);
  insertDataToPdf(page, pdfFields["öğrencino"], [363, 398], appDocPath);
  insertDataToPdf(page, pdfFields["yerleştirmeyıl"], [432, 415], appDocPath);
  insertDataToPdf(
      page,
      pdfFields["yerleştirmepuantür"] == null
          ? ""
          : pdfFields["yerleştirmepuantür"],
      [432, 435],
      appDocPath);
  insertDataToPdf(
      page,
      pdfFields["yabancıdilpuan"] == null ? "" : pdfFields["yabancıdilpuan"],
      [112, 465],
      appDocPath);
  insertDataToPdf(page, pdfFields["selectedFaculty"], [222, 508], appDocPath);
  insertDataToPdf(
      page, pdfFields["selectedDepartment"], [222, 528], appDocPath);
  insertDataToPdf(page, 'X', [222, 545], appDocPath);
  insertDataToPdf(
      page,
      pdfFields["puantür"] == null ? "" : pdfFields["puantür"],
      [122, 575],
      appDocPath);
  File('$appDocPath/yataygecis_out.pdf').writeAsBytes(document.save());
  document.dispose();
  OpenFile.open('$appDocPath/yataygecis_out.pdf');
}

class _yatayGecisState extends State<yatayGecis> {
  late PFormController pformController;
  @override
  void initState() {
    super.initState();
    pformController = PFormController(13);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: 30),
            child: Center(
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                            height: 50,
                            width: 30,
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                size: 25,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )),
                      ),
                    ],
                  ),
                  Image.asset(
                    'lib/assets/koulogo.png',
                    width: 165,
                    height: 165,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text("YATAY GEÇİŞ BAŞVURUSU",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
            width: width,
            height: height,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xff317254), Color(0xffE6EAED)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
          ),
          DraggableScrollableSheet(
              maxChildSize: 0.8,
              minChildSize: 0.3,
              initialChildSize: 0.5,
              builder: (ctx, controler) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)),
                  child: SingleChildScrollView(
                    controller: controler,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PForm(
                          controller: pformController,
                          pages: [
                            Page1(),
                            Page2(),
                            Page3(),
                            Page4(),
                            Page5(),
                            Page6(),
                            Page7(),
                            Page8(),
                            Page9(),
                            Page10(),
                            Page11(),
                            Page12(),
                            Page13(student: widget.student, appTree: widget.appTree),
                          ],
                          title: [
                            PTitle(
                              title: "BAŞVURU TÜRÜ",
                            ),
                            PTitle(
                              title: "ÖĞRENİMİNE İLİŞKİN BİLGİLER -1",
                            ),
                            PTitle(
                              title: "ÖĞRENİMİNE İLİŞKİN BİLGİLER -2",
                            ),
                            PTitle(title: "BAŞVURULAN PROGRAM BİLGİLERİ"),
                            PTitle(title: "ÖĞRENCİ BELGESİ"),
                            PTitle(title: "ÖSYM SINAV SONUÇ BELGESİ"),
                            PTitle(title: "ÖSYM YERLEŞTİRME BELGESİ"),
                            PTitle(title: "TRANSKRİPT"),
                            PTitle(title: "DİSİPLİN CEZASI YOKTUR BELGESİ"),
                            PTitle(title: "DERS İÇERİKLERİ"),
                            PTitle(title: "YABANCI DİL YETERLİLİK BELGESİ"),
                            PTitle(title: "%10 BELGESİ"),
                            PTitle(title: "YURTDIŞI SONUÇ BELGESİ")
                          ],
                        )
                      ],
                    ),
                  ),
                );
              })
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              pformController.prevPage();
              setState(() {});
            },
            child: Visibility(
              visible: pformController.currentPage != 0 ? true : false,
              child: Container(
                margin: EdgeInsets.only(bottom: 10),
                height: 50,
                width: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Color(0xff4E7966),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          InkWell(
            onTap: () {
              pformController.nextPage();
              setState(() {});
            },
            child: Visibility(
              visible: pformController.currentPage == pformController.length - 1
                  ? false
                  : true,
              child: Container(
                margin: EdgeInsets.only(bottom: 10),
                height: 50,
                width: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Color(0xff4E7966),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
