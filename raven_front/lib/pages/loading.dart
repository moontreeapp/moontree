import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:raven/raven.dart';
import 'package:raven_mobile/services/history_mock.dart';
import 'package:raven_mobile/services/password_mock.dart';
import 'package:dotenv/dotenv.dart' as dotenv;

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
    //dotenv.load('../../.env');
    //var mnemonic = dotenv.env['TEST_WALLET_01']!;
    //var mnemonic =
    //    'animal twin echo jaguar sibling man common answer dolphin sign nice evolve';
    var mnemonic =
        'board leisure impose bleak race egg abuse series seat achieve fan column';

    // recieve address mvP3CarfuewpjBDMPZvabFqY7LxHtpdjZT ???
    // https://rvnt.cryptoscope.io/tx/?txid=84ab4db04a5d32fc81025db3944e6534c4c201fcc93749da6d1e5ecf98355533
    // I thought it was supposed to be musihnwMWXSwnARhYLVdmibY1GaJkEqhim
    // are we deriving the address differently now? maybe...
    // real: mjtDhzjgoQfp63ocbp1jZxZeFosQ3KnH5S
    print(mnemonic);
    await services.wallets.createSave(
        humanTypeKey: LingoKey.leaderWalletType,
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
    print('histories: ${histories.data}');
    print('balances: ${balances.data}');
    print('rates: ${rates.data}');
    print('settings: ${settings.data}');
    print('cipherRegistry: $cipherRegistry');
    for (var add in wallets.byAccount.getAll('0')[1].addresses) {
      print(add.address);
      print(add.exposure);
    }

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
