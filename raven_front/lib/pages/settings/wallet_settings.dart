import 'package:flutter/material.dart';

import 'package:raven_mobile/components/settings/wallet_settings.dart'
    as walletSettings;

class WalletSettings extends StatefulWidget {
  final dynamic data;
  const WalletSettings({this.data}) : super();

  @override
  _WalletSettingsState createState() => _WalletSettingsState();
}

class _WalletSettingsState extends State<WalletSettings> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    Color? bgColor = Colors.blueAccent[50];
    return Scaffold(
        backgroundColor: bgColor,
        appBar: walletSettings.header(context),
        body: walletSettings.body(context));
  }
}
