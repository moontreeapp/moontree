import 'package:flutter/material.dart';

import 'package:raven_mobile/components/settings/import.dart' as importWallet;

class Import extends StatefulWidget {
  final dynamic data;
  const Import({this.data}) : super();

  @override
  _ImportState createState() => _ImportState();
}

class _ImportState extends State<Import> {
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
      appBar: importWallet.header(context),
      body: importWallet.body(formKey),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: importWallet.importWaysButtons(context),
    );
  }
}
