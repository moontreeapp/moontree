import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:raven/raven.dart';
import 'package:raven/services/wallet/constants.dart';
import 'package:raven_mobile/services/history_mock.dart';
import 'package:raven_mobile/services/password_mock.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Future setupAccounts() async {
    await services.account.createSave('Primary');
    //await services.account.createSave('Savings');
  }

  Future setupRealWallet() async {
    await dotenv.load(fileName: '.env');
    var mnemonic = dotenv.env['TEST_WALLET_02']!;
    await services.wallet.createSave(
        walletType: WalletType.leader,
        accountId: '0',
        cipherUpdate: defaultCipherUpdate,
        secret: mnemonic);
  }

  Future setup() async {
    var hiveInit = HiveInitializer(init: (dbDir) => Hive.initFlutter());
    await hiveInit.setUp();
    await initWaiters();
    if (accounts.data.isEmpty) {
      /// for testing
      //MockHistories().init();
      //mockPassword();

      await setupAccounts();
      await setupRealWallet();
    }
    settings.setCurrentAccountId();

    // for testing
    print('accounts: ${accounts.data}');
    print('wallets: ${wallets.data}');
    print('passwords: ${passwords.data}');
    print('addresses: ${addresses.data}');
    print('transactions: ${transactions.data}');
    print('vins: ${vins.data}');
    print('vouts: ${vouts.data}');
    print('securities: ${securities.data}');
    print('balances: ${balances.data}');
    print('rates: ${rates.data}');
    print('settings: ${settings.data}');
    print('blocks: ${blocks.data}');
    print('ciphers: ${ciphers.data}');

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
                              context, '/password/resume',
                              arguments: {}))
                    ]));
      } else {
        Future.microtask(() =>
            Navigator.pushReplacementNamed(context, '/login', arguments: {}));
      }
    } else {
      Future.microtask(() =>
          Navigator.pushReplacementNamed(context, '/home', arguments: {}));
    }
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    // todo: make a gif converting the old logo to the
    return Scaffold(
        body: Center(
            //child: Image(image: AssetImage("assets/splash/liquid.gif"))));
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image(image: AssetImage("assets/rvn.png")),
        Center(
          child: Text('Loading...'),
        )
      ],
    )));
  }
}
