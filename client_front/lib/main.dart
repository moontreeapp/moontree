import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

//import 'package:flutter/foundation.dart' show kDebugMode;
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:client_front/application/cubits.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/infrastructure/services/dev.dart';
import 'package:client_front/infrastructure/calls/subscription.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:client_back/streams/streams.dart';
import 'package:client_back/services/services.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('Handling a background message ${message.messageId}');
// }

// ignore: implementation_imports
import 'package:flutter_bloc/src/bloc_provider.dart'
    show BlocProviderSingleChildWidget;

import 'package:client_front/presentation/containers/bottom/modal.dart';
import 'package:client_front/presentation/containers/bottom/navbar.dart';
import 'package:client_front/presentation/containers/content/extra.dart';
import 'package:client_front/presentation/containers/content/content.dart';
import 'package:client_front/presentation/containers/content/front.dart'
    show FrontContainerView;
import 'package:client_front/presentation/containers/content/back.dart'
    show BackContainerView;
import 'package:client_front/presentation/containers/layers/loading.dart';
import 'package:client_front/presentation/containers/layers/tutorial.dart';
import 'package:client_front/presentation/pages/splash.dart';
//import 'package:client_front/presentation/containers/loading_layer.dart';
import 'package:client_front/presentation/services/sailor.dart' show Sailor;
import 'package:client_front/presentation/services/services.dart' as uiservices;
import 'package:client_front/presentation/pages/pages.dart' as pages;

Future<void> main([List<String>? _, List<DevFlag>? flags]) async {
  devFlags.addAll(flags ?? []);
  // Catch errors without crashing the app:
  WidgetsFlutterBinding.ensureInitialized();

  // setup moontree server client for subscriptions
  await services.subscription.setupClient(FlutterConnectivityMonitor());

  // setup system ui stuff
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
  //    overlays: <SystemUiOverlay>[SystemUiOverlay.top]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: <SystemUiOverlay>[SystemUiOverlay.top]);
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  if (!Platform.isIOS) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.androidSystemBar,
    ));
  }

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

class RavenMobileApp extends StatefulWidget {
  const RavenMobileApp({Key? key}) : super(key: key);

  @override
  RavenMobileAppState createState() => RavenMobileAppState();
}

class RavenMobileAppState extends State<RavenMobileApp> {
  bool _showSplash = true;

  //static final GlobalKey<NavigatorState> navigatorKey = new GlobalKey();
  void hideSplash() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    components.routes.mainContext = context;
    //return MaterialApp(
    //  debugShowCheckedModeBanner: false,
    //  theme: CustomTheme.lightTheme,
    //  darkTheme: CustomTheme.lightTheme,
    //  initialRoute: '/splash',
    //  routes: pages.routes,
    //  navigatorObservers: <NavigatorObserver>[components.routes],
    //  builder: (BuildContext context, Widget? child) => (context, child) {
    //    print(_showSplash);
    //    return _showSplash
    //        ? Stack(
    //            alignment: Alignment.topCenter,
    //            children: <Widget>[
    //              const BackContainerView(),
    //              //FrontContainer(child: child),
    //              FrontContainerView(),
    //              child!
    //            ],
    //          )
    //        : MultiBlocProvider(
    //            providers: providers, child: HomePage(child: child));
    //  }(context, child),
    //);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.lightTheme,
      //initialRoute: '/splash',
      //routes: pages.routes,
      navigatorObservers: <NavigatorObserver>[components.routes],
      builder: (BuildContext context, Widget? child) => (context, child) {
        print(_showSplash);
        return _showSplash
            ? Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  const BackContainerView(),
                  //FrontContainer(child: child),
                  FrontContainerView(),
                  child!
                ],
              )
            : MultiBlocProvider(
                providers: providers, child: HomePage(child: child));
      }(context, child),
    );
  }
}

class HomePage extends StatelessWidget {
  final Widget? child;
  const HomePage({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    components.routes.scaffoldContext = context;
    uiservices.init(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      mainContext: context,
    );
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
              BottomNavigationBarWidget(),
              BottomModalSheetWidget(),
              //LoadingLayer(),  /// must merge both implementations
              LoadingLayer(),
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
      BlocProvider<LoadingViewCubit>(
          create: (context) => components.cubits.loadingView),
      // v2
      BlocProvider<TitleCubit>(create: (context) => components.cubits.title),
      BlocProvider<BackContainerCubit>(
          create: (context) => components.cubits.backContainer),
      BlocProvider<FrontContainerCubit>(
          create: (context) => components.cubits.frontContainer),
      BlocProvider<ExtraContainerCubit>(
          create: (context) => components.cubits.extraContainer),
      BlocProvider<NavbarHeightCubit>(
          create: (context) => components.cubits.navbarHeight),
      BlocProvider<NavbarSectionCubit>(
          create: (context) => components.cubits.navbarSection),
      BlocProvider<BottomModalSheetCubit>(
          create: (context) => components.cubits.bottomModalSheet),
      BlocProvider<LoadingViewCubitv2>(
          create: (context) => components.cubits.loadingViewv2),
    ];
