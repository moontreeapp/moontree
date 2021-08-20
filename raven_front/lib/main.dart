// flutter run lib/main.dart
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';

import 'package:raven/init/raven.dart' as raven;

import 'package:raven_mobile/theme/color_gen.dart';
import 'package:raven_mobile/theme/theme.dart';
import 'package:raven_mobile/pages/home.dart';
import 'package:raven_mobile/pages/loading.dart';

Future<void> main() async {
  //await Hive.initFlutter();
  //raven.init();
  runApp(MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Loading(),
        '/home': (context) => Home(),
      },
      themeMode: ThemeMode.system,
      theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: generateMaterialColor(Palette.ravenBlue),
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
          primarySwatch: generateMaterialColor(Palette.ravenBlue),
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 24.0, letterSpacing: 2.0),
            headline3: TextStyle(color: Colors.grey.shade200),
            headline4: TextStyle(color: Colors.grey.shade200),
            bodyText1: TextStyle(fontSize: 18.0),
            bodyText2: TextStyle(fontSize: 16.0),
          ))));
}
