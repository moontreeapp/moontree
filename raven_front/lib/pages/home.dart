import 'package:flutter/material.dart';

import 'package:raven_mobile/components/pages/home.dart' as home;
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/styles.dart';

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
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            backgroundColor: RavenColor().background,
            appBar: home.balanceHeader(context, data),
            drawer: home.accountsView(context, data),
            body: home.holdingsTransactionsView(data),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: home.sendReceiveButtons(context),
            bottomNavigationBar: RavenButton().bottomNav(context)));
  }
}
