import '../client/subscribing_client.dart';
import '../raven_electrum.dart';

extension SubscribeAssetMethod on RavenElectrumClient {
  Future<Stream<String?>> subscribeAsset(String assetName) async {
    var methodPrefix = 'blockchain.asset';

    // If this is the first time, register
    registerSubscribable(methodPrefix, 1);

    return (await subscribe(methodPrefix, [assetName]))
        .asyncMap((item) => item);
  }
}
