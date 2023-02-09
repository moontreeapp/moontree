/// a service to hit the serverv2 transactions endpoints: mempool and confirmed
/// compiles info to be sent to the endpoint, gets values for front end
/// rough draft:
/*
*/
//import 'package:client_back/consent/consent_client.dart';

import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/comm_int.dart';
import 'package:client_front/infrastructure/calls/mock_flag.dart';
import 'package:client_front/infrastructure/calls/server_call.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:moontree_utils/moontree_utils.dart';

class ReceiveCall extends ServerCall {
  late LeaderWallet wallet;
  late Chain chain;
  late Net net;
  ReceiveCall({
    required this.wallet,
    Chain? chain,
    Net? net,
  }) : super() {
    this.chain = chain ?? Current.chain;
    this.net = net ?? Current.net;
  }

  Future<CommInt> emptyAddressBy({
    required Chaindata chain,
    required String root,
  }) async =>
      await client.addresses
          .nextEmptyIndex(chainName: chain.name, xpubkey: root);

  Future<CommInt> call() async {
    final CommInt index = mockFlag

        /// MOCK SERVER
        ? await Future.delayed(Duration(seconds: 1), spoof)

        /// SERVER
        : await emptyAddressBy(
            chain: ChainNet(chain, net).chaindata,
            root: await wallet.externalRoot);

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

CommInt spoof() => CommInt(value: 0);
