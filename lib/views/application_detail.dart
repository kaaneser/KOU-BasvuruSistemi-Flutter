import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yazgel_project/model/application_model.dart';
import 'package:yazgel_project/service/application_service.dart';

class ApplicationDetail extends StatefulWidget {
  const ApplicationDetail(
      {Key? key, this.application, this.category, this.student})
      : super(key: key);

  final application, category, student;

  @override
  _ApplicationDetailState createState() => _ApplicationDetailState();
}

class _ApplicationDetailState extends State<ApplicationDetail> {
  List<String> documentNames = [
    "Öğrenci Belgesi",
    "ÖSYM Sınav Sonuç Belgesi",
    "ÖSYM Yerleştirme Belgesi",
    "Transkript",
    "Disiplin Belgesi",
    "Ders İçerikleri",
    "Yabancı Dil Yeterlilik Belgesi"
  ];
  List<Documents> nonNullDocuments = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      for (var doc in widget.application.documents) {
        if (doc.path != null) {
          nonNullDocuments.add(doc);
        }
      }
    });
  }

  Future<void>? _launched;

  Future<void> _launch(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffc2c8cf),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              offset: Offset(2, 2),
                              blurRadius: 1)
                        ]),
                    child: const Icon(Icons.arrow_back_ios_new),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              offset: Offset(2, 2),
                              blurRadius: 1),
                        ]),
                    child: IconButton(
                      onPressed: () async {
                        widget.application.status = "Kabul Edildi";
                        print(widget.application.status);
                        await ApplicationService()
                            .updateApplication(widget.application)
                            .whenComplete(() {
                          showDialog(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                    title: Text("Başvuru başarıyla onaylandı!"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Tamam"))
                                    ],
                                  ));
                        });
                        setState(() {});
                      },
                      icon: const Icon(Icons.check, color: Colors.green),
                      splashRadius: 25,
                    ),
                  ),
                  const VerticalDivider(
                    width: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.grey,
                                offset: Offset(2, 2),
                                blurRadius: 1),
                          ]),
                      child: IconButton(
                        onPressed: () async {
                          widget.application.status = "Reddedildi";
                        print(widget.application.status);
                        await ApplicationService()
                            .updateApplication(widget.application)
                            .whenComplete(() {
                          showDialog(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                    title: Text("Başvuru başarıyla reddedildi!"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Tamam"))
                                    ],
                                  ));
                        });
                        setState(() {});
                        },
                        icon: const Icon(Icons.clear, color: Colors.red),
                        splashRadius: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ]),
            Container(
              padding:
                  const EdgeInsets.only(left: 5, right: 5, top: 20, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                              image: NetworkImage(widget.student.photoUrl),
                              fit: BoxFit.cover),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.grey,
                                offset: Offset(-2, 2),
                                blurRadius: 3)
                          ]),
                      height: 200,
                      width: 130),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.application.studentNum,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(widget.student.nameSurname,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black38,
                              fontSize: 16)),
                      const Divider(
                        height: 50,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(-2, 2),
                                      blurRadius: 3)
                                ]),
                            child: Icon(Icons.paste,
                                color: Theme.of(context).primaryColor),
                          ),
                          const VerticalDivider(
                            width: 10,
                          ),
                          Text(
                            widget.category.categoryName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 0),
                          blurRadius: 2)
                    ]),
                child: ListView.separated(
                    itemBuilder: (BuildContext context, int i) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 150,
                            child: Text(nonNullDocuments[i].documentName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                          OutlinedButton(
                              onPressed: () {
                                _launch(nonNullDocuments[i].path);
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                              ),
                              child: const Text("Dosya")),
                        ],
                      );
                    },
                    separatorBuilder: (context, i) => const Divider(
                          thickness: 1,
                          color: Colors.grey,
                          indent: 50,
                          endIndent: 50,
                        ),
                    itemCount: nonNullDocuments.length),
              ),
            )
          ],
        ),
      ),
    );
  }
}
