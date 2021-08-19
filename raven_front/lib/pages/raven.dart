import 'package:flutter/material.dart';

import 'package:raven_mobile/components/pages/raven.dart' as raven;
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/styles.dart';
import 'package:raven_mobile/services/account_mock.dart' as mock;

class RavenTransactions extends StatefulWidget {
  @override
  _RavenTransactionsState createState() => _RavenTransactionsState();
}

class _RavenTransactionsState extends State<RavenTransactions> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //data = data.isNotEmpty ??
    //    data ??
    //    ModalRoute.of(context)!.settings.arguments ??
    data = {
      'account': 'accountId2',
      'accounts': mock.Accounts.instance.accounts,
      'transactions': mock.Accounts.instance.transactions,
      'holdings': mock.Accounts.instance.holdings,
    };
    return Scaffold(
        appBar: raven.header(context),
        body: raven.transactionsView(context, data),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: raven.sendReceiveButtons(context),
        bottomNavigationBar: RavenButton().bottomNav(context));
  }
}
