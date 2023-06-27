// ignore_for_file: omit_local_variable_types, avoid_print

import 'dart:async';
import 'package:client_back/client_back.dart';
import 'package:client_back/utilities/database.dart' as database;


/// client creation, logic, and settings.s
class ClientService {

  Future<void> switchNetworks({required Chain chain, required Net net}) async {
    await pros.settings.setBlockchain(chain: chain, net: net);
    await resetMemoryAndConnection(keepAddresses: true);
  }

  Future<void> resetMemoryAndConnection({
    bool keepTx = false,
    bool keepBalances = false,
    bool keepAddresses = false,
  }) async {
    /// notice that we remove all our database here entirely.
    /// this is the simplest way to handle it (changing blockchains, this is also it's own feature).
    /// it might be ideal to keep the transactions, vout, unspents, vins, addresses, etc.
    /// but we're not ging to because we'd have to segment all of them by network.
    /// this is something we could do later if we want.

    database.resetInMemoryState();
    if (!keepTx) {
      await database.eraseTransactionData(quick: true);
    }
    await database.eraseUnspentData(quick: true, keepBalances: keepBalances);
    if (!keepAddresses) {
      await database.eraseAddressData(quick: true);
    }
    await database.eraseCache(quick: true);

    /// no longer needed since the await waits for the client to be created
    //await Future<void>.delayed(const Duration(seconds: 3));

    ///// the leader waiter does not do this:
    /// start derivation process
    if (!keepAddresses) {
      final Wallet currentWallet = services.wallet.currentWallet;
      if (currentWallet is LeaderWallet) {
        //print('deriving');
        await services.wallet.leader.handleDeriveAddress(leader: currentWallet);
      } else {
        // trigger single derive?
      }

      /// we could do this when we nav to it. (front services switchWallet)
      //for (var wallet in pros.wallets.records) {
      //  if (wallet != currentWallet) {
      //    await services.wallet.leader.handleDeriveAddress(leader: currentWallet);
      //  }
      //}
    }

    // subscribe
    //await waiters.block.subscribe();
    //await services.client.subscribe.toAllAddresses();

    /// update the UI
    streams.app.wallet.refresh.add(true);
  }
}
