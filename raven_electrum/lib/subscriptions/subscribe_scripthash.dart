import '../client/subscribing_client.dart';
import '../raven_electrum.dart';

extension SubscribeScripthashMethod on RavenElectrumClient {
  Stream<String?> subscribeScripthash(String scripthash) {
    var methodPrefix = 'blockchain.scripthash';

    // If this is the first time, register
    registerSubscribable(methodPrefix, 1);

    return subscribe(methodPrefix, [scripthash]);
  }
}
