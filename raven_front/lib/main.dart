import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:raven_front/pages.dart';
import 'package:raven_front/pages/password/change.dart';
import 'package:raven_front/theme/color_gen.dart';
import 'package:raven_front/theme/theme.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  // Catch errors without crashing the app:
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp();

    // Let local development handle errors normally
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);
    // NOTE: To test firebase crashlytics in debug mode, set the above to
    // `true` and call `FirebaseCrashlytics.instance.crash()` at some point
    //  later in the code.

    // Errors that we don't catch should be sent to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // In-app error notification when foregrounded
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: false,
    );

    runApp(RavenMobileApp());
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

class RavenMobileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
          '/create': (context) => CreateAsset(),
          //'/settings': (context) => Settings(), #depericated, see settings.dart
          '/settings/about': (context) => About(),
          '/settings/preferences': (context) => Preferences(),
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
