// flutter run lib/main.dart
//import 'package:hive/hive.dart';
//import 'package:hive_flutter/hive_flutter.dart';
//import 'package:raven/boxes.dart';
import 'package:flutter/material.dart';
import 'package:raven_mobile/color_gen.dart';
import 'package:raven_mobile/theme.dart';
import 'pages/home.dart';
import 'pages/loading.dart';

extension ValueColorExtension on ThemeData {
  Color? get good => this.brightness == Brightness.light
      ? Colors.green.shade800
      : Colors.green.shade400;
  Color? get bad => this.brightness == Brightness.light
      ? Colors.red.shade900
      : Colors.red.shade500;
  Color? get fine => this.brightness == Brightness.light
      ? Colors.grey.shade900
      : Colors.grey.shade400;
}

Future<void> main() async {
  //await Hive.initFlutter();
  //Truth.instance.init(); // only registers adapters
  //Box testbox = await Hive.openBox('testbox');
  //await testbox.add('whatever');
  //print(testbox.get(0));

  runApp(MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Loading(),
        '/home': (context) => Home(),
      },
      themeMode: ThemeMode.system,
      theme: ThemeData(
          brightness: Brightness.light,
          //primaryColor: Colors.blue.shade900,
          primarySwatch: generateMaterialColor(Palette.ravenBlue),
          //bottomAppBarColor: Colors.grey.shade300,
          //dividerColor: Colors.grey.shade200,
          //backgroundColor: Colors.blue.shade50,
          //scaffoldBackgroundColor: Colors.blue.shade50,
          //disabledColor: Colors.grey,
          //hintColor: Colors.grey[600],
          //textTheme: Typography.blackHelsinki,
          textTheme: TextTheme(
            headline5: TextStyle(
                fontSize: 24.0,
                letterSpacing: 2.0,
                color: Colors.grey.shade200),
            headline2: TextStyle(
                fontSize: 18.0,
                letterSpacing: 2.0,
                color: Colors.grey.shade200),
            headline3: TextStyle(color: Colors.grey.shade200),
            headline4: TextStyle(color: Colors.grey.shade200),
            headline6: TextStyle(
                fontSize: 18.0,
                letterSpacing: 1.5,
                color: Colors.grey.shade400),
            bodyText1: TextStyle(fontSize: 18.0),
            bodyText2: TextStyle(fontSize: 16.0),
          )),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          //primaryColor: Palette.ravenBlue,
          primarySwatch: generateMaterialColor(Palette.ravenBlue),
          //bottomAppBarColor: Colors.grey.shade300,
          //dividerColor: Colors.grey.shade200,
          //backgroundColor: Colors.blue.shade50,
          //scaffoldBackgroundColor: Colors.blue.shade50,
          //disabledColor: Colors.grey,
          //hintColor: Colors.grey[600],
          //textTheme: Typography.blackCupertino,
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 24.0, letterSpacing: 2.0),
            //headline2: TextStyle(fontSize: 20.0, letterSpacing: 2.0),
            headline3: TextStyle(color: Colors.grey.shade200),
            headline4: TextStyle(color: Colors.grey.shade200),

            bodyText1: TextStyle(fontSize: 18.0),
            bodyText2: TextStyle(fontSize: 16.0),
          ))));
}
