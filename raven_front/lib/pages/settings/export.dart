import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/services/storage.dart';
import 'package:raven_front/utils/data.dart';
import 'package:raven_back/utils/hex.dart' as hex;
import 'package:convert/convert.dart' as convert;

class Export extends StatefulWidget {
  //final Storage storage;
  final dynamic data;
  const Export({this.data}) : super();

  @override
  _ExportState createState() => _ExportState();
}

class _ExportState extends State<Export> {
  final Backup storage = Backup();
  dynamic data = {};
  Account? account;
  File? file;
  List<Widget> getExisting = [];
  bool encryptExport = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    if (data['accountId'] == 'all') {
    } else if (data['accountId'] == 'current' || data['accountId'] == null) {
      account = Current.account;
    } else {
      account =
          accounts.primaryIndex.getOne(data['accountId']) ?? Current.account;
    }
    getExisting = [
      TextButton(
          onPressed: () async {
            await existingFiles;
            setState(() {});
          },
          child: Text('get'))
    ];
    return Scaffold(
      appBar: components.headers.back(context, 'Export'),
      body: body(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: exportButton,
    );
  }

  String get _accountName =>
      account != null ? 'Account: ' + account!.name : 'All Accounts';
  String get _accountId =>
      account != null ? account!.accountId : 'All Accounts';

  Future<File> _download() async => await storage.writeExport(
      filename: _accountId + '-' + DateTime.now().toString(),
      rawExport: services.password.required && encryptExport
          ? hex.encrypt(
              convert.hex.encode(
                  jsonEncode(services.wallet.export.structureForExport(account))
                      .codeUnits),
              services.cipher.currentCipher!)
          : jsonEncode(services.wallet.export.structureForExport(account)));

  Widget get exportButton => ElevatedButton.icon(
      icon: components.icons.export,
      onPressed: () async {
        file = await _download();
        setState(() {});
      },
      label: Text('Export ' + _accountName));

  // todo: fix visual of exported backups
  Future get existingFiles async {
    print(await storage.listDir());
    print([
      for (var f in (await storage.listDir()).whereType<File>())
        if (f.path.endsWith('.jason')) f.path
    ]);
    getExisting = [
      for (var f in (await storage.listDir()).whereType<File>()) Text(f.path)
    ];
  }

  Column body() => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ...[
              if (!services.password.required)
                TextButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/password/change'),
                    icon: Icon(Icons.warning),
                    label: Text(
                        'For added security, it is advised to set a password '
                        'before exporting. To set a password, just click here.'))
            ],

            /// we shouldn't give the option, because if users want to backup without encryption they can get the primary keys or seed phrases manually
            //...[
            //  if (services.password.required)
            //    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            //      Checkbox(
            //          value: encryptExport,
            //          onChanged: (_) => setState(() {
            //                encryptExport = !encryptExport;
            //              })),
            //      Text('Encrypt this backup')
            //    ])
            //],
            SizedBox(height: 25),
            ...[
              if (account != null && accounts.length > 1)
                TextButton.icon(
                    onPressed: () => setState(() {
                          data['accountId'] = 'all';
                          account = null;
                        }),
                    icon: Icon(Icons.help),
                    label: Text('Export ALL?'))
            ],
            SizedBox(height: 25),
            Center(
                child: Visibility(
                    visible: true,
                    child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: file == null
                            ? Text('')
                            : Center(
                                child: Column(children: [
                                Text('file saved to:'),
                                Text('${file?.path}'),
                                SizedBox(height: 25),
                                ElevatedButton.icon(
                                  onPressed: () => storage.share(file!.path),
                                  icon: Icon(Icons.share),
                                  label: Text('Share'),
                                ),
                              ]))))),
            //...(getExisting),
          ]);
}
