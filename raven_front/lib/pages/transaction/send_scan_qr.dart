import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class SendScanQR extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SendScanQRState();
}

class _SendScanQRState extends State<SendScanQR> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                      "Scan Recipient's QR Code" /*, style: TextStyle(fontSize: 18)*/),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(8),
                        child: TextButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.cancel),
                            label: Text('Cancel')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((Barcode scanData) {
      print(scanData);
      Navigator.pop(context, scanData);
/*
'package:flutter/src/widgets/navigator.dart': Failed assertion: line 4841 pos 12: '!_debugLocked': is not true.
#0      _AssertionError._doThrowNew (dart:core-patch/errors_patch.dart:47:61)
#1      _AssertionError._throwNew (dart:core-patch/errors_patch.dart:36:5)
#2      NavigatorState.pop (package:flutter/src/widgets/navigator.dart:4841:12)
#3      Navigator.pop (package:flutter/src/widgets/navigator.dart:2431:27)
#4      _SendScanQRState._onQRViewCreated.<anonymous closure> (package:raven_mobile/pages/transaction/send_scan_qr.dart:89:17)
#5      _rootRunUnary (dart:async/zone.dart:1436:47)
#6      _CustomZone.runUnary (dart:async/zone.dart:1335:19)
#7      _CustomZone.runUnaryGuarded (dart:async/zone.dart:1244:7)
#8      _BufferingStreamSubscription._sendData (dart:async/stream_impl.dart:341:11)
#9      _DelayedData.perform (dart:async/stream_impl.dart:591:14)
#10     _StreamImplEvents.handleNext (dart:async/stream_impl.dart:706:11)
#11     _PendingEvents.schedule.<anonymous closure> (dart:async/stream_impl.dart:663:7)
#12     _rootRun (dart:async/zone.dart:1420:47)
#13     _CustomZone.run (dart:async/zone.dart:1328:19)
#14     _CustomZone.runGuarded (dart:async/zone.dart:1236:7)
#15     _CustomZone.bindCallbackGuarded.<anonymous closure> (dart:async/zone.dart:1276:23)
#16     _rootRun (dart:async/zone.dart:1428:13)
#17     _CustomZone.run (dart:async/zone.dart:1328:19)
#18     _CustomZone.runGuarded (dart:async/zone.dart:1236:7)
#19     _CustomZone.bindCallbackGuarded.<anonymous closure> (dart:async/zone.dart:1276:23)
#20     _microtaskLoop (dart:async/schedule_microtask.dart:40:21)
#21     _startMicrotaskLoop (dart:async/schedule_microtask.dart:49:5)
*/
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    // log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
