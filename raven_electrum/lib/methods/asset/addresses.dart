/// example
/// {
///   "R9HC7XkCwnQA5dQZ18BntXgUe9ESuALU3J": 2,
///   "R9HDH3ZDuLRVF8ivzUwnojZa7thtRXQooM": 1
/// }
import 'package:equatable/equatable.dart';
import '../../raven_electrum.dart';

class AssetAddresses with EquatableMixin {
  late final String asset;
  late final Map<String, int> assetCountByAddress;

  AssetAddresses({
    required this.asset,
    required this.assetCountByAddress,
  });

  String get owner =>
      asset.endsWith('!') ? assetCountByAddress.keys.toList()[0] : '';

  @override
  List<Object> get props => [assetCountByAddress];

  @override
  String toString() {
    return 'AssetAddresses(assetCountByAddress: $assetCountByAddress)';
  }
}

extension GetAssetAddressesMethod on RavenElectrumClient {
  Future<AssetAddresses?> getAddresses(String symbol) async {
    var response = await request(
      'blockchain.asset.list_addresses_by_asset',
      [symbol],
    );
    if (response.runtimeType == String) return null; // todo: error
    response = response as Map<String, int>;
    if (response.isNotEmpty) {
      return AssetAddresses(asset: symbol, assetCountByAddress: response);
    }
  }
}
