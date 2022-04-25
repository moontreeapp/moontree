import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_front/listeners/listeners.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(Duration(milliseconds: 4000));
    final loadingHelper = DataLoadingHelper(context);
    await loadingHelper.setupDatabase();
    loadingHelper.redirectToLoginOrHome();
    streams.app.splash.add(false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Lottie.asset('assets/splash/moontree_v2_001_recolored.json',
          animate: true,
          repeat: false,
          alignment: Alignment.center,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover),
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
      //await setupRealWallet('1');
      await setupRealWallet('2');
      //await setupRealWallet(null);
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
      }
    } else {
      //Future.delayed(Duration(seconds: 60));
      Future.microtask(() =>
          Navigator.pushReplacementNamed(context, '/home', arguments: {}));
    }
  }
}
