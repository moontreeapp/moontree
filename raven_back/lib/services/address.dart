import 'dart:async';

import 'package:raven/utils/transform.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:raven/raven.dart';
import 'package:tuple/tuple.dart';

class AddressService {
  Set<String> unretrieved = {};
  Set<String> retrieved = {};

  /// when an address status change: make our historic tx data match blockchain
  Future getAndSaveTransactionsByAddresses(
    List<Address> changedAddresses,
    RavenElectrumClient client,
  ) async {
    for (var changedAddress in changedAddresses) {
      // erase all vins and vouts not pulled. (or just remove all first - the simple way).
      ///await vins.removeAll(vins.byAddress.getAll(addressId)); // broken join
      ///await vouts.removeAll(vouts.byAddress.getAll(changedAddress.address));

      /// never purge tx (unless theres a reorg or something)
      /// transactions are not associated with addresses directly
      //var removeTransactions = transactions.byScripthash.getAll(addressId);
      //await transactions.removeAll(removeTransactions);

      // get a list of all historic transaction ids assicated with this address
      // ignore: omit_local_variable_types
      List<ScripthashHistory> histories =
          await client.getHistory(changedAddress.addressId);

      /// get all transactions - batch silently fails on some txHashes such as
      /// 9c0175c81d47fb3e8d99ec5a7b7f901769185682ebad31a8fcec9f77c656a97f
      /// (or one in it's batch)
      // ignore: omit_local_variable_types
      changedAddress.address == 'mxx5uTiYo5XZRWdpBaMDE2bHtxuf6MRAXt'
          ? print(changedAddress.addressId)
          : null;
      await saveTransactions([
        for (var txHash in histories.map((history) => history.txHash))

          /// this successfully reduced download redundancy but if things
          /// downloaded in a particular order, it caused the error of not
          /// downloading every transaction we needed, somehow. So this
          /// condition has been removed.
          //if (transactions.primaryIndex.getOne(txHash) == null ||
          //    transactions.primaryIndex.getOne(txHash)!.vins.isEmpty)
          await client.getTransaction(txHash)
      ], client,
          verbose:
              changedAddress.address == 'mxx5uTiYo5XZRWdpBaMDE2bHtxuf6MRAXt'
                  ? true
                  : false);
      unretrieved.remove(changedAddress.addressId);
      retrieved.add(changedAddress.addressId);
    }

    /// this condition marks the end of the external loop: after we have
    /// generated and looked for all transactions for those addresses...
    /// pull vouts for vins that don't have corresponding vouts and
    /// calculate all balances.
    await triggerDeriveOrBalance(
        client,
        changedAddresses
            .where((address) => address.wallet is LeaderWallet)
            .map((address) => address.wallet as LeaderWallet)
            .toSet());
    //if (services.address.unretrieved.isEmpty &&
    //    all([
    //      for (var leaderWallet in wallets.leaders)
    //        services.wallet.leader
    //                    .currentGap(leaderWallet, NodeExposure.Internal) >=
    //                services.wallet.leader.requiredGap &&
    //            services.wallet.leader
    //                    .currentGap(leaderWallet, NodeExposure.External) >=
    //                services.wallet.leader.requiredGap
    //    ])) {
    //  await saveDanglingTransactions(client);
    //  await services.balance.recalculateAllBalances();
    //}
  }

  Future triggerDeriveOrBalance(
      RavenElectrumClient client, Set<LeaderWallet> leaderWallets) async {
    /// here we should probably just check the the wallets are are of the set
    /// that are represented above as addresses. that way we check once for each
    /// wallet and we don't double up on calls. Also, we should add to backlog
    /// and let the leader waiter take care of those if the cipher isn't currently available
    /// it should be since we obviously just used it to make an address, most likely,
    /// but maybe there are edge cases, so we should do the check anyway.

    if (services.address.unretrieved.isEmpty) {
      var allDone = true;
      for (var leaderWallet in leaderWallets) {
        if (services.wallet.leader
                .missingGap(leaderWallet, NodeExposure.Internal) >
            0) {
          if (ciphers.primaryIndex.getOne(leaderWallet.cipherUpdate) != null) {
            allDone = false;
            var derived = services.wallet.leader.deriveMoreAddresses(
              leaderWallet,
              exposures: [NodeExposure.Internal],
            );
            for (var addressId in derived.map((address) => address.addressId)) {
              if (!services.address.retrieved.contains(addressId)) {
                services.address.unretrieved.add(addressId);
              }
            }
            services.client.subscribe.toExistingAddresses();
          } else {
            services.wallet.leader.backlog.add(leaderWallet);
          }
        }
        if (services.wallet.leader
                .missingGap(leaderWallet, NodeExposure.External) >
            0) {
          if (ciphers.primaryIndex.getOne(leaderWallet.cipherUpdate) != null) {
            allDone = false;
            var derived = services.wallet.leader.deriveMoreAddresses(
              leaderWallet,
              exposures: [NodeExposure.External],
            );
            for (var addressId in derived.map((address) => address.addressId)) {
              if (!services.address.retrieved.contains(addressId)) {
                services.address.unretrieved.add(addressId);
              }
            }
            services.client.subscribe.toExistingAddresses();
          } else {
            services.wallet.leader.backlog.add(leaderWallet);
          }
        }
      }
      if (allDone) {
        await saveDanglingTransactions(client);
        await services.balance.recalculateAllBalances();
      }
    }
  }

  /// for updating mempool transactions
  Future getAndSaveMempoolTransactions([RavenElectrumClient? client]) async {
    client = client ?? streams.client.client.value;
    if (client == null) return;
    await saveTransactions(
      [
        for (var txId in transactions.mempool.map((t) => t.txId))
          await client.getTransaction(txId)
      ],
      client,
    );
    await services.balance.recalculateAllBalances();
  }

