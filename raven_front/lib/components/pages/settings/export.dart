import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:raven_mobile/styles.dart';
import 'package:raven_mobile/components/buttons.dart';

AppBar header(context) {
  return AppBar(
    backgroundColor: RavenColor().appBar,
    leading: RavenButton().back(context),
    elevation: 2,
    centerTitle: false,
    title: Text('Export Wallet', style: RavenTextStyle().h2),
  );
}

ListView body() {
  return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.all(10.0),
      children: <Widget>[
        SizedBox(height: 30.0),
        Center(
            child: QrImage(
                data:
                    "apple cost speed dip wallet toast jump water average need clip run",
                version: QrVersions.auto,
                size: 200.0)),
        SizedBox(height: 30.0),
        Center(
            child: SelectableText('Warning! Do Not Disclose!',
                cursorColor: Colors.grey[850],
                showCursor: true,
                toolbarOptions: ToolbarOptions(
                    copy: true, selectAll: true, cut: false, paste: false),
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold))),
        SizedBox(height: 30.0),
        Center(
            child: SelectableText(
                'apple cost speed dip wallet toast jump water average need clip run',
                cursorColor: Colors.grey[850],
                showCursor: true,
                toolbarOptions: ToolbarOptions(
                    copy: true, selectAll: true, cut: false, paste: false),
                style: TextStyle(color: Colors.grey[850])))
      ]);
}
