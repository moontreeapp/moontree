import 'package:flutter/material.dart';

import 'package:raven_mobile/components/pages/settings/export.dart'
    as exportWallet;
import 'package:raven_mobile/styles.dart';

class Export extends StatefulWidget {
  final dynamic data;
  const Export({this.data}) : super();

  @override
  _ExportState createState() => _ExportState();
}

class _ExportState extends State<Export> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
        appBar: exportWallet.header(context), body: exportWallet.body());
  }
}
