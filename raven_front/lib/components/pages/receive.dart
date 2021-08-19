import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/styles.dart';

AppBar header(context) => AppBar(
      leading: RavenButton().back(context),
      elevation: 2,
      centerTitle: false,
      title: RavenText(
        //(data['accounts'][data['account']] ?? 'Unknown') + ' Wallet',
        'Wallet',
      ).h2,
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
              style: TextStyle(
                  fontSize: 14.0, letterSpacing: 1.6, color: Colors.grey[800])),
          SizedBox(height: 30.0),
          Center(
              child: QrImage(
                  data: "mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7",
                  version: QrVersions.auto,
                  size: 200.0)),
          Center(
              child: SelectableText('mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7',
                  cursorColor: Colors.grey[850],
                  showCursor: true,
                  toolbarOptions: ToolbarOptions(
                      copy: true, selectAll: true, cut: false, paste: false),
                  style: TextStyle(color: Colors.grey[850])))
        ]);

ElevatedButton shareAddressButton() => ElevatedButton.icon(
    icon: Icon(Icons.share),
    label: Text('Share'),
    onPressed: () {},
    style: RavenButtonStyle().curvedSides);
