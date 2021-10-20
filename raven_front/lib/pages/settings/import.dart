import 'package:flutter/material.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/components/styles/buttons.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/services/lookup.dart';
import 'package:raven_mobile/utils/import.dart';
import 'package:raven_mobile/utils/utils.dart';

class Import extends StatefulWidget {
  final dynamic data;
  const Import({this.data}) : super();

  @override
  _ImportState createState() => _ImportState();
}

class _ImportState extends State<Import> {
  dynamic data = {};
  var words = TextEditingController();
  bool importEnabled = false;
  late Account account;
  String importFormatDetected = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    words.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    if (data['accountId'] == 'current' || data['accountId'] == null) {
      account = Current.account;
    } else {
      account =
          accounts.primaryIndex.getOne(data['accountId']) ?? Current.account;
    }
    return Scaffold(
      appBar: header(),
      body: body(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: importWaysButtons(context),
    );
  }

  AppBar header() => AppBar(
      leading: RavenButton.back(context),
      elevation: 2,
      centerTitle: false,
      title: Text('Import Wallet'));

  /// returns id of account the wallet is already assigned to
  //String? _walletFound(walletId) =>
  //    wallets.primaryIndex.getOne(walletId)?.accountId;

  Future alertSuccess() {
    /// verify by looking up public key first - (import from private key vs wif)
    /// verify we don't already have this wallet... that means create the wallet to compare, but don't save it yet,
    ///wallet = singleWalletGenerationService.newSingleWallet(
    ///    account: account, privateKey: walletSecret!, compressed: true);
    ///wallet = leaderWalletGenerationService.newLeaderWallet(account, seed: walletSecret);
    /// if (_walletFound(wallet.walletId) != null) {
    ///   // save
    ///   singleWalletGenerationService.saveSingleWallet(wallet);
    ///   leaderWalletGenerationService.saveLeaderWallet(wallet);
    ///   // alert sucess
    ///   return ...
    /// } else {
    ///   // alert existing
    ///   return ... already exists in the _walletFound(wallet.walletId) account
    /// }
    // should we await save?
    // how else to verify?
    //if (wallets.byAccount.getAll(account.accountId).map((e) => e.secret).contains(walletSecret)) {
    if (true) {
      return showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text('success!'),
                content: Text('wallet imported into account'),
                actions: [
                  TextButton(
                      child: Text('ok'),
                      onPressed: () => Navigator.pushNamed(context, '/home'))
                ],
              ));
    }
  }

  Future alertImported(String title, String msg) => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text(title),
            content: Text(msg),
            actions: [
              TextButton(
                  child: Text('ok'), onPressed: () => Navigator.pop(context))
            ],
          ));

  TextButton submitButton() {
    var label = 'Import into ' + account.name + ' account';
    if (importEnabled) {
      return TextButton.icon(
          onPressed: () => attemptImport(),
          icon: RavenIcon.import,
          label: Text(label,
              style: TextStyle(color: Theme.of(context).primaryColor)));
    }
    return TextButton.icon(
        onPressed: () {},
        icon: RavenIcon.importDisabled(context),
        label: Text(label,
            style: TextStyle(color: Theme.of(context).disabledColor)));
  }

  void enableImport() {
    var oldImportFormatDetected = importFormatDetected;
    var detection = services.wallet.import.detectImportType(words.text.trim());
    importEnabled = detection != null;
    if (importEnabled) {
      importFormatDetected =
          'format recognized as ' + detection.toString().split('.')[1];
    } else {
      importFormatDetected = '';
    }
    if (oldImportFormatDetected != importFormatDetected) {
      setState(() => {});
    }
  }

  Future attemptImport() async {
    var importFrom =
        ImportFrom(words.text.trim(), accountId: account.accountId);
    // todo replace with a legit spinner, and reduce amount of time it's waiting
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            title: Text('Importing...'),
            content:
                Text('Please wait, importing can take several seconds...')));
    // this is used to get the please wait message to show up
    // it needs enough time to display the message
    await Future.delayed(const Duration(milliseconds: 150));
    var success = await importFrom.handleImport();
    await alertImported(importFrom.importedTitle!, importFrom.importedMsg!);
    if (success) {
      Navigator.popUntil(context, ModalRoute.withName('/home'));
    } else {
      Navigator.of(context).pop();
    }
  }

  ListView body() {
    return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(20.0),
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextField(
                autocorrect: false,
                controller: words,
                keyboardType: TextInputType.multiline,
                maxLines: 12,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText:
                        'Please enter your seed words, WIF, or private key.'),
                onChanged: (value) => enableImport(),
                onEditingComplete: () async => await attemptImport(),
              ),
              submitButton(),
              Text(importFormatDetected),
            ],
          ),
        ]);
  }

  Row importWaysButtons(context) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton.icon(
            icon: Icon(Icons.qr_code_scanner),
            label: Text('Scan'),
            onPressed: () {
              //Navigator.push(
              //  context,
              //  MaterialPageRoute(builder: (context) => Receive()),
              //);
            },
            style: RavenButtonStyle.leftSideCurved),
        ElevatedButton.icon(
            icon: Icon(Icons.upload_file),
            label: Text('File'),
            onPressed: () {
              //Navigator.push(
              //  context,
              //  MaterialPageRoute(builder: (context) => Send()),
              //);
            },
            style: RavenButtonStyle.rightSideCurved(context))
      ]);
}
