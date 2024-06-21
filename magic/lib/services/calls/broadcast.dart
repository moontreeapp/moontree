/// does this endpoint take into consideration the need to grab enough rvn for
/// the asset?
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/server/serverv2_client.dart';
import 'package:magic/services/calls/server.dart';
import 'package:moontree_utils/moontree_utils.dart';

class BroadcastTransactionCall extends ServerCall {
  late String rawTransactionHex;
  late Blockchain blockchain;

  BroadcastTransactionCall({
    required this.rawTransactionHex,
    required this.blockchain,
  });

  Future<CommString> broadcastTransactionBy({
    required Chaindata chain,
    required String rawTransactionHex,
  }) async =>
      await runCall(() async => await client.broadcastTransaction
          .get(chainName: chain.name, rawTransactionHex: rawTransactionHex));

  /// this simple version of the request handles sending one asset to one address.
  Future<CommString> call() async {
    final CommString broadcastTx = await broadcastTransactionBy(
      rawTransactionHex: rawTransactionHex,
      chain: blockchain.chaindata,
    );

    //broadcastTx.chain = chain.name + '_' + net.name + 'net';
    //broadcastTx.symbol = symbol;

    return broadcastTx; //todo: display this 8bb3f00ec3da16b768daa951a4fc8dc53b75033ac78e50f8add561084b312ff9
  }
}
