import 'dart:typed_data';

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

  TextButton submitButton() {
    var submitMessage = 'Import into ' + account.name + ' account';
    if (importEnabled) {
      return TextButton.icon(
          onPressed: () => alertSuccess(),
          icon: RavenIcon.import,
          label: Text(submitMessage,
              style: TextStyle(color: Theme.of(context).primaryColor)));
    }
    return TextButton.icon(
        onPressed: () {},
        icon: RavenIcon.importDisabled(context),
        label: Text(submitMessage,
            style: TextStyle(color: Theme.of(context).disabledColor)));
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
                        ("Please enter your seed words, WIF, or private key.")),
                onEditingComplete: () async {
                  words.text = words.text.trim();
                  var formatSeed =
                      await handleImport(words.text, Current.account.accountId);
                  //if (isWIF || isSeed || isMnemonic || isPrivateKey) {
                  if (['WIF', 'seed', 'mnumonic', 'privateKey']
                      .contains(formatSeed.format)) {
                    importEnabled = true; // import already happened
                  }
                  // create the wallet with formatSeed.seed in the correct account
                  setState(() => {});
                },
              ),
              submitButton(),
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
