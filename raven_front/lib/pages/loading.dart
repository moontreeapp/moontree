import 'dart:math';

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
    await services.account.createSave('Primary');
    await services.account.createSave('Savings');
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

  /// Generates a positive random integer uniformly distributed on the range
  /// from [min], inclusive, to [max], exclusive.
  //int next(int min, int max) => min + _random.nextInt(max - min);

  @override
  Widget build(BuildContext context) {
    final _random = new Random();
    var randomSpinner = [
      '2dTremble',
      'clockwiseSpin',
      '180Spin',
      '360Spin',
      //'blink',
      //'blur',
      'frontFlip',
      'glitch',
      'hueRotate',
      //'pixelRain',
      'squishy',
    ];
    var randomSplash = [
      'liquid',
      'rotate',
      'rotateBlue',
    ];

    // todo: make a gif converting the old logo to the new?
    return Scaffold(
        body: Center(
            child: Image(image: AssetImage("assets/splash/liquid.gif"))));
    //Image(
    //    image:
    //    AssetImage(
    //        "assets/splash/${randomSplash[_random.nextInt(randomSplash.length)]}.gif"))));
    //Image(
    //image: AssetImage(
    //    'assets/spinners/${randomSpinner[_random.nextInt(randomSpinner.length)]}.gif'))));
    //Image(image: AssetImage("assets/splash/rotate.gif"))));
    //SpinKitThreeBounce(color: Colors.black, size: 50.0)));
  }
}
