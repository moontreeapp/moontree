import 'dart:async';
import 'package:raven_back/raven_back.dart';
import 'package:raven_electrum/raven_electrum.dart';

class AssetService {
  String adminOrRestrictedToMainSlash(String symbol) => symbol.endsWith('!')
      ? symbol.replaceAll('!', '/').replaceAll('\$', '')
      : symbol.endsWith('/')
          ? symbol.replaceAll('\$', '')
          : '$symbol/'.replaceAll('\$', '');

  void allAdminsSubs() => res.assets.byAssetType
      .getAll(AssetType.Admin)
      .where((asset) => !asset.symbol.contains('/'))
      .map((asset) => asset.symbol)
      .forEach(downloadMain);

  /// we actaully don't need all the subs now.
  /// We only need the mains of admins we own.
  /// So this is unused in preference to downloadMain
  Future<void> downloadSubs(String symbol) async {
    var symbolSlash = adminOrRestrictedToMainSlash(symbol);
    var children = await services.client.api.getAssetNames(symbolSlash);
    for (String kid in children
        .where((child) => res.assets.bySymbol.getOne(child) == null)) {
      await get(kid);
    }
  }

  Future<void> downloadMain(String symbol) async {
    symbol = adminOrRestrictedToMainSlash(symbol).replaceAll('/', '');
    if (res.assets.bySymbol.getOne(symbol) == null) {
      await get(symbol);
    }
  }

  Future<AssetRetrieved?> get(
    String symbol, {
    RavenElectrumClient? client,
    TxVout? vout,
  }) async {
    client = client ?? streams.client.client.value;
    if (client == null) {
      return null;
    }
    var meta = await client.getMeta(symbol);
    if (meta != null) {
      var value =
          vout == null ? 0 : utils.amountToSat(vout.scriptPubKey.amount);
      var asset = Asset(
        symbol: meta.symbol,
        metadata: (await client.getTransaction(meta.source.txHash))
                .vout[meta.source.txPos]
                .scriptPubKey
                .ipfsHash ??
            '',
        satsInCirculation: meta.satsInCirculation,
        divisibility: meta.divisions,
        reissuable: meta.reissuable == 1,
        transactionId: meta.source.txHash,
        position: meta.source.txPos,
      );
      streams.asset.added.add(asset);
      var security = Security(
        symbol: meta.symbol,
        securityType: SecurityType.RavenAsset,
      );
      await res.assets.save(asset);
      await res.securities.save(security);
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
