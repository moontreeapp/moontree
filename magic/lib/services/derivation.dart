//import 'dart:isolate';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/exposure.dart';
import 'package:magic/services/calls/receive.dart';

Future<void> deriveInBackground([String? mnemonic]) async {
  Future<void> deriveAll() async {
    for (final mnemonicWallet in cubits.keys.master.mnemonicWallets) {
      if (mnemonic != null && mnemonicWallet.mnemonic != mnemonic) {
        continue;
      }
      for (final blockchain in Blockchain.values) {
        while (cubits.app.animating) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
        final seedWallet = mnemonicWallet.seedWallet(blockchain);
        for (final exposure in Exposure.values) {
          while (cubits.app.animating) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
          if (seedWallet.highestIndex.isEmpty) {
            seedWallet.derive({
              exposure: (await ReceiveCall(
                blockchain: blockchain,
                mnemonicWallet: mnemonicWallet,
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
  //    print('Derivation completed');
  //    receivePort.close(); // Close the receive port when derivation is complete
  //    return;
  //  }
  //  //body.add(message);
  //});
  await deriveAll();
}
