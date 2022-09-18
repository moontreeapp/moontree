import 'dart:async';

import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/services/auth.dart' show LocalAuthApi;
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_front/utils/auth.dart';
import 'package:ravencoin_front/utils/device.dart';
import 'package:ravencoin_front/widgets/backdrop/backdrop.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/services.dart';
import 'package:ravencoin_back/services/consent.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  BorderRadius? shape;
  bool showAppBar = false;

  final Duration animationDuration = Duration(milliseconds: 1000);
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation =
      Tween(begin: 1.0, end: 0.0).animate(_fadeController);
  late final Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 0),
    end: Offset(0, 56 / MediaQuery.of(context).size.height),
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
    await Future.delayed(Duration(milliseconds: 3500));
    await HIVE_INIT.setupDatabaseStart();
    await HIVE_INIT.setupDatabase1();

    /// must use a heavier isolate implementation
    //compute((_) async {

    // put here or on login screen. here seems better for now.
    await HIVE_INIT.setupWaiters1();
    await HIVE_INIT.setupDatabase2();
    await HIVE_INIT.setupWaiters2();

    //}, null);

    await Future.delayed(Duration(milliseconds: 1));
    setState(() {
      shape = components.shape.topRoundedBorder8;
    });
    _fadeController.forward();
    await Future.delayed(Duration(milliseconds: 1000));
    //await Future.delayed(Duration(milliseconds: 1000));
    //_slideController.forward();
    //// hack to trigger animate Welcome
    //streams.app.loading.add(false);
    //streams.app.loading.add(true);
    //streams.app.loading.add(false);
    //await Future.delayed(Duration(milliseconds: 1000));
    //_fadeController.forward();
    //await Future.delayed(Duration(milliseconds: 1000));
    //setState(() {
    //  _slideController.reset();
    //  showAppBar = true;
    //});
    await redirectToCreateOrLogin();
    streams.app.splash.add(false);
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
      backgroundColor: AppColors.androidSystemBar,
      appBar: showAppBar
          ? BackdropAppBarContents(spoof: true, animate: false)
          : null,
      body:
          /**/
          Stack(
        alignment: Alignment.topCenter,
        children: [
          if (!showAppBar) BackdropAppBarContents(spoof: true),
          SlideTransition(
              position: _slideAnimation,
              child: AnimatedContainer(
                  duration: Duration(milliseconds: 1000),
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(borderRadius: shape, color: Colors.white),
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
        /**/
      ),
    );
  }

  Future redirectToCreateOrLogin() async {
    Future passwordFallback() async {
      services.authentication.setMethod(method: AuthMethod.password);
      Future.microtask(() => Navigator.pushReplacementNamed(
            context,
            '/security/createlogin',
          ));
    }

    // make a password out of biokey

    // this is false on 1st startup -> create
    if (!services.password.required) {
      if (pros.settings.authMethodIsBiometric) {
        final localAuthApi = LocalAuthApi();
        if (await localAuthApi.readyToAuthenticate) {
          await services.authentication.setPassword(
            password: await SecureStorage.biometricKey,
            salt: await SecureStorage.biometricKey,
          );
          Future.microtask(() => Navigator.pushReplacementNamed(
              context, getMethodPath(),
              arguments: {'needsConsent': true}));
        } else {
          passwordFallback();
        }
      } else {
        passwordFallback();
      }
    } else {
      if (services.password.interruptedPasswordChange()) {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                    title: Text('Issue detected'),
                    content: Text(
                        'Change Password process in progress, please submit your previous password...'),
                    actions: [
                      TextButton(
                          child: Text('ok'),
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, '/security/resume',
                              arguments: {}))
                    ]));
      } else {
        final id = await getId();
        bool hasConsented = false;
        try {
          hasConsented = await discoverConsent(id);
        } catch (e) {
          streams.app.snack.add(Snack(
            message: 'Unable to connect! Please check connectivity.',
          ));
        }
        Future.microtask(() => Navigator.pushReplacementNamed(
            context, getMethodPath(),
            arguments: {'needsConsent': !hasConsented}));

        /// testing out instant/custom page transitions
        /// https://stackoverflow.com/questions/52698340/animation-for-named-routes
        //    Navigator.of(components.navigator.routeContext!)
        //        .push(PageRouteBuilder(
        //  pageBuilder: (_, __, ___) => pages.routes(
        //          components.navigator.routeContext!)['/security/login']!(
        //      components.navigator.routeContext!),
        //  transitionsBuilder: (_, a, __, c) => c,
        //  transitionDuration: Duration(milliseconds: 0),
        //)));
      }
    }

    /// old: send to homescreen
    //} else {
    //Future.delayed(Duration(seconds: 60));
    //  Future.microtask(() =>
    //      Navigator.pushReplacementNamed(context, '/home', arguments: {}));

    /// testing out instant/custom page transitions
    //Navigator.of(components.navigator.routeContext!)
    //    .push(PageRouteBuilder(
    //  pageBuilder: (_, __, ___) =>
    //      pages.routes(components.navigator.routeContext!)['/home']!(
    //          components.navigator.routeContext!),
    //  transitionsBuilder: (_, a, __, c) =>
    //      FadeTransition(opacity: a, child: c),
    //  transitionDuration: Duration(milliseconds: 2000),
    //)));
    //}
  }
}
