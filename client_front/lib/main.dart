import 'dart:async';
import 'dart:io' show Platform;

import 'package:client_front/presentation/containers/layers/loading.dart';
import 'package:client_front/presentation/containers/layers/tutorial.dart';
import 'package:client_front/presentation/pages/splash.dart';
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

import 'package:beamer/beamer.dart';
// ignore: implementation_imports
import 'package:flutter_bloc/src/bloc_provider.dart'
    show BlocProviderSingleChildWidget;

import 'package:client_front/presentation/containers/bottom/modal.dart';
import 'package:client_front/presentation/containers/bottom/navbar.dart';
import 'package:client_front/presentation/containers/content/extra.dart';
import 'package:client_front/presentation/containers/content/content.dart';
//import 'package:client_front/presentation/containers/loading_layer.dart';
import 'package:client_front/presentation/services/sailor.dart' show Sailor;
import 'package:client_front/presentation/services/services.dart' as uiservices;

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

class RavenMobileApp extends StatelessWidget {
  RavenMobileApp({Key? key}) : super(key: key);

  //static final GlobalKey<NavigatorState> navigatorKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    components.routes.mainContext = context;
    uiservices.beamer.rootDelegate = BeamerDelegate(
      //initialPath: Sailor.initialPath,
      initialPath: '/splash',
      navigatorObservers: <NavigatorObserver>[components.routes],
      locationBuilder: RoutesLocationBuilder(
        routes: {
          '/splash': (context, state, data) => const Splash(),
          Sailor.initialPath: (context, state, data) {
            print(state.uri.toString());
            print(data);
            return const HomePage();
          },
        },
      ),
    );
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: uiservices.beamer.rootDelegate,
      routeInformationParser: BeamerParser(),
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.lightTheme,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    components.routes.scaffoldContext = context;
    final scaffold = Scaffold(
      backgroundColor: AppColors.primary,
      resizeToAvoidBottomInset: false,
      body: MultiBlocProvider(
        providers: providers,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: const <Widget>[
            ContentScaffold(),
            ContentExtra(),
            BottomNavigationBarWidget(),
            BottomModalSheetWidget(),
            //LoadingLayer(),  /// must merge both implementations
            LoadingLayer(),
            TutorialLayer(),
          ],
        ),
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
      BlocProvider<FrontContainerHeightCubit>(
          create: (context) => components.cubits.frontContainerHeight),
      BlocProvider<NavbarHeightCubit>(
          create: (context) => components.cubits.navbarHeight),
      BlocProvider<NavbarSectionCubit>(
          create: (context) => components.cubits.navbarSection),
      BlocProvider<BottomModalSheetCubit>(
          create: (context) => components.cubits.bottomModalSheet),
      BlocProvider<LoadingViewCubitv2>(
          create: (context) => components.cubits.loadingViewv2),
      BlocProvider<ContentExtraCubit>(
          create: (context) => components.cubits.contentExtra),
    ];
