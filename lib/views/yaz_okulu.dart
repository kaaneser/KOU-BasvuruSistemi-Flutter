import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:balancedtrees/balancedtrees.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:yazgel_project/model/application_model.dart';
import 'package:yazgel_project/service/application_service.dart';
import 'package:yazgel_project/service/faculty_service.dart';
import 'progress.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';

Map pdfData = {};
List<Map<String, dynamic>> files = [];
List<String?> fileNames = [];
final FirebaseStorage _storage = FirebaseStorage.instance;

class yazOkulu extends StatefulWidget {
  const yazOkulu({Key? key, this.student, this.appTree}) : super(key: key);

  final student;
  final appTree;

  @override
  _yazOkuluState createState() => _yazOkuluState();
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
          color: const Color(0xffE6EAED),
          borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        onChanged: (text) {
          pdfData[input] = text;
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

class dersBilgi extends StatelessWidget {
  dersBilgi(this.list);

  final List<String> list;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TProgress(hintText: "DERSİN ADI VE KODU", input: list[0]),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            flex: 1,
            child: TProgress(hintText: "T", input: list[1]),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            flex: 1,
            child: TProgress(hintText: "U", input: list[2]),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            flex: 1,
            child: TProgress(hintText: "L", input: list[3]),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            flex: 1,
            child: TProgress(hintText: "AKTS", input: list[4]),
          ),
        ],
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
            child: Text(
              'BELGE SEÇİNİZ',
              style: TextStyle(color: Colors.white),
            ),
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
              child: Text(
                'SEÇİLMİŞ BELGEYİ GÖR',
                style: TextStyle(color: Colors.white),
              ),
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

  void pickFiles(String filetype, String input) async {
    switch (filetype) {
      case 'Pdf':
        result = await FilePicker.platform
            .pickFiles(type: FileType.custom, allowedExtensions: [
          'pdf',
        ]);
        if (result == null) return;
        file = result!.files.first;
        final fileName = file!.name;
        final filePath = file!.path;
        final File fileForFirebase = File(filePath!);
        files.add({"fileName": input, "file": fileForFirebase});
        setState(() {});
        break;
      case 'Doc':
        result = await FilePicker.platform.pickFiles(
            type: FileType.custom, allowedExtensions: ['doc', 'docx']);
        if (result == null) return;
        file = result!.files.first;
        final fileName = file!.name;
        final filePath = file!.path;
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
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 10,
          ),
          TProgress(
              hintText: "ÖĞRENCİ DANIŞMANI ADI - SOYADI", input: "danışman"),
        ],
      ),
    );
  }
} //ÖĞRENİMİNE İLİŞKİN BİLGİLER

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 3,
            itemBuilder: (BuildContext context, int i) {
              return dersBilgi([
                "sdersad$i",
                "sderst$i",
                "sdersu$i",
                "sdersl$i",
                "sdersakts$i"
              ]);
            }));
  }
} //SORUMLU OLUNAN DERSLER

class Page3 extends StatefulWidget {
  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  String? facultyVal, departmentVal;
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
                      pdfData["faculty"] = text;
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
                      pdfData["department"] = text;
                      setState(() {
                        departmentVal = text;
                      });
                    })),
          ),
          SizedBox(
            height: 10,
          ),
          TProgress(
            hintText: "YAZ OKULU İÇİN BAŞVURULAN ÜNİ.",
            input: "başvurulanüni",
          ),
          SizedBox(
            height: 10,
          ),
          TProgress(
              hintText: "YAZ OKULU BAŞLAMA - BİTİŞ TARİHLERİ", input: "tarih"),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
} //YAZ ÖĞRETİMİ BİLGİLERİ

class Page4 extends StatefulWidget {
  const Page4({Key? key}) : super(key: key);
  @override
  _Page4State createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 3,
            itemBuilder: (BuildContext context, int i) {
              return dersBilgi([
                "ydersad$i",
                "yderst$i",
                "ydersu$i",
                "ydersl$i",
                "ydersakts$i"
              ]);
            }));
  }
} //YAZ ÖĞRETİMİNDE ALINACAK DERSLER

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
        children: [fileUpload(input: "Taban Puanları")],
      ),
    );
  }
} //TABAN PUANI (KURUM-KARŞI KURUM)

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
        children: [fileUpload(input: "Ders Bilgileri")],
      ),
    );
  }
} //KARŞI KURUM DERS BİLGİLERİ

class Page7 extends StatefulWidget {
  const Page7({Key? key, this.student, this.appTree}) : super(key: key);

  final student;
  final appTree;

  @override
  _Page7State createState() => _Page7State();
} //TRANSKRİPT

class _Page7State extends State<Page7> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          fileUpload(
            input: "Transkript",
          ),
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
                Expanded(
                    flex: 3,
                    child: fileUpload(
                        input:
                            "${widget.student.sId.split('-')[1]}_${widget.student.nameSurname}_${DateTime.now()}"))
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
                model.applicationType = "kat-1";
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
          SizedBox(height: 80)
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
      PdfTrueTypeFont(File('$path/Roboto-Black.ttf').readAsBytesSync(), 8),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds:
          Rect.fromLTWH(bounds[0].toDouble(), bounds[1].toDouble(), 200, 20));
}

