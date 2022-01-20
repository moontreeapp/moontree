import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/backdrop/backdrop.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/widgets/widgets.dart';

class QRCodeButton extends StatefulWidget {
  QRCodeButton({Key? key}) : super(key: key);

  @override
  _QRCodeButtonState createState() => _QRCodeButtonState();
}

class _QRCodeButtonState extends State<QRCodeButton> {
  late String pageTitle = 'Wallet';
  late List listeners = [];

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.page.stream.listen((value) {
      if ((value == 'Scan' && pageTitle != 'Scan') ||
          (value != 'Scan' && pageTitle == 'Scan')) {
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
  Widget build(BuildContext context) => pageTitle == 'Scan'
      ? Container(width: 48)
      : IconButton(
          splashRadius: 24,
          icon: Icon(
            MdiIcons.qrcodeScan,
            color: Colors.white,
          ),
          onPressed: () async {
            Backdrop.of(components.navigator.routeContext!).concealBackLayer();
            //ScanResult result = await BarcodeScanner.scan();
            //Navigator.of(components.navigator.routeContext!)
            //    .pushNamed('/transaction/send', arguments: {
            //  'qrcode': <ResultType, String>{
            //        ResultType.Barcode: result.rawContent
            //      }[result.type] ??
            //      ''
            //});

            /// once the result is recognized on this page it'll send you over to
            /// send page with the result so send can populate itself...
            Navigator.of(components.navigator.routeContext!).pushNamed('/scan');
          },
        );
}
