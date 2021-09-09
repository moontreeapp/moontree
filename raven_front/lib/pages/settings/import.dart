import 'package:flutter/material.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/components/styles/buttons.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/services/lookup.dart';

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
    //data = populateData(context, data);
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

  // returns string of account the wallet is already assigned to
  //String? _walletFound(walletId) => wallet.primaryIndex.getOne(walletId)?.accountId;

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
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: ("Please enter your seed words, WIF, or anything "
                        "you've got. We will do our best to import your "
                        "wallet accordingly.")),
                onEditingComplete: () {
                  var text = words.text;

                  /// these are placeholders, they must be checked
                  var isWIF = [51, 52].contains(text.split(' ').length);
                  var isSeed = text.length == 128;
                  var isMnemonic = [12, 24].contains(text.split(' ').length);
                  var isPrivateKey = text.length == 64;
                  if (isWIF || isSeed || isMnemonic || isPrivateKey) {
                    importEnabled = true;
                  }
                },
              ),
              TextButton.icon(
                  onPressed: () {},
                  icon: RavenIcon.import,
                  label: Text(
                    'Import into ' + Current.account.name + ' account',
                    style: TextStyle(
                        color: importEnabled
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor),
                  ))
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
