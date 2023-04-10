import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc/src/bloc_provider.dart'
    show BlocProviderSingleChildWidget;
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:client_back/streams/streams.dart';
import 'package:client_front/application/cubits.dart';
import 'package:client_front/infrastructure/services/dev.dart';
import 'package:client_front/infrastructure/services/subscription.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/pages/splash.dart';
import 'package:client_front/presentation/pages/pages.dart' as pages;
import 'package:client_front/presentation/containers/containers.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
//import 'package:flutter/foundation.dart' show kDebugMode;
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('Handling a background message ${message.messageId}');
// }

Future<void> main([List<String>? _, List<DevFlag>? flags]) async {
  devFlags.addAll(flags ?? []);
  // Catch errors without crashing the app:
  WidgetsFlutterBinding.ensureInitialized();

  // setup moontree server client for subscriptions
  await subscription.setupClient(FlutterConnectivityMonitor());

  // setup system ui stuff
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
  //    overlays: <SystemUiOverlay>[SystemUiOverlay.top]);
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  if (!Platform.isIOS) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: AppColors.androidSystemBar,
        systemNavigationBarColor: AppColors.androidNavigationBar,
        systemNavigationBarIconBrightness: Brightness.light));
  }

  runApp(MoontreeMobileApp());

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
  //   runApp(MoontreeMobileApp());
  // }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

class MoontreeMobileApp extends StatelessWidget {
  const MoontreeMobileApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
      key: components.routes.appKey,
      debugShowCheckedModeBanner: false,
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.lightTheme,
      navigatorKey: components.routes.navigatorKey,
      navigatorObservers: <NavigatorObserver>[components.routes],
      //initialRoute: '/splash',
      //home: Splash(),
      routes: pages.routes,

      /* we can either have `routes` with `pageTransitionBuilder` in `theme`,
           which has the drawback of not being able to control duration, or we
           could have PageRouteBuilders using `onGenerateRoute`. Since we can
           use named routes and get the transition we want we'll use that.
        onGenerateRoute: pages.generatedRoutes,
        */

      builder: (BuildContext context, Widget? child) =>
          MoontreeApp(child: child));
}

/// StreamBuilder solution to starting the app with splashscreen first
class MoontreeApp extends StatefulWidget {
  final Widget? child;
  const MoontreeApp({Key? key, this.child}) : super(key: key);

  @override
  MoontreeAppState createState() => MoontreeAppState();
}

class MoontreeAppState extends State<MoontreeApp> {
  Widget? child;

  @override
  void initState() {
    super.initState();
    child = widget.child;
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// how to rebuild entire tree
  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
        stream: streams.app.splash.stream,
        initialData: true,
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return Splash();
          } else {
            return MultiBlocProvider(
              providers: providers,
              child: HomePage(child: child),
            );
          }
        },
      );
}

class HomePage extends StatelessWidget {
  final Widget? child;
  const HomePage({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.primary,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
              ContentScaffold(child: child),
            ] +
            const <Widget>[
              ExtraContainer(),
              SnackbarLayer(),
              Navbar(),
              BottomModalSheet(),
              MessageModalLayer(),
              LoadingLayer(),

              /// must merge both implementations
              //LoadingLayerV1(),
              TutorialLayer(),
            ],
      ),
    );
    return GestureDetector(
        onTap: () => streams.app.tap.add(null),
        behavior: HitTestBehavior.translucent,
        child: Platform.isIOS ? scaffold : SafeArea(child: scaffold));
  }
}

List<BlocProviderSingleChildWidget> get providers => [
      BlocProvider<SimpleSendFormCubit>(
          create: (context) => components.cubits.simpleSendForm),
      BlocProvider<TransactionsViewCubit>(
          create: (context) => components.cubits.transactionsView),
      BlocProvider<TransactionViewCubit>(
          create: (context) => components.cubits.transactionView),
      BlocProvider<HoldingsViewCubit>(
          create: (context) => components.cubits.holdingsView),
      //BlocProvider<LoadingViewCubit>(
      //    create: (context) => components.cubits.loadingView),
      // v2
      BlocProvider<TitleCubit>(create: (context) => components.cubits.title),
      BlocProvider<BackContainerCubit>(
          create: (context) => components.cubits.backContainer),
      BlocProvider<FrontContainerCubit>(
          create: (context) => components.cubits.frontContainer),
      BlocProvider<ExtraContainerCubit>(
          create: (context) => components.cubits.extraContainer),
      BlocProvider<NavbarCubit>(create: (context) => components.cubits.navbar),
      BlocProvider<BottomModalSheetCubit>(
          create: (context) => components.cubits.bottomModalSheet),
      BlocProvider<MessageModalCubit>(
          create: (context) => components.cubits.messageModal),
      BlocProvider<LoadingViewCubit>(
          create: (context) => components.cubits.loadingView),
      BlocProvider<LoginCubit>(create: (context) => components.cubits.login),
      BlocProvider<ImportFormCubit>(
          create: (context) => components.cubits.import),
      BlocProvider<LocationCubit>(
          create: (context) => components.cubits.location),
      BlocProvider<ConnectionStatusCubit>(
          create: (context) => components.cubits.connection),
      BlocProvider<ReceiveViewCubit>(
          create: (BuildContext context) => components.cubits.receiveView),
    ];
