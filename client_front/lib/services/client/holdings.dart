/// a service to hit the serverv2 transactions endpoints: mempool and confirmed
/// compiles info to be sent to the endpoint, gets values for front end
/// rough draft:
/*
*/
//import 'package:client_back/consent/consent_client.dart';
import 'dart:typed_data';

import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart' as server;
import 'package:client_back/server/src/protocol/comm_balance_view.dart';
import 'package:client_front/services/lookup.dart';
import 'package:collection/collection.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart';

class HoldingBalances {
  static const String moontreeUrl =
      'http://24.199.68.139:8080'; //'https://api.moontree.com';
  final server.Client client;

  HoldingBalances() : client = server.Client('$moontreeUrl/');

  Future<List<server.BalanceView>> holdingBalancesBy({
    required Chaindata chain,
    required List<String> roots,
    required List<ByteData> h160s,
  }) async =>
      await client.balances.get(
        chain: chain.name,
        xpubkeys: roots,
        h160s: h160s,
      );
}

Future<List<server.BalanceView>> discoverHoldingBalances({
  Wallet? wallet,
  Chain? chain,
  Net? net,
}) async {
  chain ??= Current.chain;
  net ??= Current.net;
  List<String>? roots;
  if (wallet is LeaderWallet) {
    roots = await wallet.roots;
    //} else if (wallet is SingleWallet) {
    //  roots = wallet.roots; ?? await Current.wallet.roots;
  }
  roots ??= await Current.wallet.roots;
  final List<server.BalanceView> history =

      /// MOCK SERVER
      //await Future.delayed(Duration(seconds: 1), spoofBalanceView);

      /// SERVER
      await HoldingBalances().holdingBalancesBy(
          chain: ChainNet(chain, net).chaindata,
          roots: roots,
          h160s: roots.isEmpty
              ? Current.wallet.addresses.map((e) => e.h160).toList()
              : []);

  for (final txView in history) {
    txView.chain = chain.name + '_' + net.name + 'net';
  }

  return sortedHoldings(history, chain.symbol);
}

List<BalanceView> sortedHoldings(List<BalanceView> records, String coin) {
  // coin
  final head = records.where((e) => e.symbol == coin).toList();

  // alphabetical by display name (tail of symbol)
  final tail = records
      .where((e) => e.symbol != coin)
      .sorted((a, b) => b.symbol.compareTo(a.symbol))
      .toList();
  return head + tail;
}

List<server.BalanceView> spoofBalanceView() {
  return <server.BalanceView>[
    server.BalanceView(symbol: 'RVN', chain: null, sats: 10 * satsPerCoin),
    server.BalanceView(symbol: 'MOONTREE', chain: null, sats: 10 * satsPerCoin),
    server.BalanceView(symbol: 'ABC', chain: null, sats: 10 * satsPerCoin),
    server.BalanceView(symbol: 'DEF', chain: null, sats: 10 * satsPerCoin),
    server.BalanceView(symbol: 'XYZ', chain: null, sats: 10 * satsPerCoin),
    server.BalanceView(symbol: 'Scam', chain: null, sats: 10 * satsPerCoin),
  ];
}
