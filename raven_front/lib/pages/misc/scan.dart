import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/spend.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/utils/data.dart';
import 'package:raven_front/utils/qrcode.dart';

class ScanQR extends StatefulWidget {
  const ScanQR({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  Map<String, dynamic> data = {};
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    return Scaffold(
      body: Container(
        child: Stack(children: [
          _buildQrView(context),
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Container(
                height: 56,
                decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8.0),
                        topLeft: Radius.circular(8.0))),
                child: Center(
                    child: Text('Point your camera at a QR code',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            fontWeight: FontWeights.bold,
                            letterSpacing: 0.14,
                            color: AppColors.offWhite)))),
          ])
        ]),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var width = MediaQuery.of(context).size.width - 32;
    var height = MediaQuery.of(context).size.height - 32;
    var scanArea = width < height ? width : height;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      // You can choose between CameraFacing.front or CameraFacing.back. Defaults to CameraFacing.back
      // cameraFacing: CameraFacing.front,
      onQRViewCreated: _onQRViewCreated,
      // Choose formats you want to scan. Defaults to all formats.
      // formatsAllowed: [BarcodeFormat.qrcode],
      overlayMargin: EdgeInsets.only(bottom: 50),
      overlay: QrScannerOverlayShape(
        //overlayColor: Color(0x00000061),
        borderColor: Color(0xff5C6BC0),
        borderRadius: 8,
        borderLength: scanArea / 2,
        borderWidth: 8,
        cutOutSize: scanArea,
      ),
      onPermissionSet: _onPermissionSet,
    );
  }

  void _onPermissionSet(QRViewController qrController, bool permission) async {
    //print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!permission) {
      //import 'package:permission_handler/permission_handler.dart';
      //await Permission.camera.request();
      Navigator.of(context).pop();
      streams.app.snack
          .add(Snack(message: 'please give Moontree app camera permissions'));
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    if (this.controller != controller) {
      setState(() {
        this.controller = controller;
      });
    }
    controller.scannedDataStream.listen((scanData) {
      var qrData = populateFromQR(code: scanData.code ?? '');
      if (data.containsKey('addressOnly') && data['addressOnly']) {
        streams.spend.form.add(SpendForm.merge(
          form: streams.spend.form.value,
          address: qrData.address,
          addressName: qrData.addressName,
        ));
        Navigator.of(components.navigator.routeContext!)
            .pushReplacementNamed('/transaction/send');
      } else {
        streams.spend.form.add(SpendForm.merge(
          form: streams.spend.form.value,
          address: qrData.address,
          addressName: qrData.addressName,
          symbol: qrData.symbol,
          note: qrData.note,
          amount: double.parse(qrData.amount ?? '0.0'),
        ));
        controller.pauseCamera();
        Navigator.of(components.navigator.routeContext!).pushReplacementNamed(
          '/transaction/send',
          //arguments: {'qrCode': scanData.code}
        );
      }
    });
  }
}
