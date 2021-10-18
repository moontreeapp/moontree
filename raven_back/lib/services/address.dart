import 'dart:async';

import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:raven/raven.dart';

class AddressService {
  /// when an address status change: make our historic tx data match blockchain
  Future getAndSaveTransaction(
    List<Address> changedAddresses,
    RavenElectrumClient client,
  ) async {
    var addressIds =
        changedAddresses.map((address) => address.addressId).toList();

    // for each scripthash
    for (var addressId in addressIds) {
      // erase all tx and vins and vouts not pulled. (or just remove all first - the simple way).
      var removeTransactions = transactions.byScripthash.getAll(addressId);
      for (var transaction in removeTransactions) {
        await vins.removeAll(transaction.vins);
        await vouts.removeAll(transaction.vouts);
      }
      await transactions.removeAll(removeTransactions);

      // get a list of all history transactions
      // ignore: omit_local_variable_types
      List<ScripthashHistory> histories = await client.getHistory(addressId);

      // get all transactions
      // ignore: omit_local_variable_types
      List<Tx> txs = await client
          .getTransactions(histories.map((history) => history.txHash).toList());

      // save all vins, vouts and transactions
      var newVins = <Vin>[];
      var newVouts = <Vout>[];
      var newTxs = <Transaction>[];
      for (var tx in txs) {
        for (var vin in tx.vin) {
          if (vin.txid != null && vin.vout != null) {
            newVins.add(Vin(
              txId: tx.txid,
              voutTxId: vin.txid!,
              voutPosition: vin.vout!,
            ));
          } else if (vin.coinbase != null && vin.sequence != null) {
            newVins.add(Vin(
              txId: tx.txid,
              voutTxId: vin.coinbase!,
              voutPosition: vin.sequence!,
              isCoinbase: true,
            ));
          }
        }
        for (var vout in tx.vout) {
          var vs = await handleAssetData(client, tx, vout);
          newVouts.add(Vout(
              txId: tx.txid,
              value: vs['value'],
              position: vout.n,
              security: vs['security'],
              memo: vout.memo));
        }
        newTxs.add(Transaction(
          addressId: addressId,
          txId: tx.txid,
          height: tx.height,
          confirmed: tx.confirmations > 0,
        ));
      }
      // must await?
      await vins.saveAll(newVins);
      await vouts.saveAll(newVouts);
      await transactions.saveAll(newTxs);
    }

    //if ([for (var ca in changedAddresses) ca.address]
    //    .contains('mpVNTrVvNGK6YfSoLsiMMCrpLoX2Vt6Tkm')) {
    //  print('ADDRESSSERVICE:');
    //  print(changedAddresses);
    //  print('');
    //}
  }

  /// we capture securities here. if it's one we've never seen,
  /// get it's metadata and save it in the securities reservoir.
  /// return value and security to be saved in vout.
  Future<Map> handleAssetData(
      RavenElectrumClient client, Tx tx, TxVout vout) async {
    var symbol = 'RVN';
    var value = vout.valueSat;
    var security;
    if (vout.scriptPubKey.type == 'transfer_asset') {
      symbol = vout.scriptPubKey.asset!;
      value = vout.scriptPubKey.amount!;
      security = securities.bySymbolSecurityType
          .getOne(symbol, SecurityType.RavenAsset);
      //if we have no record of it in securities...
      if (security == null) {
        var meta = await client.getMeta(symbol);
        if (meta != null) {
          security = Security(
            symbol: meta.symbol,
            securityType: SecurityType.RavenAsset,
            satsInCirculation: meta.satsInCirculation,
            precision: meta.divisions,
            reissuable: meta.reissuable == 1,
            metadata: (await client.getTransaction(meta.source.txHash))
                .vout[meta.source.txPos]
                .scriptPubKey
                .ipfsHash,
            txId: meta.source.txHash,
            position: meta.source.txPos,
          );
          await securities.save(security);
        }
      }
    } else if (vout.scriptPubKey.type == 'new_asset') {
      symbol = vout.scriptPubKey.asset!;
      value = vout.scriptPubKey.amount!;
      security = Security(
        symbol: symbol,
        securityType: SecurityType.RavenAsset,
        satsInCirculation: value, //?? as sats?
        precision: vout.scriptPubKey.units,
        reissuable: vout.scriptPubKey.reissuable == 1,
        metadata: vout.scriptPubKey.ipfsHash,
        txId: tx.txid,
        position: vout.n,
      );
      await securities.save(security);
    }

    return {'value': value, 'security': security};
  }
}
