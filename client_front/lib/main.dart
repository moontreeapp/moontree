import 'dart:async';
import 'dart:io' show Platform;

import 'package:beamer/beamer.dart';
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
import 'package:client_front/presentation/services/services.dart' show sailor;

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
    //Router(routerDelegate: routerDelegate)
    //uiservices.beamer.rootDelegate = BeamerDelegate(
    //  //initialPath: Sailor.initialPath,
    //  initialPath: '/splash',
    //  navigatorObservers: <NavigatorObserver>[components.routes],
    //  locationBuilder: RoutesLocationBuilder(
    //    routes: {
    //      '/splash': (context, state, data) => const Splash(),
    //      Sailor.initialPath: (context, state, data) {
    //        print(state.uri.toString());
    //        print(data);
    //        return const HomePage();
    //      },
    //    },
    //  ),
    //);
    //return MaterialApp.router(
    //  debugShowCheckedModeBanner: false,
    //  routerDelegate: uiservices.beamer.rootDelegate,
    //  routeInformationParser: BeamerParser(),
    //  theme: CustomTheme.lightTheme,
    //  darkTheme: CustomTheme.lightTheme,
    //);

    return MaterialApp(
        key: components.routes.appKey,
        debugShowCheckedModeBanner: false,
        theme: CustomTheme.lightTheme,
        darkTheme: CustomTheme.lightTheme,
        navigatorKey: components.routes.navigatorKey,
        navigatorObservers: <NavigatorObserver>[components.routes],
        initialRoute: '/splash',
        routes: pages.routes,
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name == '/splash') {
            return PageRouteBuilder<dynamic>(
              pageBuilder: (BuildContext context, Animation<double> animation,
                      Animation<double> secondaryAnimation) =>
                  Splash(),
              transitionsBuilder: (
                BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child,
              ) {
                final Tween<Offset> offsetTween = Tween<Offset>(
                    begin: Offset(0.0, 0.0), end: Offset(-1.0, 0.0));
                final Animation<Offset> slideOutLeftAnimation =
                    offsetTween.animate(secondaryAnimation);
                return SlideTransition(
                    position: slideOutLeftAnimation, child: child);
              },
            );
          } else {
            // handle other routes here
            return null;
          }
        },
        builder: (BuildContext context, Widget? child) =>
            MoontreeApp(child: child));
  }
}

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

  void reload() => setState(() {});

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    //rebuildAllChildren(context);
    print(streams.app.splash.value);
    print(widget.child!.key.toString());

    if (streams.app.splash.value == true) {
      child = SizedBox.shrink();
      return widget.child!;
    }

    return MultiBlocProvider(
        providers: providers,
        child: HomePage(
            child: //streams.app.splash.value == false
                //? () {
                //    streams.app.splash.add(null);
                //    setState(() {});
                //    return Startup();
                //  }()
                //:
                child));
  }
}

class HomePage extends StatelessWidget {
  final Widget? child;
  const HomePage({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

class Startup extends StatelessWidget {
  const Startup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //sailor.sailTo(
    //  location: Sailor.initialPath,
    //  replaceOverride: false,
    //);
    return SizedBox.shrink();
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
