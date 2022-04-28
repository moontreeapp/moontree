import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/listeners/listeners.dart';
import 'package:raven_front/widgets/backdrop/backdrop.dart';
import 'package:raven_front/pages/pages.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  BorderRadius? shape;
  bool showAppBar = true;

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
    curve: Curves.decelerate,
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
    await Future.delayed(Duration(milliseconds: 4000));
    setState(() {
      print('setting state');
      shape = BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      );
    });
    await Future.delayed(Duration(milliseconds: 1000));
    _slideController.forward();
    // hack to trigger animate Welcome
    streams.app.loading.add(false);
    streams.app.loading.add(true);
    streams.app.loading.add(false);
    await Future.delayed(Duration(milliseconds: 1000));
    _fadeController.forward();
    await Future.delayed(Duration(milliseconds: 1000));
    final loadingHelper = DataLoadingHelper(context);
    setState(() {
      showAppBar = false;
    });
    await loadingHelper.setupDatabase();
    streams.app.splash.add(false);
    loadingHelper.redirectToLoginOrHome();
    //await Future.delayed(Duration(milliseconds: 1));
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
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (showAppBar) BackdropAppBarContents(spoof: true),
          SlideTransition(
              position: _slideAnimation,
              child: AnimatedContainer(
                  duration: Duration(seconds: 1),
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(borderRadius: shape, color: Colors.white),
                  child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Lottie.asset(
                          'assets/splash/moontree_v2_001_recolored.json',
                          animate: true,
                          repeat: false,
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover))))
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}

class DataLoadingHelper {
  const DataLoadingHelper(this.context);
  final BuildContext context;
  Future setupDatabase() async {
    var hiveInit =
        HiveInitializer(init: (dbDir) => Hive.initFlutter(), beforeLoad: () {});
    await hiveInit.setUp();
    await initWaiters();
    unawaited(waiters.app.logoutThread());
    initListeners();
    //await res.settings.save(
    //    Setting(name: SettingName.Local_Path, value: await Storage().localPath));
    await setupWallets();
  }

  Future setupRealWallet(String? id) async {
    await dotenv.load(fileName: '.env');
    var mnemonic = id == null ? null : dotenv.env['TEST_WALLET_0$id']!;
    await services.wallet.createSave(
        walletType: WalletType.leader,
        cipherUpdate: defaultCipherUpdate,
        secret: mnemonic);
  }

  Future setupWallets() async {
    if (res.wallets.data.isEmpty) {
      //await setupRealWallet('1');
      //await setupRealWallet('2');
      await setupRealWallet(null);
      await res.settings.setCurrentWalletId(res.wallets.first.id);
      await res.settings.savePreferredWalletId(res.wallets.first.id);
    }

    // for testing
    //print('-------------------------');
    //print('addresses: ${res.addresses.length}');
    //print('assets: ${res.assets.length}');
    //print('balances: ${res.balances.length}');
    //print('blocks: ${res.blocks}');
    //print('ciphers: ${res.ciphers}');
    //print('metadata: ${res.metadatas.length}');
    //print('passwords: ${res.passwords}');
    //print('rates: ${res.rates}');
    //print('securities: ${res.securities.length}');
    //print('settings: ${res.settings.length}');
    //print('transactions: ${res.transactions.length}');
    //print('vins: ${res.vins.length}');
    //print('vouts: ${res.vouts.length}');
    //print('wallets: ${res.wallets}');
    //print('-------------------------');
    ////print(services.cipher.getPassword(altPassword: ''));
    //print('-------------------------');
  }

  Future redirectToLoginOrHome() async {
    if (services.password.required) {
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
        Future.microtask(() => Navigator.pushReplacementNamed(
            context, '/security/login',
            arguments: {}));

        /// testing out instant/custom page transitions
        //    Navigator.of(components.navigator.routeContext!)
        //        .push(PageRouteBuilder(
        //  pageBuilder: (_, __, ___) => pages.routes(
        //          components.navigator.routeContext!)['/security/login']!(
        //      components.navigator.routeContext!),
        //  transitionsBuilder: (_, a, __, c) => c,
        //  transitionDuration: Duration(milliseconds: 0),
        //)));
      }
    } else {
      //Future.delayed(Duration(seconds: 60));
      Future.microtask(() =>
          Navigator.pushReplacementNamed(context, '/home', arguments: {}));

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
    }
  }
}
