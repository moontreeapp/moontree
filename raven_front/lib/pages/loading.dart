import 'package:flutter/material.dart';
import '../services/account_mock.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void setupAccounts() async {
    await Accounts.instance.load();
    Navigator.pushReplacementNamed(context, '/home', arguments: {
      'account': Accounts.instance.accounts['accountId1'],
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
        backgroundColor: Colors.blue[900],
        body: Center(
            child: SpinKitThreeBounce(
          color: Colors.white,
          size: 50.0,
        )));
  }
}
