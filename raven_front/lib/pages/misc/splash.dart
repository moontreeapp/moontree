import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/wallet/constants.dart';

import '../../listeners/listeners.dart';

/// This works by creating an AnimationController instance and passing it
/// to the Lottie widget.
/// The AnimationController class has a rich API to run the animation in various ways.
class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  BuildContext? givenContext;

  @override
  void initState() {
    super.initState();
    _init();
    // _controller = AnimationController(vsync: this)
    //   ..value = 0
    //   ..addListener(() {
    //     if (_controller.value == 1) {
    //       streams.app.splash.add(false);
    //       Future.microtask(() => Navigator.pushReplacementNamed(
    //           context, '/loading',
    //           arguments: {}));
    //     } else {
    //       setState(() {
    //         // Rebuild the widget at each frame to update the "progress" label.
    //       });
    //     }
    //   });
    //Navigator.pushReplacementNamed(components.navigator.routeContext!, '/home');
  }

  DateTime startTime = DateTime.now();
  Future<void> _init() async {
    startTime = DateTime.now();
    await Future.delayed(Duration(milliseconds: 4000));
    final loadingHelper = DataLoadingHelper(context);

    await loadingHelper.setupDatabase();
    final totalMsTaken = DateTime.now().difference(startTime).inMilliseconds;
    final remainingMs = 7000 - totalMsTaken;
    final totalDelayTime = remainingMs > 0 ? remainingMs : 0;

    await Future.delayed(Duration(milliseconds: totalDelayTime));
    loadingHelper.redirectToLoginOrHome();
    streams.app.splash.add(false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    givenContext = context;
    return Scaffold(
      body: Lottie.asset(
        'assets/splash/moontree_v2_001.json',
        animate: true,
        repeat: false,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.fitWidth,
      ),
      backgroundColor: Colors.white,
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
      await setupRealWallet('2');
      await res.settings.setCurrentWalletId(res.wallets.first.id);
      await res.settings.savePreferredWalletId(res.wallets.first.id);
      //setupRealWallet('1');
      //setupRealWallet(null);
    }

    // for testing
    print('-------------------------');
    print('addresses: ${res.addresses.length}');
    print('assets: ${res.assets.length}');
    print('balances: ${res.balances.length}');
    print('blocks: ${res.blocks}');
    print('ciphers: ${res.ciphers}');
    print('metadata: ${res.metadatas.length}');
    print('passwords: ${res.passwords}');
    print('rates: ${res.rates}');
    print('securities: ${res.securities.length}');
    print('settings: ${res.settings.length}');
    print('transactions: ${res.transactions.length}');
    print('vins: ${res.vins.length}');
    print('vouts: ${res.vouts.length}');
    print('wallets: ${res.wallets}');
    print('-------------------------');
    //print(services.cipher.getPassword(altPassword: ''));
    print('-------------------------');
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
      }
    } else {
      //Future.delayed(Duration(seconds: 60));
      Future.microtask(() =>
          Navigator.pushReplacementNamed(context, '/home', arguments: {}));
    }
  }
}
