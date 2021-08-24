import 'dart:io';

import 'package:flutter/material.dart';
import '../services/account_mock.dart' as mock;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:raven/init/services.dart';
import 'package:raven/init/reservoirs.dart' as res;

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void setup() async {
    print('accounts: ${res.accounts.data}');
    print('wallets: ${res.wallets.data}');
    // (flutter) if no accounts -> create account, set default account setting
    if (res.accounts.data.isEmpty) {
      // create one
      var account = accountGenerationService.makeAndSaveAccount('Primary');
      print(account);
      // set its id as settings default account id
      //sett.settings.add({'default Account': account.id});
    }
    //res.accounts.changes.listen((changes) {
    //  build(context);
    //}); // //sett
    print('accounts: ${res.accounts.data}');
    print('wallets: ${res.wallets.data}');
    await mock.Accounts.instance.load();
    Navigator.pushReplacementNamed(context, '/home', arguments: {
      'account': 'accountId1',
      'accounts': mock.Accounts.instance.accounts,
      'transactions': mock.Accounts.instance.transactions,
      'holdings': mock.Accounts.instance.holdings,
    });
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
            Center(child: SpinKitThreeBounce(color: Colors.white, size: 50.0)));
  }
}
