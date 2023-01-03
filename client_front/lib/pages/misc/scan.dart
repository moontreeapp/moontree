import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/components/components.dart';
import 'package:client_front/theme/theme.dart';
import 'package:client_front/utils/data.dart';
import 'package:client_front/utils/qrcode.dart';

class ScanQR extends StatefulWidget {
  const ScanQR({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  Map<String, dynamic> data = <String, dynamic>{};
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void initState() {
    super.initState();
    streams.app.browsing.add(true);
  }

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

    /// still getting blank scan on android as of august 2022, attempting this solution
    //https://github.com/juliuscanute/qr_code_scanner/issues/415#issuecomment-1006918288
    if (controller != null && mounted) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
    return Scaffold(
      body: Stack(children: <Widget>[
        _buildQrView(context),
        Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          Container(
              height: 56,
              decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: const BorderRadius.only(
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
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    final double width = MediaQuery.of(context).size.width - 32;
    final double height = MediaQuery.of(context).size.height - 32;
    final double scanArea = width < height ? width : height;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      // You can choose between CameraFacing.front or CameraFacing.back. Defaults to CameraFacing.back
      // cameraFacing: CameraFacing.front,
      onQRViewCreated: _onQRViewCreated,
      // Choose formats you want to scan. Defaults to all formats.
      // formatsAllowed: [BarcodeFormat.qrcode],
      overlayMargin: const EdgeInsets.only(bottom: 50),
      overlay: QrScannerOverlayShape(
        //overlayColor: Color(0x00000061),
        borderColor: const Color(0xff5C6BC0),
        borderRadius: 8,
        borderLength: scanArea / 2,
        borderWidth: 8,
        cutOutSize: scanArea,
      ),
      onPermissionSet: _onPermissionSet,
    );
  }

  Future<void> _onPermissionSet(
      QRViewController qrController, bool permission) async {
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
      setState(() => this.controller = controller);
    }
    controller.scannedDataStream.listen((Barcode scanData) {
      final QRData qrData = populateFromQR(code: scanData.code ?? '');
      controller.pauseCamera();
      Navigator.of(components.navigator.routeContext!).pushReplacementNamed(
          '/transaction/send',
          arguments: <String, Object?>{
            'address': qrData.address,
            'addressName': qrData.addressName,
            // should we assume current network?
            if (!(data.containsKey('addressOnly') &&
                data['addressOnly'] as bool)) ...<String, Object?>{
              'security': pros.securities.primaryIndex.getOne(
                  qrData.symbol, pros.settings.chain, pros.settings.net),
              'note': qrData.note,
              'amount': double.parse(qrData.amount ?? '0.0')
              // add fee, memo, chain, net
            }
          });
    });
  }
}
