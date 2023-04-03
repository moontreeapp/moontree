import 'dart:async';
import 'package:electrum_adapter/electrum_adapter.dart';
import 'package:client_back/client_back.dart';
import 'package:wallet_utils/wallet_utils.dart';

class AssetService {
  String adminOrRestrictedToMainSlash(String symbol) => symbol.endsWith('!')
      ? symbol.replaceAll('!', '/').replaceAll(r'$', '')
      : symbol.endsWith('/')
          ? symbol.replaceAll(r'$', '')
          : '$symbol/'.replaceAll(r'$', '');

  void allAdminsSubs() => pros.assets.bySymbolType
      .getAll(SymbolType.admin)
      .where((Asset asset) => !asset.symbol.contains('/'))
      .map((Asset asset) => asset.symbol)
      .forEach(downloadMain);

  /// we actaully don't need all the subs now.
  /// We only need the mains of admins we own.
  /// So this is unused in preference to downloadMain
  Future<void> downloadSubs(String symbol) async {
    final String symbolSlash = adminOrRestrictedToMainSlash(symbol);
    final Iterable<String> children =
        await services.client.api.getAssetNames(symbolSlash);
    for (final String kid in children.where((String child) =>
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
    final AssetMeta? meta = await services.client.api.getMeta(symbol);
    if (meta != null) {
      final int value = vout == null ? 0 : vout.scriptPubKey.amount.asSats;
      final Asset asset = Asset(
        chain: pros.settings.chain,
        net: pros.settings.net,
        symbol: meta.symbol,
        metadata: (await services.client.api.getTransaction(meta.source.txHash))
                .vout[meta.source.txPos]
                .scriptPubKey
                .ipfsHash ?? // This can also be a TXID
            '',
        totalSupply: meta.satsInCirculation,
        divisibility: meta.divisions,
        reissuable: meta.reissuable,
        frozen: false,
        transactionId: meta.source.txHash,
        position: meta.source.txPos,
      );
      streams.asset.added.add(asset);
      final Security security = Security(
        symbol: meta.symbol,
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
  AssetRetrieved(this.asset, this.security, [this.value = 0]);
  final Asset asset;
  final Security security;
  final int value;
}
