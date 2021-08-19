import 'package:flutter/material.dart';

import 'package:raven_mobile/components/pages/transaction.dart' as transaction;
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/styles.dart';

class Transaction extends StatefulWidget {
  final dynamic data;
  const Transaction({this.data}) : super();

  @override
  _TransactionState createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
        appBar: transaction.header(context),
        body: transaction.body(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: RavenButton().bottomNav(context));
  }
}
