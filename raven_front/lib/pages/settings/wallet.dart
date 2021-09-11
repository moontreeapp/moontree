import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:raven_mobile/services/lookup.dart';
import 'package:raven_mobile/theme/extensions.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/utils/utils.dart';

class WalletView extends StatefulWidget {
  final dynamic data;
  const WalletView({this.data}) : super();

  @override
  _WalletViewState createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  dynamic data = {};
  bool showSecret = false;
  ToolbarOptions toolbarOptions =
      ToolbarOptions(copy: true, selectAll: true, cut: false, paste: false);

  @override
  void initState() {
    super.initState();
  }

  void _toggleShow() {
    setState(() {
      showSecret = !showSecret;
    });
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    return Scaffold(appBar: header(), body: body());
  }

  PreferredSize header() => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.14),
      child: AppBar(
          leading: RavenButton.back(context),
          elevation: 2,
          centerTitle: false,
          title: Text('Wallet'),
          flexibleSpace: Container(
            alignment: Alignment.center,
            child: Text(
                '\n\$ ${Current.walletBalanceUSD(data['address']).valueUSD}',
                style: Theme.of(context).textTheme.headline3),
          ),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(50.0),
              child: TabBar(tabs: [
                Tab(text: 'Details'),
                //#Tab(text: 'Holdings'),
                //Tab(text: 'Transactions')
              ]))));

  TabBarView body() => TabBarView(children: [
        ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(10.0),
            children: <Widget>[
              SizedBox(height: 30.0),
              Center(
                  child: Column(children: <Widget>[
                QrImage(
                    backgroundColor: Colors.white,
                    data: data['address'],
                    semanticsLabel: data['address'],
                    version: QrVersions.auto,
                    size: 200.0),
                SelectableText(data['address'],
                    cursorColor: Colors.grey[850],
                    showCursor: true,
                    style: Theme.of(context).mono,
                    toolbarOptions: toolbarOptions),
                Text('(address)', style: Theme.of(context).annotate),
              ])),
              SizedBox(height: 60.0),
              Text('Warning! Do Not Disclose!',
                  style: TextStyle(color: Theme.of(context).bad)),
              SizedBox(height: 15.0),
              Text(data['secretName'] + ':'),
              Center(
                  child: Visibility(
                      visible: showSecret,
                      child: SelectableText(
                        data['secret'],
                        cursorColor: Colors.grey[850],
                        showCursor: true,
                        style: Theme.of(context).mono,
                        toolbarOptions: toolbarOptions,
                      ))),
              SizedBox(height: 30.0),
              ElevatedButton(
                  onPressed: () => _toggleShow(),
                  child: Text(showSecret
                      ? 'Hide ' + data['secretName']
                      : 'Show ' + data['secretName']))
            ]),
        // holdings,
        // transactions
      ]);
}
