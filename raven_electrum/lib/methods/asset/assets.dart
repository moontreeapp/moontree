/// for
import '../../raven_electrum.dart';

extension GetAssetNamesMethod on RavenElectrumClient {
  Future<Iterable> getAssetsByPrefix(String symbol) async {
    return await request(
      'blockchain.asset.get_assets_with_prefix',
      [symbol.toUpperCase()],
    );
  }
}
