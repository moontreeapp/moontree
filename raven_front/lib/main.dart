import 'package:flutter/material.dart';
import 'package:raven_mobile/pages.dart';
import 'package:raven_mobile/theme/color_gen.dart';
import 'package:raven_mobile/theme/theme.dart';

void main() => runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => Loading(),
      '/login': (context) => Login(),
      '/password/resume': (context) => ChangeResume(),
      '/home': (context) => Home(),
      '/settings': (context) => Settings(),
      '/settings/about': (context) => About(),
      '/settings/account': (context) => AccountSettings(),
      '/settings/import': (context) => Import(),
      '/settings/export': (context) => Export(),
      '/settings/currency': (context) => Currency(),
      '/settings/language': (context) => Language(),
      '/settings/technical': (context) => TechnicalView(),
      '/settings/wallet': (context) => WalletView(),
      '/asset': (context) => Asset(),
      '/transactions': (context) => RavenTransactions(),
      '/transaction': (context) => Transaction(),
      '/send': (context) => Send(),
      '/send/scan_qr': (context) => SendScanQR(),
      '/create': (context) => CreateAsset(),
      '/receive': (context) => Receive(),
    },
    themeMode: ThemeMode.system,
    theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: generateMaterialColor(Palette.ravenBlue),
        textTheme: TextTheme(
          headline5: TextStyle(
              fontSize: 24.0, letterSpacing: 2.0, color: Colors.grey.shade200),
          headline2: TextStyle(
              fontSize: 18.0, letterSpacing: 2.0, color: Colors.grey.shade200),
          headline3: TextStyle(color: Colors.grey.shade200),
          headline4: TextStyle(fontSize: 20, color: Colors.grey.shade900),
          headline6: TextStyle(
              fontSize: 18.0, letterSpacing: 1.5, color: Colors.grey.shade400),
          bodyText1: TextStyle(fontSize: 20.0),
          bodyText2: TextStyle(fontSize: 16.0),
        )),
    darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: generateMaterialColor(Palette.ravenOrange),
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 24.0, letterSpacing: 2.0),
          headline2: TextStyle(
              fontSize: 18.0, letterSpacing: 2.0, color: Colors.grey.shade200),
          headline3: TextStyle(color: Colors.grey.shade200),
          headline4: TextStyle(color: Colors.grey.shade200),
          bodyText1: TextStyle(fontSize: 20.0),
          bodyText2: TextStyle(fontSize: 16.0),
        ))));
