import '../client/subscribing_client.dart';
import '../raven_electrum.dart';

extension UnsubscribeScripthashMethod on RavenElectrumClient {
  Future<bool> unsubscribeScripthash(scripthash) async => await request(
        'blockchain.scripthash.unsubscribe',
        [scripthash],
      );

  Future<List<bool>> unsubscribeScripthashes(
    Iterable<String> scripthashes,
  ) async {
    var futures = <Future<bool>>[];
    if (scripthashes.isNotEmpty) {
      peer.withBatch(() {
        for (var scripthash in scripthashes) {
          futures.add(unsubscribeScripthash(scripthash));
        }
      });
    }
    return await Future.wait<bool>(futures);
  }
}
