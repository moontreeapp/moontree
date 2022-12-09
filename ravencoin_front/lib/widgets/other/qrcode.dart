import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/components/components.dart';

class QRCodeButton extends StatefulWidget {
  final String pageTitle;
  final bool light;

  const QRCodeButton({
    Key? key,
    this.pageTitle = 'Home',
    this.light = true,
  }) : super(key: key);

  @override
  _QRCodeButtonState createState() => _QRCodeButtonState();
}

class _QRCodeButtonState extends State<QRCodeButton> {
  @override
  Widget build(BuildContext context) =>
      <String>['Send', 'Scan'].contains(widget.pageTitle)
          ? Container(width: 0)
          : IconButton(
              padding: EdgeInsets.zero,
              splashRadius: 24,
              icon: Icon(
                MdiIcons.qrcodeScan,
                color: widget.light ? Colors.white : Colors.black,
              ),
              onPressed: () async {
                if (streams.app.scrim.value == true) return;
                ScaffoldMessenger.of(context).clearSnackBars();
                //Backdrop.of(components.navigator.routeContext!).concealBackLayer();
                //ScanResult result = await BarcodeScanner.scan();
                //Navigator.of(components.navigator.routeContext!)
                //    .pushNamed('/transaction/send', arguments: {
                //  'qrcode': <ResultType, String>{
                //        ResultType.Barcode: result.rawContent
                //      }[result.type] ??
                //      ''
                //});
                if (widget.pageTitle == 'Send-to') {
                  Navigator.of(components.navigator.routeContext!)
                      .pushReplacementNamed('/scan',
                          arguments: <String, bool>{'addressOnly': true});
                } else {
                  Navigator.of(components.navigator.routeContext!)
                      .pushNamed('/scan');
                }
              },
            );
}
