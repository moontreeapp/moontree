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
  late MnemonicWallet mnemonicWallet;
  late Blockchain blockchain;
  late bool change;

  ReceiveCall({
    required this.mnemonicWallet,
    required this.blockchain,
    this.change = false, // default external
  });

  Future<CommInt> emptyAddressBy({required Chaindata chain}) async =>
      await runCall(() async => await client.addresses.nextEmptyIndex(
          chainName: chain.name,
          xpubkey: mnemonicWallet.root(
              blockchain, change ? Exposure.internal : Exposure.external)));

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
