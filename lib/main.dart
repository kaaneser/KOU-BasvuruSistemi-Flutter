//@dart=2.9
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:yazgel_project/views/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yazılım Geliştirme Proje 1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
          colorScheme: const ColorScheme(
              primary: Color(0xff149A43),
              primaryVariant: Color(0xff4E7966),
              secondary: Color(0xff317254),
              secondaryVariant: Color(0xff26262B),
              background: Color(0xffE6EAED),
              onPrimary: Color(0xff364545),
              onBackground: Color(0xff9EA5B1),
              surface: Color(0xffE6EAED),
              error: Color(0xffE6EAED),
              onSurface: Color(0xffE6EAED),
              brightness: Brightness.light,
              onSecondary: Color(0xffE6EAED),
              onError: Color(0xffE6EAED))),
      home: Login(),
    );
  }
}
