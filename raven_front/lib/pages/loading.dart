import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_front/listeners/listeners.dart';
import 'package:raven_front/services/storage.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Future setupAccounts() async {
    await services.account.createSave('Account 1', net: Net.Test);
    await services.account.createSave('Account 2', net: Net.Main);
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
    //for (var transaction in transactions.data) {
    //  print(transaction);
    //}
    //var tx = transactions.primaryIndex.getOne(
    //    'b13feb18ae0b66f47e1606230b0a70de7d40ab52fbfc5626488136fbaa668b34')!;
    //print(tx);
    //print(tx.vins);
    //print(tx.vouts);
    //print(tx.vins.map((vin) => vin.vout?.rvnValue ?? 0).toList().sumInt());
    //print(tx.vins.map((vin) => vin.vout?.assetValue ?? 0).toList().sumInt());
    //print(tx.vouts.map((vout) => vout.rvnValue).toList().sumInt());
    //print(tx.vouts.map((vout) => vout.assetValue).toList().sumInt());
    //print(tx.vins.map((vin) => vin.vout?.rvnValue ?? 0).toList().sumInt() -
    //    tx.vouts.map((vout) => vout.rvnValue).toList().sumInt());
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
        //Image(image: AssetImage("assets/rvn.png")),
        Image(image: AssetImage("assets/splash/fast.gif")),
        Center(
          child: Text('Loading...'),
        )
      ],
    )));
  }
}
