import 'dart:io';
import 'package:flutter/material.dart';
import '../services/account_mock.dart' as mock;
import 'package:flutter_spinkit/flutter_spinkit.dart';
//import 'package:raven/accounts.dart';
//import 'package:raven/boxes.dart';

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
      //'account': Accounts
      //    .instance.accounts[Accounts.instance.accounts.keys.toList()[0]],
      'account': mock.Accounts.instance.accounts['accountId1'],
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
