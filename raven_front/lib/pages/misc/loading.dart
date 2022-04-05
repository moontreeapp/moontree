import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_front/listeners/listeners.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with TickerProviderStateMixin {
  Future setupDatabase() async {
    var hiveInit =
        HiveInitializer(init: (dbDir) => Hive.initFlutter(), beforeLoad: () {});
    await hiveInit.setUp();
    await initWaiters();
    initListeners();
    //await res.settings.save(
    //    Setting(name: SettingName.Local_Path, value: await Storage().localPath));
    setupWallets();
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
    for (var wallet in res.wallets) {
      print(wallet);
    }
    print('-------------------------');
    redirectToLoginOrHome();
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

  @override
  void initState() {
    super.initState();
    setupDatabase();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Loading probably doesn't make sense as a page.
  // It is more of a background process - move the above computation to
  // somewhere else.
  @override
  Widget build(BuildContext context) {
    return Container();
    //BackdropLayers(
    //    back: BlankBack(),
    //    front: FrontCurve(
    //        child: Image(image: AssetImage("assets/splash/fast.gif"))));
  }
}
