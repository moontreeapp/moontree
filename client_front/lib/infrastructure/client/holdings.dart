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
import 'package:client_front/infrastructure/client/mock_flag.dart';
import 'package:client_front/infrastructure/client/server_call.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:collection/collection.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart';

class HoldingBalancesCall extends ServerCall {
  HoldingBalancesCall() : super();

  Future<List<server.BalanceView>> holdingBalancesBy({
    //server.BalanceView
    required Chaindata chain,
    required List<String> roots,
    required List<ByteData> h160s,
  }) async =>
      await client.balances.get(
        chainName: chain.name,
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
  final List<server.BalanceView> history = mockFlag

      /// MOCK SERVER
      ? await Future.delayed(Duration(seconds: 1), spoofBalanceView)

      /// SERVER
      : await HoldingBalancesCall().holdingBalancesBy(
          chain: ChainNet(chain, net).chaindata,
          roots: roots,
          h160s: roots.isEmpty
              ? Current.wallet.addresses.map((e) => e.h160).toList()
              : []);

  if (history.length == 1 && history.first.error != null) {
    // handle
    return [];
  }

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
    server.BalanceView(symbol: 'EVR', chain: null, sats: 10 * satsPerCoin),
    server.BalanceView(symbol: 'SATORI', chain: null, sats: 10 * satsPerCoin),
    server.BalanceView(symbol: 'XYZ', chain: null, sats: 10 * satsPerCoin),
    server.BalanceView(symbol: 'Scam', chain: null, sats: 10 * satsPerCoin),
    server.BalanceView(symbol: '1RVN', chain: null, sats: 10 * satsPerCoin),
    server.BalanceView(symbol: '1MOON', chain: null, sats: 10 * satsPerCoin),
    server.BalanceView(symbol: '1ABC', chain: null, sats: 10 * satsPerCoin),
    server.BalanceView(symbol: '1DEF', chain: null, sats: 10 * satsPerCoin),
    server.BalanceView(symbol: '1XYZ', chain: null, sats: 10 * satsPerCoin),
    server.BalanceView(symbol: '1Scam', chain: null, sats: 10 * satsPerCoin),
  ];
}
