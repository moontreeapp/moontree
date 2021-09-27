import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:raven/raven.dart';
import 'package:raven_mobile/services/history_mock.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Future setupAccounts() async {
    await services.passwords.create.save('asdf');
    cipherRegistry.updatePassword(altPassword: 'asdf');
    await services.accounts.makeSaveAccount('Primary');
    await services.accounts.makeSaveAccount('Savings');
  }

  Future setup() async {
    var hiveInit = HiveInitializer(init: (dbDir) => Hive.initFlutter());
    await hiveInit.setUp();
    await initWaiters();
    // seems to trigger stream listener to work
    //print(await ravenClientSubject.stream.last);

    if (accounts.data.isEmpty) {
      MockHistories().init();
      await setupAccounts();
    }
    settings.setCurrentAccountId();
    print('accounts: ${accounts.data}');
    print('wallets: ${wallets.data}');
    print('passwords: ${passwords.data}');
    print('addresses: ${addresses.data}');
    print('histories: ${histories.data}');
    print('balances: ${balances.data}');
    print('rates: ${rates.data}');
    print('settings: ${settings.data}');
    print('cipherRegistry: $cipherRegistry');

    if (services.passwords.passwordRequired) {
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
