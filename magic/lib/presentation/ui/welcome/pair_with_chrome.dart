import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/services/server_connection.dart';
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
    WidgetsBinding.instance.addObserver(this);
    unawaited(controller.start());
  }

  @override
  void dispose() {
    // Clean up the controller first
    unawaited(controller.dispose());

    // Then remove the observer and dispose the widget
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
                          color: AppColors.toast,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                  onDetect: (BarcodeCapture event) {
                    if (barcode == null &&
                        (event.barcodes.first.rawValue?.isNotEmpty ?? false)) {
                      final value = event.barcodes.first.rawValue!;
                      barcode = value;
                      final msg = ScannerMessage(raw: value);
                      see('scanner event: ${msg.raw}');
                      //final hdPubKeys = cubits.keys.master.derivationWallets
                      //    .expand((wallet) => wallet.seedWallets.values)
                      //    .expand((seedWallet) => seedWallet.subwallets.values)
                      //    .expand((subWallets) => subWallets)
                      //    .map((subWallet) => subWallet.pubKey)
                      //    .toList();
                      //final kpPubKeys = cubits.keys.master.keypairWallets
                      //    .expand((wallet) => wallet.pubkeys)
                      //    .toList();
                      final hdPubKeys = [
                        for (Blockchain blockchain in Blockchain.mainnets)
                          cubits.keys.master.derivationWallets
                              .map((e) => e.roots(blockchain))
                              .expand((e) => e)
                              .toList()
                      ].expand((i) => i).toSet().toList();
                      final kpPubKeys = [
                        for (Blockchain blockchain in Blockchain.mainnets)
                          cubits.keys.master.keypairWallets
                              .map((e) => e.h160AsByteData(blockchain))
                              .toList()
                      ].expand((i) => i).toSet().toList();
                      see(msg.pairCode);
                      see(hdPubKeys, kpPubKeys);
                      // Todo: Send data to server
                      //sendDataToServer(msg.pairCode, hdPubKeys, kpPubKeys);
                      WebSocketEndpoint(
                        endpoint: msg.scannerMessageType.toServerEndpoint,
                        params: {
                          'code': msg.pairCode,
                          'hd_pubkeys': hdPubKeys,
                          'keypair_pubkeys': kpPubKeys,
                        },
                      ).send();
                      controller.stop();
                      toStage(PairWithChromeLifeCycle.exiting);
                      //toStage(PairWithChromeLifeCycle.paused);
                      //Future.delayed(const Duration(milliseconds: 500), () {
                      //  toStage(PairWithChromeLifeCycle.exiting);
                      //});
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

enum ScannerMessageType {
  pair,
  send,
  unknown;

  static ScannerMessageType from(String value) {
    switch (value) {
      case 'pair':
        return ScannerMessageType.pair;
      case 'send':
        return ScannerMessageType.send;
      default:
        return ScannerMessageType.unknown;
    }
  }

  String get toServerEndpoint {
    switch (this) {
      case ScannerMessageType.pair:
        return 'pair.prove';
      case ScannerMessageType.send:
        return '';
      case ScannerMessageType.unknown:
        return '';
      default:
        return '';
    }
  }
}

class ScannerMessage {
  /* examples
  {
    "action": "send",
    "params": {
      "to": "<some_address>",
      "amount": "<some_amount>",
      "blockchain": "<some_chain>",
      "asset": "<some_asset>"
    }
  }
  {
    "action": "pair",
    "code": "cfc6f6ae-391d-49d3-9835-931aa29cf361"
  }
  */
  final String raw;

  const ScannerMessage({required this.raw});

  ScannerMessageType get scannerMessageType =>
      ScannerMessageType.from(message['action'] as String);

  Map<String, dynamic> get message => jsonDecode(raw) as Map<String, dynamic>;

  String get pairCode =>
      (message['code'] ?? message['params']['code'] ?? '') as String;
  String get sendTo => message['params']['to'] as String;
  String get sendAmount => message['params']['amount'] as String;
  int get sendSats => int.tryParse(message['params']['amount'] as String) ?? 0;
  String get sendAsset => message['params']['asset'] as String;
  Blockchain get sendBlockchain =>
      Blockchain.from(name: message['params']['blockchain'] as String);
}
