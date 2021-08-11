import 'package:flutter/material.dart';

import 'package:raven_mobile/components/receive.dart' as receive;
import 'package:raven_mobile/components/all.dart' as all;

class Receive extends StatefulWidget {
  final dynamic data;
  const Receive({this.data}) : super();

  @override
  _ReceiveState createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    Color? bgColor = Colors.blueAccent[50];
    return Scaffold(
        backgroundColor: bgColor,
        appBar: receive.header(context),
        body: receive.body(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: receive.shareAddressButton(),
        bottomNavigationBar: all.walletTradingButtons());
  }
}
