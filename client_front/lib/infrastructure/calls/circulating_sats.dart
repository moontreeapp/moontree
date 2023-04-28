import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart' as server;
import 'package:client_front/infrastructure/calls/mock_flag.dart';
import 'package:client_front/infrastructure/calls/server_call.dart';
import 'package:client_front/infrastructure/services/lookup.dart';

class CirculatingSatsCall extends ServerCall {
  late Chain chain;
  late Net net;
  CirculatingSatsCall({
    Chain? chain,
    Net? net,
  }) : super() {
    this.chain = chain ?? Current.chain;
    this.net = net ?? Current.net;
  }

  Future<server.CommInt> coinCirculatingSatsBy({
    required Chaindata chain,
  }) async =>
      await runCall(() async => await client.circulatingSats.get(
            chainName: chain.name,
          ));

  Future<server.CommInt> call() async {
    final server.CommInt value = mockFlag

        /// MOCK SERVER
        ? await Future.delayed(Duration(seconds: 1), spoof)

        /// SERVER
        : await coinCirculatingSatsBy(chain: ChainNet(chain, net).chaindata);

    return value;
  }
}

server.CommInt spoof() {
  return server.CommInt(
    value: -1,
  );
}
