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
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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
    var _controller = TextEditingController();
    return ListView(shrinkWrap: true, padding: EdgeInsets.all(20.0), children: <
        Widget>[
      Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _controller,
              maxLength: null,
              maxLines: null,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: ("Please enter your seed words, WIF, or anything "
                      "you've got. We will do our best to import your "
                      "wallet accordingly.")),
              //validator: (String? value) {
              //  //if (value == null || value.isEmpty) {
              //  //  return 'Please enter a valid address';
              //  //}
              //  //return null;
              //},
            ),
            TextButton.icon(
                onPressed: () {},
                icon: RavenIcon.import,
                label: Text('Import into ' + Current.account.name + ' account'))
          ],
        ),
      )
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
