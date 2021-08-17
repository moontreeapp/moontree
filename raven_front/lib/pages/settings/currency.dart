import 'package:flutter/material.dart';

import 'package:raven_mobile/components/pages/settings/currency.dart'
    as currency;
import 'package:raven_mobile/styles.dart';

class Currency extends StatefulWidget {
  final dynamic data;
  const Currency({this.data}) : super();

  @override
  _CurrencyState createState() => _CurrencyState();
}

class _CurrencyState extends State<Currency> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
        backgroundColor: RavenColor().background,
        appBar: currency.header(context),
        body: currency.body(context));
  }
}
