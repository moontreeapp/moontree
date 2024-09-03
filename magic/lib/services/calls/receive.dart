/*
what would be more ideal is to have the server endpoint accept a list, and it
returns a list in the same order or even a map.
*/

import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/exposure.dart';
import 'package:magic/domain/server/protocol/comm_int.dart';
import 'package:magic/domain/wallet/wallets.dart';
import 'package:magic/services/calls/server.dart';
import 'package:moontree_utils/moontree_utils.dart';

class ReceiveCall extends ServerCall {
  late String root;
  late Blockchain blockchain;
  late Exposure exposure;

  ReceiveCall({
    required this.root,
    required this.blockchain,
    this.exposure = Exposure.external,
  });

  factory ReceiveCall.fromXPubWallet({
    required XPubWallet xPubWallet,
    required Blockchain blockchain,
    Exposure exposure = Exposure.external,
  }) =>
      ReceiveCall(
        root: xPubWallet.xpub,
        blockchain: blockchain,
        exposure: exposure,
      );

  factory ReceiveCall.fromMnemonicWallet({
    required MnemonicWallet mnemonicWallet,
    required Blockchain blockchain,
    Exposure exposure = Exposure.external,
  }) =>
      ReceiveCall(
        root: mnemonicWallet.root(blockchain, exposure),
        blockchain: blockchain,
        exposure: exposure,
      );

  Future<CommInt> emptyAddressBy({required Chaindata chain}) async =>
      await runCall(() async => await client.addresses
          .nextEmptyIndex(chainName: chain.name, xpubkey: root));

  Future<CommInt> call() async {
    late CommInt index;
    try {
      index = await emptyAddressBy(chain: blockchain.chaindata);
    } catch (e) {
      index = CommInt(error: 'unable to contact server', value: -1);
    }

    if (index.error != null) {
      // handle
      // maybe the pubkey was not associated with any h160s through WalletChainLink
      // maybe the pubkey was not associated with any h160s at all.
      // maybe the pubkey was not found in the database.
      // maybe the chain net was invalid.
      // myabe there was some unknown issue.
      return index;
    }

    return index;
  }
}
