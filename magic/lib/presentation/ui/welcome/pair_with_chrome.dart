import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:magic/services/services.dart';
import 'package:magic/cubits/cubits.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/utils/log.dart';

enum PairWithChromeLifeCycle {
  entering,
  shown,
  exiting;

  bool get animating => [
        PairWithChromeLifeCycle.entering,
        PairWithChromeLifeCycle.exiting,
      ].contains(this);
}

class PairWithChromePage extends StatefulWidget {
  const PairWithChromePage({super.key});

  @override
  PairWithChromePageState createState() => PairWithChromePageState();
}

class PairWithChromePageState extends State<PairWithChromePage>
    with WidgetsBindingObserver {
  PairWithChromeLifeCycle lifecycle = PairWithChromeLifeCycle.entering;
  final MobileScannerController controller = MobileScannerController();
  String? barcode;
  KeysCubit keysCubit = KeysCubit();
  void toStage(PairWithChromeLifeCycle stage) {
    if (mounted) {
      if (stage == PairWithChromeLifeCycle.exiting) {
        cubits.app.animating = true;
        Future.delayed(slideDuration * 1.1, () {
          cubits.welcome.update(active: false, child: const SizedBox.shrink());
          cubits.app.animating = false;
        });
      }
      setState(() => lifecycle = stage);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(controller.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) return;
    switch (state) {
      case AppLifecycleState.resumed:
        controller.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        controller.stop();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    unawaited(controller.start());
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (lifecycle == PairWithChromeLifeCycle.entering) {
        toStage(PairWithChromeLifeCycle.shown);
      }
    });
    return Stack(
      children: <Widget>[
        AnimatedPositioned(
          duration: slideDuration,
          curve: Curves.easeOutCubic,
          top: 0,
          bottom: 0,
          left: lifecycle.animating ? screen.width : 0,
          right: lifecycle.animating ? -screen.width : 0,
          child: Column(
            children: [
              Expanded(
                child: MobileScanner(
                  controller: controller,
                  overlayBuilder: (context, controller) {
                    return Container(
                      height: screen.height * 0.33,
                      width: screen.width * 0.7,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                  onDetect: (BarcodeCapture event) {
                    if (event.barcodes.first.rawValue?.isNotEmpty ?? false) {
                      final randomNumber = event.barcodes.first.rawValue!;
                      if (barcode != randomNumber) {
                        see('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
                        barcode = randomNumber;
                        final pubKeys = cubits.keys.master.derivationWallets
                            .expand((wallet) => wallet.seedWallets.values)
                            .expand(
                                (seedWallet) => seedWallet.subwallets.values)
                            .expand((subWallets) => subWallets)
                            .map((subWallet) => subWallet.pubKey)
                            .toList();
                        see(randomNumber, pubKeys);
                        // Todo: Send data to server
                        // await sendDataToServer(randomNumber, pubKeys);
                        Future.delayed(const Duration(milliseconds: 500), () {
                          toStage(PairWithChromeLifeCycle.exiting);
                          controller.stop();
                        });
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        AnimatedPositioned(
          duration: slideDuration,
          curve: Curves.easeOutCubic,
          top: Platform.isIOS ? 36.0 : 8,
          left: lifecycle.animating ? screen.width : 16,
          child: SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () {
                toStage(PairWithChromeLifeCycle.exiting);
              },
            ),
          ),
        ),
      ],
    );
  }
}
