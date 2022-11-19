import 'dart:async';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:electrum_adapter/electrum_adapter.dart';

class AssetService {
  String adminOrRestrictedToMainSlash(String symbol) => symbol.endsWith('!')
      ? symbol.replaceAll('!', '/').replaceAll('\$', '')
      : symbol.endsWith('/')
          ? symbol.replaceAll('\$', '')
          : '$symbol/'.replaceAll('\$', '');

  void allAdminsSubs() => pros.assets.byAssetType
      .getAll(AssetType.admin)
      .where((asset) => !asset.symbol.contains('/'))
      .map((asset) => asset.symbol)
      .forEach(downloadMain);

  /// we actaully don't need all the subs now.
  /// We only need the mains of admins we own.
  /// So this is unused in preference to downloadMain
  Future<void> downloadSubs(String symbol) async {
    var symbolSlash = adminOrRestrictedToMainSlash(symbol);
    var children = await services.client.api.getAssetNames(symbolSlash);
    for (String kid in children.where((child) =>
        pros.assets.primaryIndex
            .getOne(child, pros.settings.chain, pros.settings.net) ==
        null)) {
      await get(kid);
    }
  }

  Future<void> downloadMain(String symbol) async {
    symbol = adminOrRestrictedToMainSlash(symbol).replaceAll('/', '');
    if (pros.assets.primaryIndex
            .getOne(symbol, pros.settings.chain, pros.settings.net) ==
        null) {
      await get(symbol);
    }
  }

  Future<AssetRetrieved?> get(
    String symbol, {
    TxVout? vout,
  }) async {
    var meta = await services.client.api.getMeta(symbol);
    if (meta != null) {
      var value =
          vout == null ? 0 : utils.amountToSat(vout.scriptPubKey.amount);
      var asset = Asset(
        chain: pros.settings.chain,
        net: pros.settings.net,
        symbol: meta.symbol,
        metadata: (await services.client.api.getTransaction(meta.source.txHash))
                .vout[meta.source.txPos]
                .scriptPubKey
                .ipfsHash ?? // This can also be a TXID
            '',
        satsInCirculation: meta.satsInCirculation,
        divisibility: meta.divisions,
        reissuable: meta.reissuable,
        transactionId: meta.source.txHash,
        position: meta.source.txPos,
      );
      streams.asset.added.add(asset);
      var security = Security(
        symbol: meta.symbol,
        securityType: SecurityType.asset,
        chain: asset.chain,
        net: asset.net,
      );
      await pros.assets.save(asset);
      await pros.securities.save(security);
      return AssetRetrieved(asset, security, value);
    }
    return null;
  }
}

class AssetRetrieved {
  final Asset asset;
  final Security security;
  final int value;

  AssetRetrieved(this.asset, this.security, [this.value = 0]);
}
