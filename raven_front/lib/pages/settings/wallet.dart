import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
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

  AppBar header() => AppBar(
      leading: RavenButton.back(context),
      elevation: 2,
      centerTitle: false,
      title: Text('Wallet View'));

  ListView body() => ListView(
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
              Text('(address)', style: Theme.of(context).annotate),
            ])),
            SizedBox(height: 30.0),
            Text('Address:'),
            Center(
                child: SelectableText(data['address'],
                    cursorColor: Colors.grey[850],
                    showCursor: true,
                    style: Theme.of(context).mono,
                    toolbarOptions: toolbarOptions)),
            SizedBox(height: 30.0),
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
          ]);
}