  /// when an address status change: make our historic tx data match blockchain
  Future saveTransactions(
    List<Tx> txs,
    RavenElectrumClient client, {
    bool verbose = true,
  }) async {
    // why called twice?
    verbose ? print('0') : null;

    /// save all vins, vouts and transactions
    var newVins = <Vin>{};
    var newVouts = <Vout>{};
    var newTxs = <Transaction>{};
    for (var tx in txs) {
      verbose ? print('1') : null;
      for (var vin in tx.vin) {
        verbose ? print('2') : null;
        if (vin.txid != null && vin.vout != null) {
          verbose ? print('3.0') : null;
          verbose
              ? print(Vin(
                  txId: tx.txid,
                  voutTxId: vin.txid!,
                  voutPosition: vin.vout!,
                ))
              : null;
          newVins.add(Vin(
            txId: tx.txid,
            voutTxId: vin.txid!,
            voutPosition: vin.vout!,
          ));
        } else if (vin.coinbase != null && vin.sequence != null) {
          verbose ? print('3.1') : null;
          newVins.add(Vin(
            txId: tx.txid,
            voutTxId: vin.coinbase!,
            voutPosition: vin.sequence!,
            isCoinbase: true,
          ));
        }
      }
      for (var vout in tx.vout) {
        verbose ? print('5') : null;
        if (vout.scriptPubKey.type == 'nulldata') continue;
        verbose ? print('5.0') : null;
        var vs = await handleAssetData(client, tx, vout);
        verbose ? print(vs) : null;
        verbose ? print('5.1') : null;
        verbose
            ? print(Vout(
                txId: tx.txid,
                rvnValue: vs.item1,
                position: vout.n,
                memo: vout.memo,
                type: vout.scriptPubKey.type,
                toAddress: vout.scriptPubKey.addresses![0],
                assetSecurityId: vs.item2.securityId,
                assetValue: vout.scriptPubKey.amount,
                // multisig - must detect if multisig...
                additionalAddresses:
                    (vout.scriptPubKey.addresses?.length ?? 0) > 1
                        ? vout.scriptPubKey.addresses!
                            .sublist(1, vout.scriptPubKey.addresses!.length)
                        : null,
              ))
            : null;
        newVouts.add(Vout(
          txId: tx.txid,
          rvnValue: vs.item1,
          position: vout.n,
          memo: vout.memo,
          type: vout.scriptPubKey.type,
          toAddress: vout.scriptPubKey.addresses![0],
          assetSecurityId: vs.item2.securityId,
          assetValue: vout.scriptPubKey.amount,
          // multisig - must detect if multisig...
          additionalAddresses: (vout.scriptPubKey.addresses?.length ?? 0) > 1
              ? vout.scriptPubKey.addresses!
                  .sublist(1, vout.scriptPubKey.addresses!.length)
              : null,
        ));
      }

      /// might as well just save them all  - maybe avoiding saving them all
      /// can save some time, but then you have to also check confirmations
      /// and see if anything else changed. meh, just save them all for now.
      newTxs.add(Transaction(
        txId: tx.txid,
        height: tx.height,
        confirmed: (tx.confirmations ?? 0) > 0,
        time: tx.time,
      ));
    }

    //await vins.removeAll(existingVins.difference(newVins));
    //await vouts.removeAll(existingVouts.difference(newVouts));

    // must await?
    await transactions.saveAll(newTxs);
    await vins.saveAll(newVins);
    await vouts.saveAll(newVouts);
  }

  /// when an address status change: make our historic tx data match blockchain
  Future saveDanglingTransactions(
    RavenElectrumClient client,
  ) async {
    /// one more step - get all vins that have no corresponding vout (in the db)
    /// and get the vouts for them
    var finalVouts = <Vout>[];
    var finalTxs = <Transaction>[];
    // ignore: omit_local_variable_types
    var myVins = List.from(vins.danglingVins.map((vin) => vin.voutTxId));
    // ignore: omit_local_variable_types
    List<Tx> txs = [
      for (var txHash in myVins) await client.getTransaction(txHash)
    ];

    for (var tx in txs) {
      for (var vout in tx.vout) {
        if (vout.scriptPubKey.type == 'nulldata') continue;
        var vs = await handleAssetData(client, tx, vout);
        finalVouts.add(Vout(
          txId: tx.txid,
          rvnValue: vs.item1,
          position: vout.n,
          memo: vout.memo,
          type: vout.scriptPubKey.type,
          toAddress: vout.scriptPubKey.addresses![0],
          assetSecurityId: vs.item2.securityId,
          assetValue: vout.scriptPubKey.amount,
          // multisig - must detect if multisig...
          additionalAddresses: (vout.scriptPubKey.addresses?.length ?? 0) > 1
              ? vout.scriptPubKey.addresses!
                  .sublist(1, vout.scriptPubKey.addresses!.length)
              : null,
        ));
      }

      /// might as well just save them all  - maybe avoiding saving them all
      /// can save some time, but then you have to also check confirmations
      /// and see if anything else changed. meh, just save them all for now.
      finalTxs.add(Transaction(
        txId: tx.txid,
        height: tx.height,
        confirmed: (tx.confirmations ?? 0) > 0,
        time: tx.time,
      ));
    }
    await transactions.saveAll(finalTxs);
    await vouts.saveAll(finalVouts);
  }

  /// we capture securities here. if it's one we've never seen,
  /// get it's metadata and save it in the securities reservoir.
  /// return value and security to be saved in vout.
  Future<Tuple2<int, Security>> handleAssetData(
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
    return Tuple2(value, security ?? securities.RVN);
  }
}
