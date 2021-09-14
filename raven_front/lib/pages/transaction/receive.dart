import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/components/styles/buttons.dart';
import 'package:raven_mobile/services/lookup.dart';
import 'package:raven_mobile/utils/utils.dart';

class Receive extends StatefulWidget {
  final dynamic data;
  const Receive({this.data}) : super();

  @override
  _ReceiveState createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> {
  Map<String, dynamic> data = {};
  late String address;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    address = Current.account.wallets[0].addresses[0].address;
    return Scaffold(
        appBar: header(),
        body: body(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: shareAddressButton(),
        bottomNavigationBar: RavenButton.bottomNav(context));
  }

  AppBar header() => AppBar(
        leading: RavenButton.back(context),
        elevation: 2,
        centerTitle: false,
        title: Text(
          //(data['accounts'][data['account']] ?? 'Unknown') + ' Wallet',
          'Address',
        ),
      );

  ListView body() => ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(10.0),
          children: <Widget>[
            SizedBox(height: 15.0),
            Text(
                // rvn is default but if balance is 0 then take the largest asset balance and also display name here.
                'RVN',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1),
            SizedBox(height: 30.0),
            Center(
                child: QrImage(
                    backgroundColor: Colors.white,
                    data: 'raven:$address',
                    version: QrVersions.auto,
                    size: 200.0)),
            SizedBox(height: 60.0),
            Center(
                child: SelectableText(
              address,
              cursorColor: Colors.grey[850],
              showCursor: true,
              toolbarOptions: ToolbarOptions(
                  copy: true, selectAll: true, cut: false, paste: false),
            ))
          ]);

  ElevatedButton shareAddressButton() => ElevatedButton.icon(
      icon: Icon(Icons.share),
      label: Text('Share'),
      onPressed: () {},
      style: RavenButtonStyle.curvedSides);
}
