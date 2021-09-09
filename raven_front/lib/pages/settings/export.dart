import 'dart:io';

import 'package:flutter/material.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/services/lookup.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/utils/utils.dart';
import 'package:raven_mobile/utils/files.dart';

class Export extends StatefulWidget {
  final dynamic data;
  const Export({this.data}) : super();

  @override
  _ExportState createState() => _ExportState();
}

class _ExportState extends State<Export> {
  dynamic data = {};
  Account? account;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    if (data['accountId'] == 'all') {
    } else if (data['accountId'] == 'current') {
      account = Current.account;
    } else {
      account =
          accounts.primaryIndex.getOne(data['accountId']) ?? Current.account;
    }
    return Scaffold(appBar: header(), body: body());
  }

  String get _accountName =>
      account != null ? 'Account: ' + account!.name : 'All Accounts';
  String get _accountId => account != null ? account!.accountId : 'AllAccounts';

  AppBar header() => AppBar(
      leading: RavenButton.back(context),
      elevation: 2,
      centerTitle: false,
      title: Text('Export ' + _accountName));

  Future<File> _download() async => await writeToExport(
      filename: _accountId, json: structureForExport(account));

  Column body() => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
                child: TextButton.icon(
                    icon: RavenIcon.export,
                    onPressed: () => _download(),
                    label: Text('Export ' + _accountName))),
            Center(
                child: Visibility(
                    visible: true,
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                          'file saved to... (this should show up from listener when file is detected saved)...'),
                    )))
          ]);
}
