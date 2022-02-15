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
      .forEach(downloadSubs);

  Future<void> downloadSubs(String symbol) async {
    var symbolSlash = adminOrRestrictedToMainSlash(symbol);
    // WXRAVEN/
    var children = await services.client.api.getAssetNames(symbolSlash);
    // [WXRAVEN/P2P_MARKETPLACE, WXRAVEN/P2P_MARKETPLACE!,
    //  WXRAVEN/P2P_MARKETPLACE/TEST, WXRAVEN/P2P_MARKETPLACE/TEST!,
    //  WXRAVEN/PING, WXRAVEN/PING!, WXRAVEN/SUBASSET1, WXRAVEN/SUBASSET1!,
    //  WXRAVEN/SUBASSET1#AUNIQUEASSET]

    //var kids = children.toList();
    //kids.sort((a, b) => a.length.compareTo(b.length));
    for (String kid in children
        .where((child) => res.assets.bySymbol.getOne(child) == null)) {
      await downloadAsset(kid);
      /* /// I don't think there's a reason to care what type it is...
      var justKid = kid.replaceFirst(symbolSlash, '');
      if (justKid.startsWith('#')) {
        if (symbolSlash.startsWith('#')) {
          // it's a qualifier
        } else {
          // it's an NFT
        }
      } else if (justKid.contains('#')) {
        // it's a subasset(s) with an NFT
      } else if (justKid.endsWith('!')) {
        // it's an admin token for a subasset
      } else if (justKid.startsWith('~')) {
        // it's a Message Channel
      } else if (justKid.contains('~')) {
        // it's a subasset(s) with a Message Channel
      }
      */
    }
  }

  Future<bool> downloadAsset(
    String symbol, [
    RavenElectrumClient? client,
  ]) async {
    client = client ?? streams.client.client.value;
    if (client == null) {
      return false;
    }
    print('symbol $symbol');
    var meta = await client.getMeta(symbol);
    print('meta $meta');
    if (meta != null) {
      streams.asset.added.add(Asset(
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
      ));
      var security = Security(
        symbol: meta.symbol,
        securityType: SecurityType.RavenAsset,
      );
      await res.securities.save(security);
      return true;
    }
    return false;
  }
}
