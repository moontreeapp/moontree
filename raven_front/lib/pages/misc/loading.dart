import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_front/listeners/listeners.dart';
import 'package:raven_front/services/identicon.dart';
import 'package:raven_front/services/storage.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with TickerProviderStateMixin {
  Future setupAccounts() async {
    await services.account.createSave('Primary', net: Net.Test);
    //await services.account.createSave('Hodl', net: Net.Main);
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
    var hiveInit = HiveInitializer(
        init: (dbDir) => Hive.initFlutter(),
        beforeLoad: () {
          accountWaiter.init();
        });
    await hiveInit.setUp();
    await initWaiters();
    initListeners();
    await settings.save(Setting(
        name: SettingName.Local_Path, value: await Storage().localPath));
    if (accounts.data.isEmpty) {
      await setupAccounts();
      await setupRealWallet();
    }
    settings.setCurrentAccountId();

    // for testing
    print('-------------------------');
    print('accounts: ${accounts.data}');
    print('addresses: ${addresses.data}');
    print('assets: ${assets.data}');
    print('balances: ${balances.data}');
    print('blocks: ${blocks.data}');
    print('ciphers: ${ciphers.data}');
    print('metadata: ${metadatas.data}');
    print('passwords: ${passwords.data}');
    print('rates: ${rates.data}');
    print('securities: ${securities.data}');
    print('settings: ${settings.data}');
    print('transactions: ${transactions.data}');
    print('vins: ${vins.data}');
    print('vouts: ${vouts.data}');
    print('wallets: ${wallets.data}');
    print('-------------------------');
    print(services.cipher.getPassword(altPassword: ''));
    print('-------------------------');

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
    setup();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // todo: make a gif converting the old logo to the
    return Scaffold(
        body: Center(
            //child: Image(image: AssetImage("assets/splash/liquid.gif"))));
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //Image(image: AssetImage("assets/rvn.png")),
        Image(image: AssetImage("assets/splash/fast.gif")),
        Text('Loading...'),
      ],
    )));
  }
}
