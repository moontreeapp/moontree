import 'dart:async';
import 'package:flutter/material.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/utils/log.dart';
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
    try {
      see(event.barcodes.first.rawValue);
      // Your existing processing logic
      see(event);
      see(event.barcodes);
      see(event.barcodes.first.rawValue);
      see(event.image);
      see(event.raw);
    } catch (e) {
      see('Error processing barcode: $e');
    }
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
    //controller.start();
  }

  @override
  void dispose() {
    // Stop listening to lifecycle changes.
    WidgetsBinding.instance.removeObserver(this);
    // Stop listening to the barcode events.
    unawaited(_subscription?.cancel());
    //_subscription?.cancel().then((_) {
    //  _subscription = null;
    //  // Finally, dispose of the controller.
    //  controller.dispose().then((_) => super.dispose());
    //  // Dispose the widget itself.
    //});
    _subscription = null;
    super.dispose();
    unawaited(controller.dispose());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _subscription ??= controller.barcodes.listen(_handleBarcode);
        controller.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        _subscription?.cancel();
        _subscription = null;
        controller.stop();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
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
              if (event.barcodes.first.rawValue?.isNotEmpty ?? false) {
                cubits.send.update(address: barcode);
                cubits.send.update(scanActive: false);
                see(cubits.send.state.address);
                see(event);
                see(event.barcodes);
                see(event.barcodes.first.rawValue);
                see(event.image);
                see(event.raw);
              }
              setState(() {
                barcode = event.barcodes.first.rawValue;
                if (barcode?.isNotEmpty ?? false) {
                  cubits.send.update(fromQR: true, address: barcode);
                  cubits.send.update(scanActive: false);
                }
              });
              // Consider stopping the scanner after a slight delay if necessary
              Future.delayed(const Duration(milliseconds: 500), () {
                controller.stop();
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
