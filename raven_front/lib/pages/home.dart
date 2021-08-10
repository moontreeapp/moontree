import 'package:flutter/material.dart';

import 'package:raven_mobile/components/stateful.dart' as stateful;
import 'package:raven_mobile/components/stateless.dart' as stateless;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;

    Color? bgColor = Colors.blueAccent[50];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: stateful.balanceHeader(context, data),
        body: stateful.holdingsTransactionsView(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: stateless.sendReceiveButtons(),
        bottomNavigationBar: stateless.walletTradingButtons(),
      ),
    );
  }
}
