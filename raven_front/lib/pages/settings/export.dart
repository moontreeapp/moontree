import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/components.dart';
import 'package:raven_mobile/services/lookup.dart';
import 'package:raven_mobile/services/storage.dart';
import 'package:raven_mobile/utils/utils.dart';
import 'package:raven/utils/hex.dart' as hex;
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
      appBar: components.headers.back(context, 'Export (Backup)'),
      body: body(),
    );
  }

  String get _accountName =>
      account != null ? 'Account: ' + account!.name : 'All Accounts';
  String get _accountId =>
      account != null ? account!.accountId : 'All Accounts';

  //Future<File> _download() async => await writeToExport(
  //    filename: _accountId + '-' + DateTime.now().toString(),
  //    json: services.wallet.export.structureForExport(account));

  Future<File> _download() async => await storage.writeExport(
      filename: _accountId + '-' + DateTime.now().toString(),
      rawExport: services.password.required && encryptExport
          ? hex.encrypt(
              convert.hex.encode(
                  jsonEncode(services.wallet.export.structureForExport(account))
                      .codeUnits),
              services.cipher.currentCipher!)
          : jsonEncode(services.wallet.export.structureForExport(account)));

  // todo: fix visual of exported backups, add behavior for each like share
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
            ...[
              if (services.password.required)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Checkbox(
                      value: encryptExport,
                      onChanged: (_) => setState(() {
                            encryptExport = !encryptExport;
                          })),
                  Text('Encrypt this backup')
                ])
            ],
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
                child: TextButton.icon(
                    icon: components.icons.export,
                    onPressed: () async {
                      file = await _download();
                      //print(await storage.readExport(file: file));
                      setState(() {});
                    },
                    label: Text('Export ' + _accountName))),
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
                                TextButton(
                                  onPressed: () => storage.share(file!.path),
                                  child: Text('Share'),
                                ),
                              ]))))),
            //...(getExisting),
          ]);
}
