import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ravencoin_front/cubits/send/cubit.dart';

//import 'package:flutter/foundation.dart' show kDebugMode;
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:ravencoin_front/pages/pages.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:ravencoin_back/streams/streams.dart';

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
    components.navigator.mainContext = context;
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
    //    overlays: [SystemUiOverlay.top]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (!Platform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: AppColors.androidSystemBar,
      ));
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      // look up flutter view model for sub app structure.
      routes: pages.routes(context),
      themeMode: ThemeMode.system,
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.lightTheme,
      navigatorObservers: [components.navigator],
      builder: (BuildContext context, child) {
        components.navigator.scaffoldContext = context;
        final scaffold =
            Stack(alignment: Alignment.bottomCenter, children: <Widget>[
          Scaffold(
            backgroundColor:
                Platform.isIOS ? AppColors.primary : AppColors.androidSystemBar,
            extendBodyBehindAppBar: false,
            appBar: const BackdropAppBar(),
            body: MultiBlocProvider(
              providers: [
                BlocProvider<SimpleSendFormCubit>(
                    create: (context) => SimpleSendFormCubit()),
              ],
              child: child!,
            ),
          ),
          const TutorialLayer(),
        ]);
        return GestureDetector(
            onTap: () => streams.app.tap.add(null),
            behavior: HitTestBehavior.translucent,
            child: Platform.isIOS ? scaffold : SafeArea(child: scaffold));
      },
    );
  }
}

//class MyCustomRoute<T> extends MaterialPageRoute<T> {
//  MyCustomRoute(
//      {required WidgetBuilder builder, required RouteSettings settings})
//      : super(builder: builder, settings: settings);
//
//  @override
//  Widget buildTransitions(BuildContext context, Animation<double> animation,
//      Animation<double> secondaryAnimation, Widget child) {
//    return child;
//    // Fades between routes. (If you don't want any animation,
//    // just return child.)
//    //return new FadeTransition(opacity: animation, child: child);
//  }
//
//  /*
//  onGenerateRoute: (RouteSettings settings) {
//        switch (settings.name) {
//          case '/': return new MyCustomRoute(
//            builder: (_) => new MyHomePage(),
//            settings: settings,
//          );
//          case '/somewhere': return new MyCustomRoute(
//            builder: (_) => new Somewhere(),
//            settings: settings,
//          );
//        }
//        assert(false);
//      }
//  */
//}
//
//
///*
//Route _createRoute() {
//  return PageRouteBuilder(
//    pageBuilder: (context, animation, secondaryAnimation) => Page2(),
//    transitionsBuilder: (context, animation, secondaryAnimation, child) {
//      return child;
//    },
//  );
//}
//And if you want to transition instantly, you can do this:
//
//transitionDuration: Duration(seconds: 0)
//*/
