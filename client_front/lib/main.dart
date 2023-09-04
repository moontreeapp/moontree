import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        stream: streams.app.loc.splash.stream,
        initialData: true,
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return Splash();
          } else {
            return MultiBlocProvider(
              providers: [
                BlocProvider<SimpleSendFormCubit>(
                    create: (context) => components.cubits.simpleSendForm),
                BlocProvider<SimpleReissueFormCubit>(
                    create: (context) => components.cubits.simpleReissueForm),
                BlocProvider<SimpleCreateFormCubit>(
                    create: (context) => components.cubits.simpleCreateForm),
                BlocProvider<WalletHoldingViewCubit>(
                    create: (context) => components.cubits.transactionsView),
                BlocProvider<TransactionViewCubit>(
                    create: (context) => components.cubits.transactionView),
                BlocProvider<WalletHoldingsViewCubit>(
                    create: (context) => components.cubits.holdingsView),
                BlocProvider<ManageHoldingsViewCubit>(
                    create: (context) => components.cubits.manageHoldingsView),
                BlocProvider<ManageHoldingViewCubit>(
                    create: (context) => components.cubits.manageHoldingView),
                BlocProvider<TitleCubit>(
                    create: (context) => components.cubits.title),
                BlocProvider<BackContainerCubit>(
                    create: (context) => components.cubits.backContainer),
                BlocProvider<FrontContainerCubit>(
                    create: (context) => components.cubits.frontContainer),
                BlocProvider<ExtraContainerCubit>(
                    create: (context) => components.cubits.extraContainer),
                BlocProvider<NavbarCubit>(
                    create: (context) => components.cubits.navbar),
                BlocProvider<SnackbarCubit>(
                    create: (context) => components.cubits.snackbar),
                BlocProvider<BottomModalSheetCubit>(
                    create: (context) => components.cubits.bottomModalSheet),
                BlocProvider<MessageModalCubit>(
                    create: (context) => components.cubits.messageModal),
                BlocProvider<LoadingViewCubit>(
                    create: (context) => components.cubits.loadingView),
                BlocProvider<LoginCubit>(
                    create: (context) => components.cubits.login),
                BlocProvider<ImportFormCubit>(
                    create: (context) => components.cubits.import),
                BlocProvider<LocationCubit>(
                    create: (context) => components.cubits.location),
                BlocProvider<SearchCubit>(
                    create: (context) => components.cubits.search),
                BlocProvider<ConnectionStatusCubit>(
                    create: (context) => components.cubits.connection),
                BlocProvider<ReceiveViewCubit>(
                    create: (BuildContext context) =>
                        components.cubits.receiveView),
                BlocProvider<TutorialCubit>(
                    create: (BuildContext context) =>
                        components.cubits.tutorial),
              ],
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
              Navbar(),
              BottomModalSheet(),
              MessageModalLayer(),
              LoadingLayer(),
              TutorialLayer(),
            ],
      ),
    );
    //todo fix - not a real solution
    //components.cubits.connection.update(status: ConnectionStatus.connected);
    return GestureDetector(
        onTap: () => streams.app.active.tap.add(null),
        behavior: HitTestBehavior.translucent,
        child: Platform.isIOS ? scaffold : SafeArea(child: scaffold));
  }
}
