//import 'dart:isolate';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/exposure.dart';
import 'package:magic/services/calls/receive.dart';
import 'package:magic/utils/log.dart';

Future<void> deriveInBackground([String? mnemonic]) async {
  Future<void> deriveAll() async {
    for (final derivationWallet in cubits.keys.master.derivationWallets) {
      if (mnemonic != null && derivationWallet.mnemonic != mnemonic) {
        continue;
      }
      for (final blockchain in Blockchain.values) {
        while (cubits.app.animating) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
        final seedWallet = derivationWallet.seedWallet(blockchain);
        for (final exposure in Exposure.values) {
          while (cubits.app.animating) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
          if (seedWallet.highestIndex.isEmpty) {
            seedWallet.derive({
              exposure: (await ReceiveCall.fromDerivationWallet(
                blockchain: blockchain,
                derivationWallet: derivationWallet,
                exposure: exposure,
              ).call())
                  .value,
            });
          } else {
            seedWallet.derive();
          }
          //sendPort.send(seedWallet.externals.last.address);
        }
      }
      //await Future.delayed(const Duration(seconds: 5)); // allow app to load ui
      //await scan(sendPort, ranges: ['192.168.0.0-192.168.0.40']);
    }
  }

  //final receivePort = ReceivePort();
  //Isolate.spawn(deriveAll, receivePort.sendPort);
  //receivePort.listen((message) {
  //  if (message == null) {
  //    see('Derivation completed');
  //    receivePort.close(); // Close the receive port when derivation is complete
  //    return;
  //  }
  //  //body.add(message);
  //});
  see('DERIVING IN BACKGROUND - NOT USED I THINK');
  await deriveAll();
}
