import 'package:equatable/equatable.dart';
import 'package:json_rpc_2/json_rpc_2.dart';

import '../client/subscribing_client.dart';
import '../raven_electrum_client.dart';

extension SubscribeScripthashMethod on RavenElectrumClient {
  Stream<String> subscribeScripthash(String scripthash) {
    var methodPrefix = 'blockchain.scripthash';

    // If this is the first time, register
    registerSubscribable(methodPrefix, 1);

    return subscribe(methodPrefix, [scripthash]).asyncMap((item) => item);
  }
}
