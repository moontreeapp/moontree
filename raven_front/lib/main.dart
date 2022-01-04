import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:raven_front/pages.dart';
import 'package:raven_front/pages/password/change.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/widgets/nav_drawer.dart';
import 'package:raven_front/widgets/widgets.dart';

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
  //static final GlobalKey<NavigatorState> navigatorKey = new GlobalKey();
  static final GlobalKey<ScaffoldState> _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      themeMode: ThemeMode.system,
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.darkTheme,
      navigatorObservers: [components.navigator],
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
        '/settings/about': (context) => About(),
        '/settings/settings': (context) => Settings(),
        '/settings/preferences': (context) => Preferences(),
        '/settings/network': (context) => ElectrumNetwork(),
        '/settings/import': (context) => Import(),
        '/settings/export': (context) => Export(),
        '/settings/currency': (context) => Language(),
        '/settings/technical': (context) => TechnicalView(),
        '/settings/wallet': (context) => WalletView(),
      },
      builder: (context, child) {
        return Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            key: _key,
            //extendBodyBehindAppBar: true,
            drawer:
                Drawer(child: Text('testing\n this will be quite different')),
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(56),
                child: AppBar(
                    leading: PageLead(scaffoldKey: _key, mainContext: context),
                    title: PageTitle(),
                    actions: <Widget>[
                      components.status,
                      ConnectionLight(),
                      SizedBox(width: 16),
                      Image(
                        image: AssetImage('assets/icons/scan/scan.png'),
                        height: 24,
                        width: 24,
                      ),
                      SizedBox(width: 16)
                    ])),
            body: Stack(children: [
              NavDrawer(),
              Container(
                //padding: EdgeInsets.only(top: 80), //23+56
                //color: Theme.of(context).backgroundColor,
                color: Colors.transparent,
                child: Container(
                    child: child,
                    // if color below are not transparent, push it down
                    //padding: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8.0),
                            topLeft: Radius.circular(8.0)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0x33000000),
                              offset: Offset(1, 0),
                              blurRadius: 5),
                        ])),
              )
            ]));
        //body: Scaffold(
        //    extendBodyBehindAppBar: true,
        //    appBar: PreferredSize(
        //        preferredSize: Size.fromHeight(0), child: NavDrawer()),
        //    body: Container(
        //        padding: EdgeInsets.only(top: 80), //23+56
        //        color: Theme.of(context).backgroundColor,
        //        child: Container(
        //            child: child,
        //            // if color below are not transparent, push it down
        //            //padding: EdgeInsets.only(top: 8),
        //            decoration: BoxDecoration(
        //                borderRadius: BorderRadius.only(
        //                    topRight: Radius.circular(8.0),
        //                    topLeft: Radius.circular(8.0)),
        //                color: Colors.white,
        //                boxShadow: [
        //                  BoxShadow(
        //                      color: const Color(0x33000000),
        //                      offset: Offset(1, 0),
        //                      blurRadius: 5),
        //                ])))));
        //body: NavDrawer(child: child!));
      },
    );
  }
}
