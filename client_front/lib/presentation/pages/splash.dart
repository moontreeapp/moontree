import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/components/shapes.dart' as shapes;
import 'package:client_front/presentation/components/shadows.dart' as shadows;
import 'package:client_front/infrastructure/services/services.dart';
import 'package:client_front/presentation/services/services.dart' as uiservices;

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('Splash');

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  final Duration animationDuration = const Duration(milliseconds: 2000);
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late final Animation<double> _fadeAnimation =
      Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);
  late Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: Offset(0, (56 + 24) / MediaQuery.of(context).size.height),
  ).animate(CurvedAnimation(
    parent: _slideController,
    curve: Curves.easeInOut,
  ));

  @override
  void initState() {
    super.initState();
    _slideController =
        AnimationController(vsync: this, duration: animationDuration);
    _fadeController =
        AnimationController(vsync: this, duration: animationDuration);
    _init();
  }

  /*
  /// example of spawning an isolate and passing data back, used because it 
  /// fails and because hive init has side effects, it's not pure.
  Future<void> _openHiveBoxInBackground() async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_hiveInit, receivePort.sendPort);
    final hiveBox = await receivePort.first;
  }
  */
  Future<void> _hiveInit([SendPort? sendPort]) async {
    await HIVE_INIT.setupDatabaseStart();
    await HIVE_INIT.setupDatabase1();

    /// update version right after we open settings box, capture a snapshot of
    /// the movement if we need to use it for migration logic:
    services.version.rotate(
      services.version.byPlatform(Platform.isIOS ? 'ios' : 'android'),
    );

    /// must use a heavier isolate implementation
    //compute((_) async {

    // put here or on login screen. here seems better for now.
    await HIVE_INIT.setupWaiters1();
    //await services.client.createClient(); // why?
    await HIVE_INIT.setupDatabase2();
    await HIVE_INIT.setupWaiters2();
    //sendPort.send(hiveBox);
    if (sendPort != null) {
      sendPort.send(true);
    }
    uiservices.init(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      statusBarHeight: MediaQuery.of(context).padding.top,
    );
  }

  Future<void> _init() async {
    final Stopwatch s = Stopwatch()..start();
    print('setup ${s.elapsed}');
    await _hiveInit();
    print('after setup: ${s.elapsed}');
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    await Future<void>.delayed(const Duration(milliseconds: 1));
    setState(() {
      _slideAnimation = Tween<Offset>(
        begin: Offset.zero,
        //Offset(
        //    0,
        //    uiservices.screen.app.systemStatusBarHeight /
        //        uiservices.screen.app.height),
        end: Offset(
            0,
            (uiservices.screen.app.systemStatusBarHeight +
                    uiservices.screen.app.appBarHeight -
                    3 // not sure why it's off by 3 pixels... rounding error
                ) /
                uiservices.screen.app.height),
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeInOutCubic,
      ));
    });
    _fadeController.forward();
    _slideController.forward();
    await Future<void>.delayed(animationDuration);

    //await Future<void>.delayed(const Duration(milliseconds: 1000));
    //// hack to trigger animate Welcome
    //streams.app.loading.add(false);
    //streams.app.loading.add(true);
    //streams.app.loading.add(false);
    //await Future<void>.delayed(const Duration(milliseconds: 1000));
    //_fadeController.forward();
    //await Future<void>.delayed(const Duration(milliseconds: 1000));
    //setState(() {
    //  _slideController.reset();
    //});

    streams.app.loc.splash.add(false);

    /// does not work
    ///
    //Navigator.of(components.routes.navigatorKey.currentContext!)
    //    .pushReplacement(MaterialPageRoute(
    //        builder: (c) => MultiBlocProvider(
    //              providers: providers,
    //              child: HomePage(child: Startup()),
    //            )));

    /// how to call a function on a statefulwidget above you:
    //(context.findAncestorStateOfType<MoontreeAppState>() as MoontreeAppState)
    //    .reload();

    /// how to call a function of a stateless widget above you:
    //(context.findAncestorWidgetOfExactType<MoontreeApp>() as MoontreeApp)
    //    .reloadApp();
    //await Future.delayed(Duration(milliseconds: 1000));
    //Navigator.of(components.routes.routeContext!).pushReplacement(
    //    MaterialPageRoute(builder: (BuildContext context) => MoontreeApp()));
    //Navigator.of(components.routes.routeContext!)
    //    .pushReplacementNamed(Sail.initialPath);
    //Navigator.of(components.routes.navigatorKey.currentContext!)
    //    .pushReplacementNamed(Sail.initialPath);
    //components.routes.navigatorKey.currentState!
    //    .pushReplacementNamed(Sail.initialPath);
    // allow for rebuild of root app
    //await redirectToCreateOrLogin();

    //await HIVE_INIT.setupWaiters1(); // if you put on login screen
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.primary,
        appBar: null,
        body: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            SlideTransition(
                position: _slideAnimation,
                child: AnimatedContainer(
                  duration: animationDuration,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: shapes.topRoundedBorder16,
                      boxShadow: shadows.frontLayer,
                      color: Colors.white),
                )),
            FadeTransition(
                opacity: _fadeAnimation,
                child:
                    /**/
                    Lottie.asset('assets/splash/moontree_v2_001_recolored.json',
                        animate: true,
                        repeat: false,
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover
                        /**/
                        ))
          ],
        ),
      );
}
