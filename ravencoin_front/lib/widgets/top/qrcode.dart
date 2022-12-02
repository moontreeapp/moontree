import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class QRCodeContainer extends StatefulWidget {
  const QRCodeContainer({Key? key}) : super(key: key);

  @override
  _QRCodeContainerState createState() => _QRCodeContainerState();
}

class _QRCodeContainerState extends State<QRCodeContainer> {
  late String pageTitle = 'Home';
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  final List<String> blanks = <String>[
    'main',
    '',
    'Scan',
    'Send',
    'Login',
    'Splash',
    'Createlogin',
    'Setup',
    'Backupintro',
    'BackupConfirm',
    'Backup',
  ];
  late bool loading = true;

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.loading.listen((bool value) {
      if (value != loading) {
        setState(() {
          loading = value;
        });
      }
    }));
    listeners.add(streams.app.page.listen((String value) {
      if ((blanks.contains(value) && !blanks.contains(pageTitle)) ||
          (!blanks.contains(value) && blanks.contains(pageTitle))) {
        setState(() {
          pageTitle = value;
        });
      }
    }));
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      loading //|| streams.app.context.value == AppContext.login
          ? Container(width: 0)
          : pageTitle == 'Send'
              ? Padding(
                  padding: EdgeInsets.zero,
                  child: QRCodeButton(pageTitle: 'Send-to'))
              : (blanks.contains(pageTitle)
                  ? Container(width: 0)
                  : Padding(
                      padding: EdgeInsets.zero,
                      child: QRCodeButton(pageTitle: pageTitle)));
}
