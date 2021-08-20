import 'package:flutter/material.dart';
import '../services/account_mock.dart' as mock;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Future setup() async {
    //await Directory('database').delete(recursive: true);
    //await Truth.instance.open(); // causes uninitialized error
    //await Accounts.instance.load();
  }

  void setupAccounts() async {
    setup();
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
    setupAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
            Center(child: SpinKitThreeBounce(color: Colors.white, size: 50.0)));
  }
}
