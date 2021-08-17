import 'package:flutter/material.dart';

import 'package:raven_mobile/components/pages/receive.dart' as receive;
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/styles.dart';

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
    return Scaffold(
        backgroundColor: RavenColor().background,
        appBar: receive.header(context),
        body: receive.body(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: receive.shareAddressButton(),
        bottomNavigationBar: RavenButton().bottomNav(context));
  }
}
