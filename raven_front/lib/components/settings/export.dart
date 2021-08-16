import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

AppBar header(context) {
  return AppBar(
    backgroundColor: Colors.blue[900],
    leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey[100]),
        onPressed: () => Navigator.pop(context)),
    elevation: 2,
    centerTitle: false,
    title: Text('Export Wallet',
        style: TextStyle(fontSize: 18.0, letterSpacing: 2.0)),
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
