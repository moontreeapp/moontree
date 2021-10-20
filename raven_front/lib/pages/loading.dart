import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
    await services.accounts.createSave('Primary');
    await services.accounts.createSave('Savings');
  }

  Future setupRealWallet() async {
    await dotenv.load(fileName: '.env');
    var mnemonic = dotenv.env['TEST_WALLET_02']!;
    await services.wallets.createSave(
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
    print('cipherRegistry: $cipherRegistry');

    if (services.passwords.required) {
      if (services.passwords.interruptedPasswordChange()) {
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
    return Scaffold(
        body:
            Center(child: SpinKitThreeBounce(color: Colors.black, size: 50.0)));
  }
}
