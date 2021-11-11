import 'dart:async';

import 'package:datadog_flutter/datadog_observer.dart';
import 'package:flutter/material.dart';
import 'package:datadog_flutter/datadog_rum.dart';

import 'package:raven_mobile/pages.dart';
import 'package:raven_mobile/pages/password/change.dart';
import 'package:raven_mobile/theme/color_gen.dart';
import 'package:raven_mobile/theme/theme.dart';
import 'package:raven_mobile/utils/log.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    // Continue doing the usual thing we do with flutter errors:
    FlutterError.presentError(details);

    // ... and also send Flutter errors to Datadog:
    DatadogRum.instance.addFlutterError(details);
  };

  await Log.initialize();
  log('App started...');

  // Catch errors without crashing the app:
  runZonedGuarded(() {
    runApp(RavenMobileApp());
  }, (error, stackTrace) {
    DatadogRum.instance.addError(error, stackTrace);
  });
}

class RavenMobileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorObservers: [DatadogObserver()],
        initialRoute: '/',
        routes: {
          '/': (context) => Loading(),
          '/password/change': (context) => ChangePassword(),
          '/password/resume': (context) => ChangeResume(),
          '/login': (context) => Login(),
          '/home': (context) => Home(),
          '/asset': (context) => Asset(),
          '/transactions': (context) => RavenTransactions(),
          '/transaction': (context) => TransactionPage(),
          '/receive': (context) => Receive(),
          '/send': (context) => Send(),
          '/send/scan_qr': (context) => SendScanQR(),
          '/create': (context) => CreateAsset(),
          '/settings': (context) => Settings(),
          '/settings/about': (context) => About(),
          '/settings/account': (context) => AccountSettings(),
          '/settings/network': (context) => ElectrumNetwork(),
          '/settings/import': (context) => Import(),
          '/settings/export': (context) => Export(),
          '/settings/currency': (context) => Currency(),
          '/settings/language': (context) => Language(),
          '/settings/technical': (context) => TechnicalView(),
          '/settings/wallet': (context) => WalletView(),
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
              headline4: TextStyle(fontSize: 20, color: Colors.grey.shade900),
              headline6: TextStyle(
                  fontSize: 18.0,
                  letterSpacing: 1.5,
                  color: Colors.grey.shade400),
              bodyText1: TextStyle(fontSize: 20.0),
              bodyText2: TextStyle(fontSize: 16.0),
            )),
        darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: generateMaterialColor(Palette.ravenOrange),
            textTheme: TextTheme(
              headline1: TextStyle(fontSize: 24.0, letterSpacing: 2.0),
              headline2: TextStyle(
                  fontSize: 18.0,
                  letterSpacing: 2.0,
                  color: Colors.grey.shade200),
              headline3: TextStyle(color: Colors.grey.shade200),
              headline4: TextStyle(color: Colors.grey.shade200),
              bodyText1: TextStyle(fontSize: 20.0),
              bodyText2: TextStyle(fontSize: 16.0),
            )));
  }
}
