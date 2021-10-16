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
            // ignore coinbase ins for now (edge case)
            newVins.add(Vin(
              txId: tx.txid,
              voutTxId: vin.txid!,
              voutPosition: vin.vout!,
            ));
          }
        }
        for (var vout in tx.vout) {
          // todo we should capture securities here. and if it's one we've never
          // seen, get it's metadata and save it in the securities reservoir
          newVouts.add(Vout(
              txId: tx.txid,
              value: vout.valueSat,
              position: vout.n,
              //security:
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
}
