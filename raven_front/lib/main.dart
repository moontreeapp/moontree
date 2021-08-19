// flutter run lib/main.dart
//import 'package:hive/hive.dart';
//import 'package:hive_flutter/hive_flutter.dart';
//import 'package:raven/boxes.dart';
import 'package:flutter/material.dart';
import 'package:raven_mobile/color_gen.dart';
import 'package:raven_mobile/theme.dart';
import 'pages/home.dart';
import 'pages/loading.dart';
import 'pages/choose_account.dart';

Future<void> main() async {
  //await Hive.initFlutter();
  //Truth.instance.init(); // only registers adapters
  //Box testbox = await Hive.openBox('testbox');
  //await testbox.add('whatever');
  //print(testbox.get(0));
  runApp(MaterialApp(
    theme: ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue.shade900,
      primarySwatch: generateMaterialColor(Palette.primary),
      bottomAppBarColor: Colors.grey.shade300,
      dividerColor: Colors.grey.shade200,
      backgroundColor: Colors.blue.shade50,
      scaffoldBackgroundColor: Colors.blue.shade50,
      disabledColor: Colors.grey,
      //hintColor: Colors.grey[600],
      //textTheme: Typography.blackCupertino,
      //textTheme: TextTheme(
      //  headline1: TextStyle(color: Colors.black),
      //  headline2: TextStyle(color: Colors.black),
      //  bodyText1: TextStyle(color: Colors.black),
      //  bodyText2: TextStyle(color: Colors.black),
      //),
    ),
    initialRoute: '/',
    routes: {
      '/': (context) => Loading(),
      '/home': (context) => Home(),
      '/account': (context) => ChooseAccount()
    },
  ));
}
