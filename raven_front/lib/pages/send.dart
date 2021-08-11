import 'package:flutter/material.dart';

import 'package:raven_mobile/components/send.dart' as send;
import 'package:raven_mobile/components/all.dart' as all;

class Send extends StatefulWidget {
  final dynamic data;
  const Send({this.data}) : super();

  @override
  _SendState createState() => _SendState();
}

class _SendState extends State<Send> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    Color? bgColor = Colors.blueAccent[50];
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return Scaffold(
        backgroundColor: bgColor,
        appBar: send.header(context),
        body: send.body(formKey),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: send.sendTransactionButton(formKey),
        bottomNavigationBar: all.walletTradingButtons());
  }
}
