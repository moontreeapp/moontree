import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/widgets/widgets.dart';

class QRCodeContainer extends StatefulWidget {
  QRCodeContainer({Key? key}) : super(key: key);

  @override
  _QRCodeContainerState createState() => _QRCodeContainerState();
}

class _QRCodeContainerState extends State<QRCodeContainer> {
  late String pageTitle = 'Wallet';
  late List listeners = [];

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.page.listen((value) {
      if ((value == 'Scan' && pageTitle != 'Scan') ||
          (value != 'Scan' && pageTitle == 'Scan') ||
          (value == 'Send' && pageTitle != 'Send') ||
          (value != 'Send' && pageTitle == 'Send')) {
        setState(() {
          pageTitle = value;
        });
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ['Send', 'Scan'].contains(pageTitle)
      ? Container(width: 0)
      : Padding(
          padding: EdgeInsets.only(left: 16),
          child: QRCodeButton(pageTitle: pageTitle));
}
