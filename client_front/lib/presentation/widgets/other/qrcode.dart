import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

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
                if (streams.app.behavior.scrim.value == true) return;
                ScaffoldMessenger.of(context).clearSnackBars();
                //Backdrop.of(components.routes.routeContext!).concealBackLayer();
                //ScanResult result = await BarcodeScanner.scan();
                //Navigator.of(components.routes.routeContext!)
                //    .pushNamed('/transaction/send', arguments: {
                //  'qrcode': <ResultType, String>{
                //        ResultType.Barcode: result.rawContent
                //      }[result.type] ??
                //      ''
                //});
                if (widget.pageTitle == 'Send-to') {
                  Navigator.of(components.routes.routeContext!)
                      .pushReplacementNamed('/scan',
                          arguments: <String, bool>{'addressOnly': true});
                } else {
                  Navigator.of(components.routes.routeContext!)
                      .pushNamed('/scan');
                }
              },
            );
}
