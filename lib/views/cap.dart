import 'dart:io';
import 'dart:ui';
import 'package:balancedtrees/bplustree/bplustree.dart';
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
import 'progress.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';

Map pdfFields = {};
List<int> currentStudyBounds = [];
List<Map<String, dynamic>> files = [];
final FirebaseStorage _storage = FirebaseStorage.instance;

class cap extends StatefulWidget {
  const cap({Key? key, this.student, this.appTree}) : super(key: key);
  final student;
  final appTree;
  @override
  _capState createState() => _capState();
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

  void pickFiles(String? filetype, String input) async {
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
        final fileName = file!.name;
        final filePath = file!.path;
        final File fileForFirebase = File(filePath!);
        files.add({"fileName": input, "file": fileForFirebase});
        setState(() {});
        break;
      case 'Hepsi':
        result = await FilePicker.platform.pickFiles();
        if (result == null) return;
        file = result!.files.first;
        final fileName = file!.name;
        final filePath = file!.path;
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
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 10,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                      child: Container(
                          width: 145,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _index == 1
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
                                  color: _index == 1
                                      ? Colors.white
                                      : Colors.grey[900],
                                  fontWeight: _index == 1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 15,
                                ),
                              )
                            ],
                          )),
                      onTap: () {
                        currentStudyBounds = [106, 351];
                        setState(() {
                          _index = 1;
                        });
                      }),
                ), // I.ÖĞRETİM
                SizedBox(width: 5),
                Expanded(
                  child: GestureDetector(
                      child: Container(
                          width: 145,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _index == 2
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
                                  color: _index == 2
                                      ? Colors.white
                                      : Colors.grey[900],
                                  fontWeight: _index == 2
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 15,
                                ),
                              )
                            ],
                          )),
                      onTap: () {
                        currentStudyBounds = [189, 351];
                        setState(() {
                          _index = 2;
                        });
                      }),
                ), // II.ÖĞRETİM
              ]),
          SizedBox(
            height: 10,
          ),
          TProgress(hintText: "ÇAP YAPILACAK FAKÜLTE", input: 'targetfaculty'),
          SizedBox(
            height: 10,
          ),
          TProgress(hintText: "ÇAP YAPILACAK BÖLÜM", input: 'targetdepartment'),
        ],
      ),
    );
  }
} // ÖĞRENİMİNE İLİŞKİN BİLGİLER

class Page2 extends StatefulWidget {
  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [fileUpload(input: "Transkript",)],
      ),
    );
  }
} // TRANSKRİPT

class Page3 extends StatefulWidget {
  const Page3({Key? key, this.student, this.appTree}) : super(key: key);
  final student;
  final appTree;
  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          fileUpload(input: "İkinci Anadal Puanı"),
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
                Expanded(flex: 3, child: fileUpload(input: "${widget.student.sId.split('-')[1]}_${widget.student.nameSurname}_${DateTime.now()}"))
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
                model.applicationType = "kat-4";
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
} // İKİNCİ ANADAL VE ÖĞRENCİ PUANI

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
      PdfDocument(inputBytes: await _readDocData('cap.pdf'));
  final PdfPage page = document.pages[0];
  insertDataToPdf(page, pdfFields['targetfaculty'], [235, 137], appDocPath);
  insertDataToPdf(page, pdfFields['targetdepartment'], [155, 150], appDocPath);
  insertDataToPdf(page, student.universityInfo.facility, [90, 187], appDocPath);
  insertDataToPdf(
      page, student.universityInfo.department, [175, 187], appDocPath);
  String studentNum = student.sId.split('-')[1];
  insertDataToPdf(page, studentNum, [90, 200], appDocPath);
  insertDataToPdf(page, student.nameSurname, [215, 200], appDocPath);
  insertDataToPdf(page, pdfFields['targetdepartment'], [215, 238], appDocPath);
  insertDataToPdf(page, 'X', currentStudyBounds, appDocPath); //106-189
  insertDataToPdf(page, student.address.home, [115, 405], appDocPath);
  insertDataToPdf(page, student.telNum, [115, 433], appDocPath);
  insertDataToPdf(page, student.mail, [115, 445], appDocPath);
  File('$appDocPath/cap_out.pdf').writeAsBytes(document.save());
  document.dispose();
  OpenFile.open('$appDocPath/cap_out.pdf');
}

class _capState extends State<cap> {
  late PFormController pformController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pformController = PFormController(3);
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
                  Text("ÇAP BAŞVURUSU",
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
                            Page3(student: widget.student, appTree: widget.appTree,),
                          ],
                          title: [
                            PTitle(
                              title: "BAŞVURU BİLGİLERİ",
                            ),
                            PTitle(
                              title: "TRANSKRİPT",
                            ),
                            PTitle(title: "İKİNCİ ANADAL VE ÖĞRENCİ PUANI"),
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
