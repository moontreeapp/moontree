import 'dart:async';
import 'dart:io';
import 'package:client_front/main.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/services/consent.dart';
import 'package:client_front/infrastructure/services/password.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/domain/utils/auth.dart';
import 'package:client_front/domain/utils/device.dart';
import 'package:client_front/presentation/widgets/backdrop/backdrop.dart';
import 'package:client_front/presentation/components/shapes.dart' as shapes;
import 'package:client_front/presentation/components/shadows.dart' as shadows;
import 'package:client_front/infrastructure/services/services.dart';
import 'package:client_front/presentation/services/services.dart' show sailor;
import 'package:client_front/presentation/services/sailor.dart' show Sailor;
import 'package:client_front/presentation/services/services.dart' as uiservices;
import 'package:client_front/presentation/components/components.dart'
    as components;

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('Splash');

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  BorderRadius? shape;
  List<BoxShadow>? shadow;
  bool showAppBar = false;

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

  Future<void> _init() async {
    await Future<void>.delayed(const Duration(milliseconds: 4000));
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
    await services.client.createClient();
    await HIVE_INIT.setupDatabase2();
    await HIVE_INIT.setupWaiters2();

    //}, null);

    await Future<void>.delayed(const Duration(milliseconds: 1));
    uiservices.init(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      mainContext: context,
    );
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
      shape = shapes.topRoundedBorder16;
      shadow = shadows.frontLayer;
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
    //  showAppBar = true;
    //});

    streams.app.splash.add(false);

    /// how to call a function on a statefulwidget above you:
    //(context.findAncestorStateOfType<MoontreeAppState>() as MoontreeAppState)
    //    .reload();

    /// how to call a function of a stateless widget above you:
    //(context.findAncestorWidgetOfExactType<MoontreeApp>() as MoontreeApp)
    //    .reloadApp();
    await Future.delayed(Duration(milliseconds: 1000));
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => HomePage()));
    //Navigator.of(components.routes.routeContext!)
    //    .pushReplacementNamed(Sailor.initialPath);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: null,
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          //if (!showAppBar) BackdropAppBarContents(spoof: true),
          SlideTransition(
              position: _slideAnimation,
              child: AnimatedContainer(
                  duration: animationDuration,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: shape,
                      boxShadow: shadow,
                      color: Colors.white),
                  child: FadeTransition(
                      opacity: _fadeAnimation,
                      child:
                          /**/
                          Lottie.asset(
                              'assets/splash/moontree_v2_001_recolored.json',
                              animate: true,
                              repeat: false,
                              alignment: Alignment.center,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover
                              /**/
                              ))))
        ],
      ),
    );
  }

  Future<void> redirectToCreateOrLogin() async {
    //Future passwordFallback() async {
    //  services.authentication.setMethod(method: AuthMethod.moontreePassword);
    //  Future.microtask(() => Navigator.pushReplacementNamed(
    //        context,
    //        getMethodPathCreate(),
    //      ));
    //}
    Future<void>.microtask(() =>
        //    //Navigator.pushReplacementNamed(
        //    //          context,
        //    //          Sailor.initialPath,
        //    //        )
        //
        sailor.sailTo(location: Sailor.initialPath, replaceOverride: false));
    return;
    // make a password out of biokey
    // this is false on 1st startup -> create
    if (!services.password.required) {
      //streams.app.page.add('Setup');
      /**/ //Future<void>.microtask(() => Navigator.pushReplacementNamed(
      /**/ //      context,
      /**/ //      '/security/create/setup',
      /**/ //    ));
      print('going0');
      Future<void>.microtask(() => sailor.sailTo(
            location: '/wallet/holdings',
          ));

      //if (pros.settings.authMethodIsNativeSecurity) {
      //  final localAuthApi = LocalAuthApi();
      //  if (await localAuthApi.readyToAuthenticate) {
      //    Future.microtask(() => Navigator.pushReplacementNamed(
      //        context, getMethodPathCreate(),
      //        arguments: {'needsConsent': true}));
      //  } else {
      //    passwordFallback();
      //  }
      //} else {
      //  passwordFallback();
      //}
    } else {
      print('going1');
      Navigator.pop(context);
      Future<void>.microtask(() => sailor.sailTo(
            location: '/wallet/holdings',
          ));
      /**/ //await maybeSwitchToPassword();
      /**/ //if (services.password.interruptedPasswordChange()) {
      /**/ //  showDialog(
      /**/ //      context: context,
      /**/ //      builder: (BuildContext context) => AlertDialog(
      /**/ //              title: const Text('Issue detected'),
      /**/ //              content: const Text(
      /**/ //                  'Change Password process in progress, please submit your previous password...'),
      /**/ //              actions: <Widget>[
      /**/ //                TextButton(
      /**/ //                    child: const Text('ok'),
      /**/ //                    onPressed: () => Navigator.pushReplacementNamed(
      /**/ //                        context, '/security/resume',
      /**/ //                        arguments: <String, dynamic>{}))
      /**/ //              ]));
      /**/ //} else {
      /**/ //  bool hasConsented = false;
      /**/ //  try {
      /**/ //    hasConsented = await discoverConsent(await getId());
      /**/ //  } catch (e) {
      /**/ //    streams.app.snack.add(Snack(
      /**/ //      message: 'Unable to connect! Please check connectivity.',
      /**/ //    ));
      /**/ //  }
      /**/ //  Future<void>.microtask(() => Navigator.pushReplacementNamed(
      /**/ //      context, getMethodPathLogin(),
      /**/ //      arguments: <String, bool>{'needsConsent': !hasConsented}));
      /**/ //}
    }
  }
}
