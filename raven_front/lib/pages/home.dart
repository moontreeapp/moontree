import 'package:flutter/material.dart';

import 'package:raven_mobile/components/home.dart' as home;
import 'package:raven_mobile/components/all.dart' as all;

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
            appBar: home.balanceHeader(context, data),
            drawer: home.accountsView(context, data),
            body: home.holdingsTransactionsView(data),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: home.sendReceiveButtons(context),
            bottomNavigationBar: all.walletTradingButtons()));
  }
}
