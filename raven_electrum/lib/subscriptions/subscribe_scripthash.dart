import '../client/subscribing_client.dart';
import '../raven_electrum.dart';

extension SubscribeScripthashMethod on RavenElectrumClient {
  Future<Stream<String?>> subscribeScripthash(String scripthash) async {
    var methodPrefix = 'blockchain.scripthash';

    // If this is the first time, register
    registerSubscribable(methodPrefix, 1);

    return await subscribe(methodPrefix, [scripthash]);
  }

  Future<List<Stream<String?>>> subscribeScripthashes(
    Iterable<String> scripthashes,
  ) async {
    var futures = <Future<Stream<String?>>>[];
    if (scripthashes.isNotEmpty) {
      peer.withBatch(() {
        for (var scripthash in scripthashes) {
          futures.add(subscribeScripthash(scripthash));
        }
      });
    }
    return await Future.wait<Stream<String?>>(futures);
  }
}
