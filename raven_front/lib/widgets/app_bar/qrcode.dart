import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_front/backdrop/backdrop.dart';
import 'package:raven_front/components/components.dart';

class QRCodeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => IconButton(
        splashRadius: 24,
        icon: Icon(
          MdiIcons.qrcodeScan,
          color: Colors.white,
        ),
        onPressed: () async {
          Backdrop.of(components.navigator.routeContext!).concealBackLayer();
          ScanResult result = await BarcodeScanner.scan();
          Navigator.of(components.navigator.routeContext!)
              .pushNamed('/transaction/send', arguments: {
            'qrcode': <ResultType, String>{
                  ResultType.Barcode: result.rawContent
                }[result.type] ??
                ''
          });
        },
      );
}
