// flutter run lib/main.dart
//import 'package:hive/hive.dart';
//import 'package:hive_flutter/hive_flutter.dart';
//import 'package:raven/boxes.dart';
import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/loading.dart';
import 'pages/choose_account.dart';

Future<void> main() async {
  //await Hive.initFlutter();
  //Truth.instance.init(); // only registers adapters
  //Box testbox = await Hive.openBox('testbox');
  //await testbox.add('whatever');
  //print(testbox.get(0));
  runApp(MaterialApp(initialRoute: '/', routes: {
    '/': (context) => Loading(),
    '/home': (context) => Home(),
    '/account': (context) => ChooseAccount()
  }));
}
