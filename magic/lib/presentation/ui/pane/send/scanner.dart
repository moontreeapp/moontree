import 'dart:async';
import 'package:flutter/material.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRViewable extends StatefulWidget {
  const QRViewable({super.key});
  @override
  State<StatefulWidget> createState() => QRViewableState();
}

class QRViewableState extends State<QRViewable> with WidgetsBindingObserver {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final MobileScannerController controller = MobileScannerController();
  StreamSubscription<Object?>? _subscription;
  String? barcode;

  void _handleBarcode(BarcodeCapture event) {
    print(event);
    print(event.barcodes);
    print(event.barcodes.first.rawValue);
    print(event.image);
    print(event.raw);
  }

  @override
  void initState() {
    super.initState();
    // Start listening to lifecycle changes.
    WidgetsBinding.instance.addObserver(this);

    // Start listening to the barcode events.
    _subscription = controller.barcodes.listen(_handleBarcode);

    // Finally, start the scanner itself.
    unawaited(controller.start());
  }

  @override
  Future<void> dispose() async {
    // Stop listening to lifecycle changes.
    WidgetsBinding.instance.removeObserver(this);
    // Stop listening to the barcode events.
    unawaited(_subscription?.cancel());
    _subscription = null;
    // Dispose the widget itself.
    super.dispose();
    // Finally, dispose of the controller.
    await controller.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it.
    // Permission dialogs can trigger lifecycle changes before the controller is ready.
    if (!controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // Restart the scanner when the app is resumed.
        // Don't forget to resume listening to the barcode events.
        _subscription = controller.barcodes.listen(_handleBarcode);

        unawaited(controller.start());
      case AppLifecycleState.inactive:
        // Stop the scanner when the app is paused.
        // Also stop the barcode events subscription.
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: MobileScanner(
            //fit: BoxFit.contain,
            controller: controller,
            onDetect: (BarcodeCapture event) {
              print(event);
              print(event.barcodes);
              print(event.barcodes.first.rawValue);
              print(event.image);
              print(event.raw);
              setState(() {
                barcode = event.barcodes.first.rawValue;
                if (barcode?.isNotEmpty ?? false) {
                  cubits.send.update(address: barcode);
                  cubits.send.update(scanActive: false);
                }
              });
            },
          ),
        ),
        //Padding(
        //  padding: const EdgeInsets.all(16.0),
        //  child: Text(
        //    barcode != null ? 'Barcode found: $barcode' : 'Scan a code',
        //    style: TextStyle(fontSize: 20),
        //  ),
        //),
      ],
    );
  }
}
