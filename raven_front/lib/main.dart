import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//import 'package:flutter/foundation.dart' show kDebugMode;
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:raven_front/pages/pages.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/widgets/widgets.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('Handling a background message ${message.messageId}');
// }

Future<void> main() async {
  // Catch errors without crashing the app:
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RavenMobileApp());

  // runZonedGuarded<Future<void>>(() async {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   WidgetsFlutterBinding.ensureInitialized();

  //   await Firebase.initializeApp();

  //   // Let local development handle errors normally
  //   await FirebaseCrashlytics.instance
  //       .setCrashlyticsCollectionEnabled(!kDebugMode);
  //   // NOTE: To test firebase crashlytics in debug mode, set the above to
  //   // `true` and call `FirebaseCrashlytics.instance.crash()` at some point
  //   //  later in the code.

  //   // Errors that we don't catch should be sent to Crashlytics
  //   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  //   // Set the background messaging handler early on, as a named top-level function
  //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  //   // In-app error notification when foregrounded
  //   await FirebaseMessaging.instance
  //       .setForegroundNotificationPresentationOptions(
  //     alert: true, // Required to display a heads up notification
  //     badge: true,
  //     sound: false,
  //   );
  //   //setup();
  //   runApp(RavenMobileApp());
  // }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

class RavenMobileApp extends StatelessWidget {
  //static final GlobalKey<NavigatorState> navigatorKey = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return MaterialApp(
      initialRoute: '/splash',
      // look up flutter view model for sub app structure.
      //routes: pages.routes(context),
      routes: pages.routes(context),
      themeMode: ThemeMode.system,
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.lightTheme,
      navigatorObservers: [components.navigator],
      builder: (context, child) {
        components.navigator.scaffoldContext = context;
        return Scaffold(appBar: BackdropAppBar(), body: child!);
      },
    );
  }
}

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute(
      {required WidgetBuilder builder, required RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 1000);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final Animation<double> curve =
        CurvedAnimation(parent: animation, curve: Curves.easeOut);
    if (settings.name == "/splash") return child;
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, -1.0),
        end: Offset.zero,
      ).animate(curve),
      child: FadeTransition(opacity: curve, child: child),
    );
  }
}

class EnterExitRoute extends PageRouteBuilder {
  final Widget enterPage;
  final Widget exitPage;
  EnterExitRoute({required this.exitPage, required this.enterPage})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              enterPage,
          transitionDuration: const Duration(seconds: 4),
          reverseTransitionDuration: const Duration(seconds: 4),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              Container(
            color: Colors.white,
            child: Stack(
              children: <Widget>[
                SlideTransition(
                  position: new Tween<Offset>(
                    begin: Offset.zero,
                    end: const Offset(0.0, 1.0),
                  ).animate(animation),
                  child: exitPage,
                ),
                FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: new Tween<Offset>(
                      begin: const Offset(0.0, -1.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: enterPage,
                  ),
                )
              ],
            ),
          ),
        );
}
