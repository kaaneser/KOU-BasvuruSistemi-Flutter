import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:yazgel_project/views/forgot_password.dart';
import 'package:flutter/material.dart';
import 'package:yazgel_project/views/admin_menu.dart';
import 'package:yazgel_project/model/student_model.dart';
import 'package:yazgel_project/service/application_service.dart';
import 'package:yazgel_project/service/student_service.dart';
import 'package:yazgel_project/views/signup.dart';
import 'package:yazgel_project/views/custom_page_route.dart';
import 'package:yazgel_project/views/home.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String id = "";
  String pass = "";

  Future loginAuth(StudentModel user, String pass) async {
    try {
      var userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: user.mail, password: pass);
      return userCred;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
                  title: const Text("Hatalı Şifre!"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Tamam"))
                  ],
                ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [Color(0xff3d8f69), Color(0xffe6eaed),],
        )),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Container(
                height: height * 0.15,
              ),
              Container(
                margin: EdgeInsets.only(top: height * 0.15),
                height: height * 0.85,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50))),
                child: ListView(
                  children: [
                    const Text(
                      'KOCAELİ ÜNİVERSİTESİ\nBAŞVURU SİSTEMİ',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff26262b),),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Center(
                      child: Container(
                        
                        height: 1,
                        width: width * 0.8,
                        color: Color(0xff364545),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.1,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: TextField(
                          onChanged: (text) {
                            id = text;
                          },
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Öğrenci No",
                            hintStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                  width: 1,
                                  style: BorderStyle.solid,
                                  color: Colors.green),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.all(12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                  width: 1,
                                  style: BorderStyle.solid,
                                  color: Color(0xff26262b)),
                            ),
                          )),
                    ),
                    SizedBox(
                      height: height * 0.04,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: TextField(
                          onChanged: (text) {
                            pass = text;
                          },
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Şifre",
                            hintStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                  width: 1,
                                  style: BorderStyle.solid,
                                  color: Colors.green),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.all(12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                  width: 1,
                                  style: BorderStyle.solid,
                                  color: Color(0xff26262b)),
                            ),
                          )),
                    ),
                    SizedBox(
                      height: height * 0.08,
                    ),
                    GestureDetector(
                      onTap: () async {
                        showDialog(
                            context: context,
                            builder: (context) => const CupertinoAlertDialog(
                                  content: Center(child: CircularProgressIndicator()),
                                ));
                        final login = await StudentService().getStudent(id);
                        if (login.mail != null) {
                          await loginAuth(login, pass).whenComplete(() {
                            Navigator.pop(context);
                            if (id == 'admin') {
                              Navigator.push(context,
                                  CustomPageRoute(child: const AdminMenu()));
                            } else {
                              Navigator.push(context,
                                  CustomPageRoute(child: Home(student: login)));
                            }
                          });
                        } else {
                          return showDialog(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                    title: const Text("Kullanıcı bulunamadı!"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Tamam"))
                                    ],
                                  ));
                        }
                      },
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 26, vertical: 10),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xff4e7966),
                                Color(0xff317254)
                              ]),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 4,
                                    color: Color(0xff9ea5b1),
                                    offset: const Offset(2, 2))
                              ]),
                          child: const Text(
                            "GİRİŞ",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.7),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.05,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(context,
                            CustomPageRoute(child: const ForgotPassword()));
                      },
                      child: Text(
                        "Şifremi unuttum?".toUpperCase(),
                        style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xff26262b),
                            letterSpacing: 1.7),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.05,
                    ),
                    Center(
                      child: Container(
                        height: 1,
                        width: width * 0.8,
                        color: Color(0xff364545)
                      ),
                    ),
                    SizedBox(
                      height: height * 0.04,
                    ),
                    Text(
                      "Hesabın yok?".toUpperCase(),
                      style: const TextStyle(fontSize: 16, letterSpacing: 1.7,
                      color: Color(0xff26262b),),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context, CustomPageRoute(child: const Signup()));
                      },
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xff4e7966),
                                Color(0xff317254)
                              ]),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 4,
                                    color: Color(0xff9ea5b1),
                                    offset: const Offset(2, 2))
                              ]),
                          child: Text(
                            "Kayıt ol".toUpperCase(),
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.7),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
