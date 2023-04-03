/// does this endpoint take into consideration the need to grab enough rvn for
/// the asset?
import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart' as server;
import 'package:client_front/infrastructure/calls/mock_flag.dart';
import 'package:client_front/infrastructure/calls/server_call.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:moontree_utils/moontree_utils.dart';

class BroadcastTransactionCall extends ServerCall {
  late String rawTransactionHex;
  late Chain chain;
  late Net net;

  BroadcastTransactionCall({
    required this.rawTransactionHex,
    Chain? chain,
    Net? net,
  }) : super() {
    this.chain = chain ?? Current.chain;
    this.net = net ?? Current.net;
  }

  Future<server.CommString> broadcastTransactionBy({
    required Chaindata chain,
    required String rawTransactionHex,
  }) async =>
      await runCall(() async => await client.broadcastTransaction
          .get(chainName: chain.name, rawTransactionHex: rawTransactionHex));

  /// this simple version of the request handles sending one asset to one address.
  Future<server.CommString> call() async {
    final server.CommString broadcastTx = mockFlag

        /// MOCK SERVER
        ? await Future.delayed(Duration(seconds: 1), spoof)

        /// SERVER
        : await broadcastTransactionBy(
            rawTransactionHex: rawTransactionHex,
            chain: ChainNet(chain, net).chaindata,
          );

    //broadcastTx.chain = chain.name + '_' + net.name + 'net';
    //broadcastTx.symbol = symbol;

    return broadcastTx; //todo: display this 8bb3f00ec3da16b768daa951a4fc8dc53b75033ac78e50f8add561084b312ff9
  }
}

server.CommString spoof() => server.CommString(value: '');