pdfGenerate(dynamic student) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  print(appDocPath);
  final PdfDocument document =
      PdfDocument(inputBytes: await _readDocData('yazokulu.pdf'));
  final PdfPage page = document.pages[0];
  insertDataToPdf(page, pdfData["faculty"], [215, 110], appDocPath);
  insertDataToPdf(page, pdfData["department"], [175, 125], appDocPath);
  insertDataToPdf(
      page, student.universityInfo.facility, [100, 143], appDocPath);
  insertDataToPdf(
      page, student.universityInfo.department, [198, 137], appDocPath);
  String studentNum = student.sId.split("-")[1];
  insertDataToPdf(page, studentNum, [328, 143], appDocPath);
  insertDataToPdf(page, student.nameSurname, [432, 143], appDocPath);
  insertDataToPdf(page, '2021', [100, 171], appDocPath);
  insertDataToPdf(page, '22', [124, 171], appDocPath);
  insertDataToPdf(page, pdfData["danışman"], [256, 253], appDocPath);
  insertDataToPdf(page, student.address.home, [256, 265], appDocPath);
  insertDataToPdf(page, student.telNum, [256, 278], appDocPath);
  insertDataToPdf(page, student.mail, [256, 292], appDocPath);
  insertDataToPdf(page, pdfData["başvurulanüni"], [256, 318], appDocPath);
  insertDataToPdf(page, pdfData["tarih"], [256, 332], appDocPath);
  insertDataToPdf(page, pdfData["sdersad0"], [200, 397], appDocPath);
  insertDataToPdf(page, pdfData["sderst0"], [430, 397], appDocPath);
  insertDataToPdf(page, pdfData["sdersu0"], [460, 397], appDocPath);
  insertDataToPdf(page, pdfData["sdersl0"], [490, 397], appDocPath);
  insertDataToPdf(page, pdfData["sdersakts0"], [520, 397], appDocPath);
  insertDataToPdf(page, pdfData["sdersad1"], [200, 427], appDocPath);
  insertDataToPdf(page, pdfData["sderst1"], [430, 427], appDocPath);
  insertDataToPdf(page, pdfData["sdersu1"], [460, 427], appDocPath);
  insertDataToPdf(page, pdfData["sdersl1"], [490, 427], appDocPath);
  insertDataToPdf(page, pdfData["sdersakts1"], [520, 427], appDocPath);
  insertDataToPdf(page, pdfData["sdersad2"], [200, 457], appDocPath);
  insertDataToPdf(page, pdfData["sderst2"], [430, 457], appDocPath);
  insertDataToPdf(page, pdfData["sdersu2"], [460, 457], appDocPath);
  insertDataToPdf(page, pdfData["sdersl2"], [490, 457], appDocPath);
  insertDataToPdf(page, pdfData["sdersakts2"], [520, 457], appDocPath);
  insertDataToPdf(page, pdfData["ydersad0"], [256, 538], appDocPath);
  insertDataToPdf(page, pdfData["yderst0"], [430, 538], appDocPath);
  insertDataToPdf(page, pdfData["ydersu0"], [460, 538], appDocPath);
  insertDataToPdf(page, pdfData["ydersl0"], [490, 538], appDocPath);
  insertDataToPdf(page, pdfData["ydersakts0"], [520, 538], appDocPath);
  insertDataToPdf(page, pdfData["ydersad1"], [256, 588], appDocPath);
  insertDataToPdf(page, pdfData["yderst1"], [430, 588], appDocPath);
  insertDataToPdf(page, pdfData["ydersu1"], [460, 588], appDocPath);
  insertDataToPdf(page, pdfData["ydersl1"], [490, 588], appDocPath);
  insertDataToPdf(page, pdfData["ydersakts1"], [520, 588], appDocPath);
  insertDataToPdf(page, pdfData["ydersad2"], [256, 628], appDocPath);
  insertDataToPdf(page, pdfData["yderst2"], [430, 628], appDocPath);
  insertDataToPdf(page, pdfData["ydersu2"], [460, 628], appDocPath);
  insertDataToPdf(page, pdfData["ydersl2"], [490, 628], appDocPath);
  insertDataToPdf(page, pdfData["ydersakts2"], [520, 628], appDocPath);
  File('$appDocPath/yazokulu_out.pdf').writeAsBytes(document.save());
  document.dispose();
  OpenFile.open('$appDocPath/yazokulu_out.pdf');
}

class _yazOkuluState extends State<yazOkulu> {
  late PFormController pformController;
  @override
  void initState() {
    super.initState();
    pformController = PFormController(7);
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
                  Text("YAZ OKULU BAŞVURUSU",
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
                            Page7(
                                student: widget.student,
                                appTree: widget.appTree),
                          ],
                          title: [
                            PTitle(
                              title: "ÖĞRENİMİNE İLİŞKİN BİLGİLER",
                            ),
                            PTitle(
                              title: "SORUMLU OLUNAN DERSLER",
                            ),
                            PTitle(
                              title: "YAZ ÖĞRETİMİ BİLGİLERİ",
                            ),
                            PTitle(title: "ALINACAK DERSLER"),
                            PTitle(title: "TABAN PUANLARI"),
                            PTitle(title: "KARŞI KURUM DERS BİLGİLERİ"),
                            PTitle(title: "TRANSKRİPT"),
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
